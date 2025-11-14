#!/bin/bash

# Task Execution Wrapper with Automatic Sudo Escalation
# Integrates with TodoWrite system to stop task list on permission errors

set -euo pipefail

# Import the sudo escalation functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/sudo-escalation.sh"

# Task state management
TASK_CURRENT=""
TASK_STATUS="pending"
TASK_ESCALATION_TRIGGERED=false
ORIGINAL_TODO_STATE=""

# Color codes
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly NC='\033[0m'

# Enhanced logging
log_task() {
    local level="$1"
    local message="$2"
    echo -e "${MAGENTA}[TASK]${NC} $level: $message" >&2
}

# Function to detect if we're in a Claude Code session
is_claude_code_session() {
    [[ -n "${CLAUDE_CODE_SESSION:-}" ]] || [[ -n "${CLAUDECODE:-}" ]]
}

# Function to update todo state for escalation
update_todo_for_escalation() {
    local task_name="$1"
    local status="escalation-required"

    if is_claude_code_session; then
        # Create a todo entry indicating escalation is needed
        cat << EOF
🚨 PERMISSION ESCALATION REQUIRED 🚨

Task: $task_name
Status: $status
Action: STOP - Escalate privileges

⚠️  Current task list paused for privilege escalation
EOF

        # Try to update Claude's internal todo state if possible
        if command -v echo >/dev/null 2>&1; then
            echo "ESCALATION_REQUIRED: $task_name" >&2
        fi
    fi
}

# Function to simulate stopping task list
stop_task_list() {
    local failed_task="$1"
    local error_output="$2"

    log_task "STOP" "🛑 TASK LIST PAUSED - PERMISSION ERROR DETECTED"
    echo
    log_task "ERROR" "Failed task: $failed_task"
    log_task "ERROR" "Permission issue: $error_output"
    echo
    log_task "ESCALATION" "🔄 INITIATING AUTOMATIC PRIVILEGE ESCALATION"
    echo

    # Update todo state
    update_todo_for_escalation "$failed_task"
}

# Function to resume task list after successful escalation
resume_task_list() {
    local original_task="$1"

    log_task "RESUME" "✅ PRIVILEGE ESCALATION SUCCESSFUL"
    log_task "RESUME" "🔄 RESUMING TASK LIST EXECUTION"
    echo
    log_task "CONTINUE" "Retrying original task: $original_task"
    echo
}

# Function to execute task with automatic escalation handling
execute_task_with_escalation() {
    local task_name="$1"
    shift
    local task_command=("$@")

    TASK_CURRENT="$task_name"
    TASK_STATUS="running"
    TASK_ESCALATION_TRIGGERED=false

    log_task "START" "Executing task: $task_name"
    log_task "COMMAND" "${task_command[*]}"
    echo

    # Create temp files for output capture
    local temp_output=$(mktemp)
    local temp_error=$(mktemp)
    local exit_code=0

    # Execute the command
    if "${task_command[@]}" >"$temp_output" 2>"$temp_error"; then
        # Success
        cat "$temp_output"
        TASK_STATUS="completed"
        log_task "SUCCESS" "✅ Task completed: $task_name"
        rm -f "$temp_output" "$temp_error"
        return 0
    else
        # Failure
        exit_code=$?
        local error_output
        error_output=$(cat "$temp_error" 2>/dev/null || echo "No error output")
        local command_output
        command_output=$(cat "$temp_output" 2>/dev/null || echo "No stdout output")

        # Display error output
        if [[ -s "$temp_error" ]]; then
            cat "$temp_error" >&2
        fi
        if [[ -s "$temp_output" ]]; then
            cat "$temp_output" >&2
        fi

        TASK_STATUS="failed"

        # Check if this is a permission error and we haven't escalated yet
        if detect_permission_error "$error_output$command_output" && [[ "$TASK_ESCALATION_TRIGGERED" != "true" ]]; then

            # STOP THE TASK LIST
            stop_task_list "$task_name" "$error_output"

            # Check if passwordless sudo is available
            if check_passwordless_sudo; then
                TASK_ESCALATION_TRIGGERED=true
                TASK_STATUS="escalating"

                # ESCALATE AND RETRY
                resume_task_list "$task_name"

                log_task "RETRY" "🔄 Retrying with sudo: ${task_command[*]}"
                echo

                # Execute with sudo
                if sudo "${task_command[@]}" >"$temp_output" 2>"$temp_error"; then
                    cat "$temp_output"
                    TASK_STATUS="completed-escalated"
                    log_task "SUCCESS" "✅ Task completed with sudo escalation: $task_name"
                    log_task "NOTICE" "📝 Task list execution can continue"
                    echo
                    rm -f "$temp_output" "$temp_error"
                    return 0
                else
                    local sudo_exit_code=$?
                    local sudo_error
                    sudo_error=$(cat "$temp_error" 2>/dev/null || echo "Sudo failed")

                    # Even sudo failed
                    log_task "CRITICAL" "❌ Task failed even with sudo escalation"
                    log_task "CRITICAL" "Sudo error: $sudo_error"
                    log_task "CRITICAL" "Manual intervention required"
                    echo
                    rm -f "$temp_output" "$temp_error"
                    return $sudo_exit_code
                fi
            else
                # Passwordless sudo not available
                log_task "CRITICAL" "❌ Cannot escalate privileges automatically"
                log_task "CRITICAL" "Passwordless sudo not available"
                log_task "HELP" "To enable automatic escalation:"
                echo "  1. Run: sudo visudo"
                echo "  2. Add line: \$USER ALL=(ALL) NOPASSWD: ALL"
                echo "  3. Retry the task"
                echo
                rm -f "$temp_output" "$temp_error"
                return $exit_code
            fi
        else
            # Not a permission error or already escalated
            log_task "FAILED" "❌ Task failed: $task_name (exit code: $exit_code)"
            rm -f "$temp_output" "$temp_error"
            return $exit_code
        fi
    fi
}

