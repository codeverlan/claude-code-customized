# Claude Code Custom Slash Commands

This document describes the custom slash commands integrated into the Docker baseline for system prompt management.

## Available Commands

### `/system-prompt` - Comprehensive System Prompt Management

**Description**: Full-featured system prompt management interface

**Usage**:
```bash
/system-prompt list [--category base|append|context|domains|core] [--search term] [--recent]
/system-prompt view <prompt-name|current>
/system-prompt use <prompt-name> [--append <append-prompt>]
/system-prompt use --interactive
/system-prompt extract [--save] [--compare]
/system-prompt create <name> [--interactive]
/system-prompt search <term>
/system-prompt help
```

**Examples**:
```bash
# List all available prompts
/system-prompt list

# List base prompts only
/system-prompt list --category base

# Search for security-related prompts
/system-prompt list --search security

# View current system prompt
/system-prompt view current

# Use development-focused prompt
/system-prompt use base/development-focus

# Use base prompt with security append
/system-prompt use base/core-enhancement --append append/security-focused

# Interactive prompt builder
/system-prompt use --interactive

# Extract current prompt
/system-prompt extract --save

# Create new prompt
/system-prompt create my-custom-prompt
```

### `/prompts` - Quick Preset Selection

**Description**: Quick access to commonly used prompt combinations

**Usage**:
```bash
/prompts dev          # Development-focused
/prompts security     # Security-enhanced
/prompts analysis     # Analysis mode
/prompts docker       # Docker development
/prompts research     # Research mode
/prompts default      # Reset to default
/prompts              # Interactive menu
```

**Natural Language Triggers**:
- "Switch to development mode"
- "Enable security focus"
- "Use analysis mode"
- "Go to Docker development"
- "Reset to default prompt"

### `/prompt` - Quick Prompt Actions

**Description**: Quick access to common prompt operations

**Usage**:
```bash
/prompt view          # View current prompt
/prompt list          # List available prompts
/prompt reset         # Reset to default
/prompt use <prompt>  # Use specific prompt
/prompt extract       # Extract current prompt
/prompt help          # Show help
```

**Natural Language Triggers**:
- "What prompt am I using?"
- "Show me my current prompt"
- "Reset my prompt"
- "List available prompts"
- "Save my current prompt"

## Natural Language Integration

The system supports natural language triggers for common operations:

### Prompt Management
- "Show me available system prompts"
- "What system prompts are available?"
- "List all prompts"

### Prompt Switching
- "Use the development-focused system prompt"
- "Switch to security mode"
- "Enable analysis mode"
- "Go to Docker development context"

### Current Prompt Operations
- "What prompt am I using?"
- "Show me my current system prompt"
- "Extract my current prompt"
- "Save current system prompt"

### Creation and Search
- "Create a new system prompt for security analysis"
- "Search for prompts related to Docker"
- "Find prompts about security"

### Reset Operations
- "Reset to default prompt"
- "Clear custom prompts"
- "Use default Claude Code prompt"

## Interactive Features

### Interactive Prompt Builder
```bash
/system-prompt use --interactive
```

Guides you through:
1. Selecting a base prompt
2. Adding append prompts
3. Previewing the combination
4. Getting the command to use

### Interactive Preset Selection
```bash
/prompts
```

Shows an interactive menu of all available presets with descriptions.

## File Structure Integration

The commands integrate with the following directory structure:

```
~/projects/claude-system-prompts/
├── _README.md           # Comprehensive documentation
├── _TEMPLATE.md         # Standardized template
├── base/                # Standalone replacement prompts
├── append/              # Prompt additions
├── context/             # Context-specific prompts
├── domains/             # Domain-specific prompts
├── core/                # Reference prompts
└── scripts/             # Management scripts
    ├── slash-command-handler.sh      # Main command processor
    ├── interactive-prompt-manager.sh # Interactive interface
    ├── manage-system-prompts.sh      # CLI management
    ├── extract-current-prompt.sh     # Prompt extraction
    ├── view-current-prompt.sh        # Prompt viewing
    └── list-prompts.sh               # Prompt listing
```

## Implementation Details

### Command Processing Flow

1. **Slash Command Recognition**: Claude Code recognizes `/system-prompt`, `/prompts`, `/prompt`
2. **Command File Loading**: Loads corresponding `.md` file from `~/projects/claude-commands/`
3. **Parameter Parsing**: Extracts action and parameters from command
4. **Script Execution**: Calls appropriate management script
5. **Response Formatting**: Returns formatted output for user interaction

### Natural Language Processing

1. **Intent Recognition**: Pattern matching against common phrases
2. **Entity Extraction**: Identifies prompt names, categories, search terms
3. **Action Mapping**: Maps intent to appropriate command
4. **Response Generation**: Provides helpful responses and suggestions

### Integration Points

- **Settings.json**: System prompt configuration
- **Environment Variables**: Default prompt settings
- **Docker Container**: Pre-configured with all commands
- **CLI Integration**: Seamless command-line usage
- **Interactive Mode**: User-friendly selection interfaces

## Docker Integration

All commands are pre-configured in the Docker baseline:

```dockerfile
# Copy custom slash commands
COPY claude-commands/ ${HOME}/.claude/commands/

# Copy system prompt management scripts
COPY claude-system-prompts/ ${HOME}/projects/claude-system-prompts/
RUN chmod +x ${HOME}/projects/claude-system-prompts/scripts/*.sh
```

## Usage Examples

### Complete Workflow Example

```bash
# Start a Docker container with customizations
./build-and-run.sh

# Inside the container, check available prompts
/system-prompt list

# Use natural language to switch prompts
"Switch to security-focused mode"

# Extract current prompt for reference
/system-prompt extract --save

# Create custom prompt interactively
/system-prompt create --interactive

# Use quick preset
/prompts dev
```

### Development Session Example

```bash
# List development-related prompts
/system-prompt list --search development

# Switch to development mode
/prompts dev

# Add security focus for a security review
/system-prompt use base/development-focus --append append/security-focused

# Extract the combined prompt for reference
/system-prompt extract --compare
```

## Troubleshooting

### Common Issues

1. **Command not recognized**: Ensure Docker container is running with customizations
2. **Scripts not executable**: Check permissions in claude-system-prompts/scripts/
3. **Prompts not found**: Verify symlink structure in ~/projects/
4. **Natural language not working**: Check slash-command-handler.sh functionality

### Debug Commands

```bash
# Check if scripts are executable
ls -la ~/projects/claude-system-prompts/scripts/

# Test slash command handler directly
~/projects/claude-system-prompts/scripts/slash-command-handler.sh help

# Verify prompt files exist
ls -la ~/projects/claude-system-prompts/base/

# Check symlinks
ls -la ~/projects/ | grep claude
```

## Future Enhancements

Planned improvements:
- Custom preset management
- Project-specific prompt loading
- Prompt validation and conflict detection
- Advanced search with filters
- Prompt versioning and rollback
- Integration with Git for prompt tracking

---

**Version**: 1.0.0
**Created**: 2025-11-14
**Integration**: Docker Baseline v1.0