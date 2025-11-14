# Strategic Permission Escalation System

## Overview

The Strategic Permission Escalation system provides automatic detection of permission errors and seamless retry with passwordless sudo when available. This system is designed to stop task execution immediately when permission issues are detected, escalate privileges, and then retry the original task.

## 🚨 Core Behavioral Directives

### 1. IMMEDIATE Task List Suspension
When ANY permission error is detected:

1. **STOP ALL CURRENT TASKS IMMEDIATELY**
2. **Update todo list** to reflect "escalation-required" status
3. **Do not continue** with any subsequent tasks until escalation is resolved

### 2. Automatic Escalation Protocol
After stopping the task list:

1. **Check for passwordless sudo availability**
2. **If available**: Retry the EXACT same command with `sudo` prefix
3. **If not available**: Provide clear instructions for enabling passwordless sudo
4. **After successful escalation**: Update todo status and resume task execution

## 📁 File Structure

```
claude-system-prompts/
├── base/
│   └── sudo-strategy.md                    # Core behavioral instructions
├── scripts/
│   ├── sudo-escalation.sh                  # Main escalation script
│   └── task-with-sudo.sh                   # Task wrapper with escalation
└── _README.md

claude-commands/
└── sudo.md                                 # Slash command definition
```

## 🔧 Components

### 1. System Prompt: `sudo-strategy.md`
Configures Claude's behavior for permission management:
- Automatic permission error detection
- Task list suspension protocol
- Escalation and retry procedures
- User communication templates

### 2. Escalation Script: `sudo-escalation.sh`
Core functionality for automatic privilege escalation:
- 15+ permission error pattern detection
- Passwordless sudo verification
- Smart command execution with fallback
- Preemptive sudo for known privileged commands

### 3. Task Wrapper: `task-with-sudo.sh`
Integration with TodoWrite system:
- Task state management during escalation
- Progress tracking and reporting
- Sequence execution with automatic escalation

### 4. Slash Command: `/sudo`
User interface for sudo operations:
- Status checking and testing
- Manual escalation commands
- Natural language triggers

## 🎯 Permission Error Detection

The system automatically detects these patterns:

### Error Messages
- "Permission denied"
- "Operation not permitted"
- "Access denied"
- "Insufficient permissions"
- "must be root"
- "requires root privileges"
- "sudo required"

### Exit Codes
- 1, 13, 126, 127 (when indicating permission issues)

### Contextual Indicators
- File system errors in protected directories
- Network errors on privileged ports (< 1024)
- Service management failures
- Package installation failures

## 🔄 Escalation Process

### Step 1: Error Detection
```bash
# Example failing command
mkdir -p /usr/local/custom-tool
# Output: mkdir: cannot create directory '/usr/local/custom-tool': Permission denied
```

### Step 2: Task Suspension
```
🚨 PERMISSION ERROR DETECTED - STOPPING TASK LIST

Failed operation: Create system directory
Error: mkdir: cannot create directory '/usr/local/custom-tool': Permission denied
Status: ESCALATION REQUIRED

⚠️  All subsequent tasks paused until privilege escalation is resolved.
```

### Step 3: Escalation Check
```bash
# Check if passwordless sudo is available
sudo -n true && echo "Passwordless sudo available" || echo "Passwordless sudo not available"
```

### Step 4: Automatic Retry
```bash
# If passwordless sudo is available:
sudo mkdir -p /usr/local/custom-tool
# Output: (success - directory created)
```

### Step 5: Task Resumption
```
✅ PRIVILEGE ESCALATION SUCCESSFUL

Passwordless sudo confirmed.
Retrying original operation with elevated privileges...

✅ Operation completed successfully.
📝 Task list execution can resume.
```

## 📋 Usage Examples

### Automatic Escalation
```bash
# These commands automatically escalate when needed:

# File operations
sudo-escalation.sh mkdir -p /usr/local/bin
sudo-escalation.sh cp script.sh /etc/init.d/
sudo-escalation.sh chmod +x /usr/local/bin/tool

# System operations
sudo-escalation.sh systemctl restart nginx
sudo-escalation.sh usermod -aG docker $USER
sudo-escalation.sh mount /dev/sdb1 /mnt/data

# Package management
sudo-escalation.sh pip install -g package
sudo-escalation.sh npm install -g tool
sudo-escalation.sh apt update && sudo apt install package
```

