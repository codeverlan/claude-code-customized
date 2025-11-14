#!/bin/bash

# Strategic Permission Elevation Script
# Automatically detects permission failures and retries with sudo

set -euo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Global state
SCRIPT_NAME=""
ORIGINAL_ARGS=()
PERMISSION_DETECTED=false
ESCALATION_ATTEMPTED=false
MAX_RETRIES=2
CURRENT_RETRY=0

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
}

# Permission error detection patterns
readonly PERMISSION_PATTERNS=(
    "Permission denied"
    "Operation not permitted"
    "Access denied"
    "Insufficient permissions"
    "must be root"
    "requires root privileges"
    "sudo required"
    "unable to create"
    "cannot create directory"
    "failed to create"
    "Read-only file system"
    "PermissionError"
    "OSError:.*Permission denied"
    "Error: EACCES"
    "Error: EPERM"
)

# Function to detect permission-related errors
detect_permission_error() {
    local error_output="$1"

    for pattern in "${PERMISSION_PATTERNS[@]}"; do
        if echo "$error_output" | grep -qiE "$pattern"; then
            return 0
        fi
    done

    return 1
}

# Function to check if current command needs privileges
check_privilege_requirement() {
    local command="$1"

    # Commands that typically need elevated privileges
    local privileged_commands=(
        "mount|umount"
        "systemctl|service"
        "iptables|ufw|firewall-cmd"
        "useradd|usermod|userdel"
        "groupadd|groupmod|groupdel"
        "chmod.*[0-9][0-9][0-9]"
        "chown.*root"
        "apt-get|apt|yum|dnf|pacman"
        "pip.*install.*--global"
        "npm.*install.*-g"
        "docker.*ps|docker.*inspect"
        "crontab|/etc/cron"
        "sysctl"
        "modprobe|insmod|rmmod"
        "fdisk|parted|mkfs"
        "mount.*-o"
        "dd.*if=.*of=/dev"
        "ln.*-s.*usr|lib|etc"
        "tar.*-x.*usr|lib|etc"
        "cp.*usr|lib|etc"
        "mv.*usr|lib|etc"
        "mkdir.*usr|lib|etc"
        "touch.*usr|lib|etc"
        "echo.*>/etc|/usr|/lib|/var"
        "cat.*>/etc|/usr|/lib|/var"
        "printf.*>/etc|/usr|/lib|/var"
    )

    for cmd_pattern in "${privileged_commands[@]}"; do
        if echo "$command" | grep -qE "$cmd_pattern"; then
            return 0
        fi
    done

    return 1
}

# Function to check if we have passwordless sudo
check_passwordless_sudo() {
    if ! command -v sudo >/dev/null 2>&1; then
        log_warning "sudo command not found"
        return 1
    fi

    # Test if we can run sudo without password
    if sudo -n true 2>/dev/null; then
        log_success "Passwordless sudo is available"
        return 0
    else
        log_warning "Passwordless sudo is not available"
        return 1
    fi
}

# Function to execute command with optional sudo escalation
execute_with_fallback() {
    local command=("$@")
    local temp_output=$(mktemp)
    local exit_code=0

    log_info "Executing: ${command[*]}"

    # Execute command and capture output
    if "${command[@]}" >"$temp_output" 2>&1; then
        # Success - display output and return
        cat "$temp_output"
        rm -f "$temp_output"
        return 0
    else
        exit_code=$?
        local error_output
        error_output=$(cat "$temp_output")

        log_error "Command failed with exit code: $exit_code"
        echo "$error_output" >&2

        # Check if this is a permission error and we haven't escalated yet
        if [[ $exit_code -ne 0 ]] && detect_permission_error "$error_output" && [[ "$ESCALATION_ATTEMPTED" != "true" ]]; then

            log_warning "Permission error detected. Attempting privilege escalation..."

            # Check if passwordless sudo is available
            if check_passwordless_sudo; then
                ESCALATION_ATTEMPTED=true
                log_info "Retrying command with sudo..."

                # Retry with sudo
                if sudo "${command[@]}" >"$temp_output" 2>&1; then
                    log_success "Command succeeded with sudo escalation"
                    cat "$temp_output"
                    rm -f "$temp_output"
                    return 0
                else
                    local sudo_exit_code=$?
                    local sudo_error_output
                    sudo_error_output=$(cat "$temp_output")

                    log_error "Command failed even with sudo (exit code: $sudo_exit_code)"
                    echo "$sudo_error_output" >&2
                    rm -f "$temp_output"
                    return $sudo_exit_code
                fi
            else
                log_error "Passwordless sudo not available. Cannot escalate privileges."
                log_error "Please configure passwordless sudo or run with appropriate privileges."
                rm -f "$temp_output"
                return $exit_code
            fi
        else
            # Not a permission error or already attempted escalation
            rm -f "$temp_output"
            return $exit_code
        fi
    fi
}

