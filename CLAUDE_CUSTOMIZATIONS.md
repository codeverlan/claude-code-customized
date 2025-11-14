# Claude Code Docker Baseline Customizations

This document tracks all customizations made to Claude Code for replication in Docker baseline images.

## Overview

Customizations applied:
1. **Context Management Optimization** - Reduced auto-compact buffer from 22.5% to 5%
2. **Markdown-Based Folder Structure** - Created symlinks for easy customization management

---

## 1. Context Management Improvements

### Problem
- Auto-compact buffer was consuming 22.5% (45k tokens) of available context space
- Needed permanent solution to reduce memory usage

### Solution Applied
Updated `/Users/tyler-lcsw/.claude/settings.json` with environment variables:

```json
{
  "alwaysThinkingEnabled": true,
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "${ANTHROPIC_AUTH_TOKEN}",
    "ANTHROPIC_BASE_URL": "${ANTHROPIC_BASE_URL}",
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
```

### Key Environment Variables Added
- `CLAUDE_AUTO_COMPACT_BUFFER_RATIO`: "0.05" - Reduces buffer to 5%
- `CLAUDE_CONTEXT_AUTOCOMPACT_TARGET`: "5%" - Target compaction size

### Expected Outcome
- Auto-compact buffer reduced from 22.5% to ~5%
- Frees up approximately 17.5% more context space
- Permanent solution that persists across sessions

---

## 2. Markdown-Based Folder Customization Structure

### Problem
- Claude customization folders scattered across different locations
- Difficult to manage and work with markdown-based customizations
- Need centralized hub for skills, commands, and other extensions

### Solution Applied
Created symlinks in `~/projects/` to centralize all customization folders:

#### Symlink Structure Created
```bash
# Core Customizations (Markdown-based)
claude-skills/ -> ~/.claude/skills/
claude-commands/ -> ~/.claude/commands/
claude-hooks/ -> ~/.claude/hooks/
claude-agents/ -> ~/.claude/agents/

# Data & Management
claude-projects/ -> ~/.claude/projects/
claude-sessions/ -> ~/.claude/session-env/
claude-todos/ -> ~/.claude/todos/

# System Prompts (NEW)
claude-system-prompts/ -> ~/.claude/system-prompts/

# External Integrations
mcp-config/ -> ~/.config/mcp/
```

---

## 3. System Prompt Management System (NEW)

### Problem
- No easy way to manage and customize Claude Code's system prompts
- Difficulty understanding what the current system prompt contains
- No standardized approach to creating custom system prompts
- Hard to combine different prompt enhancements

### Solution Applied
Created comprehensive system prompt management with drop-in markdown files:

#### Directory Structure
```bash
claude-system-prompts/
├── _README.md           # Usage documentation
├── _TEMPLATE.md         # Standardized template
├── base/                # Standalone replacement prompts
├── append/              # Additions to existing prompts
├── context/             # Context-specific prompts
├── domains/             # Domain-specific prompts
├── core/                # Reference and extracted prompts
└── scripts/             # Management tools
```

#### Key Features
- **Drop-in Management**: Add `.md` files to easily create system prompts
- **Core Prompt Visibility**: Extract and view current active system prompts
- **CLI Integration**: Management commands for listing, viewing, and using prompts
- **Template System**: Standardized format for consistent prompt creation
- **Validation**: Built-in prompt validation and conflict detection

#### Example Prompts Created
- `base/core-enhancement.md` - Enhanced core instructions
- `base/development-focus.md` - Development-optimized behavior
- `append/security-focused.md` - Security and compliance additions
- `append/analysis-mode.md` - Enhanced analytical capabilities
- `context/docker-development.md` - Docker environment specific
- `core/claude-code-base-instructions.md` - Reference documentation

#### Management Scripts
- `extract-current-prompt.sh` - Extract active system prompt
- `view-current-prompt.sh` - View current or saved prompts
- `list-prompts.sh` - List available prompts with metadata
- `manage-system-prompts.sh` - Comprehensive management tool

#### Settings Integration
```json
{
  "systemPrompts": {
    "enabled": true,
    "directory": "${CLAUDE_SYSTEM_PROMPT_DIR}",
    "defaultBasePrompt": "${CLAUDE_DEFAULT_BASE_PROMPT}",
    "autoLoad": true,
    "contextAwareLoading": true
  }
}
```

#### Commands Used
```bash
mkdir -p ~/projects
cd ~/projects
ln -sf ~/.claude/commands claude-commands
ln -sf ~/.claude/skills claude-skills
ln -sf ~/.claude/hooks claude-hooks
ln -sf ~/.claude/agents claude-agents
ln -sf ~/.claude/todos claude-todos
ln -sf ~/.claude/projects claude-projects
ln -sf ~/.claude/session-env claude-sessions
ln -sf ~/.config/mcp mcp-config
```

### Benefits
- **Drop-in Customization**: Add .md files to easily create skills/commands
- **Centralized Management**: All folders accessible from ~/projects/
- **Git-Friendly**: Can version control the symlink structure
- **Quick Navigation**: Faster access to customization folders

---

## 3. File Structure Summary

### Files Modified
- `~/.claude/settings.json` - Added context optimization environment variables and system prompt configuration

### Files Created
- `~/projects/README.md` - Documentation for symlink structure
- `~/projects/docker-baseline/CLAUDE_CUSTOMIZATIONS.md` - This documentation

