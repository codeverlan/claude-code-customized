# Claude Code Docker Baseline

This directory contains Docker configuration files to replicate all Claude Code customizations applied on 2025-11-14, including comprehensive system prompt management with slash commands and natural language integration.

## Quick Start

1. **Copy environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit .env with your API token:**
   ```bash
   # Set your Anthropic API token
   ANTHROPIC_AUTH_TOKEN=your_token_here
   ```

3. **Build and run:**
   ```bash
   ./build-and-run.sh
   ```

4. **Use Claude Code with enhanced features:**
   ```bash
   docker exec -it claude-code-customized claude
   ```

## 🚀 Enhanced Features Included

### Context Optimization (22.5% → 5%)
- Auto-compact buffer reduced from 22.5% to 5%
- Frees up 17.5% more context space
- Permanent configuration via environment variables

### System Prompt Management
- **Slash Commands**: `/system-prompt`, `/prompts`, `/prompt`
- **Natural Language**: "Show available prompts", "Use development mode"
- **Interactive Selection**: Guided prompt builder
- **Quick Presets**: Development, Security, Analysis, Docker modes

### Customization Hub (9 Symlinks)
- **Centralized Management**: All custom folders in `~/projects/`
- **Drop-in Customization**: Add `.md` files for skills, commands, prompts
- **Easy Access**: `claude-skills/`, `claude-commands/`, `claude-system-prompts/`

### Complete Docker Integration
- Pre-configured with all customizations
- All scripts executable and ready to use
- Environment variables properly set
- Volume mounts for persistent customizations

## Customizations Included

### 1. Context Management Optimization
- **Auto-compact buffer** reduced from 22.5% to 5%
- **Frees up 17.5% more context space**
- **Permanent solution** via environment variables

### 2. System Prompt Management System
- **Drop-in Management**: Add `.md` files to create system prompts
- **Core Prompt Visibility**: Extract and view current active system prompts
- **CLI Integration**: Management commands for listing, viewing, using prompts
- **Template System**: Standardized format for consistent prompt creation
- **Validation**: Built-in prompt validation and conflict detection

### 3. Slash Command & Natural Language Integration
- **Custom Commands**: `/system-prompt`, `/prompts`, `/prompt` integrated in Claude Code
- **Natural Language**: "Show available prompts", "Use development mode", etc.
- **Interactive Interfaces**: Guided prompt selection and management
- **Quick Presets**: One-click access to common prompt combinations

### 4. Markdown-Based Customization Hub
- **9 Centralized Symlinks**: All custom folders in `~/projects/` directory
- **Drop-in Skills**: Add `.md` files to `claude-skills/` for custom functionality
- **Drop-in Commands**: Add `.md` files to `claude-commands/` for slash commands
- **Easy MCP Management**: Configure servers via `mcp-config/` symlink

## File Structure

```
docker-baseline/
├── Dockerfile.claude-custom      # Docker image with all customizations
├── docker-compose.yml           # Docker Compose configuration
├── settings.json.template       # Optimized Claude settings
├── setup-claude-customizations.sh # Setup script for manual application
├── build-and-run.sh             # Build and run automation script
├── .env.example                 # Environment variables template
├── CLAUDE_CUSTOMIZATIONS.md     # Detailed documentation
├── SLASH_COMMANDS.md            # Command integration documentation
├── INTEGRATION_CHECKLIST.md     # Complete verification checklist
└── README.md                    # This file
```

## Usage Examples

### Adding Custom Skills
```bash
# Add a new skill via Docker
docker exec -it claude-code-customized bash -c 'echo "# My Custom Skill

This skill provides enhanced functionality..." > ~/projects/claude-skills/my-skill.md'
```

### Adding Custom Commands
```bash
# Add a new command via Docker
docker exec -it claude-code-customized bash -c 'echo "# My Command

## Description
Does something useful...

## Usage
/my-command [args]" > ~/projects/claude-commands/my-command.md'
```

