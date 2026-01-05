---
name: 'CF Launcher'
description: 'Manage Cloudflare tunnels in tmux sessions with dual-mode architecture (background default for automation, -D flag for foreground interactive mode), multi-configuration support, status monitoring, and browser integration'
triggers: ['$CFLauncher']
trigger_keywords: ['cf-launcher', 'cloudflare tunnel', 'tunnel management', 'start tunnels', 'manage tunnels']
related_skills: ['$VPSGenericDeploy', '$WorktreeOrchestration', '$TmuxProtectedExecution', '$LaravelScriptsInit']
references: {'Troubleshooting guide': 'references/cf-launcher-troubleshooting.md', 'Triad architecture': 'references/triad-architecture.md', 'VPS deployment integration': 'references/vps-deployment.md', 'Worktree integration': 'references/worktree-integration.md', 'Command cheatsheet': 'references/command-cheatsheet.md'}
---

# CF Launcher Skill

## Purpose
Manage Cloudflare tunnels using cf-launcher.sh in tmux sessions

## Core Principle
Centralized tunnel management with dual-mode architecture:
- Background mode (default): For automation
- Foreground mode (-D flag): For interactive debugging

## When to Use
1. Setting up Cloudflare tunnels for local development
2. Managing multiple tunnel configurations <reference title="Advanced configuration" path="references/cf-launcher-advanced-usage.md" />
3. Deploying applications requiring public access


## Core Operations

<reference title="Command cheatsheet" path="references/command-cheatsheet.md" />

### Create New Tunnel Session
```bash
# Background mode (default - for automation)
./scripts/cf-launcher.sh --config myapp

# With specific configurations
./scripts/cf-launcher.sh --config config1,config2

# From configuration file
./scripts/cf-launcher.sh --config-file workspaces.txt
```

### Append to Existing Session
```bash
# Append new tunnel
./scripts/cf-launcher.sh append --config new-tunnel

# Append multiple from file
./scripts/cf-launcher.sh append --config-file additional-workspaces.txt
```

### Status and Monitoring
```bash
# Check tunnel status
./scripts/cf-launcher.sh status

# Check with configuration list
./scripts/cf-launcher.sh status --list-configs

# Attach to running session
tmux attach -t cf-launcher
```

### Tunnel Management
```bash
# Kill specific tunnel
./scripts/cf-launcher.sh --kill-config tunnel-name

# Kill all tunnels
./scripts/cf-launcher.sh --kill
```

## Critical Rules

### 1. NEVER Run cf-launcher with sudo

**CRITICAL PITFALL**: Tmux sessions are **user-specific**. Running cf-launcher with sudo creates a separate tmux session under root, causing session isolation.

```bash
# ✓ CORRECT: Run as regular user
./scripts/cf-launcher.sh --config myapp

# ✗ WRONG: Sudo creates root-owned tmux session
sudo ./scripts/cf-launcher.sh --config myapp
./scripts/local-sudo-runner/sudo-runner.sh "./scripts/cf-launcher.sh --config myapp"
```

**Why This Matters**:
- User session: `tmux list-sessions` shows `cf-launcher` session
- Sudo session: Creates separate root tmux session, invisible to user
- Status detection: Works for cloudflared processes but tmux management breaks
- Session management: Cannot attach/manage tunnels across user boundaries

**Deterministic Use Case**:
- ✅ Always run cf-launcher as the **same user** who needs to manage tunnels
- ✅ Use regular user context for all cf-launcher operations
- ✅ Avoid mixing sudo and non-sudo cf-launcher calls
- ❌ Never wrap cf-launcher in sudo/sudo-runner scripts

### 2. ALWAYS Use Background Mode (Default)

```bash
# ✓ CORRECT: Default background mode
./scripts/cf-launcher.sh --config myapp

# ✗ WRONG: -D flag will fail in automation
./scripts/cf-launcher.sh -D --config myapp
```

## Success Criteria

✓ Tunnels created successfully
✓ Multiple tunnels managed in single tmux session
✓ Status monitoring shows accurate information
✓ Tunnels can be individually terminated

### Create New Tunnel Session
```bash
# Background mode (default - for automation)
./scripts/cf-launcher.sh --config myapp

# With specific configurations
./scripts/cf-launcher.sh --config config1,config2

# From configuration file
./scripts/cf-launcher.sh --config-file workspaces.txt
```
## Progressive Disclosure

**References** (load only when needed):
<references>
  <reference title="Troubleshooting guide" path="references/cf-launcher-troubleshooting.md" description="Common tunnel issues, connection problems, recovery procedures" />
  <reference title="Triad architecture" path="references/triad-architecture.md" description="Multi-application tunnel setup, architecture patterns, integration" />
  <reference title="VPS deployment integration" path="references/vps-deployment.md" description="Tunnel usage in VPS deployments, configuration patterns" />
  <reference title="Worktree integration" path="references/worktree-integration.md" description="Tunnel management for worktree environments" />
  <reference title="Command cheatsheet" path="references/command-cheatsheet.md" description="Quick reference for all cf-launcher commands" />
</references>
