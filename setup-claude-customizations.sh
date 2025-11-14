#!/bin/bash

# Claude Code Customizations Setup Script
# Replicates all customizations applied on 2025-11-14

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
CLAUDE_HOME="${HOME}/.claude"
PROJECTS_DIR="${HOME}/projects"
CONFIG_DIR="${HOME}/.config"

# Check if running in appropriate environment
check_environment() {
    log_info "Checking environment..."

    if [ -z "$HOME" ]; then
        log_error "HOME environment variable not set"
        exit 1
    fi

    if [ ! -d "$CLAUDE_HOME" ]; then
        log_warning "Claude home directory not found. Creating it..."
        mkdir -p "$CLAUDE_HOME"
    fi

    log_success "Environment check passed"
}

# Setup context management optimizations
setup_context_optimization() {
    log_info "Setting up context management optimizations..."

    # Create backup of existing settings if it exists
    if [ -f "$CLAUDE_HOME/settings.json" ]; then
        cp "$CLAUDE_HOME/settings.json" "$CLAUDE_HOME/settings.json.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backed up existing settings.json"
    fi

    # Check if we need to update settings.json
    if [ -f "$CLAUDE_HOME/settings.json.template" ]; then
        cp "$CLAUDE_HOME/settings.json.template" "$CLAUDE_HOME/settings.json"
        log_success "Applied optimized settings.json"
    else
        log_warning "settings.json.template not found. Applying optimizations manually..."

        # Create settings.json with optimizations
        cat > "$CLAUDE_HOME/settings.json" << EOF
{
  "alwaysThinkingEnabled": true,
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "\${ANTHROPIC_AUTH_TOKEN}",
    "ANTHROPIC_BASE_URL": "\${ANTHROPIC_BASE_URL:-https://api.anthropic.com}",
    "API_TIMEOUT_MS": "3000000",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": 1,
    "CLAUDE_AUTO_COMPACT_BUFFER_RATIO": "0.05",
    "CLAUDE_CONTEXT_AUTOCOMPACT_TARGET": "5%"
  },
  "hooks": {},
  "includeCoAuthoredBy": false,
  "permissions": {
    "allow": [],
    "deny": []
  }
}
EOF
        log_success "Created optimized settings.json"
    fi
}

# Setup markdown-based customization symlinks
setup_symlinks() {
    log_info "Setting up markdown-based customization symlinks..."

    # Create projects directory
    mkdir -p "$PROJECTS_DIR"

    # Define symlinks to create
    declare -A symlinks=(
        ["claude-commands"]="$CLAUDE_HOME/commands"
        ["claude-skills"]="$CLAUDE_HOME/skills"
        ["claude-hooks"]="$CLAUDE_HOME/hooks"
        ["claude-agents"]="$CLAUDE_HOME/agents"
        ["claude-todos"]="$CLAUDE_HOME/todos"
        ["claude-projects"]="$CLAUDE_HOME/projects"
        ["claude-sessions"]="$CLAUDE_HOME/session-env"
        ["claude-system-prompts"]="$CLAUDE_HOME/system-prompts"
        ["mcp-config"]="$CONFIG_DIR/mcp"
    )

    # Create symlinks
    for link_name in "${!symlinks[@]}"; do
        target_path="${symlinks[$link_name]}"
        link_path="$PROJECTS_DIR/$link_name"

        # Create target directory if it doesn't exist
        if [ ! -d "$target_path" ]; then
            mkdir -p "$target_path"
            log_info "Created target directory: $target_path"
        fi

        # Remove existing link if it exists
        if [ -L "$link_path" ]; then
            rm "$link_path"
        elif [ -e "$link_path" ]; then
            log_warning "Path $link_path exists but is not a symlink. Skipping..."
            continue
        fi

        # Create symlink
        ln -sf "$target_path" "$link_path"
        log_success "Created symlink: $link_path -> $target_path"
    done
}

