# System Prompt Template

## Metadata
- **Name**: [Prompt Name]
- **Category**: [base|append|context|domains|core]
- **Version**: 1.0.0
- **Author**: [Your Name]
- **Created**: [Date]
- **Updated**: [Date]
- **Compatible**: Claude Code All Versions
- **Priority**: [1-10, where 10 is highest priority]

## Description
[Brief description of what this system prompt does and when to use it]

## Use Cases
- [Use case 1]
- [Use case 2]
- [Use case 3]

## Dependencies
- [List any other system prompts this depends on]
- [e.g., core-enhancement.md, context-optimizer.md]

## Conflicts
- [List any system prompts this may conflict with]
- [e.g., security-focused.md if this prompt reduces security measures]

## System Prompt Content

```
[Your actual system prompt content goes here]

Follow these guidelines:
- Start with clear role definition
- Include specific behaviors and constraints
- Add examples where helpful
- Keep prompts focused and modular
- Use markdown formatting for clarity
```

## Usage Examples

### CLI Usage
```bash
# Use as standalone system prompt
claude --system-prompt "$(cat ~/projects/claude-system-prompts/[category]/[filename].md)"

# Append to existing system prompt
claude --append-system-prompt "$(cat ~/projects/claude-system-prompts/[category]/[filename].md)"
```

### Environment Variable
```bash
export CLAUDE_SYSTEM_PROMPT="~/projects/claude-system-prompts/[category]/[filename].md"
claude
```

### Project-Specific Usage
```bash
# Add to project directory for automatic loading
cp ~/projects/claude-system-prompts/[category]/[filename].md ~/my-project/.claude/system-prompt-append.md
```

## Testing
- [ ] Test with basic queries
- [ ] Test with complex tasks
- [ ] Test compatibility with other prompts
- [ ] Validate no conflicts with core functionality

## Changelog
### v1.0.0 - [Date]
- Initial version
- [Description of changes]

---

## Notes
[Additional notes, considerations, or documentation]

## License
[License information if applicable]

## Contributing
[Guidelines for others to modify or contribute to this prompt]