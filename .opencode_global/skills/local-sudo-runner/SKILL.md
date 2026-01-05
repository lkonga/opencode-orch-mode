---
name: Local Sudo Runner
description: Run local scripts requiring sudo privileges with automated password handling, integrated with trunner for protected execution
triggers: [$LocalSudoRunner, $SudoRunner, 'local sudo', 'sudo automation']
related_skills: [$TmuxProtectedExecution, $VPSSudoPassword, $WorktreeOrchestration, $SQLiteDeployTracker]
references: {'Security': 'references/sudo-security.md', 'Workflows': 'references/sudo-workflows.md', 'Sudo runner script': 'scripts/sudo-runner.sh', 'Usage examples': 'references/usage-examples.md', 'Combined execution patterns': '../tmux-protected-execution/references/combined-execution-patterns.md', 'Example usage': 'scripts/examples/README.md'}
---

# Local Sudo Runner

## Purpose
Execute local scripts requiring sudo privileges with automated password handling, eliminating interactive prompts.

## Core Capabilities

1. **Automated Sudo Authentication**: Pass sudo password via stdin
2. **Trunner Integration**: Combine sudo with tmux protection
3. **Universal Wrapper**: Works with any command requiring sudo

## Script Location

```
Workspace root/
├── .vscode/skills/local-sudo-runner/scripts/sudo-runner.sh (primary)
└── scripts/local-sudo-runner/sudo-runner.sh (symlink)
```

**Recommended**: Use symlink for shorter paths:
```bash
./scripts/local-sudo-runner/sudo-runner.sh [options] <command>
```

## Quick Start

```bash
# Navigate to project root first
cd /home/lkonga/codes/psp-p2p

# Direct sudo execution
./scripts/sudo-runner.sh \
  ./scripts/setup-worktree.sh worktree-name \
    --source-worktree-type psp-p2p

# Trunner-protected execution
./scripts/sudo-runner.sh --trunner \
  "./scripts/setup-worktree.sh worktree-name \
    --source-worktree-type psp-p2p"

# Inline commands (unchanged)
./scripts/sudo-runner.sh "systemctl restart nginx"
```

## Bidirectional Integration with $TmuxProtectedExecution

```bash
# Pattern 1: Trunner → Sudo
trunner "echo '$$$123123' | sudo -S ./scripts/deploy.sh"

# Pattern 2: Sudo → Trunner (recommended)
./scripts/sudo-runner.sh --trunner ./scripts/long-running-setup.sh

# Pattern 3: Combined (maximum protection)
./scripts/sudo-runner.sh --trunner ./scripts/deploy.sh
```

## Common Use Cases

<reference title="Example usage" path="scripts/examples/README.md" />

### Setup Scripts
```bash
# Navigate to project root first
cd /home/lkonga/codes/psp-p2p

# Worktree setup requiring sudo for symlinks
./scripts/sudo-runner.sh \
  ./scripts/setup-worktree.sh worktree-02 \
    --source-worktree-type psp-p2p

# With trunner for background execution
./scripts/sudo-runner.sh --trunner \
  "./scripts/setup-worktree.sh worktree-02 \
    --source-worktree-type psp-p2p"
```

### Deploy Scripts
```bash
# Navigate to project root first
cd /home/lkonga/codes/psp-p2p

# Local deployment requiring sudo
./scripts/sudo-runner.sh \
  ./scripts/deploy-worktree.sh worktree-01 \
    --source-worktree-type psp-p2p

# Protected deployment with monitoring
./scripts/sudo-runner.sh --trunner \
  "./scripts/deploy-worktree.sh worktree-01 \
    --source-worktree-type psp-p2p"
```

### System Operations
```bash
# Service management
./scripts/sudo-runner.sh "systemctl restart php8.2-fpm"

# Permission fixes
./scripts/sudo-runner.sh "chown -R www-data:www-data storage/"
```

## Wrapper Script Features

### Flags

- `--trunner`: Execute command in tmux-protected session
- `--help, -h`: Display usage information

### Examples

```bash
# Navigate to project root first
cd /home/lkonga/codes/psp-p2p

# Script with arguments
./scripts/sudo-runner.sh \
  ./scripts/setup-worktree.sh worktree-03 \
    --source-worktree-type psp-p2p \
    --config custom

# Inline command (unchanged)
./scripts/sudo-runner.sh "nginx -t && systemctl reload nginx"

# With trunner protection
./scripts/sudo-runner.sh --trunner \
  "./scripts/setup-worktree.sh worktree-03 \
    --source-worktree-type psp-p2p"
```

## Security Notes

- Password hardcoded as `$$$123123`
- Same password used for local and remote operations
- When using trunner: all output logged to `/tmp/test_suite_output_*.log`

## Progressive Disclosure

Load additional content as needed:

- **Security considerations**: <reference title="Security" path="references/sudo-security.md" />
- **Advanced workflows**: <reference title="Workflows" path="references/sudo-workflows.md" />
- **Combined examples**: <reference title="Combined execution patterns" path="../tmux-protected-execution/references/combined-execution-patterns.md" />

## Relationship to $VPSSudoPassword

- **VPS Sudo Password**: Uses expect script for remote SSH + sudo
- **Local Sudo Runner**: Uses stdin piping for local sudo
- **Same Password**: Both use `$$$123123`

## Related Skills

- **$TmuxProtectedExecution**: For tmux session management and monitoring
- **$VPSSudoPassword**: For remote sudo operations
- **$WorktreeOrchestration**: For worktree lifecycle with sudo support
- **$SQLiteDeployTracker**: Deployment metadata tracking (integrates with sudo-runner for local deployments)

## Progressive Disclosure

**References** (load only when needed):
<references>
  <reference title="Security" path="references/sudo-security.md" description="Password handling, security implications, best practices" />
  <reference title="Workflows" path="references/sudo-workflows.md" description="Advanced sudo patterns, complex scenarios, integration examples" />
  <reference title="Sudo runner script" path="scripts/sudo-runner.sh" description="Main wrapper script implementation and usage" />
  <reference title="Usage examples" path="references/usage-examples.md" description="Comprehensive examples for common use cases" />
  <reference title="Example usage" path="scripts/examples/README.md" description="Quick reference examples and patterns" />
  <reference title="Combined execution patterns" path="../tmux-protected-execution/references/combined-execution-patterns.md" description="Sudo + trunner integration workflows" />
</references>
