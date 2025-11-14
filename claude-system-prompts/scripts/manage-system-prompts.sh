#!/bin/bash

# System Prompt Management Script
# Comprehensive management tool for Claude Code system prompts

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_debug() { echo -e "${MAGENTA}[DEBUG]${NC} $1"; }

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_PROMPTS_DIR="$(dirname "$SCRIPT_DIR")"
SETTINGS_FILE="${HOME}/.claude/settings.json"

# Help function
show_help() {
    cat << EOF
System Prompt Management Script

Usage: $0 <command> [options] [arguments]

Commands:
    list                List available system prompts
    view <prompt>       View a specific system prompt
    extract             Extract current active system prompt
    use <prompt>        Use a specific system prompt
    combine <base> <append>  Combine base and append prompts
    validate <prompt>   Validate a system prompt file
    enable <prompt>     Enable a system prompt for default use
    disable             Disable custom system prompts
    compare <p1> <p2>   Compare two system prompts
    search <term>       Search for prompts containing term
    create <name>       Create a new system prompt from template
    edit <prompt>       Edit a system prompt file
    export <prompt>     Export prompt to stdout
    stats               Show system prompt statistics

List Options:
    -c, --category CAT  Filter by category (base, append, context, domains, core)
    -t, --type TYPE     Filter by type (custom, template, extracted)
    -r, --recent        Show recently modified prompts only
    -d, --detailed      Show detailed information

View Options:
    -s, --short         Show only prompt content (no metadata)
    -c, --content       Extract content only (no formatting)

Extract Options:
    -o, --output FILE   Save to specific file
    -d, --display       Display to console after extraction
    -c, --compare       Compare with previous extraction

Use Options:
    -a, --append PROMPT Append additional prompt(s)
    -e, --env           Set as environment variable
    -t, --temporary     Use for current session only

Create Options:
    -c, --category CAT  Category for new prompt (default: append)
    -t, --type TYPE     Type for new prompt (default: custom)
    -d, --description   Description for new prompt

Examples:
    $0 list                           # List all prompts
    $0 list --category base           # List base prompts only
    $0 view base/core-enhancement     # View a specific prompt
    $0 extract                        # Extract current system prompt
    $0 use base/core-enhancement      # Use a base prompt
    $0 combine base/core-enhancement append/security-focused  # Combine prompts
    $0 create my-prompt -c append -d "My custom prompt"  # Create new prompt
    $0 enable base/development-focus  # Set as default
    $0 search "security"              # Search for security prompts

EOF
}

# Function to list prompts
list_prompts() {
    local category=""
    local type_filter=""
    local recent_only=false
    local detailed=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--category) category="$2"; shift 2 ;;
            -t|--type) type_filter="$2"; shift 2 ;;
            -r|--recent) recent_only=true; shift ;;
            -d|--detailed) detailed=true; shift ;;
            *) log_error "Unknown option: $1"; return 1 ;;
        esac
    done

    log_info "Listing system prompts..."
    "$SCRIPT_DIR/list-prompts.sh" ${category:+$category} ${type_filter:+--type $type_filter} ${recent_only:+--recent} ${detailed:+--detailed}
}

# Function to view a prompt
view_prompt() {
    local prompt_name="$1"
    local short=false
    local content_only=false

    while [[ $# -gt 1 ]]; do
        case $2 in
            -s|--short) short=true; shift ;;
            -c|--content) content_only=true; shift ;;
            *) log_error "Unknown option: $2"; return 1 ;;
        esac
    done

    if [[ -z "$prompt_name" ]]; then
        log_error "Please specify a prompt to view"
        return 1
    fi

    local prompt_path="$SYSTEM_PROMPTS_DIR/$prompt_name"
    if [[ ! -f "$prompt_path" ]]; then
        log_error "Prompt not found: $prompt_name"
        return 1
    fi

    if [[ "$content_only" == "true" ]]; then
        awk '/^```$/,/^```$/' "$prompt_path" | sed '1d;$d'
    elif [[ "$short" == "true" ]]; then
        "$SCRIPT_DIR/view-current-prompt.sh" --file "$prompt_path" --short
    else
        "$SCRIPT_DIR/view-current-prompt.sh" --file "$prompt_path"
    fi
}

