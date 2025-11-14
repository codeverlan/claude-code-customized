#!/bin/bash

# Slash Command Handler for System Prompt Management
# Bridges Claude Code slash commands and natural language to system prompt management

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_PROMPTS_DIR="$(dirname "$SCRIPT_DIR")"
INTERACTIVE_MANAGER="$SCRIPT_DIR/interactive-prompt-manager.sh"
MANAGE_SCRIPT="$SCRIPT_DIR/manage-system-prompts.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

# Parse natural language for system prompt operations
parse_natural_language() {
    local input="$1"

    # Convert to lowercase for matching
    local lower_input=$(echo "$input" | tr '[:upper:]' '[:lower:]')

    # Pattern matching for different intents
    case "$lower_input" in
        *"list"*"prompt"*|*"show"*"prompt"*|*"available"*"prompt"*)
            handle_list_prompts
            ;;
        *"current"*"prompt"*|*"what"*"prompt"*|*"show"*"current"*)
            handle_view_current_prompt
            ;;
        *"extract"*"prompt"*|*"save"*"prompt"*)
            handle_extract_prompt
            ;;
        *"use"*"development"*"prompt"*|*"switch"*"development"*|*"dev"*"mode"*)
            handle_use_preset "dev"
            ;;
        *"use"*"security"*"prompt"*|*"switch"*"security"*|*"security"*"mode"*)
            handle_use_preset "security"
            ;;
        *"use"*"analysis"*"prompt"*|*"switch"*"analysis"*|*"analysis"*"mode"*)
            handle_use_preset "analysis"
            ;;
        *"use"*"docker"*"prompt"*|*"switch"*"docker"*|*"docker"*"mode"*)
            handle_use_preset "docker"
            ;;
        *"reset"*"prompt"*|*"default"*"prompt"*)
            handle_reset_prompt
            ;;
        *"create"*"prompt"*|*"new"*"prompt"*)
            handle_create_prompt
            ;;
        *"search"*"prompt"*|*"search for"*"prompt"*|*"search"*)
            local search_term=$(echo "$input" | sed -n 's/.*search[^a-zA-Z]*\([a-zA-Z ]*\).*prompt/\1/p' | sed 's/^ *//;s/ *$//')
            if [[ -z "$search_term" ]]; then
                search_term=$(echo "$input" | sed -n 's/.*search[^a-zA-Z]*\([a-zA-Z ]*\).*/\1/p' | sed 's/^ *//;s/ *$//')
            fi
            if [[ -n "$search_term" ]]; then
                handle_search_prompts "$search_term"
            else
                print_error "Please specify what to search for"
            fi
            ;;
        *"compare"*"prompt"*)
            handle_compare_prompts
            ;;
        *"help"*"prompt"*)
            show_prompt_help
            ;;
        *)
            print_info "I'm not sure how to handle that request. Try:"
            echo "  • 'Show available prompts'"
            echo "  • 'Use development prompt'"
            echo "  • 'Extract current prompt'"
            echo "  • 'Search for security prompts'"
            echo "  • Or use /system-prompt help"
            ;;
    esac
}

# Handle /system-prompt commands
handle_system_prompt_command() {
    local action="$1"
    shift

    case "$action" in
        "list"|"ls")
            shift
            if [[ "$1" == "--category" ]]; then
                "$MANAGE_SCRIPT" list --category "$2"
            elif [[ "$1" == "--search" ]]; then
                "$MANAGE_SCRIPT" list --search "$2"
            elif [[ "$1" == "--recent" ]]; then
                "$MANAGE_SCRIPT" list --recent
            else
                "$INTERACTIVE_MANAGER" list "$@"
            fi
            ;;
        "view"|"show")
            if [[ "$1" == "current" ]]; then
                handle_view_current_prompt
            else
                "$MANAGE_SCRIPT" view "$@"
            fi
            ;;
        "use"|"switch")
            if [[ "$1" == "--interactive" ]]; then
                "$INTERACTIVE_MANAGER" interactive
            else
                "$MANAGE_SCRIPT" use "$@"
            fi
            ;;
        "extract"|"save")
            if [[ "$1" == "--compare" ]]; then
                "$SCRIPT_DIR/extract-current-prompt.sh" --compare
            elif [[ "$1" == "--save" ]]; then
                "$SCRIPT_DIR/extract-current-prompt.sh"
                print_success "Current prompt extracted and saved"
            else
                "$SCRIPT_DIR/extract-current-prompt.sh" --display
            fi
            ;;
        "create"|"new")
            if [[ "$1" == "--interactive" ]]; then
                "$MANAGE_SCRIPT" create --interactive
            else
                "$MANAGE_SCRIPT" create "$@"
            fi
            ;;
        "search")
            if [[ -z "$1" ]]; then
                print_error "Please provide a search term"
                return 1
            fi
            "$INTERACTIVE_MANAGER" search "$1"
            ;;
        "help"|"--help"|"-h"|"")
            show_system_prompt_help
            ;;
        *)
            # Try to use as prompt name
            if [[ -f "$SYSTEM_PROMPTS_DIR/$action.md" ]]; then
                "$MANAGE_SCRIPT" use "$action" "$@"
            else
                print_error "Unknown action or prompt: $action"
                echo "Use '/system-prompt help' for available actions"
            fi
            ;;
    esac
}

