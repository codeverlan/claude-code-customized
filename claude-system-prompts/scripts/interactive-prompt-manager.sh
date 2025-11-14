#!/bin/bash

# Interactive System Prompt Manager
# Provides interactive interfaces for system prompt management
# Designed to be called by Claude Code slash commands

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_PROMPTS_DIR="$(dirname "$SCRIPT_DIR")"

# Logging functions for interactive use
print_header() {
    echo -e "${BLUE}${BOLD}$1${NC}"
    echo "$(printf -- '=%.0s' {1..50})"
}

print_section() {
    echo -e "${CYAN}${BOLD}$1${NC}"
    echo "$(printf -- '-%.0s' {1..30})"
}

print_option() {
    local number="$1"
    local name="$2"
    local description="$3"
    printf "  ${GREEN}%2d${NC}) ${BOLD}%s${NC}\n" "$number" "$name"
    if [[ -n "$description" ]]; then
        printf "      %s\n" "$description"
    fi
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Get prompt metadata
get_prompt_metadata() {
    local prompt_file="$1"
    local field="$2"

    if [[ ! -f "$prompt_file" ]]; then
        echo ""
        return
    fi

    case $field in
        "name")
            grep -A 5 "^## Metadata" "$prompt_file" | grep "^- \*\*Name\*\*:" | sed 's/.*: //' || echo ""
            ;;
        "description")
            grep -A 5 "^## Description" "$prompt_file" | head -1 | sed 's/^## Description //' || echo ""
            ;;
        "category")
            echo "$prompt_file" | grep -o "/[a-z]*/" | sed 's/\///g' || echo "unknown"
            ;;
        "version")
            grep -A 5 "^## Metadata" "$prompt_file" | grep "^- \*\*Version\*\*:" | sed 's/.*: //' || echo ""
            ;;
        "priority")
            grep -A 5 "^## Metadata" "$prompt_file" | grep "^- \*\*Priority\*\*:" | sed 's/.*: //' || echo "0"
            ;;
    esac
}

