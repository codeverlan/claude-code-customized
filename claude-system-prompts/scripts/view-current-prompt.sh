#!/bin/bash

# View Current System Prompt Script
# Quick script to display Claude Code's current active system prompt

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_PROMPTS_DIR="$(dirname "$SCRIPT_DIR")"
CORE_DIR="$SYSTEM_PROMPTS_DIR/core"

# Help function
show_help() {
    cat << EOF
View Current System Prompt Script

Usage: $0 [OPTIONS]

Description:
    Quickly displays Claude Code's current active system prompt.

Options:
    -h, --help          Show this help message
    -f, --file FILE     View specific extracted prompt file
    -l, --latest        View latest extracted prompt
    -s, --short         Show only the prompt content (no metadata)
    -c, --count         Show character/word count
    -e, --extract       Force new extraction before viewing

Examples:
    $0                              # Extract and view current prompt
    $0 --latest                     # View latest extracted prompt
    $0 --short                      # View only prompt content
    $0 --count                      # Show prompt statistics
    $0 --file current-prompt.md     # View specific file

EOF
}

# Parse command line arguments
VIEW_FILE=""
SHORT=false
COUNT=false
FORCE_EXTRACT=false
LATEST=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--file)
            VIEW_FILE="$2"
            shift 2
            ;;
        -l|--latest)
            LATEST=true
            shift
            ;;
        -s|--short)
            SHORT=true
            shift
            ;;
        -c|--count)
            COUNT=true
            shift
            ;;
        -e|--extract)
            FORCE_EXTRACT=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Function to extract prompt content from file
extract_prompt_content() {
    local file="$1"

    if [[ "$SHORT" == "true" ]]; then
        # Extract only the system prompt content
        awk '/^```$/,/^```$/' "$file" | sed '1d;$d'
    else
        # Show entire file
        cat "$file"
    fi
}

# Function to show prompt statistics
show_prompt_stats() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        log_error "File not found: $file"
        return 1
    fi

    # Extract prompt content for stats
    local content=$(awk '/^```$/,/^```$/' "$file" | sed '1d;$d')
    local chars=$(echo "$content" | wc -c)
    local words=$(echo "$content" | wc -w)
    local lines=$(echo "$content" | wc -l)
    local tokens=$(echo "scale=0; $words * 1.3" | bc 2>/dev/null || echo "Unknown")

    echo "Prompt Statistics for: $(basename "$file")"
    echo "=================================="
    echo "Characters: $chars"
    echo "Words: $words"
    echo "Lines: $lines"
    echo "Estimated Tokens: $tokens"
    echo "File Size: $(du -h "$file" | cut -f1)"
    echo "Modified: $(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null || echo "Unknown")"
}

# Determine which file to view
if [[ -n "$VIEW_FILE" ]]; then
    # Specific file requested
    if [[ ! -f "$VIEW_FILE" ]]; then
        # Try relative to core directory
        VIEW_FILE="$CORE_DIR/$VIEW_FILE"
        if [[ ! -f "$VIEW_FILE" ]]; then
            log_error "File not found: $VIEW_FILE"
            exit 1
        fi
    fi
elif [[ "$LATEST" == "true" ]]; then
    # Find latest extracted prompt
    VIEW_FILE=$(find "$CORE_DIR" -name "current-system-prompt-*.md" -type f | sort -r | head -1)
    if [[ -z "$VIEW_FILE" ]]; then
        log_error "No extracted prompts found. Run extraction first."
        exit 1
    fi
elif [[ "$FORCE_EXTRACT" == "true" ]]; then
    # Force new extraction
    log_info "Extracting current system prompt..."
    "$SCRIPT_DIR/extract-current-prompt.sh" --quiet > /dev/null
    VIEW_FILE=$(find "$CORE_DIR" -name "current-system-prompt-*.md" | sort -r | head -1)
else
    # Check for latest extraction, extract if none found
    VIEW_FILE=$(find "$CORE_DIR" -name "current-system-prompt-*.md" -type f | sort -r | head -1)
    if [[ -z "$VIEW_FILE" ]]; then
        log_info "No extracted prompt found. Extracting current system prompt..."
        "$SCRIPT_DIR/extract-current-prompt.sh" --quiet > /dev/null
        VIEW_FILE=$(find "$CORE_DIR" -name "current-system-prompt-*.md" | sort -r | head -1)
    fi
fi

if [[ ! -f "$VIEW_FILE" ]]; then
    log_error "Unable to find or create system prompt file"
    exit 1
fi

# Show statistics if requested
if [[ "$COUNT" == "true" ]]; then
    show_prompt_stats "$VIEW_FILE"
    exit 0
fi

# Display the prompt
if [[ "$SHORT" == "false" ]]; then
    log_info "Viewing: $(basename "$VIEW_FILE")"
    echo "=================================="
fi

extract_prompt_content "$VIEW_FILE"

if [[ "$SHORT" == "false" ]]; then
    echo "=================================="
    log_info "Full file: $VIEW_FILE"
    echo "Use --count for statistics or --short for content only"
fi