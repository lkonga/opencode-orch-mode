# Design Principles & Architecture

## Single Responsibility Principle

Each option performs exactly one action for maximum composability:

- `--list`: Only lists sessions
- `--kill SESSION_ID`: Only kills specific session
- `--kill-all`: Only kills all sessions
- `--clean-logs`: Only cleans log files

This atomic design enables complex workflows through composition rather than monolithic commands.

## Research-Based Improvements

### Unique Session Identifiers

Uses `timestamp-PID` pattern for guaranteed uniqueness:

```
tmux-runner-1702835123-45678
            ^         ^
            |         └── Process ID (guarantees uniqueness within same second)
            └── Unix timestamp (seconds since epoch)
```

**Benefits**:
- Prevents collisions even with rapid concurrent launches
- Human-readable timestamp component
- PID component ensures uniqueness
- Sortable for chronological analysis

### Atomic Operations

Each flag performs a single, well-defined operation:

```bash
# Atomic operations can be composed
./tmux-runner.sh --list                    # Check sessions
./tmux-runner.sh --kill SESSION_ID         # Kill specific session
./tmux-runner.sh --clean-logs              # Clean logs separately
```

**Benefits**:
- Predictable behavior
- Easier testing and debugging
- Clear error messages
- Composable workflows

### Agent-Friendly Design

Clear separation between human operations and agent operations:

**Human Operations** (Interactive):
- `tmux attach-session` - Manual session inspection
- `tmux detach` - Manual session exit
- Direct tmux commands - Human troubleshooting

**Agent Operations** (Automated):
- `trunner` - Launch commands
- `--list` - Check session status
- `--kill` - Terminate sessions
- `tail -f logfile` - Monitor progress

**Why This Matters**: Multi-agent AI systems need non-interactive operations. The agent-friendly design ensures AI can manage sessions without human intervention.

### Auto-Cleanup Architecture

Sessions automatically terminate when commands complete:

```bash
# Command completes → session exits → cleanup automatic
./tmux-runner.sh "php artisan test"
# Session terminates after test completes
```

**Benefits**:
- Prevents session accumulation
- No manual cleanup needed for successful operations
- Log files preserved for review
- Resource-efficient for long-running agent systems

## Token Efficiency Design

### Background Execution Model

**Problem**: Long operations block AI agent, consuming tokens waiting for completion.

**Solution**: Launch in tmux, continue other work, monitor via logs.

```bash
# Traditional (blocking)
./run_full_test_suite.sh  # Agent waits 30 minutes

# Token-efficient (non-blocking)
trunner "./run_full_test_suite.sh"  # Agent continues immediately
# ... work on other tasks ...
tail -50 /tmp/test_suite_output_*.log  # Check progress later
```

### High-Frequency Monitoring Pattern

**Problem**: Long sleep intervals waste time and reduce responsiveness.

**Solution**: Short sleep intervals with frequent checks.

```bash
# Inefficient (waits 2 minutes between checks)
sleep 120 && tail -100 logfile

# Efficient (checks every 5 seconds for 1 minute)
for i in {1..12}; do sleep 5 && tail -20 logfile; done
```

**Benefits**:
- Faster problem detection
- More responsive to completion
- Smaller tail output (less tokens)
- Better progress visibility

## Integration Philosophy

### Wrapper Pattern

Trunner serves as a universal wrapper for long-running operations:

```bash
# Any command can be wrapped
trunner "command"
trunner "./script.sh"
trunner "echo '$$$123123' | sudo -S ./deploy.sh"
```

### Bidirectional Integration

Designed to integrate both ways with other skills:

**Trunner → Other Skills**:
```bash
trunner "echo '$$$123123' | sudo -S ./script.sh"  # Wraps sudo
trunner "./scripts/cf-launcher.sh --config app"   # Wraps cf-launcher
```

**Other Skills → Trunner**:
```bash
./scripts/sudo-runner.sh --trunner ./script.sh  # Sudo wraps trunner
```

## Error Handling Philosophy

### Fail Fast with Clear Messages

```bash
# Detects nested tmux early
"Error: Running inside tmux. Exit session first."

# Clear session conflict resolution
"Session exists. Killing existing session..."
```

### Graceful Degradation

When operations fail:
- Exit codes propagate to caller
- Full output in log files
- Session remains for inspection
- Manual cleanup available
