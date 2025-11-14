# Claude Code Projects Directory

This directory contains symlinks to your global Claude Code customization folders.

## Symlink Structure

### Core Customizations
- **claude-skills/** → ~/.claude/skills/ - Custom functionality extensions
- **claude-commands/** → ~/.claude/commands/ - Custom slash commands
- **claude-hooks/** → ~/.claude/hooks/ - Event-driven automation scripts
- **claude-agents/** → ~/.claude/agents/ - Custom agent configurations

### Data & Management
- **claude-projects/** → ~/.claude/projects/ - Project tracking and metadata
- **claude-sessions/** → ~/.claude/session-env/ - Per-session configurations
- **claude-todos/** → ~/.claude/todos/ - Task tracking

### System Prompts (NEW)
- **claude-system-prompts/** → ~/.claude/system-prompts/ - System prompt management

### External Integrations
- **mcp-config/** → ~/.config/mcp/ - Model Context Protocol server configurations

## Usage Examples

### Add Custom Skills
```bash
echo "# My Custom Skill

This skill provides enhanced functionality..." > ~/projects/claude-skills/my-skill.md
```

### Add Custom Commands
```bash
echo "# My Command

## Description
Does something useful...

## Usage
/my-command [args]" > ~/projects/claude-commands/my-command.md
```

### Manage System Prompts
```bash
# List available prompts
find ~/projects/claude-system-prompts -name "*.md" | sort

# Use a system prompt
claude --system-prompt "$(cat ~/projects/claude-system-prompts/base/development-focus.md)"
```

### Configure MCP Servers
```bash
# Edit MCP configuration
vim ~/projects/mcp-config/master-config.json
```

## Notes

- These are symlinks - changes here affect the actual Claude configuration
- Use `ls -la` to see symlink targets if needed
- Be careful when deleting - you're deleting the symlink, not the source
- System prompt management requires Docker container restart for changes to take effect