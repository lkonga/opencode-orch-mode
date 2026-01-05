# Combined Tmux & Sudo Execution Patterns

This document demonstrates bidirectional integration patterns between `$TmuxProtectedExecution` and `$LocalSudoRunner` skills.

## Core Integration Patterns

### Pattern 1: Trunner → Sudo (Most Common)

Execute sudo-requiring commands in protected tmux session.

```bash
# Background sudo operation
trunner "echo '$$$123123' | sudo -S ./scripts/deploy.sh"

# With arguments
trunner "echo '$$$123123' | sudo -S ./scripts/setup.sh worktree-01 --full"

# Multiple sudo commands
trunner "echo '$$$123123' | sudo -S bash -c 'apt-get update && apt-get install -y nginx'"
```

**When to Use**:
- Long-running deployments requiring sudo
- Package installations
- System configuration that shouldn't be interrupted

### Pattern 2: Sudo → Trunner (Recommended)

Wrap trunner execution with sudo authentication.

```bash
# Using sudo-runner wrapper
./scripts/sudo-runner.sh --trunner ./scripts/long-running-setup.sh

# With arguments
./scripts/sudo-runner.sh --trunner ./scripts/deploy.sh worktree-01 --production

# Inline commands
./scripts/sudo-runner.sh --trunner "systemctl restart nginx && ./scripts/verify.sh"
```

**When to Use**:
- Setup scripts requiring sudo throughout
- Deploy scripts with multiple sudo operations
- Cleaner syntax than Pattern 1

### Pattern 3: Combined (Maximum Protection)

Use sudo-runner's built-in trunner integration.

```bash
# Simplest syntax
./scripts/sudo-runner.sh --trunner ./scripts/deploy.sh

# Equivalent to Pattern 2 but more concise
./scripts/sudo-runner.sh --trunner ./scripts/setup-worktree.sh worktree-04
```

**When to Use**:
- When both sudo and tmux protection are required
- Long operations needing both capabilities
- Preferred for clarity and maintainability

## Complex Workflow Examples

### Laravel Worktree Setup with Sudo

```bash
# Complete Laravel setup with tmux protection
./scripts/sudo-runner.sh --trunner ./scripts/setup-worktree.sh psp-p2p-merchant-preview-3 \
  --setup-laravel \
  --source-branch main

# Monitor progress
SESSION_ID=$(trunner --list | grep setup-worktree | tail -1 | awk '{print $1}')
tail -f /tmp/test_suite_output_${SESSION_ID}.log
```

### Production Deployment Pipeline

```bash
# Multi-step deployment with sudo
./scripts/sudo-runner.sh --trunner bash -c "
  ./scripts/setup-worktree.sh prod-release &&
  ./scripts/run-tests.sh prod-release &&
  ./scripts/deploy-worktree.sh prod-release &&
  systemctl reload nginx
"

# Check deployment status
tail -100 /tmp/test_suite_output-*.log | grep -i "deploy\|success\|error"
```

### Concurrent Worktree Setup

```bash
# Launch multiple setups concurrently
for i in 3 4 5 6; do
  ./scripts/sudo-runner.sh --trunner ./scripts/setup-worktree.sh \
    psp-p2p-merchant-preview-${i} \
    --setup-laravel &
done

# Wait for all to complete
wait

# Verify all setups
trunner --list
```

### Service Restart with Verification

```bash
# Restart services and verify
./scripts/sudo-runner.sh --trunner bash -c "
  systemctl restart php8.2-fpm &&
  sleep 5 &&
  systemctl status php8.2-fpm | grep 'Active: active' &&
  systemctl restart nginx &&
  sleep 5 &&
  systemctl status nginx | grep 'Active: active'
"
```

## Monitoring Combined Operations

### Quick Status Check

```bash
# List all active sessions
trunner --list

# Check specific session
tail -50 /tmp/test_suite_output_tmux-runner-SESSIONID.log

# Search for completion status
tail -20 /tmp/test_suite_output-*.log | grep -i "complete\|done\|error"
```

### High-Frequency Monitoring

```bash
# Monitor every 5 seconds for 1 minute
SESSION_ID="tmux-runner-1234567890-12345"
for i in {1..12}; do
  sleep 5
  echo "=== Check $i/12 ==="
  tail -20 /tmp/test_suite_output_${SESSION_ID}.log
done
```

