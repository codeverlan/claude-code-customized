# Quick Prompt Switcher

## Description
Quick interface for switching between commonly used system prompt combinations.

## Usage
`/prompts [preset-name]`

## Available Presets

### Development
```bash
/prompts dev
```
Uses `base/development-focus` with enhanced coding practices and testing mindset.

### Security
```bash
/prompts security
```
Uses `base/core-enhancement` with `append/security-focused` for secure development.

### Analysis
```bash
/prompts analysis
```
Uses `base/core-enhancement` with `append/analysis-mode` for deep technical analysis.

### Docker
```bash
/prompts docker
```
Uses `base/development-focus` with `context/docker-development` for containerized development.

### Research
```bash
/prompts research
```
Uses `base/core-enhancement` with enhanced analytical capabilities.

### Default
```bash
/prompts default
```
Resets to Claude Code's default system prompt.

## Interactive Selection
```bash
/prompts
```
Shows an interactive menu of all available presets.

## Natural Language

- "Switch to development mode"
- "Enable security focus"
- "Use analysis mode"
- "Go to Docker development"
- "Reset to default prompt"
- "Show me prompt presets"

## Custom Presets

You can create custom presets by adding them to your `~/.claude/prompts.json` file:

```json
{
  "my-preset": {
    "base": "base/core-enhancement",
    "append": ["append/security-focused", "append/analysis-mode"],
    "description": "Custom preset for secure analysis"
  }
}
```

## Examples

```bash
/prompts dev          # Development focus
/prompts security     # Security enhanced
/prompts analysis     # Analysis mode
/prompts docker       # Docker development
/prompts              # Interactive menu
```

## Notes

- Presets are temporary unless saved with `--save`
- Use `/system-prompt` for advanced management
- Custom presets override built-in ones with the same name