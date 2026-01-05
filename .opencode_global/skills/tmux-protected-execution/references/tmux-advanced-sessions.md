# Advanced Session Management

## Concurrent Execution Patterns

### Multiple Simultaneous Commands

```bash
# Launch multiple commands simultaneously
./tmux-runner.sh "./run_full_test_suite.sh" &
./tmux-runner.sh "./run_production_tests.sh" &
./tmux-runner.sh "php artisan test --parallel" &
```

### Concurrent Worktree Setup

```bash
# Launch multiple worktree setups simultaneously
for i in 3 4 5 6; do
  trunner "./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-${i} \
    --setup-laravel \
    --source-branch psp-p2p-merchant-preview-2" &
done

# Monitor all sessions
./tmux-runner.sh --list
```

## Session Management Commands

### List Active Sessions

```bash
# List all active sessions with log file sizes
./tmux-runner.sh --list

# Using tmux directly
tmux list-sessions | grep tmux-runner
```

### Kill Sessions

```bash
# Kill specific session
./tmux-runner.sh --kill tmux-runner-1234567890-12345

# Kill all sessions
./tmux-runner.sh --kill-all

# Clean up log files (keeps sessions running)
./tmux-runner.sh --clean-logs
```

## Log File Management

### Log File Location

```
/tmp/test_suite_output_tmux-runner-TIMESTAMP-PID.log
```

Exact path displayed when session starts.

### Log File Cleanup

**Automatic cleanup** when using `--kill-all`:
```bash
./tmux-runner.sh --kill-all
```

**Manual cleanup** (keeps sessions running):
```bash
./tmux-runner.sh --clean-logs
```

## Complex Scenarios

### Nested Session Prevention

The script automatically detects and prevents running inside existing tmux sessions:

```bash
# Error: "Running inside tmux"
# Solution: Exit existing tmux session first
```

### Session Already Exists

Script automatically kills existing session before starting new one to prevent conflicts.

### Auto-Termination

Sessions automatically terminate when command completes - this is normal behavior. Check log file for full output.

## Session Isolation

### Protection Features

- **Terminal Independence**: Survives even if terminal is closed
- **Process Isolation**: Commands protected from interruptions
- **Resource Management**: Each session has unique log file and session ID

### Concurrent Execution Benefits

- **No Conflicts**: Unique session IDs prevent collisions
- **Parallel Processing**: Run multiple operations simultaneously
- **Independent Monitoring**: Each session has separate log file
