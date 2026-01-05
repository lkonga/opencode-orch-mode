# Tmux Protected Execution Patterns

## Overview

This document provides common patterns for using `trunner` (tmux-runner) from the `$TmuxProtectedExecution` skill for token-efficient background command execution.

## Basic Usage

### Simple Command Execution
```bash
# Execute command in background
trunner "command-to-execute"

# Example
trunner "./scripts/deploy-worktree.sh my-app"
```

### With Custom Session Name
```bash
# Use descriptive session name for easier tracking
trunner --session-name "deploy-app-v2" "command-to-execute"
```

### Session Management
```bash
# List active sessions
trunner --list

# Output shows:
# Session ID: tmux-runner-20250118-123456-98765
# Command: ./scripts/deploy-worktree.sh my-app
# Status: running

# Kill specific session
trunner --kill tmux-runner-20250118-123456-98765
```

## Monitoring Progress

### Initial Wait Pattern
```bash
# Launch command
trunner "./scripts/setup-worktree.sh app-name"

# Wait for command to start
sleep 5

# Check initial progress
tail -30 /tmp/test_suite_output_tmux-runner-*.log | tail -15
```

### Periodic Monitoring Pattern
```bash
# Check progress periodically (recommended for AI agents)
tail -30 /tmp/test_suite_output_tmux-runner-*.log | tail -15

# Wait before next check
sleep 10

# Check again
tail -30 /tmp/test_suite_output_tmux-runner-*.log | tail -15
```

### Continuous Monitoring Pattern
```bash
# For interactive monitoring (use sparingly in automation)
while true; do
    sleep 5
    tail -30 /tmp/test_suite_output_tmux-runner-*.log | tail -15
    echo "---"
done
```

### Completion Detection
```bash
# Look for completion indicators
tail -20 /tmp/test_suite_output_tmux-runner-*.log | grep -i "complete\|error\|success\|failed"

# Check exit status (after command completes)
tail -5 /tmp/test_suite_output_tmux-runner-*.log | grep -i "exit code"
```

## Common Patterns

### Long-Running Deployments
```bash
# Launch deployment in background
trunner "./vps-deploy-worktree.sh deploy \
  --subdomain app-name \
  --repo git@github.com:user/app.git \
  --branch main \
  --app-type psp-p2p \
  --landing-url https://staging.psp-landing.trylatest.in \
  --psp-url https://staging.psp-p2p.trylatest.in \
  --ppp-url https://staging.push-parser-panel.trylatest.in"

# Continue with other tasks...
# Agent can process other requests while deployment runs

# Check progress periodically
sleep 30 && tail -50 /tmp/test_suite_output_tmux-runner-*.log

# Check completion
tail -20 /tmp/test_suite_output_tmux-runner-*.log | grep -i "deployment complete"
```

### Worktree Setup
```bash
# Setup worktree in background (token-efficient)
trunner "./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-3 \
  --setup-laravel \
  --source-worktree-type psp-p2p \
  --source-branch psp-p2p-merchant-preview-2"

# Monitor progress after brief wait
sleep 10 && tail -30 /tmp/test_suite_output_tmux-runner-*.log

# Look for Laravel setup completion
tail -20 /tmp/test_suite_output_tmux-runner-*.log | grep -i "composer install\|migrations\|complete"
```

### Multiple Concurrent Operations
```bash
# Launch multiple operations concurrently
for i in 3 4 5 6; do
  trunner "./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-${i} \
    --setup-laravel \
    --source-branch psp-p2p-merchant-preview-2" &
done

# Wait for all to start
sleep 10

# Monitor all sessions
./tmux-runner.sh --list

# Check progress across all logs
tail -30 /tmp/test_suite_output_tmux-runner-*.log | sort | uniq | tail -30
```

### Test Suite Execution
```bash
# Run tests in protected environment
trunner "./run_full_test_suite.sh"

# Monitor test progress
sleep 5
tail -50 /tmp/test_suite_output_tmux-runner-*.log | grep -E "test|PASS|FAIL"

# Check final results
tail -30 /tmp/test_suite_output_tmux-runner-*.log | grep -i "tests:"
```

### Build Operations
```bash
# Run build process in background
trunner "npm run build"

# Monitor build progress
sleep 5
tail -30 /tmp/test_suite_output_tmux-runner-*.log | grep -E "build|compiled|error"

# Check build completion
tail -10 /tmp/test_suite_output_tmux-runner-*.log | grep -i "build complete\|build failed"
```

## Log File Patterns

### Finding Active Log Files
```bash
# Find all trunner log files
ls -lt /tmp/test_suite_output_tmux-runner-*.log

# Find most recent log
ls -lt /tmp/test_suite_output_tmux-runner-*.log | head -1
```

### Log File Naming Convention
```
/tmp/test_suite_output_tmux-runner-{TIMESTAMP}-{PID}.log
```

Example: `/tmp/test_suite_output_tmux-runner-20250118-123456-98765.log`

### Filtering Log Output
```bash
# Show only errors
tail -100 /tmp/test_suite_output_tmux-runner-*.log | grep -i error

# Show progress indicators
tail -100 /tmp/test_suite_output_tmux-runner-*.log | grep -E "progress|%|complete"

# Show last N unique lines (deduplicate)
tail -50 /tmp/test_suite_output_tmux-runner-*.log | sort | uniq | tail -20
```