### Symlinks Created
- 9 symlinks in ~/projects/ pointing to various Claude configuration folders (including system prompts)

### System Prompt Files Created
- 10+ system prompt files in various categories (base, append, context, core)
- Management scripts for system prompt operations
- Templates and documentation for prompt creation

---

## 4. Slash Command & Natural Language Integration (NEW)

### Problem
- System prompt management required direct CLI usage
- No intuitive interface within Claude Code
- Complex commands difficult to remember
- No natural language support for common operations

### Solution Applied
Created comprehensive integration with Claude Code's command system:

#### Custom Slash Commands
- **`/system-prompt`** - Comprehensive system prompt management (2.6KB command file)
- **`/prompts`** - Quick preset selection (1.9KB command file)
- **`/prompt`** - Quick prompt actions (1.1KB command file)

#### Natural Language Triggers
- **"Show me available system prompts"** → Lists all prompts
- **"Use development-focused prompt"** → Switches to dev mode
- **"Switch to security mode"** → Enables security focus
- **"Extract my current prompt"** → Saves current system prompt
- **"Search for security prompts"** → Finds relevant prompts
- **"Reset to default prompt"** → Resets to default

#### Interactive Interfaces
- **Interactive prompt builder** with guided selection
- **Preset selection menu** with descriptions
- **Natural language processing** with pattern matching

#### Integration Scripts Created
- **`slash-command-handler.sh`** - Main command processor (14KB)
- **`interactive-prompt-manager.sh`** - Interactive interface (14KB)
- **Natural language parser** with 20+ intent patterns
- **Preset system** with 6 built-in combinations

#### Usage Examples
```bash
# Slash commands
/system-prompt list --category base
/system-prompt use base/development-focus
/system-prompt extract --save
/prompts dev
/prompts security
/prompt view

# Natural language
"Show available prompts"
"Use security-focused mode"
"Extract current prompt"
"Search Docker prompts"
```

---

## 5. Docker Implementation Notes

### Environment Variables for Docker
```dockerfile
ENV CLAUDE_AUTO_COMPACT_BUFFER_RATIO=0.05
ENV CLAUDE_CONTEXT_AUTOCOMPACT_TARGET=5%
ENV CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
ENV CLAUDE_SYSTEM_PROMPT_DIR=/home/claude/projects/claude-system-prompts
ENV CLAUDE_DEFAULT_BASE_PROMPT=base/core-enhancement.md
```

### Directory Structure in Docker
```dockerfile
# Create projects directory
RUN mkdir -p /home/claude/projects

# Create symlinks for customization folders (9 total)
RUN ln -sf /home/claude/.claude/commands /home/claude/projects/claude-commands
RUN ln -sf /home/claude/.claude/skills /home/claude/projects/claude-skills
RUN ln -sf /home/claude/.claude/hooks /home/claude/projects/claude-hooks
RUN ln -sf /home/claude/.claude/agents /home/claude/projects/claude-agents
RUN ln -sf /home/claude/.claude/todos /home/claude/projects/claude-todos
RUN ln -sf /home/claude/.claude/projects /home/claude/projects/claude-projects
RUN ln -sf /home/claude/.claude/session-env /home/claude/projects/claude-sessions
RUN ln -sf /home/claude/.claude/system-prompts /home/claude/projects/claude-system-prompts
RUN ln -sf /home/claude/.config/mcp /home/claude/projects/mcp-config

# Copy slash commands
COPY claude-commands/ /home/claude/.claude/commands/

# Copy system prompt management scripts
COPY claude-system-prompts/ /home/claude/projects/claude-system-prompts/
RUN chmod +x /home/claude/projects/claude-system-prompts/scripts/*.sh
```

### Settings.json Template for Docker
```json
{
  "alwaysThinkingEnabled": true,
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "${ANTHROPIC_AUTH_TOKEN}",
    "ANTHROPIC_BASE_URL": "${ANTHROPIC_BASE_URL}",
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
```

---

## 5. Validation Steps

### Context Management Validation
```bash
# Check context usage after customization
claude
/context  # Should show auto-compact buffer at ~5% instead of 22.5%
```

### Symlink Structure Validation
```bash
# Verify all symlinks exist and work
ls -la ~/projects/ | grep claude
ls -la ~/projects/mcp-config

# Test drop-in functionality
echo "# Test Skill" > ~/projects/claude-skills/test.md
ls ~/projects/claude-skills/test.md
```

---

## 6. Future Customization Areas

Based on Claude Code capabilities, these areas are ready for markdown-based customization:

### Ready for Use
- **Skills** (`claude-skills/`) - Drop .md files for custom functionality
- **Commands** (`claude-commands/`) - Drop .md files for custom slash commands
- **MCP Servers** (`mcp-config/servers/`) - Add .json files for new integrations

### Potential Extensions
- **Hooks** (`claude-hooks/`) - Automation scripts for tool events
- **Agents** (`claude-agents/`) - Custom agent configurations
- **Status Line** - Custom status information scripts

---

## 7. Maintenance

### Regular Tasks
- Monitor context usage to ensure 5% target is maintained
- Update symlinks if Claude Code folder structure changes
- Add new customization folders as Claude Code evolves

### Updates Required When
- Claude Code changes folder structure
- New environment variables are introduced
- Additional customization types become available

---

**Created**: 2025-11-14
**Version**: 1.0
**Claude Code Version**: Current
**Docker Compatibility**: Yes