# Function to execute multiple tasks in sequence
execute_task_sequence() {
    local -n task_array=$1
    local failed_tasks=()
    local total_tasks=${#task_array[@]}
    local completed_tasks=0

    log_task "SEQUENCE" "Starting task sequence: $total_tasks tasks"
    echo

    for task_entry in "${task_array[@]}"; do
        # Parse task entry: "task_name:command arg1 arg2..."
        local task_name="${task_entry%%:*}"
        local task_command="${task_entry#*:}"

        if [[ -z "$task_name" ]] || [[ -z "$task_command" ]]; then
            log_task "ERROR" "Invalid task format: $task_entry"
            log_task "FORMAT" "Expected: 'task_name:command arg1 arg2...'"
            continue
        fi

        # Convert command string to array
        read -ra cmd_array <<< "$task_command"

        # Execute the task
        if execute_task_with_escalation "$task_name" "${cmd_array[@]}"; then
            ((completed_tasks++))
        else
            failed_tasks+=("$task_name")

            # Ask whether to continue on failure
            if [[ "${CONTINUE_ON_FAILURE:-false}" != "true" ]]; then
                log_task "PAUSE" "Task failed. Continue with remaining tasks? (y/N)"
                read -r response
                if [[ ! "$response" =~ ^[Yy]$ ]]; then
                    log_task "ABORT" "Task sequence aborted by user"
                    break
                fi
            fi
        fi

        echo
        log_task "PROGRESS" "Progress: $completed_tasks/$total_tasks tasks completed"
        echo
    done

    # Summary
    log_task "SUMMARY" "Task sequence completed"
    log_task "SUMMARY" "Total tasks: $total_tasks"
    log_task "SUMMARY" "Completed: $completed_tasks"
    log_task "SUMMARY" "Failed: ${#failed_tasks[@]}"

    if [[ ${#failed_tasks[@]} -gt 0 ]]; then
        log_task "FAILED" "Failed tasks: ${failed_tasks[*]}"
        return 1
    else
        log_task "SUCCESS" "✅ All tasks completed successfully"
        return 0
    fi
}

# Main execution function
main() {
    if [[ $# -eq 0 ]]; then
        cat << EOF
Task Execution Wrapper with Automatic Sudo Escalation

Usage:
    $0 <task-name> <command> [args...]     Execute single task with escalation
    $0 --sequence <task-list-file>         Execute multiple tasks from file
    $0 --check-sudo                        Check passwordless sudo availability

Examples:
    $0 "Install package globally" "pip install -g some-package"
    $0 "Create system directory" "mkdir -p /usr/local/custom"
    $0 "Start system service" "systemctl restart nginx"

Task List File Format (for --sequence):
    install-package:pip install -g global-tool
    create-dir:mkdir -p /usr/local/bin
    copy-file:sudo cp tool.sh /usr/local/bin/tool.sh
    set-permissions:chmod +x /usr/local/bin/tool.sh

Features:
    - Automatic permission error detection
    - Task list pause on permission failures
    - Automatic sudo escalation with passwordless sudo
    - Task state management and progress tracking
    - Integration with Claude Code todo system
    - Detailed logging and error reporting
EOF
        exit 1
    fi

    case "${1:-}" in
        --sequence)
            if [[ $# -lt 2 ]]; then
                echo "Usage: $0 --sequence <task-list-file>"
                exit 1
            fi

            local task_file="$2"
            if [[ ! -f "$task_file" ]]; then
                log_task "ERROR" "Task list file not found: $task_file"
                exit 1
            fi

            # Read tasks from file
            local tasks=()
            while IFS= read -r line || [[ -n "$line" ]]; do
                # Skip comments and empty lines
                [[ "$line" =~ ^[[:space:]]*# ]] && continue
                [[ -z "${line// }" ]] && continue

                tasks+=("$line")
            done < "$task_file"

            if [[ ${#tasks[@]} -eq 0 ]]; then
                log_task "ERROR" "No tasks found in file: $task_file"
                exit 1
            fi

            execute_task_sequence tasks
            exit $?
            ;;
        --check-sudo)
            check_passwordless_sudo
            exit $?
            ;;
        --help|-h)
            main
            exit 0
            ;;
        *)
            if [[ $# -lt 2 ]]; then
                echo "Usage: $0 <task-name> <command> [args...]"
                echo "Use --help for more information"
                exit 1
            fi

            local task_name="$1"
            shift
            execute_task_with_escalation "$task_name" "$@"
            exit $?
            ;;
    esac
}

# Execute main function with all arguments
main "$@"