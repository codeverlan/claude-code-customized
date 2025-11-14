# Quick Prompt Actions

## Description
Quick actions for common system prompt operations.

## Usage
`/prompt <action> [prompt-name]`

## Actions

### View Current Prompt
```bash
/prompt view
/prompt current
```

### List Available Prompts
```bash
/prompt list
/prompt available
```

### Reset to Default
```bash
/prompt reset
/prompt default
```

### Extract Current Prompt
```bash
/prompt extract
/prompt save
```

### Use Specific Prompt
```bash
/prompt use base/development-focus
/prompt switch security-focused
```

### Get Help
```bash
/prompt help
/prompt
```

## Natural Language Triggers

- "What prompt am I using?"
- "Show me my current prompt"
- "Reset my prompt"
- "Switch to development prompt"
- "List available prompts"
- "Save my current prompt"
- "Use security prompt"

## Examples

```bash
/prompt view           # Show current prompt
/prompt list           # List all prompts
/prompt reset          # Reset to default
/prompt use security   # Switch to security
```

## Notes

- Use `/system-prompt` for advanced management
- Use `/prompts` for preset combinations
- All actions apply to current session only