# Troubleshooting Guide

## Common Issues and Solutions

### "Running inside tmux" Error

**Problem**: Attempting to create tmux session from within existing tmux session.

**Symptoms**:
```
Error: Running inside tmux. Exit session first.
```

**Solution**:
```bash
# Exit existing tmux session
exit
# Or detach (Ctrl+b, then d)

# Then run trunner from normal shell
trunner "./script.sh"
```

**Why**: Nested tmux sessions cause conflicts. Trunner detects this and prevents execution.

### Session Already Exists

**Problem**: Session ID collision (extremely rare with timestamp-PID pattern).

**Symptoms**:
```
Session tmux-runner-XXX already exists
Killing existing session...
```

**Solution**: Automatic - script kills existing session before creating new one.

**Manual Override**:
```bash
# Kill all sessions
./tmux-runner.sh --kill-all

# Then retry
trunner "./script.sh"
```

### Session Auto-Terminated

**Problem**: Session terminates unexpectedly (usually normal behavior).

**Symptoms**:
- Session ID not in `--list` output
- Log file exists with complete output

**Solution**: This is normal - sessions terminate when commands complete. Check log file:
```bash
tail -100 /tmp/test_suite_output_tmux-runner-*.log
```

**Verify Completion**:
```bash
# Look for completion indicators
tail -20 /tmp/test_suite_output_*.log | grep -i "complete\|done\|finished\|error"
```

### Command Not Found

**Problem**: Script path incorrect or permissions missing.

**Symptoms**:
```
command not found: ./script.sh
```

**Solutions**:
```bash
# Check file exists
ls -la ./script.sh

# Fix permissions
chmod +x ./script.sh

# Use correct path
./tmux-runner.sh "/full/path/to/script.sh"
```

### Log File Not Found

**Problem**: Incorrect session ID or log file cleaned up.

**Symptoms**:
```
tail: cannot open '/tmp/test_suite_output_*.log': No such file
```

**Solutions**:
```bash
# List all trunner logs
ls -lh /tmp/test_suite_output_tmux-runner-*.log

# Find active sessions
./tmux-runner.sh --list

# Use correct session ID from --list output
tail -50 /tmp/test_suite_output_tmux-runner-CORRECT-ID.log
```

### Monitoring Not Updating

**Problem**: Log file not receiving new output.

**Possible Causes**:
1. Command completed
2. Command hung/stuck
3. Buffering issues

**Diagnosis**:
```bash
# Check if session still active
./tmux-runner.sh --list

# Check log file size
ls -lh /tmp/test_suite_output_*.log

# Verify command running
ps aux | grep -i "script-name"
```

**Solutions**:
```bash
# If hung, kill session
./tmux-runner.sh --kill SESSION_ID

# If completed, review full log
less /tmp/test_suite_output_*.log
```

### Too Many Sessions

**Problem**: Many old sessions accumulated.

**Symptoms**:
```bash
./tmux-runner.sh --list
# Shows dozens of sessions
```

**Solution**:
```bash
# Kill all sessions at once
./tmux-runner.sh --kill-all

# Clean up log files
./tmux-runner.sh --clean-logs
```

### Permission Denied on Log Files

**Problem**: Log file permissions incorrect.

**Symptoms**:
```
Permission denied: /tmp/test_suite_output-*.log
```

**Solution**:
```bash
# Fix permissions
chmod 644 /tmp/test_suite_output-*.log

# Or remove and recreate
rm /tmp/test_suite_output-*.log
trunner "./script.sh"  # Creates new log file
```

## Advanced Troubleshooting

### Inspect Session Manually (Humans Only)

```bash
# List all sessions
tmux list-sessions

# Attach to session for inspection
tmux attach-session -t tmux-runner-SESSION-ID

# Detach when done (Ctrl+b, then d)
```

**Note**: AI agents should NOT attach to sessions. Use log files instead.

### Debug Script Execution

```bash
# Add debug output to script
set -x  # Enable bash debugging

# Or wrap in bash with debugging
trunner "bash -x ./script.sh"
```

### Check Tmux Server Status

```bash
# Check tmux server
tmux info

# Kill tmux server (kills all sessions)
tmux kill-server

# Restart tmux server (automatic on next trunner)
```

### Log File Analysis

```bash
# Search for errors
grep -i error /tmp/test_suite_output-*.log

# Check exit codes
tail -20 /tmp/test_suite_output-*.log | grep "exit"

# Count lines (progress indicator)
wc -l /tmp/test_suite_output-*.log
```

## Prevention Best Practices

### Before Running

```bash
# Check not already in tmux
echo $TMUX  # Should be empty

# Verify script is executable
ls -la ./script.sh

# Test script manually first
./script.sh --help
```

### During Monitoring

```bash
# Use high-frequency monitoring
for i in {1..12}; do sleep 5 && tail -20 logfile; done

# Not low-frequency
# sleep 120 && tail -100 logfile  # DON'T DO THIS
```

### After Completion

```bash
# Verify completion
tail -50 /tmp/test_suite_output-*.log

# Clean up when done
./tmux-runner.sh --kill-all
./tmux-runner.sh --clean-logs
```

## Getting Help

If problems persist:

1. Check log files for complete output
2. Verify script works outside trunner
3. Review related skills ($LocalSudoRunner, $CFLauncher)
4. Check integration patterns in `../core-infrastructure/examples/`
