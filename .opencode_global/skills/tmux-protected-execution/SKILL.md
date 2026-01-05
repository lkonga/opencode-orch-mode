---
name: 'Tmux Protected Execution'
description: 'Protected command execution in tmux sessions for long-running operations without interruption, using trunner wrapper'
trigger: ['$TmuxProtectedExecution', '$Trunner', 'run in tmux', 'protected execution', 'tmux runner', 'background command']
related_skills: ['$ArchitectCoder', '$SurgicalImplementation', '$LocalSudoRunner']
references: {'Advanced sessions': 'references/tmux-advanced-sessions.md', 'CF Launcher integration': 'references/tmux-cf-launcher-integration.md', 'Design principles': 'references/tmux-design-principles.md', 'Troubleshooting': 'references/tmux-troubleshooting.md', 'Combined execution patterns': 'references/combined-execution-patterns.md', 'Tmux patterns': 'references/tmux-patterns.md'}
---

# Tmux Protected Execution Skill

## Purpose
Execute long-running commands in protected tmux sessions to prevent execution interruption. Provides isolated execution with real-time monitoring.

## Core Principle
**Token-efficient background execution**: Use `trunner` wrapper for long-running operations to avoid blocking AI agent.

## Quick Start

```bash
# Basic execution
./tmux-runner.sh "command to run"

# Example: Worktree setup from project root
cd /home/lkonga/codes/psp-p2p
trunner "./scripts/setup-worktree.sh worktree-name \
  --source-worktree-type psp-p2p"

# Session management
./tmux-runner.sh --list
./tmux-runner.sh --kill SESSION_ID
./tmux-runner.sh --kill-all
```

## When to Use

- Test suites (minutes/hours duration)
- Database migrations and seeders
- Deployment scripts
- CF Launcher operations (always background mode)
- Any command that shouldn't be interrupted

## Key Features

- **Unique Session IDs**: Timestamped session ID (`tmux-runner-TIMESTAMP-PID`)
- **Concurrent Execution**: Multiple commands simultaneously
- **Auto-Cleanup**: Sessions terminate when complete
- **Output Logging**: Full capture to `/tmp/test_suite_output_tmux-runner-SESSIONID.log`

## Monitoring Progress (SUBAGENT DELEGATION REQUIRED)

⚠️ **CRITICAL**: Log monitoring MUST be performed by a **SUBAGENT** for token efficiency.
The main agent/architect delegates monitoring to avoid consuming tokens on repeated log checks.

### Monitoring Script Usage

**Script location**: `scripts/monitor-trunner-log.sh` (symlink to skill script)

**Delegate to subagent with these prompts**:

```bash
# Default monitoring (subagent uses default needles, auto-finds most recent log)
./scripts/monitor-trunner-log.sh

# Monitor specific log file
./scripts/monitor-trunner-log.sh /tmp/test_suite_output_tmux-runner-XYZ.log

# Monitor specific log with custom max checks
./scripts/monitor-trunner-log.sh /tmp/test_suite_output_tmux-runner-XYZ.log 50

# Auto-find most recent log with custom max checks
./scripts/monitor-trunner-log.sh "" 50

# Custom completion needles (override defaults)
./scripts/monitor-trunner-log.sh "" 30 "Custom Pattern|Another Pattern"

# Monitor specific log with custom needles
./scripts/monitor-trunner-log.sh /tmp/custom.log 30 "Custom Pattern|Another Pattern"
```

**What the subagent does**:
1. Finds most recent trunner log automatically (if not specified)
2. Checks log every 5 seconds (sleep 5) ← NEVER exceed
3. Shows last 20 lines each check (tail -20) ← NEVER exceed
4. Detects completion markers (needles) and returns immediately
5. Reports back with matched lines when needle found
6. Shows last 50 lines if max checks reached

**Default completion needles**:
- "Main Branch Deployment Complete"
- "✓ Deployment complete"
- "Setup completed successfully"
- "Rebuild.*Complete"
- "Cloudflare tunnel started"
- "ERROR:", "Failed", "fatal"