# Function to extract current prompt
extract_current_prompt() {
    local output_file=""
    local display=false
    local compare=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -o|--output) output_file="$2"; shift 2 ;;
            -d|--display) display=true; shift ;;
            -c|--compare) compare=true; shift ;;
            *) log_error "Unknown option: $1"; return 1 ;;
        esac
    done

    local args=()
    [[ -n "$output_file" ]] && args+=("--output" "$output_file")
    [[ "$display" == "true" ]] && args+=("--display")
    [[ "$compare" == "true" ]] && args+=("--compare")

    "$SCRIPT_DIR/extract-current-prompt.sh" "${args[@]}"
}

# Function to use a prompt
use_prompt() {
    local base_prompt="$1"
    shift
    local append_prompts=()
    local set_env=false
    local temporary=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--append) append_prompts+=("$2"); shift 2 ;;
            -e|--env) set_env=true; shift ;;
            -t|--temporary) temporary=true; shift ;;
            *) log_error "Unknown option: $1"; return 1 ;;
        esac
    done

    if [[ -z "$base_prompt" ]]; then
        log_error "Please specify a base prompt to use"
        return 1
    fi

    local base_path="$SYSTEM_PROMPTS_DIR/$base_prompt"
    if [[ ! -f "$base_path" ]]; then
        log_error "Base prompt not found: $base_prompt"
        return 1
    fi

    # Validate append prompts
    for append in "${append_prompts[@]}"; do
        local append_path="$SYSTEM_PROMPTS_DIR/$append"
        if [[ ! -f "$append_path" ]]; then
            log_error "Append prompt not found: $append"
            return 1
        fi
    done

    # Build the command
    local cmd="claude --system-prompt \"\$(cat '$base_path')\""

    for append in "${append_prompts[@]}"; do
        cmd+=" --append-system-prompt \"\$(cat '$SYSTEM_PROMPTS_DIR/$append')\""
    done

    if [[ "$set_env" == "true" ]]; then
        local env_file="$HOME/.claude_system_prompt_env"
        echo "export CLAUDE_CUSTOM_SYSTEM_PROMPT_CMD=\"$cmd\"" > "$env_file"
        log_success "Environment set. Run 'source $env_file' to use."
    else
        log_info "Command to use the prompt:"
        echo "$cmd"

        if [[ "$temporary" == "false" ]]; then
            log_info "Use --env to set as environment variable"
            log_info "Use --temporary to use for current session only"
        fi
    fi
}

# Function to combine prompts
combine_prompts() {
    local base_prompt="$1"
    local append_prompt="$2"

    if [[ -z "$base_prompt" || -z "$append_prompt" ]]; then
        log_error "Please specify both base and append prompts"
        return 1
    fi

    use_prompt "$base_prompt" --append "$append_prompt"
}