### Real-Time Following

```bash
# Follow output in real-time
tail -f /tmp/test_suite_output_tmux-runner-*.log

# Follow with grep filtering
tail -f /tmp/test_suite_output-*.log | grep -i "error\|warning\|success"
```

## Error Handling Patterns

### Retry on Failure

```bash
# Retry deployment up to 3 times
for attempt in {1..3}; do
  ./scripts/sudo-runner.sh --trunner ./scripts/deploy.sh && break
  echo "Attempt $attempt failed, retrying in 10s..."
  sleep 10
done
```

### Rollback on Error

```bash
# Deploy with automatic rollback
./scripts/sudo-runner.sh --trunner bash -c "
  ./scripts/deploy.sh || {
    echo 'Deployment failed, rolling back...'
    ./scripts/rollback.sh
    exit 1
  }
"
```

### Cleanup Trap

```bash
# Ensure cleanup even on failure
./scripts/sudo-runner.sh --trunner bash -c "
  trap './scripts/cleanup.sh' EXIT
  ./scripts/deploy.sh
"
```

## Best Practices

### Session Management

```bash
# Before starting new operations, check existing sessions
trunner --list

# Clean up old sessions if needed
trunner --kill-all

# Clean logs to free disk space
trunner --clean-logs
```

### Log Organization

```bash
# Use descriptive operation names
./scripts/sudo-runner.sh --trunner ./scripts/deploy.sh prod-release-v2.1

# Log naming reflects operation
# /tmp/test_suite_output_tmux-runner-TIMESTAMP-PID.log
```

### Monitoring Discipline

```bash
# GOOD: High-frequency, focused monitoring
for i in {1..12}; do sleep 5 && tail -20 logfile; done

# BAD: Low-frequency, verbose monitoring
# sleep 120 && tail -150 logfile  # DON'T DO THIS
```

## Troubleshooting Combined Operations

### Session Not Starting

```bash
# Check not already in tmux
echo $TMUX  # Should be empty

# Check script permissions
ls -la ./scripts/sudo-runner.sh ./scripts/deploy.sh

# Test sudo password
echo '$$$123123' | sudo -S whoami
```

### Sudo Password Rejected

```bash
# Verify password works
echo '$$$123123' | sudo -S whoami

# Reset sudo timestamp
sudo -v

# Check sudo configuration
sudo -l
```

### Log File Not Found

```bash
# List all trunner logs
ls -lh /tmp/test_suite_output-*.log

# Find session ID
trunner --list

# Use correct session ID
tail -50 /tmp/test_suite_output_tmux-runner-CORRECT-ID.log
```

## Advanced Integration Examples

### Architect-Coder Workflow

```bash
# Architect delegates setup to coder
# Coder uses combined pattern for efficiency

# Phase 1: Protected environment setup
./scripts/sudo-runner.sh --trunner ./scripts/setup-env.sh

# Phase 2: Deploy without blocking
./scripts/sudo-runner.sh --trunner ./scripts/deploy.sh

# Phase 3: Verify and continue
tail -50 /tmp/test_suite_output-*.log | grep -i "success"
```

### CI/CD Integration

```bash
# Automated deployment in pipeline
./scripts/sudo-runner.sh --trunner ./scripts/ci-deploy.sh

# Wait for completion with timeout
timeout 600 bash -c '
  until tail -20 /tmp/test_suite_output-*.log | grep -i "complete"; do
    sleep 10
  done
'

# Verify deployment
tail -100 /tmp/test_suite_output-*.log
```

## Summary

**Choose Pattern Based on Use Case**:

- **Pattern 1** (`trunner → sudo`): Direct control, inline commands
- **Pattern 2** (`sudo → trunner`): Cleaner syntax, script wrapping
- **Pattern 3** (Combined): Simplest, most maintainable

**Remember**:
- Always monitor via log files (never attach to sessions)
- Use high-frequency monitoring (sleep < 10s)
- Keep tail output focused (≤ 20 lines)
- Clean up sessions when done

## Related Documentation

- Tmux details: `$TmuxProtectedExecution` skill
- Sudo details: `$LocalSudoRunner` skill
- Worktree operations: `$WorktreeOrchestration` skill
