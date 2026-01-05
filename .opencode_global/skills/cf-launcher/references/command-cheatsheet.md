# CF Launcher Command Cheatsheet

## Basic Operations

### Create Tunnels
```bash
# Create with all configs
./scripts/cf-launcher.sh

# Create with specific configs
./scripts/cf-launcher.sh --config name1,name2

# Create from file
./scripts/cf-launcher.sh --config-file workspaces.txt

# Create without browser
./scripts/cf-launcher.sh --config name --no-browser

# Create without attaching
./scripts/cf-launcher.sh --config name --no-attach
```

### Append to Existing
```bash
# Append single config
./scripts/cf-launcher.sh append --config new-name

# Append from file
./scripts/cf-launcher.sh append --config-file additional.txt
```

### Status and Monitoring
```bash
# Quick status (counts)
./scripts/cf-launcher.sh status

# Detailed status (list all)
./scripts/cf-launcher.sh status --list-configs

# Attach to tmux session
tmux attach -t cf-launcher
```

### Cleanup Operations
```bash
# Kill specific tunnel
./scripts/cf-launcher.sh --kill-config tunnel-name

# Kill all tunnels
./scripts/cf-launcher.sh --kill
```

## Advanced Options

### Custom Configuration
```bash
# Custom config directory
./scripts/cf-launcher.sh --config-dir /path/to/configs

# Dry run (plan only)
./scripts/cf-launcher.sh --dry-run --config test-name
```

### Flags Reference
| Flag | Description | Default |
|------|-------------|---------|
| `--config` | Comma-separated config names | All configs |
| `--config-file` | File with one config per line | N/A |
| `--config-dir` | Custom config directory | `~/.cloudflared/psp-p2p` |
| `--open-browser` | Open browser tabs | Enabled |
| `--no-browser` | Skip browser tabs | Disabled |
| `--no-attach` | Don't attach to tmux | Disabled |
| `--dry-run` | Plan only, no execution | Disabled |
| `--list-configs` | Show all config names | Disabled |
| `--kill` | Kill all tunnels | N/A |
| `--kill-config` | Kill specific tunnel | N/A |

## Configuration File Format

Create a text file with one tunnel name per line:
```
psp-p2p-preview-13
psp-landing-staging
api-development
```

## Browser Priority Order

1. Brave (brave-browser --incognito)
2. Google Chrome (google-chrome --incognito)
3. Chromium (chromium-browser --incognito)
4. Firefox (firefox --private-window)

## Quick Examples

### Start work for the day
```bash
./scripts/cf-launcher.sh --config-file daily-workspaces.txt
```

### Quick test
```bash
./scripts/cf-launcher.sh --config test-app --no-browser --no-attach
```

### Add new project
```bash
./scripts/cf-launcher.sh append --config new-project
```

### End of day cleanup
```bash
./scripts/cf-launcher.sh --kill
```

### Check what's running
```bash
./scripts/cf-launcher.sh status --list-configs
```
