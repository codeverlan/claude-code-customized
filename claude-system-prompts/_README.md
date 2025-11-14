# Claude Code System Prompts

This directory contains a comprehensive collection of system prompts for Claude Code, organized for easy management and customization through drop-in markdown files.

## Directory Structure

```
claude-system-prompts/
├── _README.md           # This file - usage documentation
├── _TEMPLATE.md         # Template for creating new system prompts
├── base/                # Base system prompts (standalone replacements)
├── append/              # Append prompts (additions to existing system prompt)
├── context/             # Context-specific prompts
├── domains/             # Domain-specific prompts
├── core/                # Core system prompt references and extractions
└── scripts/             # Management and utility scripts
```

## Categories

### 📁 base/
Base system prompts that can replace or fundamentally modify the core system prompt. Use these when you want to completely change Claude's behavior.

**Examples:**
- `core-enhancement.md` - Enhanced core instructions
- `context-optimizer.md` - Improved context management
- `development-focus.md` - Development-specific base behavior

### 📁 append/
Prompts designed to be appended to the existing system prompt. Use these to add specific capabilities without replacing core functionality.

**Examples:**
- `security-focused.md` - Security and compliance additions
- `analysis-mode.md` - Enhanced analysis capabilities
- `automation-focused.md` - Workflow automation enhancements

### 📁 context/
Context-specific prompts that adapt Claude's behavior for particular environments or situations.

**Examples:**
- `docker-development.md` - Docker environment specific
- `security-audit.md` - Security audit context
- `architecture-review.md` - Architecture analysis context

### 📁 domains/
Domain-specific prompts for specialized fields or industries.

**Examples:**
- `compliance.md` - Regulatory compliance
- `architecture.md` - Software architecture
- `research.md` - Research and analysis

### 📁 core/
Reference copies of current system prompts and extraction tools for understanding what Claude is currently using.

**Examples:**
- `current-system-prompt.md` - Extracted active system prompt
- `base-claude-instructions.md` - Core Claude instructions
- `context-management.md` - Current context handling logic

## Quick Start

### 1. View Available Prompts
```bash
# List all available prompts
find ~/projects/claude-system-prompts -name "*.md" ! -name "_*" | sort

# List prompts by category
ls ~/projects/claude-system-prompts/base/
ls ~/projects/claude-system-prompts/append/
ls ~/projects/claude-system-prompts/context/
ls ~/projects/claude-system-prompts/core/
```

### 2. Use a System Prompt

#### As Replacement (Base Prompts)
```bash
# Replace system prompt entirely
claude --system-prompt "$(cat ~/projects/claude-system-prompts/base/development-focus.md)"
```

#### As Addition (Append Prompts)
```bash
# Add to existing system prompt
claude --append-system-prompt "$(cat ~/projects/claude-system-prompts/append/security-focused.md)"
```

#### Multiple Appends
```bash
# Combine multiple append prompts
claude --append-system-prompt "$(cat ~/projects/claude-system-prompts/append/security-focused.md && echo && cat ~/projects/claude-system-prompts/append/analysis-mode.md)"
```

### 3. View Current System Prompt
```bash
# Extract and view current active system prompt
claude --print --model sonnet "Please show me your current system prompt" 2>/dev/null | grep -A 50 "System prompt" || echo "Use core extraction scripts"
```

### 4. Create Custom Prompts

#### Use the Template
```bash
# Copy template for new prompt
cp ~/projects/claude-system-prompts/_TEMPLATE.md ~/projects/claude-system-prompts/append/my-custom-prompt.md

# Edit the new prompt
vim ~/projects/claude-system-prompts/append/my-custom-prompt.md
```

#### Follow Naming Conventions
- Use kebab-case for filenames: `my-custom-prompt.md`
- Include category in filename for clarity: `security-append.md`
- Use descriptive names that indicate purpose

## Advanced Usage