# Function to validate a prompt
validate_prompt() {
    local prompt_name="$1"

    if [[ -z "$prompt_name" ]]; then
        log_error "Please specify a prompt to validate"
        return 1
    fi

    local prompt_path="$SYSTEM_PROMPTS_DIR/$prompt_name"
    if [[ ! -f "$prompt_path" ]]; then
        log_error "Prompt not found: $prompt_name"
        return 1
    fi

    log_info "Validating prompt: $prompt_name"

    # Check required sections
    local required_sections=("## Metadata" "## Description" "## System Prompt Content")
    local missing_sections=()

    for section in "${required_sections[@]}"; do
        if ! grep -q "^$section" "$prompt_path"; then
            missing_sections+=("$section")
        fi
    done

    # Check for system prompt content
    if ! grep -q "^\`\`\`" "$prompt_path"; then
        missing_sections+=("System prompt content block")
    fi

    # Validate metadata
    local metadata_fields=("Name" "Category" "Version")
    local missing_fields=()

    for field in "${metadata_fields[@]}"; do
        if ! grep -q "\*\*$field\*\*:" "$prompt_path"; then
            missing_fields+=("$field")
        fi
    done

    # Check file size
    local size=$(wc -c < "$prompt_path")
    local max_size=50000  # 50KB

    # Report results
    if [[ ${#missing_sections[@]} -eq 0 && ${#missing_fields[@]} -eq 0 && $size -le $max_size ]]; then
        log_success "Prompt validation passed"
        echo "✓ All required sections present"
        echo "✓ All required metadata fields present"
        echo "✓ File size: $size bytes (under ${max_size} bytes limit)"
    else
        log_warning "Prompt validation has issues:"

        [[ ${#missing_sections[@]} -gt 0 ]] && echo "✗ Missing sections: ${missing_sections[*]}"
        [[ ${#missing_fields[@]} -gt 0 ]] && echo "✗ Missing metadata fields: ${missing_fields[*]}"
        [[ $size -gt $max_size ]] && echo "✗ File too large: $size bytes (limit: ${max_size} bytes)"

        return 1
    fi
}

# Function to enable/disable prompts
manage_prompt_config() {
    local action="$1"
    local prompt_name="$2"

    case $action in
        enable)
            if [[ -z "$prompt_name" ]]; then
                log_error "Please specify a prompt to enable"
                return 1
            fi

            # Update settings file or environment
            log_info "Enabling prompt: $prompt_name"
            log_warning "Feature not yet implemented - use environment variables manually"
            ;;
        disable)
            log_info "Disabling custom system prompts"
            log_warning "Feature not yet implemented - unset environment variables manually"
            ;;
        *)
            log_error "Unknown action: $action"
            return 1
            ;;
    esac
}

# Function to compare prompts
compare_prompts() {
    local prompt1="$1"
    local prompt2="$2"

    if [[ -z "$prompt1" || -z "$prompt2" ]]; then
        log_error "Please specify two prompts to compare"
        return 1
    fi

    local path1="$SYSTEM_PROMPTS_DIR/$prompt1"
    local path2="$SYSTEM_PROMPTS_DIR/$prompt2"

    if [[ ! -f "$path1" ]]; then
        log_error "Prompt not found: $prompt1"
        return 1
    fi

    if [[ ! -f "$path2" ]]; then
        log_error "Prompt not found: $prompt2"
        return 1
    fi

    log_info "Comparing prompts:"
    echo "Prompt 1: $prompt1 ($(wc -c < "$path1") bytes)"
    echo "Prompt 2: $prompt2 ($(wc -c < "$path2") bytes)"
    echo

    # Extract content and compare
    local content1=$(awk '/^```$/,/^```$/' "$path1" | sed '1d;$d')
    local content2=$(awk '/^```$/,/^```$/' "$path2" | sed '1d;$d')

    if [[ "$content1" == "$content2" ]]; then
        log_success "Prompts have identical content"
    else
        log_info "Content differences:"
        diff -u <(echo "$content1") <(echo "$content2") || true
    fi
}

# Function to search prompts
search_prompts() {
    local search_term="$1"

    if [[ -z "$search_term" ]]; then
        log_error "Please specify a search term"
        return 1
    fi

    log_info "Searching for prompts containing: $search_term"
    "$SCRIPT_DIR/list-prompts.sh" --search "$search_term"
}

# Function to create new prompt
create_prompt() {
    local name="$1"
    local category="append"
    local type="custom"
    local description=""

    while [[ $# -gt 1 ]]; do
        case $2 in
            -c|--category) category="$2"; shift 2 ;;
            -t|--type) type="$2"; shift 2 ;;
            -d|--description) description="$2"; shift 2 ;;
            *) log_error "Unknown option: $2"; return 1 ;;
        esac
    done

    if [[ -z "$name" ]]; then
        log_error "Please specify a name for the new prompt"
        return 1
    fi

    local filename="$name.md"
    local target_dir="$SYSTEM_PROMPTS_DIR/$category"
    local target_path="$target_dir/$filename"

    if [[ ! -d "$target_dir" ]]; then
        log_error "Invalid category: $category"
        return 1
    fi

    if [[ -f "$target_path" ]]; then
        log_error "Prompt already exists: $category/$filename"
        return 1
    fi

    # Create from template
    cp "$SYSTEM_PROMPTS_DIR/_TEMPLATE.md" "$target_path"

    # Update template with provided information
    sed -i '' "s/\[Prompt Name\]/$name/g" "$target_path"
    sed -i '' "s/\[category\]/$category/g" "$target_path"
    sed -i '' "s/\[Your Name\]/User/g" "$target_path"
    sed -i '' "s/\[Date\]/$(date +%Y-%m-%d)/g" "$target_path"

    if [[ -n "$description" ]]; then
        sed -i '' "s/\[Brief description of what this system prompt does and when to use it\]/$description/g" "$target_path"
    fi

    log_success "Created new prompt: $category/$filename"
    log_info "Edit with: $0 edit $category/$filename"
}

# Function to edit prompt
edit_prompt() {
    local prompt_name="$1"

    if [[ -z "$prompt_name" ]]; then
        log_error "Please specify a prompt to edit"
        return 1
    fi

    local prompt_path="$SYSTEM_PROMPTS_DIR/$prompt_name"
    if [[ ! -f "$prompt_path" ]]; then
        log_error "Prompt not found: $prompt_name"
        return 1
    fi

    # Use default editor or fallback
    local editor="${EDITOR:-vim}"
    if command -v "$editor" &> /dev/null; then
        "$editor" "$prompt_path"
    elif command -v code &> /dev/null; then
        code "$prompt_path"
    else
        log_error "No editor found. Please set EDITOR environment variable"
        return 1
    fi
}

# Function to export prompt
export_prompt() {
    local prompt_name="$1"

    if [[ -z "$prompt_name" ]]; then
        log_error "Please specify a prompt to export"
        return 1
    fi

    view_prompt "$prompt_name" --content
}

# Function to show statistics
show_stats() {
    log_info "System Prompt Statistics"
    echo "=========================="

    local total_prompts=0
    local categories=("base" "append" "context" "domains" "core")

    for category in "${categories[@]}"; do
        local count=$(find "$SYSTEM_PROMPTS_DIR/$category" -name "*.md" -type f ! -name "_*" 2>/dev/null | wc -l)
        printf "%-12s: %d prompts\n" "$(echo "$category" | sed 's/.*/\u&/')" "$count"
        total_prompts=$((total_prompts + count))
    done

    echo "------------"
    printf "%-12s: %d prompts\n" "Total" "$total_prompts"

    # Directory size
    local dir_size=$(du -sh "$SYSTEM_PROMPTS_DIR" | cut -f1)
    printf "%-12s: %s\n" "Size" "$dir_size"

    # Most recent prompt
    local most_recent=$(find "$SYSTEM_PROMPTS_DIR" -name "*.md" -type f ! -name "_*" -exec stat -f "%m %N" {} + 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2-)
    if [[ -n "$most_recent" ]]; then
        printf "%-12s: %s\n" "Latest" "$(basename "$most_recent")"
    fi
}

# Main command dispatch
main() {
    if [[ $# -eq 0 ]]; then
        show_help
        exit 1
    fi

    local command="$1"
    shift

    case $command in
        list|ls)
            list_prompts "$@"
            ;;
        view|v)
            view_prompt "$@"
            ;;
        extract|ext)
            extract_current_prompt "$@"
            ;;
        use|u)
            use_prompt "$@"
            ;;
        combine|comb)
            combine_prompts "$@"
            ;;
        validate|val)
            validate_prompt "$@"
            ;;
        enable|en)
            manage_prompt_config "enable" "$@"
            ;;
        disable|dis)
            manage_prompt_config "disable" "$@"
            ;;
        compare|comp)
            compare_prompts "$@"
            ;;
        search)
            search_prompts "$@"
            ;;
        create|new)
            create_prompt "$@"
            ;;
        edit|e)
            edit_prompt "$@"
            ;;
        export|exp)
            export_prompt "$@"
            ;;
        stats|stat)
            show_stats
            ;;
        -h|--help|help)
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"