### System Prompt Management (NEW)
```bash
# Inside the Docker container
/system-prompt list                              # List all available prompts
/system-prompt use base/development-focus       # Use development prompt
/prompts security                               # Quick security preset
"Show me available prompts"                     # Natural language
"Use development mode"                          # Natural language
```

### Checking Context Usage
```bash
# Start Claude Code in container
docker exec -it claude-code-customized claude

# Check context optimization
/context
# Should show auto-compact buffer at ~5% instead of 22.5%
```

### Configuring MCP Servers
```bash
# Edit MCP configuration
docker exec -it claude-code-customized vim ~/projects/mcp-config/master-config.json

# Restart container to apply changes
./build-and-run.sh
```

## Scripts

### build-and-run.sh
Automation script for building and running the Docker container.

**Commands:**
- `./build-and-run.sh` (default) - Build image and run container
- `./build-and-run.sh build` - Build only
- `./build-and-run.sh run` - Run only
- `./build-and-run.sh logs` - Show logs
- `./build-and-run.sh stop` - Stop container
- `./build-and-run.sh status` - Show status

### setup-claude-customizations.sh
Standalone script that can be run in any environment to apply the customizations.

**Usage:**
```bash
# Run directly
./setup-claude-customizations.sh

# Or download and run
curl https://raw.githubusercontent.com/codeverlan/claude-code-customized/main/setup-claude-customizations.sh | bash
```

## Environment Variables

### Required
- `ANTHROPIC_AUTH_TOKEN` - Your Anthropic API token

### Optional
- `ANTHROPIC_BASE_URL` - Custom API endpoint
- `CLAUDE_AUTO_COMPACT_BUFFER_RATIO` - Buffer ratio (default: 0.05)
- `CLAUDE_CONTEXT_AUTOCOMPACT_TARGET` - Target size (default: 5%)
- `API_TIMEOUT_MS` - Request timeout (default: 3000000)

## Docker Volumes

The following volumes are persisted:

- `projects-data` - Your customizations and projects
- `claude-config` - Claude Code configuration
- `mcp-config` - MCP server configurations

## Validation

To verify customizations are working:

1. **Check context usage:**
   ```bash
   docker exec -it claude-code-customized claude
   /context
   # Look for "Autocompact buffer: ~5%"
   ```

2. **Verify symlinks:**
   ```bash
   docker exec -it claude-code-customized ls -la ~/projects/
   # Should show 8 symlinks starting with "claude-"
   ```

3. **Test drop-in functionality:**
   ```bash
   docker exec -it claude-code-customized bash -c 'echo "# Test" > ~/projects/claude-skills/test.md'
   docker exec -it claude-code-customized ls ~/projects/claude-skills/
   # Should show test.md
   ```

## Manual Installation

If you prefer not to use Docker, you can apply the customizations manually:

1. **Run the setup script:**
   ```bash
   ./setup-claude-customizations.sh
   ```

2. **Or apply manually:**
   - Add environment variables to `~/.claude/settings.json`
   - Create symlinks in `~/projects/` directory

## Troubleshooting

### Container Won't Start
- Check that `.env` file is properly configured
- Verify Docker is running and you have permissions
- Check logs with `./build-and-run.sh logs`

### Context Optimization Not Working
- Verify environment variables are set in container
- Check `~/.claude/settings.json` contains the optimizations
- Restart Claude Code session

### Symlinks Not Working
- Check that target directories exist
- Verify proper permissions in container
- Run setup script manually in container

## Updates

To update customizations:

1. **Pull latest changes:**
   ```bash
   git pull origin main
   ```

2. **Rebuild and run:**
   ```bash
   ./build-and-run.sh
   ```

3. **Or update manually:**
   ```bash
   docker exec -it claude-code-customized /usr/local/bin/setup-claude-customizations.sh
   ```

## Support

For issues with:
- **Docker setup**: Check Docker documentation
- **Claude Code**: Check Claude Code documentation
- **Customizations**: Review `CLAUDE_CUSTOMIZATIONS.md`

---

**Version**: 1.0
**Created**: 2025-11-14
**Claude Code Compatibility**: Latest