# List prompts in interactive format
list_prompts_interactive() {
    local category_filter="$1"

    print_header "Available System Prompts"

    local categories=("base" "append" "context" "domains" "core")
    local count=1

    for category in "${categories[@]}"; do
        if [[ -n "$category_filter" && "$category" != "$category_filter" ]]; then
            continue
        fi

        local prompts=()
        while IFS= read -r -d '' prompt_file; do
            # Skip documentation files
            if [[ "$prompt_file" == *"README"* ]] || [[ "$prompt_file" == *"_TEMPLATE"* ]]; then
                continue
            fi
            prompts+=("$prompt_file")
        done < <(find "$SYSTEM_PROMPTS_DIR/$category" -name "*.md" -type f -print0 2>/dev/null)

        if [[ ${#prompts[@]} -gt 0 ]]; then
            print_section "$(echo "$category" | sed 's/.*/\u&/') Prompts"

            # Sort by priority
            IFS=$'\n' sorted_prompts=($(sort -t: -k2 -nr < <(
                for prompt_file in "${prompts[@]}"; do
                    priority=$(get_prompt_metadata "$prompt_file" "priority")
                    echo "$priority:$prompt_file"
                done
            )))
            unset IFS

            for prompt_entry in "${sorted_prompts[@]}"; do
                local prompt_file="${prompt_entry#*:}"
                local name=$(get_prompt_metadata "$prompt_file" "name")
                local description=$(get_prompt_metadata "$prompt_file" "description")

                [[ -z "$name" ]] && name="$(basename "$prompt_file" .md)"

                print_option "$count" "$name" "$description"
                echo "$prompt_file" >> /tmp/prompt_map_$$
                count=$((count + 1))
            done
            echo
        fi
    done

    echo "$count"
}

# Interactive prompt selection
select_prompt_interactive() {
    local prompt_type="$1"  # "base" or "append"

    print_header "Select $prompt_type Prompt"

    local max_count
    max_count=$(list_prompts_interactive "$prompt_type")

    while true; do
        echo -n "${CYAN}Enter prompt number (1-$((max_count - 1))) or 'q' to quit: ${NC}"
        read -r selection

        if [[ "$selection" == "q" || "$selection" == "Q" ]]; then
            echo "Selection cancelled."
            return 1
        elif [[ "$selection" =~ ^[0-9]+$ ]] && [[ "$selection" -ge 1 ]] && [[ "$selection" -lt "$max_count" ]]; then
            local selected_file
            selected_file=$(sed -n "${selection}p" /tmp/prompt_map_$$)

            if [[ -f "$selected_file" ]]; then
                local name=$(get_prompt_metadata "$selected_file" "name")
                print_success "Selected: $name"
                echo "$selected_file"
                return 0
            else
                print_error "Invalid selection. Please try again."
            fi
        else
            print_error "Invalid number. Please enter a number between 1 and $((max_count - 1))."
        fi
    done
}

# Preview prompt combination
preview_prompts() {
    local base_prompt="$1"
    shift
    local append_prompts=("$@")

    print_header "Prompt Preview"

    echo "${BOLD}Base Prompt:${NC}"
    local base_name=$(get_prompt_metadata "$base_prompt" "name")
    echo "  • $base_name"
    echo

    if [[ ${#append_prompts[@]} -gt 0 ]]; then
        echo "${BOLD}Append Prompts:${NC}"
        for append_prompt in "${append_prompts[@]}"; do
            local append_name=$(get_prompt_metadata "$append_prompt" "name")
            echo "  • $append_name"
        done
        echo
    fi

    echo "${BOLD}Combined Content Preview:${NC}"
    echo "$(printf '─%.0s' {1..40})"
    echo

    # Extract and display content
    awk '/^```$/,/^```$/' "$base_prompt" | sed '1d;$d'

    for append_prompt in "${append_prompts[@]}"; do
        echo
        echo "$(printf '·%.0s' {1..20})"
        echo
        awk '/^```$/,/^```$/' "$append_prompt" | sed '1d;$d'
    done

    echo
    echo "$(printf '─%.0s' {1..40})"
}

# Build claude command
build_claude_command() {
    local base_prompt="$1"
    shift
    local append_prompts=("$@")

    local cmd="claude --system-prompt \"\$(cat '$base_prompt')\""

    for append_prompt in "${append_prompts[@]}"; do
        cmd+=" --append-system-prompt \"\$(cat '$append_prompt')\""
    done

    echo "$cmd"
}

# Interactive prompt builder
build_prompt_interactive() {
    print_header "Interactive System Prompt Builder"

    # Step 1: Select base prompt
    print_info "Step 1: Choose a base prompt"
    local base_prompt
    base_prompt=$(select_prompt_interactive "base")

    if [[ -z "$base_prompt" ]]; then
        print_warning "No base prompt selected. Exiting."
        return 1
    fi

    # Step 2: Select append prompts
    local append_prompts=()
    while true; do
        echo
        print_info "Step 2: Add append prompts (optional)"
        print_option "a" "Add append prompt" ""
        print_option "d" "Done with append prompts" ""
        print_option "p" "Preview current selection" ""

        echo -n "${CYAN}Choose an option: ${NC}"
        read -r choice

        case $choice in
            "a"|"A")
                local append_prompt
                append_prompt=$(select_prompt_interactive "append")
                if [[ -n "$append_prompt" ]]; then
                    append_prompts+=("$append_prompt")
                    print_success "Added append prompt"
                fi
                ;;
            "d"|"D")
                break
                ;;
            "p"|"P")
                if [[ ${#append_prompts[@]} -eq 0 ]]; then
                    print_info "No append prompts selected yet."
                else
                    preview_prompts "$base_prompt" "${append_prompts[@]}"
                fi
                ;;
            *)
                print_error "Invalid option. Please try again."
                ;;
        esac
    done

    # Step 3: Preview and confirm
    echo
    print_info "Step 3: Preview and confirm"
    preview_prompts "$base_prompt" "${append_prompts[@]}"

    echo
    print_option "c" "Use this prompt combination" ""
    print_option "b" "Build again from scratch" ""
    print_option "q" "Cancel" ""

    while true; do
        echo -n "${CYAN}Choose an option: ${NC}"
        read -r final_choice

        case $final_choice in
            "c"|"C")
                local claude_cmd
                claude_cmd=$(build_claude_command "$base_prompt" "${append_prompts[@]}")

                print_success "Prompt combination ready!"
                echo
                echo "${BOLD}Command to use:${NC}"
                echo "$claude_cmd"
                echo
                print_info "You can now run this command to start Claude Code with your custom system prompt."
                return 0
                ;;
            "b"|"B")
                build_prompt_interactive
                return $?
                ;;
            "q"|"Q")
                print_info "Prompt building cancelled."
                return 1
                ;;
            *)
                print_error "Invalid option. Please try again."
                ;;
        esac
    done
}

# Quick preset selection
select_preset() {
    print_header "Quick Prompt Presets"

    local presets=(
        "dev:base/development-focus:Development-focused coding with best practices"
        "security:base/core-enhancement+append/security-focused:Security-first development approach"
        "analysis:base/core-enhancement+append/analysis-mode:Enhanced analytical and debugging capabilities"
        "docker:base/development-focus+context/docker-development:Docker and container development"
        "research:base/core-enhancement:Research and analysis focused"
        "default::Reset to Claude Code default"
    )

    print_option "1" "Development" "Focus on coding practices and testing"
    print_option "2" "Security" "Security-first development with compliance"
    print_option "3" "Analysis" "Enhanced debugging and analysis"
    print_option "4" "Docker" "Container and orchestration development"
    print_option "5" "Research" "Research and analysis mode"
    print_option "6" "Default" "Reset to default Claude Code prompt"

    echo
    echo -n "${CYAN}Select preset (1-6): ${NC}"
    read -r preset_choice

    case $preset_choice in
        1)
            echo "claude --system-prompt \"\$(cat '$SYSTEM_PROMPTS_DIR/base/development-focus.md')\""
            ;;
        2)
            echo "claude --system-prompt \"\$(cat '$SYSTEM_PROMPTS_DIR/base/core-enhancement.md')\" --append-system-prompt \"\$(cat '$SYSTEM_PROMPTS_DIR/append/security-focused.md')\""
            ;;
        3)
            echo "claude --system-prompt \"\$(cat '$SYSTEM_PROMPTS_DIR/base/core-enhancement.md')\" --append-system-prompt \"\$(cat '$SYSTEM_PROMPTS_DIR/append/analysis-mode.md')\""
            ;;
        4)
            echo "claude --system-prompt \"\$(cat '$SYSTEM_PROMPTS_DIR/base/development-focus.md')\" --append-system-prompt \"\$(cat '$SYSTEM_PROMPTS_DIR/context/docker-development.md')\""
            ;;
        5)
            echo "claude --system-prompt \"\$(cat '$SYSTEM_PROMPTS_DIR/base/core-enhancement.md')\""
            ;;
        6)
            echo "claude"
            ;;
        *)
            print_error "Invalid selection"
            return 1
            ;;
    esac
}

