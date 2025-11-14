# Claude Code Customized - Comprehensive Configuration Guide

## 🎯 Overview

This guide explains all the configurable environment variables available in the Claude Code customized Docker image. Every aspect of the container can be customized without modifying the Docker image itself.

## 📋 Table of Contents

- [Required Configuration](#required-configuration)
- [User & Directory Configuration](#user--directory-configuration)
- [API & Authentication](#api--authentication)
- [Mount Points & Volumes](#mount-points--volumes)
- [System Prompt Configuration](#system-prompt-configuration)
- [Performance & Behavior Settings](#performance--behavior-settings)
- [Permission Escalation](#permission-escalation)
- [Development & Debugging](#development--debugging)
- [Network & Security](#network--security)
- [Integration Settings](#integration-settings)
- [Advanced Configuration](#advanced-configuration)
- [Example Configurations](#example-configurations)

## 🔧 Required Configuration

### API Authentication
```bash
# Required: Your Anthropic API token
ANTHROPIC_AUTH_TOKEN=your_api_token_here

# Optional: Custom API endpoint
ANTHROPIC_BASE_URL=https://api.anthropic.com
```

**Supported API Providers:**
- `https://api.anthropic.com` (Official Anthropic)
- `https://api.z.ai/api/anthropic` (Z.AI Proxy)
- `https://anyrouter.top/v1` (AnyRouter)
- `https://openrouter.ai/api/v1` (OpenRouter)
- `https://your-custom-proxy.com/v1` (Custom Proxy)

## 👤 User & Directory Configuration

### Container User Settings
```bash
# Change the container user (useful for file permissions)
CONTAINER_USER=myuser              # Default: claude
CONTAINER_GROUP=myuser             # Default: claude
CONTAINER_UID=1001                 # Default: 1000
CONTAINER_GID=1001                 # Default: 1000
```

### Directory Configuration
```bash
# Home directory (automatically adjusts to username)
CONTAINER_HOME_DIR=/home/myuser    # Default: /home/claude

# Working directory where your code will be
CONTAINER_WORK_DIR=/data/workspace  # Default: /workspace

# Projects directory for customizations
PROJECTS_DIR=/shared/projects      # Default: /home/claude/projects

# Claude Code configuration directory
CLAUDE_CONFIG_DIR=/shared/.claude  # Default: /home/claude/.claude

# Local binary directory
LOCAL_BIN_DIR=/home/myuser/.local/bin  # Default: /home/claude/.local/bin
```

**Example: Custom User Structure**
```bash
CONTAINER_USER=developer
CONTAINER_UID=1001
PROJECTS_DIR=/data/claude-projects
CONTAINER_WORK_DIR=/data/workspace
```

## 📍 Mount Points & Volumes

### Binary Mounting
```bash
# Where your Claude binary will be mounted
CLAUDE_BINARY_MOUNT_POINT=/claude-binaries  # Default: /claude-binaries
CLAUDE_BINARY_DIR=./local-claude-binary     # Host directory
```

### Working Directory
```bash
# Host directory to mount as workspace
HOST_WORK_DIR=./my-project                   # Default: .
```

### Volume Names
```bash
# Custom volume names for persistence
PROJECTS_VOLUME_NAME=my-projects-volume     # Default: claude-code-projects
CONFIG_VOLUME_NAME=my-config-volume         # Default: claude-code-config
MCP_VOLUME_NAME=my-mcp-volume               # Default: claude-code-mcp
```

**Example: Development Setup**
```bash
HOST_WORK_DIR=/Users/username/my-project
CLAUDE_BINARY_DIR=/Users/username/claude-binaries
PROJECTS_VOLUME_NAME=dev-claude-projects
```

## 🧠 System Prompt Configuration

### Prompt Directories
```bash
# System prompt storage location
SYSTEM_PROMPT_DIR=/custom/prompts           # Default: /home/claude/projects/claude-system-prompts

# Default prompts to load
CLAUDE_DEFAULT_BASE_PROMPT=base/dev-focused.md  # Default: base/core-enhancement.md
DEFAULT_APPEND_PROMPTS=security-focused,analysis-mode  # Default: (empty)
```

### Custom Prompt Location
```bash
# Alternative location for custom prompts
CUSTOM_PROMPTS_DIR=/shared/custom-prompts    # Optional
```

## ⚡ Performance & Behavior Settings

### Context Optimization
```bash
# Memory optimization (lower = more aggressive cleanup)
CLAUDE_AUTO_COMPACT_BUFFER_RATIO=0.03       # Default: 0.05
CLAUDE_CONTEXT_AUTOCOMPACT_TARGET=3%        # Default: 5%

# Network optimization
CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1  # Default: 1
```

### API Configuration
```bash
# API timeouts and retries
API_TIMEOUT_MS=600000                      # Default: 300000 (10 minutes)
API_MAX_RETRIES=5                           # Default: 3
API_RETRY_DELAY_MS=2000                     # Default: 1000
```

### Session Configuration
```bash
# Claude Code session settings
CLAUDE_CODE_SESSION=1                       # Default: 1
CLAUDE_CODE_ENTRYPOINT=cli                  # Default: cli
CLAUDECODE=1                                # Default: 1
```

## 🔐 Permission Escalation

### Sudo Configuration
```bash
# Enable/disable automatic sudo escalation
CLAUDE_SUDO_ESCALATION_ENABLED=1             # Default: 1
CLAUDE_AUTO_ESCALATE_ON_PERMISSION_ERROR=1  # Default: 1

# Sudo behavior
CLAUDE_SUDO_TIMEOUT=60                      # Default: 30 (seconds)
CLAUDE_MAX_ESCALATION_RETRIES=3             # Default: 2
```

**Security Example:**
```bash
# Disable sudo escalation for production
CLAUDE_SUDO_ESCALATION_ENABLED=0
SECURE_MODE=1
AUDIT_LOGGING=1
```

## 🛠️ Development & Debugging

### Debug Mode
```bash
# Enable verbose logging
CLAUDE_DEBUG_MODE=1                         # Default: 0
CLAUDE_LOG_LEVEL=debug                      # Default: info
CLAUDE_PERFORMANCE_MONITORING=1             # Default: 0
CLAUDE_METRICS_ENABLED=1                    # Default: 0
```

### Feature Flags
```bash
# Experimental features
CLAUDE_EXPERIMENTAL_FEATURES=1             # Default: 0
CLAUDE_BETA_FEATURES=1                      # Default: 0
```

## 🌐 Network & Security

### Network Configuration
```bash
# Container network
CONTAINER_NETWORK=claude-dev-network       # Default: claude-network
EXPOSED_PORTS=9090:9090                    # Default: 8080:8080
```

### Security Settings
```bash
# Security features
SECURE_MODE=1                              # Default: 0
AUDIT_LOGGING=1                            # Default: 0
SUDOERS_RESTRICTIONS=1                     # Default: 0 (commented)
```

### Proxy Configuration
```bash
# Corporate proxy setup
HTTP_PROXY=http://proxy.company.com:8080
HTTPS_PROXY=http://proxy.company.com:8080
NO_PROXY=localhost,127.0.0.1,company.com
```

## 🔗 Integration Settings

### Git Integration
```bash
GIT_ENABLED=1                               # Default: 1
GIT_CONFIG_NAME=Developer Name              # Default: claude
GIT_CONFIG_EMAIL=developer@company.com     # Default: claude@localhost
```

### Docker Integration
```bash
DOCKER_INTEGRATION=1                        # Default: 1
DOCKER_SOCKET_MOUNT=/var/run/docker.sock    # Default: /var/run/docker.sock
```

### Editor Configuration
```bash
DEFAULT_EDITOR=nano                         # Default: vim
ALTERNATIVE_EDITORS=emacs,code              # Default: nano,emacs
```

## 🏗️ Advanced Configuration

### Resource Limits
```bash
# Memory and CPU limits
MEMORY_LIMIT=8g                             # Default: 4g
CPU_LIMIT=4                                 # Default: 2
MEMORY_RESERVATION=4g                       # Default: 2g
CPU_RESERVATION=2                           # Default: 1
```

### Health Check Configuration
```bash
HEALTH_CHECK_INTERVAL=60s                   # Default: 30s
HEALTH_CHECK_TIMEOUT=15s                    # Default: 10s
HEALTH_CHECK_RETRIES=5                      # Default: 3
HEALTH_CHECK_START_PERIOD=30s               # Default: 10s
```

### Backup Settings
```bash
BACKUP_ENABLED=1                            # Default: 0
BACKUP_INTERVAL_HOURS=12                    # Default: 24
BACKUP_RETENTION_DAYS=30                    # Default: 7
BACKUP_DIR=/shared/backups                  # Default: /home/claude/projects/backups
```

### Custom Initialization
```bash
INIT_SCRIPTS_DIR=/custom/init-scripts       # Default: (none)
STARTUP_COMMANDS="echo 'Custom startup'"     # Default: (none)
```

## 📝 Example Configurations

### 1. Development Environment
```bash
# .env for development
ANTHROPIC_AUTH_TOKEN=sk-ant-dev...
ANTHROPIC_BASE_URL=https://api.anthropic.com

CONTAINER_USER=developer
PROJECTS_DIR=/data/claude-projects
CONTAINER_WORK_DIR=/data/workspace

CLAUDE_DEBUG_MODE=1
CLAUDE_LOG_LEVEL=debug
CLAUDE_PERFORMANCE_MONITORING=1

GIT_ENABLED=1
GIT_CONFIG_NAME="John Developer"
GIT_CONFIG_EMAIL="john@company.com"

MEMORY_LIMIT=8g
CPU_LIMIT=4
```

### 2. Production Environment
```bash
# .env for production
ANTHROPIC_AUTH_TOKEN=sk-ant-prod...
ANTHROPIC_BASE_URL=https://api.company.com/anthropic

CONTAINER_USER=claude-prod
CONTAINER_UID=2000
PROJECTS_DIR=/app/claude-projects
CONTAINER_WORK_DIR=/app/workspace

CLAUDE_SUDO_ESCALATION_ENABLED=0
SECURE_MODE=1
AUDIT_LOGGING=1
BACKUP_ENABLED=1

CLAUDE_AUTO_COMPACT_BUFFER_RATIO=0.03
CLAUDE_CONTEXT_AUTOCOMPACT_TARGET=3%

MEMORY_LIMIT=2g
CPU_LIMIT=1
```

### 3. Corporate/Enterprise Environment
```bash
# .env for corporate use
ANTHROPIC_AUTH_TOKEN=sk-ant-corp...
ANTHROPIC_BASE_URL=https://proxy.company.com/anthropic

CONTAINER_USER=corp-user
CONTAINER_UID=3000
PROJECTS_DIR=/shared/claude-projects
CONTAINER_WORK_DIR=/shared/workspace

HTTP_PROXY=http://proxy.company.com:8080
HTTPS_PROXY=http://proxy.company.com:8080
NO_PROXY=localhost,127.0.0.1,company.com

GIT_ENABLED=1
GIT_CONFIG_NAME="Corporate User"
GIT_CONFIG_EMAIL="user@company.com"

CLAUDE_SUDO_ESCALATION_ENABLED=0
SECURE_MODE=1
AUDIT_LOGGING=1

BACKUP_ENABLED=1
BACKUP_DIR=/shared/backups
```

### 4. Resource-Constrained Environment
```bash
# .env for limited resources
ANTHROPIC_AUTH_TOKEN=sk-ant-light...

CONTAINER_USER=light-user
PROJECTS_DIR=/tmp/claude-projects
CONTAINER_WORK_DIR=/tmp/workspace

CLAUDE_AUTO_COMPACT_BUFFER_RATIO=0.02
CLAUDE_CONTEXT_AUTOCOMPACT_TARGET=2%
API_TIMEOUT_MS=120000

MEMORY_LIMIT=1g
CPU_LIMIT=0.5
MEMORY_RESERVATION=512m
CPU_RESERVATION=0.25

CLAUDE_PERFORMANCE_MONITORING=0
```

### 5. Custom Directory Structure
```bash
# .env for custom layout
ANTHROPIC_AUTH_TOKEN=sk-ant-custom...

CONTAINER_USER=custom-user
CONTAINER_HOME_DIR=/home/custom-user
PROJECTS_DIR=/opt/claude/custom-projects
CONTAINER_WORK_DIR=/opt/claude/workspace
SYSTEM_PROMPT_DIR=/opt/claude/prompts
CLAUDE_CONFIG_DIR=/opt/claude/.claude

CLAUDE_BINARY_MOUNT_POINT=/opt/claude/binaries
CLAUDE_BINARY_DIR=/host/claude-binaries

HOST_WORK_DIR=/host/my-project
PROJECTS_VOLUME_NAME=custom-projects
CONFIG_VOLUME_NAME=custom-config
```

## 🚀 Quick Setup Commands

### Basic Setup
```bash
# Copy and configure
cp .env.example .env
nano .env  # Edit with your settings

# Run with default configuration
docker-compose up -d
```

### Custom Setup
```bash
# Create custom environment file
cp .env.example .env.custom

# Edit with your custom settings
nano .env.custom

# Use custom environment
docker-compose --env-file .env.custom up -d
```

### Override Specific Settings
```bash
# Override specific variables without editing .env
ANTHROPIC_AUTH_TOKEN=your_token docker-compose up -d

# Multiple overrides
CLAUDE_DEBUG_MODE=1 GIT_CONFIG_NAME="Dev User" docker-compose up -d
```

## 🔍 Verification Commands

### Check Configuration
```bash
# Verify environment variables in container
docker exec claude-code-workspace env | grep CLAUDE

# Check directory structure
docker exec claude-code-workspace ls -la $PROJECTS_DIR

# Verify system prompts
docker exec claude-code-workspace ls -la $SYSTEM_PROMPT_DIR

# Test permission escalation
docker exec claude-code-workplace sudo whoami
```

### Health Check
```bash
# Check container health
docker ps

# View health check logs
docker inspect claude-code-workspace | grep Health -A 10
```

## 📚 Additional Resources

- [Docker Hub README](DOCKERHUB-README.md) - Complete feature overview
- [Usage Guide](DOCKER-USAGE.md) - Detailed usage instructions
- [Implementation Details](IMPLEMENTATION.md) - Technical implementation
- [Permission Escalation](SUDO_ESCALATION.md) - Sudo management system

---

**💡 Tip**: Start with the default configuration, then customize gradually based on your specific needs. All variables have sensible defaults, so you only need to configure what's different from the standard setup.