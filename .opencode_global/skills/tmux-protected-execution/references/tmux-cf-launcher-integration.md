# CF Launcher Integration

## Critical Integration Rule

**WARNING**: When using cf-launcher from trunner, NEVER use `-D` flag.

## Correct Usage Patterns

```bash
# ✓ CORRECT: Background mode works inside trunner
trunner "./scripts/cf-launcher.sh --config myapp"
trunner "./scripts/cf-launcher.sh append --config newtunnel"

# ✗ WRONG: -D flag will fail inside tmux
# trunner "./scripts/cf-launcher.sh -D --config myapp"  # WILL FAIL
```

## Why the Restriction?

The `-D` flag enables foreground mode (tmux attach), which cannot run inside an existing tmux session. Trunner already creates a tmux session, so attempting to attach to another session from within fails.

## Background Mode Details

CF Launcher's default background mode is designed for automation and works perfectly with trunner:

- **Session Isolation**: Each tunnel runs in its own tmux session
- **Non-Blocking**: Returns immediately after launch
- **Monitoring**: Check status via cf-launcher status commands
- **Logs**: Output captured in cf-launcher log files

## Integration Examples

### Basic Tunnel Launch

```bash
# Start single tunnel in background
trunner "./scripts/cf-launcher.sh --config production"

# Monitor via cf-launcher
./scripts/cf-launcher.sh status production
```

### Multiple Tunnels

```bash
# Launch multiple tunnels concurrently
trunner "./scripts/cf-launcher.sh --config app1" &
trunner "./scripts/cf-launcher.sh --config app2" &
trunner "./scripts/cf-launcher.sh --config app3" &
```

### Append Pattern

```bash
# Add tunnel to existing session
trunner "./scripts/cf-launcher.sh append --config newtunnel"
```

## Monitoring CF Launcher Sessions

CF Launcher has its own session management separate from trunner:

```bash
# Check cf-launcher status (not trunner status)
./scripts/cf-launcher.sh status

# View cf-launcher logs
tail -f /tmp/cloudflared-*.log

# List cf-launcher sessions
tmux list-sessions | grep cloudflared
```

## Related Documentation

See `$CFLauncher` skill for complete cf-launcher documentation including:
- Dual-mode architecture (background vs. foreground)
- Configuration management
- Status monitoring
- Browser integration