# Setup system prompts directory and examples
setup_system_prompts() {
    log_info "Setting up system prompts management..."

    # Create system prompts directory structure
    mkdir -p "$CLAUDE_HOME/system-prompts"/{base,append,context,domains,core,scripts}

    # Create basic README for system prompts
    cat > "$CLAUDE_HOME/system-prompts/README.md" << 'EOF'
# Claude Code System Prompts

This directory contains system prompts for customizing Claude Code's behavior.

## Categories

- **base/**: Standalone replacement system prompts
- **append/**: Prompts to append to existing system prompt
- **context/**: Context-specific prompts
- **domains/**: Domain-specific prompts
- **core/**: Reference prompts and documentation
- **scripts/**: Management and utility scripts

## Usage

```bash
# List available prompts
find . -name "*.md" ! -name "_*" | sort

# Use a base prompt
claude --system-prompt "$(cat base/core-enhancement.md)"

# Append to existing prompt
claude --append-system-prompt "$(cat append/security-focused.md)"
```

This is a basic setup. For full system prompt management capabilities, see the comprehensive system in the Docker baseline.
EOF

    log_success "System prompts directory created with basic structure"
}

# Create README for projects directory
create_readme() {
    log_info "Creating README for projects directory..."

    cat > "$PROJECTS_DIR/README.md" << 'EOF'
# Claude Code Customizations Hub

This directory contains symlinks to your global Claude Code customization folders.

## Symlink Structure

### Core Customizations (Add .md files here)
- **claude-skills/** → ~/.claude/skills/ - Custom functionality extensions
- **claude-commands/** → ~/.claude/commands/ - Custom slash commands
- **claude-hooks/** → ~/.claude/hooks/ - Event-driven automation scripts
- **claude-agents/** → ~/.claude/agents/ - Custom agent configurations

### Data & Sessions
- **claude-projects/** → ~/.claude/projects/ - Project tracking and metadata
- **claude-sessions/** → ~/.claude/session-env/ - Per-session configurations
- **claude-todos/** → ~/.claude/todos/ - Task tracking

### External Integrations
- **mcp-config/** → ~/.config/mcp/ - Model Context Protocol server configurations

## Usage Examples

### Add a Custom Skill
```bash
echo "# My Custom Skill
This skill provides..." > ~/projects/claude-skills/my-skill.md
```

### Add a Custom Command
```bash
echo "# My Command
## Description
Does something useful...

## Usage
/my-command [args]" > ~/projects/claude-commands/my-command.md
```

### Configure MCP Server
```bash
# Edit MCP configuration
vim ~/projects/mcp-config/master-config.json
```
EOF

    log_success "Created README.md in projects directory"
}

# Validate setup
validate_setup() {
    log_info "Validating setup..."

    local errors=0

    # Check if settings.json exists and has our optimizations
    if [ ! -f "$CLAUDE_HOME/settings.json" ]; then
        log_error "settings.json not found"
        errors=$((errors + 1))
    else
        if grep -q "CLAUDE_AUTO_COMPACT_BUFFER_RATIO" "$CLAUDE_HOME/settings.json"; then
            log_success "Context optimizations found in settings.json"
        else
            log_warning "Context optimizations not found in settings.json"
        fi
    fi

    # Check if symlinks exist and work
    local symlink_count=0
    for link_path in "$PROJECTS_DIR"/claude-* "$PROJECTS_DIR"/mcp-config; do
        if [ -L "$link_path" ]; then
            symlink_count=$((symlink_count + 1))
        fi
    done

    if [ $symlink_count -eq 9 ]; then
        log_success "All 9 symlinks created successfully"
    else
        log_warning "Only $symlink_count of 9 symlinks found"
    fi

    # Check if README exists
    if [ -f "$PROJECTS_DIR/README.md" ]; then
        log_success "README.md created in projects directory"
    else
        log_warning "README.md not found in projects directory"
    fi

    if [ $errors -eq 0 ]; then
        log_success "Setup validation completed successfully"
    else
        log_error "Setup validation completed with $errors errors"
        return 1
    fi
}

# Main execution
main() {
    log_info "Starting Claude Code customizations setup..."

    check_environment
    setup_context_optimization
    setup_symlinks
    setup_system_prompts
    create_readme
    validate_setup

    log_success "Claude Code customizations setup completed!"
    echo
    log_info "Next steps:"
    echo "1. Set your ANTHROPIC_AUTH_TOKEN environment variable"
    echo "2. Add custom skills to: ~/projects/claude-skills/"
    echo "3. Add custom commands to: ~/projects/claude-commands/"
    echo "4. Configure MCP servers in: ~/projects/mcp-config/"
    echo "5. Start Claude Code and check context usage with: /context"
}

# Run main function
main "$@"