# Handle /prompts commands
handle_prompts_command() {
    local preset_name="$1"

    case "$preset_name" in
        "dev"|"development")
            handle_use_preset "dev"
            ;;
        "security"|"secure")
            handle_use_preset "security"
            ;;
        "analysis"|"analyze")
            handle_use_preset "analysis"
            ;;
        "docker"|"container")
            handle_use_preset "docker"
            ;;
        "research"|"study")
            handle_use_preset "research"
            ;;
        "default"|"reset")
            handle_reset_prompt
            ;;
        ""|"help"|"--help"|"-h")
            show_prompts_help
            ;;
        *)
            # Check for custom presets
            if check_custom_preset "$preset_name"; then
                use_custom_preset "$preset_name"
            else
                print_error "Unknown preset: $preset_name"
                echo "Available presets: dev, security, analysis, docker, research, default"
                echo "Use '/prompts help' for more information"
            fi
            ;;
    esac
}

# Handle /prompt commands
handle_prompt_command() {
    local action="$1"

    case "$action" in
        "view"|"current"|"show")
            handle_view_current_prompt
            ;;
        "list"|"available"|"ls")
            "$INTERACTIVE_MANAGER" list
            ;;
        "reset"|"default")
            handle_reset_prompt
            ;;
        "use"|"switch")
            shift
            if [[ -z "$1" ]]; then
                print_error "Please specify a prompt to use"
                return 1
            fi
            "$MANAGE_SCRIPT" use "$1"
            ;;
        "extract"|"save")
            handle_extract_prompt
            ;;
        "help"|"--help"|"-h"|"")
            show_prompt_help
            ;;
        *)
            # Try to use as preset name
            case "$action" in
                "dev"|"development")
                    handle_use_preset "dev"
                    ;;
                "security"|"secure")
                    handle_use_preset "security"
                    ;;
                "analysis"|"analyze")
                    handle_use_preset "analysis"
                    ;;
                *)
                    print_error "Unknown action: $action"
                    echo "Use '/prompt help' for available actions"
                    ;;
            esac
            ;;
    esac
}

# Helper functions
handle_list_prompts() {
    "$INTERACTIVE_MANAGER" list
}

handle_view_current_prompt() {
    "$SCRIPT_DIR/view-current-prompt.sh" --latest --short
}

handle_extract_prompt() {
    "$SCRIPT_DIR/extract-current-prompt.sh" --display
}

handle_use_preset() {
    local preset="$1"
    local cmd

    case "$preset" in
        "dev"|"development")
            cmd="claude --system-prompt \"\$(cat '$SYSTEM_PROMPTS_DIR/base/development-focus.md')\""
            ;;
        "security"|"secure")
            cmd="claude --system-prompt \"\$(cat '$SYSTEM_PROMPTS_DIR/base/core-enhancement.md')\" --append-system-prompt \"\$(cat '$SYSTEM_PROMPTS_DIR/append/security-focused.md')\""
            ;;
        "analysis"|"analyze")
            cmd="claude --system-prompt \"\$(cat '$SYSTEM_PROMPTS_DIR/base/core-enhancement.md')\" --append-system-prompt \"\$(cat '$SYSTEM_PROMPTS_DIR/append/analysis-mode.md')\""
            ;;
        "docker"|"container")
            cmd="claude --system-prompt \"\$(cat '$SYSTEM_PROMPTS_DIR/base/development-focus.md')\" --append-system-prompt \"\$(cat '$SYSTEM_PROMPTS_DIR/context/docker-development.md')\""
            ;;
        "research"|"study")
            cmd="claude --system-prompt \"\$(cat '$SYSTEM_PROMPTS_DIR/base/core-enhancement.md')\""
            ;;
        *)
            print_error "Unknown preset: $preset"
            return 1
            ;;
    esac

    if [[ -n "$cmd" ]]; then
        print_info "Command to use preset '$preset':"
        echo "$cmd"
        print_info "Run this command to start Claude Code with the preset"
    fi
}

