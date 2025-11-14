# System Prompt Management

## Description
Comprehensive system prompt management interface for listing, viewing, using, and managing Claude Code system prompts through natural language and interactive selection.

## Usage
`/system-prompt [action] [prompt-name] [options]`

## Actions

### List Prompts
```bash
/system-prompt list
/system-prompt list --category base
/system-prompt list --search security
/system-prompt list --recent
```

### View Prompts
```bash
/system-prompt view base/core-enhancement
/system-prompt view current
/system-prompt view --content-only
```

### Use Prompts
```bash
/system-prompt use base/development-focus
/system-prompt use base/core-enhancement --append append/security-focused
/system-prompt use --interactive
```

### Extract Current Prompt
```bash
/system-prompt extract
/system-prompt extract --save
/system-prompt extract --compare
```

### Create New Prompt
```bash
/system-prompt create my-custom-prompt
/system-prompt create --interactive
```

### Search Prompts
```bash
/system-prompt search security
/system-prompt search "docker development"
```

### Get Help
```bash
/system-prompt help
/system-prompt
```

## Natural Language Triggers

You can also use natural language to manage system prompts:

- "Show me available system prompts"
- "Use the development-focused system prompt"
- "Extract my current system prompt"
- "Create a new system prompt for security analysis"
- "Search for prompts related to Docker"
- "Compare my current prompt with the core enhancement"
- "What system prompts are available?"
- "Switch to a security-focused prompt"
- "View the current system prompt"
- "Add security focus to my current prompt"

## Interactive Mode

Use `/system-prompt use --interactive` for an interactive selection interface that guides you through:
1. Choosing a base prompt
2. Selecting append prompts
3. Previewing the combined result
4. Applying the configuration

## Examples

### Quick Prompt Switching
```bash
/system-prompt use base/development-focus
```

### Enhanced Security Session
```bash
/system-prompt use base/core-enhancement --append append/security-focused
```

### Docker Development Context
```bash
/system-prompt use base/development-focus --append context/docker-development
```

### Analysis and Review
```bash
/system-prompt use base/core-enhancement --append append/analysis-mode
```

## Notes

- All changes are temporary for the current session unless specified
- Use `/system-prompt extract --save` to permanently save configurations
- Prompts are validated before use to ensure compatibility
- Search works across names, descriptions, and content