# Search prompts
search_prompts() {
    local search_term="$1"

    print_header "Search Results for: '$search_term'"

    local found_prompts=()
    while IFS= read -r -d '' prompt_file; do
        if [[ "$prompt_file" == *"README"* ]] || [[ "$prompt_file" == *"_TEMPLATE"* ]]; then
            continue
        fi

        # Search in filename and content
        if [[ "$(basename "$prompt_file")" == *"$search_term"* ]] || \
           grep -l -i "$search_term" "$prompt_file" >/dev/null 2>&1; then
            found_prompts+=("$prompt_file")
        fi
    done < <(find "$SYSTEM_PROMPTS_DIR" -name "*.md" -type f -print0 2>/dev/null)

    if [[ ${#found_prompts[@]} -eq 0 ]]; then
        print_warning "No prompts found matching: '$search_term'"
        return 1
    fi

    local count=1
    for prompt_file in "${found_prompts[@]}"; do
        local name=$(get_prompt_metadata "$prompt_file" "name")
        local description=$(get_prompt_metadata "$prompt_file" "description")
        local category=$(get_prompt_metadata "$prompt_file" "category")

        [[ -z "$name" ]] && name="$(basename "$prompt_file" .md)"

        print_option "$count" "$name" "$description"
        echo "      Category: $category"
        echo "      File: $(basename "$prompt_file")"
        echo
        count=$((count + 1))
    done

    print_success "Found ${#found_prompts[@]} matching prompts"
}

# Main function for slash command integration
main() {
    local action="$1"
    shift

    # Cleanup function
    cleanup() {
        rm -f /tmp/prompt_map_$$ 2>/dev/null || true
    }
    trap cleanup EXIT

    case $action in
        "interactive"|"build")
            build_prompt_interactive
            ;;
        "presets"|"preset")
            select_preset
            ;;
        "list")
            list_prompts_interactive "$@"
            ;;
        "search")
            if [[ -z "$1" ]]; then
                print_error "Please provide a search term"
                exit 1
            fi
            search_prompts "$1"
            ;;
        "help"|"--help"|"-h"|"")
            print_header "Interactive System Prompt Manager"
            echo
            echo "Usage: $0 <action> [options]"
            echo
            echo "Actions:"
            echo "  interactive     Build prompts interactively"
            echo "  presets         Quick preset selection"
            echo "  list [cat]      List prompts by category"
            echo "  search <term>   Search for prompts"
            echo "  help            Show this help"
            ;;
        *)
            print_error "Unknown action: $action"
            echo "Use '$0 help' for available actions."
            exit 1
            ;;
    esac
}

# Run main function
main "$@"