## Session Management

### Attaching to Sessions
```bash
# List tmux sessions created by trunner
trunner --list

# Attach to specific session (for interactive debugging)
tmux attach-session -t tmux-runner-20250118-123456-98765

# Detach from session (Ctrl+B, then D)
# Session continues running after detach
```

### Killing Stuck Sessions
```bash
# Kill specific session
trunner --kill tmux-runner-20250118-123456-98765

# Verify session is gone
trunner --list | grep 98765  # Should return nothing
```

### Cleaning Up Old Sessions
```bash
# List all trunner sessions
tmux ls | grep tmux-runner

# Kill all trunner sessions (use carefully!)
for session in $(tmux ls | grep tmux-runner | cut -d: -f1); do
  tmux kill-session -t "$session"
done
```

## Best Practices

### For AI Agents

**Do's**:
✓ Always use `trunner` for operations > 30 seconds
✓ Monitor via log files using `tail` (token-efficient)
✓ Check progress periodically (every 10-30 seconds)
✓ Use session IDs to track multiple concurrent operations
✓ Look for completion indicators before proceeding
✓ Kill stuck sessions to clean up resources

**Don'ts**:
✗ Never run long commands synchronously (blocks agent)
✗ Never ignore session IDs from trunner
✗ Never continuously monitor (use periodic checks)
✗ Never proceed to next step without verifying completion
✗ Never forget to check for errors in logs
✗ Never leave zombie sessions running

### Token Efficiency

**Efficient Pattern**:
```bash
# Launch command (1 token interaction)
trunner "long-running-command"

# Do other work...
# Agent can respond to other user requests

# Check progress (1 token interaction)
sleep 30 && tail -50 /tmp/test_suite_output_tmux-runner-*.log
```

**Inefficient Pattern** (avoid):
```bash
# Synchronous execution (blocks agent for entire duration)
./long-running-command  # DON'T DO THIS

# Continuous monitoring (wastes tokens)
while ! grep "complete" /tmp/log; do
  sleep 1
  tail /tmp/log
done  # DON'T DO THIS
```

### Error Handling

**Check for Errors**:
```bash
# After command completion
tail -50 /tmp/test_suite_output_tmux-runner-*.log | grep -i error

# Check exit code
tail -10 /tmp/test_suite_output_tmux-runner-*.log | grep "exit code"

# If errors found, read full context
tail -200 /tmp/test_suite_output_tmux-runner-*.log | less
```

**Recovery from Failures**:
```bash
# Kill failed session
trunner --kill {SESSION_ID}

# Clean up partial state (if needed)
./cleanup-script.sh

# Retry with fixes
trunner "./corrected-command"
```

## Integration Patterns

### With VPS Deployment
```bash
# VPS Laravel Deployment
trunner "./vps-deploy-worktree.sh deploy \
  --subdomain app \
  --repo git@github.com:user/app.git \
  --branch main \
  --app-type psp-p2p \
  --landing-url https://staging.psp-landing.trylatest.in \
  --psp-url https://staging.psp-p2p.trylatest.in \
  --ppp-url https://staging.push-parser-panel.trylatest.in"

# Monitor deployment phases
sleep 10
tail -30 /tmp/test_suite_output_tmux-runner-*.log | grep -E "clone|test|ssl|complete"
```

### With Worktree Orchestration
```bash
# Create multiple worktrees concurrently
for num in 3 4 5; do
  trunner "./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-${num} \
    --setup-laravel \
    --source-worktree-type psp-p2p" &
done

# Monitor all sessions
sleep 15
tail -50 /tmp/test_suite_output_tmux-runner-*.log | sort | uniq | tail -30
```

### With CF Launcher
```bash
# CF Launcher runs in tmux by default (no trunner needed)
./scripts/cf-launcher.sh --config app-name

# But can use trunner for complex tunnel setups
trunner "./scripts/cf-launcher.sh --config-file workspaces.txt"
```

## Troubleshooting

### Session Won't Start
**Symptom**: `trunner` returns immediately with error

**Check**:
```bash
# Verify trunner is executable
ls -la ~/.vscode/skills/tmux-protected-execution/scripts/tmux-runner.sh

# Test tmux works
tmux new-session -d -s test "echo hello"
tmux kill-session -t test
```

### Can't Find Log File
**Symptom**: Log file doesn't exist or is empty

**Check**:
```bash
# List all trunner logs
ls -lt /tmp/test_suite_output_tmux-runner-*.log

# Check if session is running
trunner --list

# Verify command started
tmux ls | grep tmux-runner
```

### Command Appears Stuck
**Symptom**: Log file stops updating

**Check**:
```bash
# Check if process is still running
ps aux | grep -i "command-name"

# Attach to session to see real-time output
tmux attach-session -t {SESSION_ID}

# If truly stuck, kill and retry
trunner --kill {SESSION_ID}
```

## Reference

**Full Documentation**: See `$TmuxProtectedExecution` skill
**Script Location**: `~/.vscode/skills/tmux-protected-execution/scripts/tmux-runner.sh`
**Log Location**: `/tmp/test_suite_output_tmux-runner-*.log`