# Function to execute command with privilege pre-check
execute_smart() {
    local command=("$@")

    log_info "Smart execution analyzing: ${command[*]}"

    # Pre-check: If command likely needs privileges, try sudo first
    if check_privilege_requirement "${command[*]}" && check_passwordless_sudo; then
        log_info "Command typically requires privileges. Using sudo preemptively."
        if sudo "${command[@]}"; then
            log_success "Command succeeded with preemptive sudo"
            return 0
        else
            local sudo_exit_code=$?
            log_warning "Preemptive sudo failed (exit code: $sudo_exit_code). Trying without sudo..."
            # Fallback to non-sudo execution
            if "${command[@]}"; then
                log_success "Command succeeded without sudo"
                return 0
            else
                log_error "Command failed with and without sudo"
                return $sudo_exit_code
            fi
        fi
    else
        # Normal execution with fallback mechanism
        execute_with_fallback "${command[@]}"
        return $?
    fi
}

# Function to stop current task list and escalate
stop_and_escalate() {
    local failed_command="$1"
    local error_output="$2"

    log_warning "🚨 PERMISSION ERROR DETECTED - STOPPING TASK LIST"
    log_warning "Failed command: $failed_command"
    log_warning "Error: $error_output"
    echo
    log_info "🔄 INITIATING PRIVILEGE ESCALATION PROTOCOL"
    log_info "Checking passwordless sudo availability..."

    if check_passwordless_sudo; then
        log_success "✅ Passwordless sudo confirmed"
        log_info "🔄 RETRYING TASK WITH ELEVATED PRIVILEGES"
        echo
        return 0
    else
        log_error "❌ Passwordless sudo not available"
        log_error "Cannot automatically escalate privileges."
        log_error "Manual intervention required:"
        echo "  1. Configure passwordless sudo: sudo visudo"
        echo "  2. Add line: $USER ALL=(ALL) NOPASSWD: ALL"
        echo "  3. Retry the command"
        return 1
    fi
}

# Main execution wrapper
main() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: $0 <command> [args...]"
        echo "  Executes command with automatic privilege escalation when needed"
        echo
        echo "Examples:"
        echo "  $0 mkdir -p /usr/local/custom"
        echo "  $0 systemctl status nginx"
        echo "  $0 pip install -g some-package"
        exit 1
    fi

    # Store original command for logging
    SCRIPT_NAME="$1"
    shift
    ORIGINAL_ARGS=("$@")

    # Check if we're running as root already
    if [[ $EUID -eq 0 ]]; then
        log_info "Already running as root. Executing directly."
        exec "$SCRIPT_NAME" "${ORIGINAL_ARGS[@]}"
    fi

    # Execute with smart privilege handling
    execute_smart "$SCRIPT_NAME" "${ORIGINAL_ARGS[@]}"
}

# Script mode handlers
case "${1:-}" in
    --stop-and-escalate)
        if [[ $# -lt 3 ]]; then
            echo "Usage: $0 --stop-and-escalate <failed-command> <error-output>"
            exit 1
        fi
        stop_and_escalate "$2" "$3"
        exit $?
        ;;
    --check-sudo)
        check_passwordless_sudo
        exit $?
        ;;
    --detect-permission)
        if [[ $# -lt 2 ]]; then
            echo "Usage: $0 --detect-permission <error-output>"
            exit 1
        fi
        if detect_permission_error "$2"; then
            echo "Permission error detected"
            exit 0
        else
            echo "No permission error detected"
            exit 1
        fi
        ;;
    --help|-h)
        cat << EOF
Strategic Permission Elevation Script

This script automatically detects permission failures and retries commands
with passwordless sudo when available.

Usage:
    $0 <command> [args...]          Execute command with smart privilege handling
    $0 --check-sudo                 Check if passwordless sudo is available
    $0 --detect-permission <error>  Test if error message indicates permission issue
    $0 --stop-and-escalate <cmd> <error>  Manual escalation trigger

Features:
    - Automatic permission error detection
    - Intelligent privilege escalation
    - Preemptive sudo for known privileged commands
    - Fallback execution strategies
    - Detailed logging and error reporting

Examples:
    $0 mkdir -p /usr/local/bin
    $0 systemctl restart nginx
    $0 pip install -g global-package
    $0 mount /dev/sdb1 /mnt/data

Configuration:
    To enable passwordless sudo, add to sudoers:
    $USER ALL=(ALL) NOPASSWD: ALL
EOF
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac