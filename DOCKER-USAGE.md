# Claude Code Customizations - Docker Usage Guide

## Overview

This Docker container includes all Claude Code customizations:
- System prompt management with markdown-based drop-in files
- Custom slash commands for natural language prompt management
- Context optimization (5% auto-compact target)
- Interactive prompt selection and management
- MCP server configuration hub
- 9 integrated customization symlinks

## Quick Start

### 1. Run the Container

```bash
# Basic container run (all customizations ready)
docker run -it --name claude-custom \
  -v /path/to/your/claude-binary:/claude-binaries \
  claude-code-customized

# Run with your Claude Code host directory mounted
docker run -it --name claude-custom \
  -v /path/to/your/claude-binary:/claude-binaries \
  -v ~/.claude:/host-claude \
  -e ANTHROPIC_AUTH_TOKEN="your_token_here" \
  claude-code-customized
```

### 2. Mount Your Working Directory

```bash
docker run -it --name claude-custom \
  -v /path/to/your/claude-binary:/claude-binaries \
  -v $(pwd):/workspace \
  -w /workspace \
  -e ANTHROPIC_AUTH_TOKEN="your_token_here" \
  claude-code-customized
```

## Container Features

### ✅ Working Customizations

1. **System Prompt Management**
   - Location: `/home/claude/projects/claude-system-prompts/`
   - 6 categories: base, append, context, domains, core, scripts
   - 20+ natural language triggers
   - Interactive prompt builder

2. **Custom Slash Commands**
   - Location: `/home/claude/.claude/commands/`
   - Commands: `/system-prompt`, `/prompt`, `/prompts`, `/sudo`
   - Natural language processing

3. **Strategic Permission Escalation**
   - **Automatic Sudo Integration**: Detects permission errors and retries with sudo
   - **Task List Suspension**: Stops all tasks when permission error detected
   - **Passwordless Sudo**: Pre-configured for seamless privilege escalation
   - **Smart Error Detection**: Recognizes 15+ permission error patterns
   - **Scripts**: `sudo-escalation.sh`, `task-with-sudo.sh`
   - **System Prompt**: `sudo-strategy.md` for behavioral integration

4. **Context Optimization**
   - Auto-compact buffer: 5% (down from 22.5%)
   - Settings location: `/home/claude/.claude/settings.json`

5. **Customization Symlinks**
   - Projects directory: `/home/claude/projects/`
   - 9 symlinks to `.claude/` subdirectories
   - MCP configuration hub

## Usage Examples

### System Prompt Management

```bash
# Inside the container:

# List available prompts
/home/claude/projects/claude-system-prompts/scripts/list-prompts.sh

# Interactive prompt selection
/home/claude/projects/claude-system-prompts/scripts/interactive-prompt-manager.sh

# Use natural language (via slash commands)
/system-prompt list
/system-prompt use development focus
/system-prompt extract current
```

### Strategic Sudo Escalation

```bash
# Inside the container:

# Test passwordless sudo availability
sudo-escalation.sh --check-sudo

# Automatic permission escalation (preemptive)
sudo-escalation.sh mkdir -p /usr/local/custom-tool

# Test permission error detection
sudo-escalation.sh --detect-permission "Permission denied"

# Execute task with automatic escalation
task-with-sudo.sh "Install package globally" pip install -g some-package

# Use slash command for sudo management
/sudo check
/sudo exec systemctl restart nginx
```

### Natural Language Sudo Triggers

```bash
# These natural language phrases automatically trigger sudo escalation:

# "I need to create a directory in /usr/local"
# "Install this package globally"
# "Start this system service"
# "I got a permission error, can you retry with sudo?"
# "Check if I have sudo access"
# "Test permission escalation"
```

### Directory Structure

```
/home/claude/projects/
├── README.md                           # Usage guide
├── claude-commands/ -> ~/.claude/commands/
├── claude-skills/ -> ~/.claude/skills/
├── claude-hooks/ -> ~/.claude/hooks/
├── claude-agents/ -> ~/.claude/agents/
├── claude-todos/ -> ~/.claude/todos/
├── claude-projects/ -> ~/.claude/projects/
├── claude-sessions/ -> ~/.claude/session-env/
├── claude-system-prompts/              # Full system prompt suite
│   ├── base/                          # Base prompts
│   ├── append/                        # Append prompts
│   ├── context/                       # Context-specific prompts
│   ├── domains/                       # Domain-specific prompts
│   ├── core/                          # Core functionality prompts
│   └── scripts/                       # Management scripts
└── mcp-config/ -> ~/.config/mcp/
```

## Environment Variables

### Required

```bash
ANTHROPIC_AUTH_TOKEN=your_token_here
```

### Optional (with defaults)

```bash
ANTHROPIC_BASE_URL=https://api.anthropic.com
CLAUDE_DEFAULT_BASE_PROMPT=base/core-enhancement.md
CLAUDE_SYSTEM_PROMPT_DIR=/home/claude/projects/claude-system-prompts
CLAUDE_AUTO_COMPACT_BUFFER_RATIO=0.05
CLAUDE_CONTEXT_AUTOCOMPACT_TARGET=5%
CLAUDE_SUDO_ESCALATION_ENABLED=1
CLAUDE_AUTO_ESCALATE_ON_PERMISSION_ERROR=1
```