**Override needles** (when prompting subagent):
```
Monitor log file: /tmp/test_suite_output_tmux-runner-XYZ.log
Max checks: 30
Needle pattern: "Your Custom Pattern|Another Pattern"
Return when needle found or max checks reached.
```

**Subagent exit codes**:
- `0` = Needle detected (completion)
- `1` = Max checks reached
- `2` = Log file not found

**Example subagent delegation**:
```
You are a monitoring subagent. Run this command and monitor the log:
  ./scripts/monitor-trunner-log.sh

Return to me when:
- Needle is detected (report the matched lines)
- Max checks reached (report last 50 lines)

Use default needles unless I specify otherwise.
```

### Manual Pattern (If Script Unavailable)

```bash
LOG_FILE=$(ls -t /tmp/test_suite_output_tmux-runner-*.log 2>/dev/null | head -1)
for i in {1..30}; do
  sleep 5 && tail -20 "$LOG_FILE"
  if grep -qE "Main Branch Deployment Complete|✓ Deployment complete|Setup completed successfully|Rebuild.*Complete|ERROR:|Failed" "$LOG_FILE" 2>/dev/null; then
    break
  fi
done
```

**Critical Limits** (from $TmuxProtectedExecution):
- Sleep interval: `sleep 5` (5 seconds) - NEVER use sleep > 10s
- Tail lines: `tail -20` (20 lines) - NEVER use tail > 20 lines

## AI Agent Workflow

**For Long Operations**:
1. Launch with `trunner`
2. Note session ID and log path
3. Continue other tasks
4. Check log periodically (sleep 30 && tail -50)
5. Verify completion status

## Integration with $LocalSudoRunner

```bash
# Trunner wrapping sudo
trunner "echo '$$$123123' | sudo -S ./scripts/deploy.sh"

# Sudo wrapping trunner (recommended)
./scripts/sudo-runner.sh --trunner ./scripts/setup.sh
```

## AI Agent Guidelines

**Do's**:
✓ Use `trunner` for Laravel setup operations
✓ Monitor via log files using `tail`
✓ Use `--list` to check active sessions

**Don'ts**:
✗ Never use `tmux attach-session` (human-only)
✗ Never wait synchronously for long operations
✗ Never ignore session IDs
✗ Never run inside existing tmux session

## Progressive Disclosure

**References** (load only when needed):
<references>
  <reference title="Advanced sessions" path="references/tmux-advanced-sessions.md" description="Multi-session management, complex workflows, advanced patterns" />
  <reference title="CF Launcher integration" path="references/tmux-cf-launcher-integration.md" description="Tunnel management in tmux, background mode patterns" />
  <reference title="Design principles" path="references/tmux-design-principles.md" description="Token efficiency theory, session isolation, design rationale" />
  <reference title="Troubleshooting" path="references/tmux-troubleshooting.md" description="Session issues, hanging commands, recovery procedures" />
  <reference title="Combined execution patterns" path="references/combined-execution-patterns.md" description="Sudo + trunner integration, complex command patterns" />
  <reference title="Tmux patterns" path="references/tmux-patterns.md" description="Common usage patterns, best practices, examples" />
</references>

## Best Practices

### Test Suites
```bash
./tmux-runner.sh "./run_full_test_suite.sh"
tail -50 /tmp/test_suite_output_tmux-runner-*.log
```

### Laravel Setup (Token-Efficient)
```bash
trunner "./scripts/setup-worktree-with-pass.sh worktree-name --setup-laravel"
sleep 10 && tail -30 /tmp/test_suite_output_tmux-runner-*.log
```

## Success Criteria

✓ Command in isolated tmux session
✓ Unique session ID tracked
✓ Output logged to unique file
✓ Progress monitorable without interruption
✓ No token blocking during operations

---

**Remember**: Primary value is **token efficiency through background execution**. Launch operations, continue work, monitor via logs.
