---
name: VPS Sudo Password
description: Run sudo on VPS deployments via SSH using `sudo -n` + NOPASSWD sudoers.d (no password prompts)
triggers: ['$VPSSudoPassword']
trigger_keywords: ['vps sudo', 'sudo -n', 'nopasswd sudo', 'vps automation', 'ssh keys']
related_skills: ['$VPSLaravelDeploy', '$VPSGenericDeploy', '$LocalSudoRunner']
references: {}
---

# VPS Sudo Password Skill

Automate sudo commands on VPS (37.60.247.12) without interactive password prompts.

## Working Solution

**Current approach**: `sudo -n` + NOPASSWD sudoers.d (no password prompts)

**VPS Configuration**:
- SSH keys configured (already set up on i7mech and g5kc)
- NOPASSWD sudoers.d configured on VPS
- Sudoers file: `/etc/sudoers.d/50-deploy`
- Content:
  - `lkonga ALL=(ALL:ALL) NOPASSWD: ALL`
  - `lkonga ALL=(www-data) NOPASSWD: ALL`

### New SSH Sudo Approach (2026-01-05 - Updated)
**Old Method** (OBSOLETE - DO NOT USE):
- Used `echo '$$$123123' | sudo -S -k` pattern
- Required password management
- Had silent failures from race conditions (~20% failure rate)

**New Method** (CURRENT - Use This):
- Uses `sudo -n` with NOPASSWD sudoers.d configuration
- VPS configured: /etc/sudoers.d/50-deploy
- Content: `lkonga ALL=(ALL:ALL) NOPASSWD: ALL` and `lkonga ALL=(www-data) NOPASSWD: ALL`
- 100% reliable (tested: 10/10 iterations, 44/44 commands)
- No password prompts
- Better debugging (clear error messages)

**Key Benefits**:
- ✅ Eliminates password piping race conditions
- ✅ No password management overhead
- ✅ Industry-standard SSH keys + sudoers.d
- ✅ Better developer experience (no friction)

**Documentation**:
- See: /home/lkonga/codes/llm-rules/tasks/ssh-sudo-research/TASK-COMPLETE-SUMMARY.md
- See: /home/lkonga/codes/llm-rules/tasks/ssh-sudo-research/IMPLEMENTATION-REVIEW-HANDOFF.md

## Usage Examples

```bash
# System operations
# (Preferred) use vps_exec which runs `sudo -n` under the hood
./scripts/vps/vps_exec "whoami"
./scripts/vps/vps_exec "sudo -n systemctl status nginx"
./scripts/vps/vps_exec "sudo -n systemctl restart nginx"

# File operations
./scripts/vps/vps_exec "sudo -n ls -la /var/www/worktrees/"
./scripts/vps/vps_exec "sudo -n chown -R www-data:www-data /var/www/app"
```

## Key Features

- Uses `sudo -n` (non-interactive) with NOPASSWD sudoers.d
- No password prompts / no expect dependency
- Clear failures when sudoers misconfigured (no silent hangs)
- Works with any sudo command (once NOPASSWD is configured)

## Related Skills

### $LocalSudoRunner - Local Sudo Automation

For local sudo operations (same machine), use `$LocalSudoRunner` instead:

**Comparison**:
- **VPS Sudo Password**: Remote SSH + sudo (uses `sudo -n` + sudoers.d)
- **Local Sudo Runner**: Local sudo only (may use stdin piping depending on setup)

**Local Sudo Examples**:
```bash
# Local script with sudo
~/.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh ./scripts/setup.sh

# Local with trunner protection
~/.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh --trunner ./scripts/deploy.sh

# Local inline command
~/.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh "systemctl restart nginx"
```

See `$LocalSudoRunner` skill for detailed local sudo automation patterns.

````

> Note: Any references to `sudo -S` / password piping are obsolete for VPS flows. Use `sudo -n` + NOPASSWD sudoers.d instead.