### Sudo Escalation Configuration

```bash
# Enable/disable automatic sudo escalation
CLAUDE_SUDO_ESCALATION_ENABLED=1          # Enable sudo escalation
CLAUDE_AUTO_ESCALATE_ON_PERMISSION_ERROR=1  # Auto-escalate on permission errors

# Sudo timeout and behavior
CLAUDE_SUDO_TIMEOUT=30                     # Timeout for sudo operations
CLAUDE_MAX_ESCALATION_RETRIES=2            # Maximum retry attempts
```

## Docker Compose (Recommended)

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  claude-custom:
    build: ./docker-baseline
    image: claude-code-customized
    container_name: claude-code-workspace
    stdin_open: true
    tty: true
    working_dir: /workspace
    environment:
      - ANTHROPIC_AUTH_TOKEN=${ANTHROPIC_AUTH_TOKEN}
      - ANTHROPIC_BASE_URL=${ANTHROPIC_BASE_URL:-https://api.anthropic.com}
      - CLAUDE_DEFAULT_BASE_PROMPT=base/core-enhancement.md
    volumes:
      # Mount your Claude binary (Linux binary required)
      - ./claude-binary:/claude-binaries:ro

      # Mount your working directory
      - .:/workspace

      # Optional: Mount host Claude configurations
      - ~/.claude:/host-claude:ro

      # Persist customizations
      - claude-customizations:/home/claude/projects

    ports:
      - "8080:8080"  # If using web-based tools

    restart: unless-stopped

volumes:
  claude-customizations:
    driver: local
```

Run with:

```bash
# Set your token
export ANTHROPIC_AUTH_TOKEN="your_token_here"

# Start the container
docker-compose up -d

# Enter the container
docker-compose exec claude-custom bash

# View logs
docker-compose logs -f claude-custom
```

## Important Notes

### ⚠️ Claude Binary Compatibility

- The container expects a **Linux** Claude Code binary
- macOS binaries won't work in the Linux container
- You can obtain the Linux binary from:
  - Claude Code releases page
  - npm package (`@anthropic-ai/claude-code`)
  - Direct download from Anthropic

### 🔧 Setting Up Claude Binary

```bash
# Create directory for Claude binary
mkdir -p ./claude-binary

# Download Linux Claude binary (example)
curl -L -o ./claude-binary/claude "https://download-url/claude-linux-x64"
chmod +x ./claude-binary/claude

# Verify it works
./claude-binary/claude --version
```

### 📁 Persistent Customizations

Your customizations persist across container restarts:

```bash
# Add custom skills
echo "# My Custom Skill" > ./volumes/claude-customizations/claude-skills/my-skill.md

# Add custom commands
echo "# My Command" > ./volumes/claude-customizations/claude-commands/my-command.md

# These persist even if you recreate the container
```

## Testing the Container

```bash
# Test all functionality
docker run --rm \
  -v ./claude-binary:/claude-binaries \
  claude-code-customized \
  /bin/bash -c "
    echo '=== Testing symlinks ===' &&
    ls -la /home/claude/projects/ &&
    echo '=== Testing scripts ===' &&
    /home/claude/projects/claude-system-prompts/scripts/list-prompts.sh --help &&
    echo '=== Testing settings ===' &&
    cat /home/claude/.claude/settings.json | jq '.env.CLAUDE_AUTO_COMPACT_BUFFER_RATIO'
  "
```

## Troubleshooting

### Claude Binary Issues

```bash
# Check if binary exists and is executable
docker run --rm -v ./claude-binary:/claude-binaries claude-code-customized ls -la /claude-binaries/

# Test binary compatibility
docker run --rm -v ./claude-binary:/claude-binaries claude-code-customized file /claude-binaries/claude
```

### Permission Issues

```bash
# Fix ownership of mounted volumes
sudo chown -R 1000:1000 ./claude-binary
```

### Environment Variables

```bash
# Check environment in container
docker run --rm claude-code-customized env | grep CLAUDE
```

## Performance Tips

1. **Use Docker Compose** for better volume management
2. **Mount working directories** as read-only when possible
3. **Use .dockerignore** to exclude unnecessary files
4. **Allocate sufficient memory** (minimum 2GB recommended)

## Integration Examples

### VS Code Integration

```bash
# Add to VS Code settings
{
  "terminal.integrated.profiles.linux": {
    "claude-custom": {
      "path": "docker",
      "args": [
        "compose", "exec", "claude-custom", "bash"
      ]
    }
  }
}
```

### Git Integration

```bash
# Git hooks work in the container
docker exec claude-custom bash -c "cd /workspace && git commit -m 'message'"
```

## Support

For issues with:
- **Docker container**: Check this guide and Docker docs
- **Claude Code**: Refer to Claude Code documentation
- **Customizations**: Check the scripts in `claude-system-prompts/scripts/`

---

**Container Version**: 1.0
**Built**: $(date)
**Claude Code Customizations**: Complete Suite (All 9 Components)