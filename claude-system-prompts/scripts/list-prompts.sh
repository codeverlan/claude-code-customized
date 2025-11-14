#!/bin/bash

# List System Prompts Script
# Lists all available system prompts with descriptions and metadata

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_PROMPTS_DIR="$(dirname "$SCRIPT_DIR")"

# Help function
show_help() {
    cat << EOF
List System Prompts Script

Usage: $0 [OPTIONS] [CATEGORY]

Description:
    Lists all available system prompts with descriptions and metadata.

Arguments:
    CATEGORY            Filter by category (base, append, context, domains, core)

Options:
    -h, --help          Show this help message
    -d, --detailed      Show detailed information including metadata
    -c, --count         Show only count of prompts per category
    -f, --format FORMAT Output format: table, list, json (default: table)
    -s, --search TERM   Search prompts by name or description
    -t, --type TYPE     Filter by type (custom, template, extracted)
    -r, --recent        Show recently modified prompts only

Examples:
    $0                              # List all prompts in table format
    $0 base                         # List only base prompts
    $0 --detailed append             # Detailed view of append prompts
    $0 --search "security"           # Search for security-related prompts
    $0 --format json                # Output in JSON format
    $0 --recent                     # Show recently modified prompts

EOF
}

# Parse command line arguments
DETAILED=false
COUNT_ONLY=false
FORMAT="table"
SEARCH_TERM=""
TYPE_FILTER=""
RECENT_ONLY=false
CATEGORY_FILTER=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -d|--detailed)
            DETAILED=true
            shift
            ;;
        -c|--count)
            COUNT_ONLY=true
            shift
            ;;
        -f|--format)
            FORMAT="$2"
            shift 2
            ;;
        -s|--search)
            SEARCH_TERM="$2"
            shift 2
            ;;
        -t|--type)
            TYPE_FILTER="$2"
            shift 2
            ;;
        -r|--recent)
            RECENT_ONLY=true
            shift
            ;;
        base|append|context|domains|core)
            CATEGORY_FILTER="$1"
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Function to extract metadata from prompt file
extract_metadata() {
    local file="$1"
    local metadata=""

    # Extract key metadata fields
    local name=$(grep -A 5 "^## Metadata" "$file" | grep "^- \*\*Name\*\*:" | sed 's/.*: //' || echo "")
    local description=$(grep -A 5 "^## Description" "$file" | head -1 | sed 's/^## Description //' || echo "")
    local version=$(grep -A 5 "^## Metadata" "$file" | grep "^- \*\*Version\*\*:" | sed 's/.*: //' || echo "")
    local author=$(grep -A 5 "^## Metadata" "$file" | grep "^- \*\*Author\*\*:" | sed 's/.*: //' || echo "")
    local priority=$(grep -A 5 "^## Metadata" "$file" | grep "^- \*\*Priority\*\*:" | sed 's/.*: //' || echo "0")
    local category=$(echo "$file" | grep -o "/[a-z]*/" | sed 's/\///g' || echo "unknown")

    # Determine type
    local type="custom"
    if [[ "$file" == *"_TEMPLATE.md" ]]; then
        type="template"
    elif [[ "$file" == *"current-system-prompt"* ]]; then
        type="extracted"
    elif [[ "$file" == *"README"* ]]; then
        type="documentation"
    fi

    # Get file stats
    local size=$(du -h "$file" | cut -f1)
    local modified=$(stat -f "%Sm" -t "%Y-%m-%d" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null | cut -d' ' -f1)
    local lines=$(wc -l < "$file")

    # Build metadata JSON
    metadata=$(cat << EOF
{
    "name": "$name",
    "description": "$description",
    "version": "$version",
    "author": "$author",
    "priority": "$priority",
    "category": "$category",
    "type": "$type",
    "file": "$(basename "$file")",
    "path": "$file",
    "size": "$size",
    "modified": "$modified",
    "lines": "$lines"
}
EOF
)

    echo "$metadata"
}

# Function to search in file content
search_in_file() {
    local file="$1"
    local term="$2"

    # Case-insensitive search in filename and content
    if [[ "$(basename "$file")" == *"$term"** ]] || \
       grep -qi "$term" "$file" 2>/dev/null; then
        return 0
    fi
    return 1
}

# Function to format and display prompts
format_output() {
    local prompts="$1"
    local format="$2"

    case "$format" in
        "json")
            echo "[$prompts]" | sed 's/}\n{/},\n{/g'
            ;;
        "list")
            echo "$prompts" | while read -r prompt; do
                if [[ -n "$prompt" ]]; then
                    local file=$(echo "$prompt" | cut -d'|' -f1)
                    local name=$(echo "$prompt" | cut -d'|' -f2)
                    local desc=$(echo "$prompt" | cut -d'|' -f3)
                    echo "📄 $file"
                    [[ -n "$name" ]] && echo "   Name: $name"
                    [[ -n "$desc" ]] && echo "   Description: $desc"
                    echo
                fi
            done
            ;;
        "table"|*)
            echo "$prompts" | column -t -s '|'
            ;;
    esac
}