### Task Wrapper Integration
```bash
# Execute tasks with automatic escalation and state management
task-with-sudo.sh "Install global tool" pip install -g some-package
task-with-sudo.sh "Create system directory" mkdir -p /usr/local/custom
task-with-sudo.sh "Start system service" systemctl enable myservice
```

### Natural Language Triggers
```bash
# These phrases automatically trigger sudo escalation:

"Create a directory in /usr/local"
"Install this package globally"
"Start this system service"
"I got a permission error, can you retry with sudo?"
"Check if I have sudo access"
"Test permission escalation"
```

### Slash Commands
```bash
# Check sudo status
/sudo check
/sudo status

# Execute with escalation
/sudo exec systemctl restart nginx
/sudo run mkdir -p /usr/local/test

# Test functionality
/sudo test
/sudo test-permissions
```

## ⚙️ Configuration

### Environment Variables
```bash
# Core escalation settings
CLAUDE_SUDO_ESCALATION_ENABLED=1                # Enable automatic escalation
CLAUDE_AUTO_ESCALATE_ON_PERMISSION_ERROR=1      # Auto-escalate on errors

# Behavior tuning
CLAUDE_SUDO_TIMEOUT=30                           # Sudo operation timeout
CLAUDE_MAX_ESCALATION_RETRIES=2                  # Maximum retry attempts
CLAUDE_PERMISSION_PATTERNS="Pattern1|Pattern2"   # Custom error patterns
```

### Docker Configuration
The Docker container is pre-configured with:
- Passwordless sudo for the `claude` user
- All escalation scripts in PATH
- System prompt integration enabled
- Environment variables pre-set

### Sudoers Configuration
For host systems, enable passwordless sudo:
```bash
# Add to /etc/sudoers
$USER ALL=(ALL) NOPASSWD: ALL

# Or for specific commands only:
$USER ALL=(ALL) NOPASSWD: /usr/bin/mkdir, /usr/bin/chmod, /usr/bin/systemctl
```

## 🔍 Testing and Verification

### Test Sudo Availability
```bash
# Test passwordless sudo
sudo-escalation.sh --check-sudo

# Test permission detection
sudo-escalation.sh --detect-permission "Permission denied"

# Test full escalation
sudo-escalation.sh mkdir -p /usr/local/test-escalation
```

### Test Task Integration
```bash
# Test task wrapper
task-with-sudo.sh "Test escalation" mkdir -p /usr/local/task-test

# Test task sequences
echo -e "test1:mkdir -p /usr/local/test1\ntest2:touch /usr/local/test1/file" > tasks.txt
task-with-sudo.sh --sequence tasks.txt
```

### Test System Prompt Integration
```bash
# Test if system prompt is loaded
grep -r "Strategic Permission Management" /home/claude/projects/claude-system-prompts/base/

# Test natural language processing
echo "I need to create a directory in /usr/local" | sudo-escalation.sh --detect-permission
```

## 🚨 Important Notes

### Security Considerations
- **Passwordless sudo** provides powerful privileges - use with caution
- All escalated operations are logged for audit purposes
- The system only escalates when permission errors are detected
- Users can disable automatic escalation if desired

### Troubleshooting
- If escalation fails, check sudoers configuration
- Verify that scripts are executable and in PATH
- Ensure environment variables are properly set
- Check Docker container permissions

### Limitations
- Requires passwordless sudo configuration
- Only works with commands that can be run with sudo
- Some complex permission scenarios may need manual intervention
- Windows environments require different approach

## 📚 Integration with Claude Code

### TodoWrite Integration
When permission errors occur:
```markdown
[
  {"content": "Install package", "status": "escalation-required", "activeForm": "Installing package - permission escalation needed"},
  {"content": "Configure service", "status": "pending", "activeForm": "Configuring service"}
]
```

### Behavioral Integration
The `sudo-strategy.md` system prompt ensures Claude:
- Immediately stops task execution on permission errors
- Provides clear communication about escalation status
- Automatically retries with sudo when available
- Updates task progress appropriately

### Natural Language Processing
Claude automatically recognizes permission-related requests and escalates appropriately without explicit user commands.

---

This system provides seamless, automatic permission escalation while maintaining security and providing clear feedback about all privileged operations.