# Sudo Escalation Management

## Description
Strategic permission escalation command that automatically detects permission issues and retries with passwordless sudo when available.

## Usage
`/sudo [action] [command] [options]`

## Actions

### Check Sudo Status
```bash
/sudo check
/sudo status
/sudo --check
```
Check if passwordless sudo is available and configured.

### Execute with Smart Escalation
```bash
/sudo exec <command> [args...]
/sudo run <command> [args...]
/sudo <command> [args...]
```
Execute command with automatic permission escalation if needed.

### Test Escalation
```bash
/sudo test
/sudo test-permissions
```
Test the sudo escalation functionality with sample operations.

### Enable Passwordless Sudo
```bash
/sudo enable
/sudo setup
```
Show instructions for enabling passwordless sudo.

## Examples

### File Operations
```bash
/sudo mkdir -p /usr/local/bin/custom-tool
/sudo cp script.sh /usr/local/bin/
/sudo chmod +x /usr/local/bin/script.sh
```

### System Operations
```bash
/sudo systemctl restart nginx
/sudo systemctl enable docker
/sudo usermod -aG docker $USER
```

### Package Management
```bash
/sudo pip install -g global-package
/sudo npm install -g package-name
/sudo apt update && sudo apt install package
```

### Network Operations
```bash
/sudo python -m http.server 80
/sudo netstat -tlnp | grep :80
```

## Natural Language Triggers

You can also use natural language to manage sudo escalation:

- "I need to create a directory in /usr/local"
- "Install this package globally"
- "Start this system service"
- "Check if I have sudo access"
- "Test permission escalation"
- "I got a permission error, can you retry with sudo?"

## Automatic Escalation Behavior

When a permission error is detected:

1. **Immediate Task Suspension**: All current tasks stop
2. **Permission Analysis**: Error is analyzed to confirm it's permission-related
3. **Sudo Availability Check**: System checks if passwordless sudo is available
4. **Automatic Retry**: If available, the exact same command is retried with sudo
5. **Task Resumption**: After successful escalation, task execution continues

## Error Detection Patterns

The system automatically detects these permission-related errors:

- "Permission denied"
- "Operation not permitted"
- "Access denied"
- "Insufficient permissions"
- "must be root"
- "requires root privileges"
- "sudo required"
- Exit codes: 1, 13, 126, 127 (when indicating permission issues)
- File system errors in protected directories
- Network errors on privileged ports (< 1024)

## Configuration

### Environment Variables
- `CLAUDE_SUDO_ESCALATION_ENABLED=1` - Enable automatic escalation
- `CLAUDE_AUTO_ESCALATE_ON_PERMISSION_ERROR=1` - Auto-escalate on permission errors
- `CLAUDE_SUDO_TIMEOUT=30` - Timeout for sudo operations

### Sudoers Configuration
To enable passwordless sudo, add to `/etc/sudoers`:
```
$USER ALL=(ALL) NOPASSWD: ALL
```

Or for specific commands:
```
$USER ALL=(ALL) NOPASSWD: /usr/bin/mkdir, /usr/bin/chmod, /usr/bin/systemctl
```

## Integration with Task Management

The sudo escalation integrates seamlessly with Claude Code's task management:

### Before Escalation
```markdown
[
  {"content": "Create system directory", "status": "in_progress", "activeForm": "Creating system directory"}
]
```

### After Permission Error Detection
```markdown
[
  {"content": "Create system directory", "status": "escalation-required", "activeForm": "Creating system directory - permission escalation needed"}
]
```

### After Successful Escalation
```markdown
[
  {"content": "Create system directory", "status": "completed", "activeForm": "Created system directory with sudo escalation"}
]
```

## Security Considerations

### Automatic Escalation Rules
- Only escalates for confirmed permission errors
- Uses the exact same command with sudo prefix
- Logs all escalation attempts
- Provides clear feedback about operations

### Manual Override
If automatic escalation is not desired:
```bash
# Disable automatic escalation
export CLAUDE_AUTO_ESCALATE_ON_PERMISSION_ERROR=0

# Or use manual escalation
/sudo exec <command>
```

### Audit Trail
All escalated operations are logged with:
- Original command that failed
- Permission error detected
- Escalation attempt
- Final result

## Troubleshooting

### Passwordless Sudo Not Working
```bash
# Check current sudo configuration
sudo -l

# Test passwordless sudo
sudo -n true

# If it fails, configure passwordless sudo:
sudo visudo
# Add: $USER ALL=(ALL) NOPASSWD: ALL
```

### Escalation Not Triggering
```bash
# Check if escalation is enabled
echo $CLAUDE_SUDO_ESCALATION_ENABLED

# Enable automatic escalation
export CLAUDE_SUDO_ESCALATION_ENABLED=1
export CLAUDE_AUTO_ESCALATE_ON_PERMISSION_ERROR=1
```

### Docker Environments
In Docker containers, ensure the container is run with appropriate privileges:
```bash
docker run --privileged ...
# or
docker run --cap-add=SYS_ADMIN ...
```

## Advanced Usage

### Task Sequences with Escalation
```bash
# Create a task list file
cat > tasks.txt << EOF
create-system-dir:mkdir -p /usr/local/custom
install-tool:cp tool.sh /usr/local/custom/
set-permissions:chmod +x /usr/local/custom/tool.sh
start-service:systemctl enable custom-tool
EOF

# Execute with automatic escalation
task-with-sudo.sh --sequence tasks.txt
```

### Custom Error Patterns
Add custom permission error patterns:
```bash
export CLAUDE_PERMISSION_PATTERNS="CustomError1|CustomError2|Permission denied"
```

### Selective Escalation
Configure escalation for specific commands only:
```bash
export CLAUDE_ESCALATION_COMMANDS="mkdir|chmod|systemctl|pip.*-g"
```

---

**Note**: This command requires proper sudo configuration. Use with caution and ensure you understand the security implications of passwordless sudo.