handle_reset_prompt() {
    print_success "Reset to default Claude Code prompt"
    echo "Command: claude"
}

handle_create_prompt() {
    print_info "Creating a new system prompt..."
    "$MANAGE_SCRIPT" create --interactive
}

handle_search_prompts() {
    local search_term="$1"
    "$INTERACTIVE_MANAGER" search "$search_term"
}

handle_compare_prompts() {
    print_info "Comparing prompts..."
    "$MANAGE_SCRIPT" compare core/current-system-prompt-*.md base/core-enhancement.md 2>/dev/null || \
    print_warning "No saved prompts found for comparison. Extract current prompt first."
}

check_custom_preset() {
    local preset_name="$1"
    # Check for custom preset in user configuration
    [[ -f "$HOME/.claude/prompts.json" ]] && \
    grep -q "\"$preset_name\"" "$HOME/.claude/prompts.json" 2>/dev/null
}

use_custom_preset() {
    local preset_name="$1"
    print_info "Using custom preset: $preset_name"
    # Implementation for custom presets would go here
    print_warning "Custom preset support not yet implemented"
}

# Help functions
show_system_prompt_help() {
    echo "System Prompt Management - Help"
    echo "==============================="
    echo
    echo "Slash Commands:"
    echo "  /system-prompt list [--category CAT] [--search TERM] [--recent]"
    echo "  /system-prompt view <prompt-name|current>"
    echo "  /system-prompt use <prompt-name> [--append <append-prompt>]"
    echo "  /system-prompt use --interactive"
    echo "  /system-prompt extract [--save] [--compare]"
    echo "  /system-prompt create <name> [--interactive]"
    echo "  /system-prompt search <term>"
    echo "  /system-prompt help"
    echo
    echo "Natural Language:"
    echo "  'Show available prompts'"
    echo "  'Use development prompt'"
    echo "  'Extract current prompt'"
    echo "  'Search for security prompts'"
    echo "  'What prompt am I using?'"
    echo "  'Reset to default prompt'"
}

show_prompts_help() {
    echo "Quick Prompt Presets - Help"
    echo "==========================="
    echo
    echo "Available Presets:"
    echo "  /prompts dev         - Development-focused"
    echo "  /prompts security    - Security-enhanced"
    echo "  /prompts analysis    - Analysis mode"
    echo "  /prompts docker      - Docker development"
    echo "  /prompts research    - Research mode"
    echo "  /prompts default     - Reset to default"
    echo "  /prompts             - Interactive selection"
    echo
    echo "Natural Language:"
    echo "  'Switch to development mode'"
    echo "  'Enable security focus'"
    echo "  'Use analysis mode'"
    echo "  'Reset to default'"
}

show_prompt_help() {
    echo "Quick Prompt Actions - Help"
    echo "==========================="
    echo
    echo "Available Actions:"
    echo "  /prompt view         - View current prompt"
    echo "  /prompt list         - List available prompts"
    echo "  /prompt reset        - Reset to default"
    echo "  /prompt use <name>   - Use specific prompt"
    echo "  /prompt extract      - Extract current prompt"
    echo "  /prompt help         - Show this help"
    echo
    echo "Natural Language:"
    echo "  'What prompt am I using?'"
    echo "  'Show me available prompts'"
    echo "  'Reset my prompt'"
    echo "  'Use security prompt'"
}

# Main entry point for slash command integration
main() {
    local command="$1"
    shift

    case "$command" in
        "/system-prompt")
            handle_system_prompt_command "$@"
            ;;
        "/prompts")
            handle_prompts_command "$@"
            ;;
        "/prompt")
            handle_prompt_command "$@"
            ;;
        "natural-language")
            parse_natural_language "$*"
            ;;
        "help"|"--help"|"-h"|"")
            echo "Claude Code System Prompt Management"
            echo "===================================="
            echo
            echo "Available slash commands:"
            echo "  /system-prompt  - Comprehensive system prompt management"
            echo "  /prompts        - Quick preset selection"
            echo "  /prompt         - Quick prompt actions"
            echo
            echo "Natural language examples:"
            echo "  'Show me available system prompts'"
            echo "  'Use the development-focused prompt'"
            echo "  'Extract my current system prompt'"
            echo
            echo "Use any command with 'help' for detailed information."
            ;;
        *)
            # Default to natural language parsing
            parse_natural_language "$command $*"
            ;;
    esac
}

# Run main function
main "$@"