### Environment Variables
```bash
# Set default system prompt
export CLAUDE_SYSTEM_PROMPT_FILE="$HOME/projects/claude-system-prompts/base/development-focus.md"

# Set default append prompt
export CLAUDE_APPEND_PROMPT_FILE="$HOME/projects/claude-system-prompts/append/security-focused.md"
```

### Project-Specific Prompts
```bash
# Create project-specific prompt directory
mkdir -p ~/my-project/.claude/system-prompts

# Link or copy prompts for project use
ln -sf ~/projects/claude-system-prompts/append/security-focused.md ~/my-project/.claude/system-prompts/
```

### Docker Integration
```bash
# In Docker container, prompts are available at:
# /home/claude/projects/claude-system-prompts/

# Use in Docker container
docker exec -it claude-code-customized claude --append-system-prompt "$(cat /home/claude/projects/claude-system-prompts/append/security-focused.md)"
```

## Management Scripts

### List and Manage Prompts
```bash
# List all prompts with descriptions
~/projects/claude-system-prompts/scripts/list-prompts.sh

# Validate prompt syntax
~/projects/claude-system-prompts/scripts/validate-prompts.sh

# Extract current system prompt
~/projects/claude-system-prompts/scripts/extract-current-prompt.sh
```

### Test Prompts
```bash
# Test a prompt with example queries
~/projects/claude-system-prompts/scripts/test-prompt.sh base/development-focus.md

# Compare two prompts
~/projects/claude-system-prompts/scripts/compare-prompts.sh prompt1.md prompt2.md
```

## Best Practices

### 1. Prompt Design
- **Be Specific**: Clearly define the role and expected behavior
- **Include Examples**: Provide examples of desired responses
- **Set Constraints**: Define what the prompt should and shouldn't do
- **Test Thoroughly**: Test with various types of queries
- **Document Usage**: Include clear usage instructions

### 2. Organization
- **Use Categories**: Place prompts in appropriate directories
- **Follow Naming Conventions**: Use consistent, descriptive names
- **Document Dependencies**: List required companion prompts
- **Version Control**: Track changes and maintain history

### 3. Compatibility
- **Test Conflicts**: Ensure prompts don't conflict with each other
- **Check Dependencies**: Verify required prompts are available
- **Maintain Backwards Compatibility**: Don't break existing workflows
- **Document Limitations**: Be clear about what prompts can't do

## Integration with Existing Tools

### CLAUDE.md Modular System
These system prompts integrate seamlessly with the existing CLAUDE.md modular instruction system:

- **CLAUDE_CORE.md**: Core instructions (use with base prompts)
- **CLAUDE_DEVELOPMENT.md**: Development workflows (use with context prompts)
- **CLAUDE_AGENTS.md**: Agent configurations (use with domain prompts)

### Docker Baseline
All prompts are included in the Docker baseline and automatically available in containers.

### Settings.json
System prompt configuration can be added to settings.json for automatic loading.

## Troubleshooting

### Common Issues

1. **Prompt Not Loading**
   - Check file path and permissions
   - Verify prompt syntax is correct
   - Ensure no conflicting prompts are active

2. **Conflicting Behaviors**
   - Review prompt dependencies
   - Check for conflicting instructions
   - Test prompts individually before combining

3. **Performance Issues**
   - Monitor token usage with longer prompts
   - Consider breaking large prompts into smaller components
   - Use append prompts instead of base prompts when possible

### Getting Help

- **Documentation**: Refer to individual prompt documentation
- **Templates**: Use `_TEMPLATE.md` as a guide
- **Examples**: Review existing prompts for patterns
- **Community**: Share and discuss prompts with other users

## Contributing

To contribute new system prompts:

1. **Use the Template**: Start with `_TEMPLATE.md`
2. **Test Thoroughly**: Ensure prompts work as expected
3. **Document Clearly**: Include comprehensive documentation
4. **Follow Conventions**: Use established naming and organization patterns
5. **Submit for Review**: Share with community for feedback

---

**Version**: 1.0.0
**Created**: 2025-11-14
**Compatible**: Claude Code All Versions
**Integration**: Docker Baseline, CLAUDE.md Modular System