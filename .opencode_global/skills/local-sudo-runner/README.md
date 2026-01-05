# Local Sudo Runner - Quick Reference

## Script Location

The sudo-runner.sh wrapper is available at:
- **Recommended**: `./scripts/local-sudo-runner/sudo-runner.sh` (symlink for easy access)
- **Source**: `./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh`

## Quick Start

```bash
# Basic usage (script path) - using recommended symlink
./scripts/local-sudo-runner/sudo-runner.sh ./scripts/deploy.sh arg1 arg2

# Inline command
./scripts/local-sudo-runner/sudo-runner.sh "systemctl restart nginx"

# With trunner protection (recommended for long operations)
./scripts/local-sudo-runner/sudo-runner.sh --trunner ./scripts/setup-worktree.sh worktree-01
```

## Common Use Cases

### Setup Scripts
```bash
# Worktree setup with sudo
./scripts/local-sudo-runner/sudo-runner.sh --trunner \
    ./scripts/setup-worktree.sh worktree-02
```

### Deploy Scripts
```bash
# Protected deployment
./scripts/local-sudo-runner/sudo-runner.sh --trunner \
    ./scripts/deploy-worktree.sh prod-01
```

### Test Runners
```bash
# Test suite requiring sudo
./scripts/local-sudo-runner/sudo-runner.sh --trunner \
    ./scripts/run-integration-tests.sh
```

### System Operations
```bash
# Service management
./scripts/local-sudo-runner/sudo-runner.sh "systemctl restart php8.2-fpm"

# Permission fixes
./scripts/local-sudo-runner/sudo-runner.sh "chown -R www-data:www-data storage/"
```

## Integration Patterns

### Pattern 1: Trunner Wrapping Sudo
```bash
# Trunner executes sudo command
trunner "echo '$$$123123' | sudo -S ./scripts/deploy.sh"
```

### Pattern 2: Sudo Wrapping Trunner (Recommended)
```bash
# Sudo runner with --trunner flag
.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh --trunner ./scripts/deploy.sh
```

## Monitoring

```bash
# List active trunner sessions
~/codes/llm-rules/scripts/tmux-runner/trunner.sh --list

# View logs in real-time
tail -f /tmp/test_suite_output_tmux-runner-*.log

# Kill specific session
~/codes/llm-rules/scripts/tmux-runner/trunner.sh --kill SESSION_ID
```

## Skill Triggers

- `$LocalSudoRunner`
- `$SudoRunner`
- "local sudo"
- "sudo automation"
- "sudo script"
- "run with sudo"

## Related Skills

- **$TmuxProtectedExecution**: Tmux session management for long operations
- **$VPSSudoPassword**: Remote VPS sudo operations (uses expect)
- **$WorktreeOrchestration**: Worktree lifecycle operations

## Files

- **SKILL.md**: Complete skill documentation
- **scripts/sudo-runner.sh**: Universal sudo wrapper script
- **scripts/examples/README.md**: Detailed usage examples

## Key Features

✓ Automated sudo password injection via stdin
✓ Trunner integration with `--trunner` flag
✓ Support for script paths or inline commands
✓ Argument forwarding to wrapped commands
✓ Exit code propagation
✓ Colored output for better visibility

## Password

Both local and VPS sudo operations use: `$$$123123`