# Collect all prompt files
prompt_files=()
categories=("base" "append" "context" "domains" "core")

for category in "${categories[@]}"; do
    if [[ -n "$CATEGORY_FILTER" && "$category" != "$CATEGORY_FILTER" ]]; then
        continue
    fi

    cat_dir="$SYSTEM_PROMPTS_DIR/$category"
    if [[ -d "$cat_dir" ]]; then
        while IFS= read -r -d '' file; do
            # Skip documentation files
            if [[ "$file" == *"README"* ]] || [[ "$file" == *"_TEMPLATE"* ]]; then
                continue
            fi

            # Apply search filter
            if [[ -n "$SEARCH_TERM" ]]; then
                if ! search_in_file "$file" "$SEARCH_TERM"; then
                    continue
                fi
            fi

            # Apply recent filter (files modified in last 7 days)
            if [[ "$RECENT_ONLY" == "true" ]]; then
                local file_age=$(( ($(date +%s) - $(stat -f "%m" "$file" 2>/dev/null || stat -c "%Y" "$file")) / 86400 ))
                if [[ $file_age -gt 7 ]]; then
                    continue
                fi
            fi

            prompt_files+=("$file")
        done < <(find "$cat_dir" -name "*.md" -type f -print0 2>/dev/null)
    fi
done

# Count only mode
if [[ "$COUNT_ONLY" == "true" ]]; then
    echo "System Prompts Summary"
    echo "===================="

    for category in "${categories[@]}"; do
        local count=$(find "$SYSTEM_PROMPTS_DIR/$category" -name "*.md" -type f ! -name "README*" ! -name "_TEMPLATE*" 2>/dev/null | wc -l)
        printf "%-12s: %d prompts\n" "$(echo "$category" | sed 's/.*/\u&/')" "$count"
    done

    local total=$((${#prompt_files[@]}))
    echo "------------"
    printf "%-12s: %d prompts\n" "Total" "$total"
    exit 0
fi

# Process prompts and collect information
prompts_data=()

for file in "${prompt_files[@]}"; do
    local metadata=$(extract_metadata "$file")

    # Apply type filter
    if [[ -n "$TYPE_FILTER" ]]; then
        local file_type=$(echo "$metadata" | grep -o '"type": "[^"]*"' | cut -d'"' -f4)
        if [[ "$file_type" != "$TYPE_FILTER" ]]; then
            continue
        fi
    fi

    # Extract fields for display
    local name=$(echo "$metadata" | grep -o '"name": "[^"]*"' | cut -d'"' -f4)
    local description=$(echo "$metadata" | grep -o '"description": "[^"]*"' | cut -d'"' -f4)
    local version=$(echo "$metadata" | grep -o '"version": "[^"]*"' | cut -d'"' -f4)
    local category=$(echo "$metadata" | grep -o '"category": "[^"]*"' | cut -d'"' -f4)
    local type=$(echo "$metadata" | grep -o '"type": "[^"]*"' | cut -d'"' -f4)
    local priority=$(echo "$metadata" | grep -o '"priority": "[^"]*"' | cut -d'"' -f4)
    local file=$(basename "$file")
    local modified=$(echo "$metadata" | grep -o '"modified": "[^"]*"' | cut -d'"' -f4)

    if [[ "$DETAILED" == "true" ]]; then
        echo "📄 $file"
        echo "   Name: ${name:-"N/A"}"
        echo "   Description: ${description:-"N/A"}"
        echo "   Version: ${version:-"N/A"}"
        echo "   Category: $category"
        echo "   Type: $type"
        echo "   Priority: ${priority:-"0"}"
        echo "   Modified: ${modified:-"N/A"}"
        echo "   Path: $file"
        echo
    else
        # Create table row
        local row="$file|${name:-"N/A"}|${category:-"unknown"}|${type:-"custom"}|${modified:-"N/A"}"
        prompts_data+=("$row")
    fi
done

# Display results
if [[ "$DETAILED" == "false" ]]; then
    if [[ "$FORMAT" == "table" ]]; then
        echo "System Prompts"
        echo "=============="
        echo "FILE|NAME|CATEGORY|TYPE|MODIFIED"
        echo "----|----|--------|----|--------"
    fi

    # Sort prompts by priority and name
    IFS=$'\n' sorted_prompts=($(sort -t'|' -k4,4r -k1,1 <<<"${prompts_data[*]}"))
    unset IFS

    # Format output
    formatted_output=$(printf "%s\n" "${sorted_prompts[@]}")
    format_output "$formatted_output" "$FORMAT"
fi

# Show summary
echo
log_info "Found ${#prompt_files[@]} system prompts"
if [[ -n "$SEARCH_TERM" ]]; then
    log_info "Search term: $SEARCH_TERM"
fi
if [[ -n "$CATEGORY_FILTER" ]]; then
    log_info "Category filter: $CATEGORY_FILTER"
fi
if [[ -n "$TYPE_FILTER" ]]; then
    log_info "Type filter: $TYPE_FILTER"
fi