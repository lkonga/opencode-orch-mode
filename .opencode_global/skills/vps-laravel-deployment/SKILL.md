---
name: VPS Laravel Deployment
description: Test-gated Laravel deployment to VPS with triad configuration, SSH access, and automated SSL setup
triggers: ['$VPSLaravelDeploy', '$DeployLaravelVPS']
trigger_keywords: ['deploy laravel to vps', 'vps deployment', 'laravel vps', 'test-gated deployment']
related_skills: ['$TmuxProtectedExecution', '$WorktreeOrchestration', '$RepositoryAnalysis', '$VPSSudoPassword', '$LaravelScriptsInit', '$SQLiteDeployTracker']
references: {'VPS infrastructure': 'references/vps-infrastructure.md', 'Advanced workflows': 'references/vps-laravel-advanced-workflows.md', 'Troubleshooting': 'references/vps-laravel-troubleshooting.md', 'Triad architecture': 'references/triad-architecture.md', 'Application architectures': 'references/vps-laravel-applications.md', 'Main branch guide': '/tmp/vps-main-branch-deployment-guide.md'}
---

# VPS Laravel Deployment Skill

## Purpose
Deploy Laravel applications to VPS using **test-gated deployment** where tests MUST pass before activation.

## Core Principle
**Test-gated deployment**: All tests must pass on VPS BEFORE activation. If ANY test fails, deployment aborts with automatic cleanup.

## ⚠️ CRITICAL: App-Type to Repo-Name Mapping (MEMORIZE)

**Problem**: Deployment fails because `--repo` parameter uses wrong repository name for given `--app-type`.

**Impact**: Git clone fails with "repository not found" error, blocking deployment.

**App-Type → Repo-Name Mapping** (ALWAYS USE THIS):
```
App-Type           → Repo Name (Required for --repo)
psp-landing        → psp-p2p-landing (NOT psp-landing!)
psp-p2p          → psp-p2p
push-parser-panel  → push-parser-panel
```

**Correct Git URLs for All Deployments**:
```bash
# psp-landing (uses psp-p2p-landing repo)
--repo git@github.com:lkonga/psp-p2p-landing.git

# psp-p2p (uses psp-p2p repo)
--repo git@github.com:lkonga/psp-p2p.git

# push-parser-panel (uses push-parser-panel repo)
--repo git@github.com:lkonga/push-parser-panel.git
```

**Quick Reference Table**:
| App-Type | Repo Name | Git URL |
|----------|-----------|---------|
| psp-landing | psp-p2p-landing | git@github.com:lkonga/psp-p2p-landing.git |
| psp-p2p | psp-p2p | git@github.com:lkonga/psp-p2p.git |
| push-parser-panel | push-parser-panel | git@github.com:lkonga/push-parser-panel.git |

**⚠️ CRITICAL**: For **psp-landing**, you must use **psp-p2p-landing** repo (NOT psp-landing).

## ⚠️ CRITICAL: The `staging.` Prefix Trap

**Problem**: VPS worktree paths automatically get `staging.` prefix added, but agents frequently forget this.

**What happens**:
- You specify: `--subdomain psp-p2p-merchant-preview-8`
- Script creates: `/var/www/worktrees/staging.psp-p2p-merchant-preview-8`
- You try to access: `/var/www/worktrees/psp-p2p-merchant-preview-8` ❌ **WRONG**
- Correct path: `/var/www/worktrees/staging.psp-p2p-merchant-preview-8` ✅

**Why this happens**:
- `ADD_STAGING_PREFIX=true` is set by default in `vps-deploy-worktree.sh`
- The script prepends `staging.` to worktree names for safety
- This is documented but agents repeatedly miss it

**How to avoid**:
1. **Always check actual VPS paths first**:
    ```bash
    ssh lkonga@37.60.247.12 "ls -1 /var/www/worktrees/ | grep preview"
    ```
2. **Never assume path names** - always verify with `ls` before deploying
3. **Remember the pattern**: `staging.<subdomain>` not just `<subdomain>`

## ⚠️ CRITICAL: Mandatory Subdomain Validation (NEW - 2026-01-04)

**Problem**: VPS deployments fail with subdomain validation errors due to missing 'staging.' prefix or branch/subdomain mismatch.

**Validation Rules** (BLOCKING - Not Warnings):
1. ✅ `--subdomain` MUST start with 'staging.' prefix
2. ✅ Subdomain (minus 'staging.') MUST match branch name (minus 'wt-')
3. ❌ Deployment ABORTS if validation fails (blocking error)

**IMPORTANT**: This validation ONLY applies to `vps-deploy-worktree.sh` (VPS deployments).
Local `setup-worktree.sh` allows ANY existing branch as `--source-branch` (e.g., develop, main, feature/*).

**Error Messages**:
- `ERROR: Subdomain MUST start with 'staging.' prefix`
- `ERROR: Subdomain MUST match branch name (minus 'staging.')`

**Correct Usage**:
```bash
# CORRECT - Full subdomain with staging. prefix, matches branch name
cd /home/lkonga/codes/llm-rules/scripts/vps
./vps-deploy-worktree.sh deploy \
  --subdomain staging.psp-p2p-merchant-preview-8 \
  --repo git@github.com:lkonga/psp-p2p.git \
  --branch wt-psp-p2p-merchant-preview-8 \
  --app-type psp-p2p \
  --ppp-url https://staging.push-parser-panel.trylatest.in
```

**Wrong Usage**:
```bash
# WRONG - Missing staging. prefix
./vps-deploy-worktree.sh deploy \
  --subdomain psp-p2p-merchant-preview-8 \
  --branch wt-psp-p2p-merchant-preview-8 \
  ...
# ERROR: Subdomain MUST start with 'staging.' prefix

# WRONG - Subdomain doesn't match branch name
./vps-deploy-worktree.sh deploy \
  --subdomain staging.preview-8 \
  --branch wt-different-branch \
  ...
# ERROR: Subdomain MUST match branch name (minus 'staging.')
```

**See**: `references/vps-laravel-troubleshooting.md` for complete troubleshooting guide.

## Refactor 1: Triad URL Handling

**⚠️ BREAKING CHANGE**: `--ppp-url` parameter is now **mandatory** for all main branch deployments.

**What Changed**: URLs are now automatically extracted from git remote and propagated through all deployment layers. Worktree deployments already required `--ppp-url` (no change). Main branch deployments now require it (breaking change).

**See**: `/home/lkonga/codes/llm-rules/docs/refactors/refactor-1/README.md` for complete documentation.

## When to Use This Skill

1. User requests Laravel deployment to VPS
2. Setting up preview/staging environment for PSP applications
3. Deploying interconnected Laravel triads

## VPS Infrastructure

- **VPS IP**: 37.60.247.12
- **SSH User**: lkonga
- **Default Server**: Nginx + PHP-FPM 8.3.27
- **Domain**: trylatest.in (Cloudflare managed)
- **Database Root Password**: Push@Parser2024!Secure

## Workflow Overview

### Phase 1: Preparation
```bash
# Navigate to VPS scripts directory
cd /home/lkonga/codes/llm-rules/scripts/vps

# Verify branch is pushed
cd /home/lkonga/codes/{psp-p2p|psp-landing|push-parser-panel}
git push -u origin {branch-name}
```

### Phase 2: Deploy with $TmuxProtectedExecution (Direct Trunner)
```bash
# Navigate to VPS scripts directory
cd /home/lkonga/codes/llm-rules/scripts/vps

# Use trunner directly for tmux protection (NOT sudo-runner - preserves SSH key access)
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "timeout 1200 ./vps-deploy-worktree.sh deploy \
  --subdomain staging.psp-p2p-merchant-preview-7 \
  --repo git@github.com:lkonga/psp-p2p.git \
  --branch wt-psp-p2p-merchant-preview-7 \
  --app-type psp-p2p \
  --landing-url https://staging.psp-landing-preview-7.trylatest.in \
  --psp-url https://staging.psp-p2p-merchant-preview-7.trylatest.in \
  --ppp-url https://staging.push-parser-panel-preview-7.trylatest.in"
```

**⚠️ DEPRECATED**: Triad numbering/derived URLs are no longer used. Always specify explicit triad URL parameters.

**CRITICAL**: Always use `trunner` directly for VPS deployments:
- **Direct trunner**: Preserves SSH key access (sudo-runner breaks SSH auth)
- **VPS-side sudo**: Handled internally via `vps_exec()` function
- **NEVER** use sudo-runner wrapper (breaks GitHub SSH key access)

### Phase 3: Monitor Progress

**⚠️ CRITICAL: Use monitor-trunner-log.sh, NOT manual loops**

**PROHIBITED: Manual sleep+tail+grep loops (NEVER USE THIS)**:
```bash
# ❌ PROHIBITED - Wastes tokens and fails to detect errors reliably
for i in {1..24}; do
    sleep 10
    tail -30 /tmp/test_suite_output_tmux-runner-*.log
    if grep -q "Deployment complete" /tmp/test_suite_output_tmux-runner-*.log; then break; fi
done
```

**Problems with manual loops**:
- ❌ Wastes tokens (720+ lines of output vs 50 lines)
- ❌ Doesn't detect errors reliably (misses "timeout: failed", "ERROR:", "Failed")
- ❌ Doesn't know when script finishes (loop continues blindly)
- ❌ Script dies but loop keeps going, masking the failure

**CORRECT: Use the smart monitoring script**:
```bash
# ✅ CORRECT - Use monitor-trunner-log.sh for ALL VPS deployments
# Step 1: Wait for deployment to initialize
sleep 5

# Step 2: Run monitoring script (auto-finds latest log, detects completion/errors)
./scripts/monitor-trunner-log.sh

# That's it! The script handles everything:
# - Finds latest trunner log automatically
# - Monitors every 5 seconds (not 10)
# - Detects completion markers (Deployment complete, Redeploy complete, etc.)
# - Detects error patterns (ERROR:, Failed, timeout:, etc.)
# - Returns immediately when done
# - Shows last 50 lines on completion
# - Token-efficient (subagent handles monitoring for you)
```

**When to use monitoring script**:
- ✅ ALL VPS deployments (worktree and main branch)
- ✅ ALL long-running operations (composer install, npm build, migrations)
- ✅ ANY command run via trunner that you need to monitor

**Advantages of monitor-trunner-log.sh**:
- ✅ **Token-efficient**: Only outputs final summary (50 lines), not every check
- ✅ **Auto-detects completion**: Returns immediately when deployment finishes
- ✅ **Auto-detects errors**: Catches ERROR:, Failed, timeout:, etc.
- ✅ **Smart log detection**: Finds latest trunner log automatically
- ✅ **No manual loop needed**: Just run the script
- ✅ **Better error detection**: Shows final context when done

**Full Example**:
```bash
# Phase 2: Deploy with $TmuxProtectedExecution
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "timeout 1200 ./vps-deploy-worktree.sh deploy \
  --subdomain {name} \
  --repo {git-url} \
  --branch {branch} \
  --app-type {type} \
  --ppp-url https://staging.push-parser-panel.trylatest.in"

# Phase 3: Monitor Progress (use smart monitoring script)
sleep 5
./scripts/monitor-trunner-log.sh

# Phase 4: Verification
curl -I https://staging.{subdomain}.trylatest.in
```

**See**: Bootstrapping Prompt Pitfall #24 for complete documentation on why manual loops are prohibited.

### Phase 4: Verification
```bash
# Check HTTP status
curl -I https://staging.psp-p2p-merchant-preview-7.trylatest.in

# Verify SSL certificate
curl -vI https://staging.psp-p2p-merchant-preview-7.trylatest.in 2>&1 | grep -i "SSL certificate\|expire"
```

## Application Types

<reference title="Application architectures" path="references/vps-laravel-applications.md" />

## Deployment Pattern Selection

### Worktree Deployment (Feature Branches)

**Use**: `vps-deploy-worktree.sh`
**When**: Deploying feature/preview branches
**URL Pattern**: `https://staging.{name}.trylatest.in`

**⚠️ DEPRECATED**: Triad numbering/derived URLs are no longer used. Always specify explicit triad URL parameters (`--landing-url`, `--psp-url`, `--ppp-url`) for all deployments. Subdomain can be any name (e.g., `feature-x`, `test-env`, `preview-5`, etc.).

### PSP-P2P (Pay-In Service)
```bash
cd /home/lkonga/codes/llm-rules/scripts/vps
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "./vps-deploy-worktree.sh deploy \
  --subdomain staging.psp-p2p-merchant-preview-7 \
  --repo git@github.com:lkonga/psp-p2p.git \
  --branch wt-psp-p2p-merchant-preview-7 \
  --app-type psp-p2p \
  --landing-url https://staging.psp-landing-preview-7.trylatest.in \
  --psp-url https://staging.psp-p2p-merchant-preview-7.trylatest.in \
  --ppp-url https://staging.push-parser-panel-preview-7.trylatest.in"
```

**⚠️ DEPRECATED**: Triad numbering/derived URLs are no longer used. Always specify explicit parameters:
- `--subdomain`: Full subdomain with `staging.` prefix (e.g., `staging.psp-p2p-merchant-preview-7`)
- `--landing-url`: Full landing page URL (e.g., `https://staging.psp-landing-preview-7.trylatest.in`)
- `--psp-url`: Full PSP-P2P URL (e.g., `https://staging.psp-p2p-merchant-preview-7.trylatest.in`)
- `--ppp-url`: Full Push Parser Panel URL (e.g., `https://staging.push-parser-panel-preview-7.trylatest.in`)

**⚠️ CRITICAL**:
- `--subdomain` MUST include `staging.` prefix explicitly
- Subdomain (minus 'staging.') MUST match branch name (minus 'wt-')
- This is a **blocking error** - deployment will fail if mismatch detected

### PSP-Landing (User Interface)
```bash
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "./vps-deploy-worktree.sh deploy \
  --subdomain staging.psp-landing-preview-7 \
  --repo git@github.com:lkonga/psp-p2p-landing.git \
  --branch wt-psp-landing-preview-7 \
  --app-type psp-landing \
  --landing-url https://staging.psp-landing-preview-7.trylatest.in \
  --psp-url https://staging.psp-p2p-merchant-preview-7.trylatest.in \
  --ppp-url https://staging.push-parser-panel-preview-7.trylatest.in"
```

**⚠️ DEPRECATED**: Triad numbering/derived URLs are no longer used. Always specify explicit parameters for full triad URLs.

**⚠️ CRITICAL**:
- `--subdomain` MUST include `staging.` prefix explicitly
- Subdomain (minus 'staging.') MUST match branch name (minus 'wt-')
- This is a **blocking error** - deployment will fail if mismatch detected

### Push Parser Panel (Verification)
```bash
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "./vps-deploy-worktree.sh deploy \
  --subdomain staging.push-parser-panel-preview-7 \
  --repo git@github.com:lkonga/push-parser-panel.git \
  --branch wt-push-parser-panel-preview-7 \
  --app-type push-parser-panel \
  --landing-url https://staging.psp-landing-preview-7.trylatest.in \
  --psp-url https://staging.psp-p2p-merchant-preview-7.trylatest.in \
  --ppp-url https://staging.push-parser-panel-preview-7.trylatest.in"
```

**⚠️ DEPRECATED**: Triad numbering/derived URLs are no longer used. Always specify explicit parameters for full triad URLs.

**⚠️ CRITICAL**:
- `--subdomain` MUST include `staging.` prefix explicitly
- Subdomain (minus 'staging.') MUST match branch name (minus 'wt-')
- This is a **blocking error** - deployment will fail if mismatch detected

---

## Main Branch Deployment

**Use**: `vps-deploy-main.sh`
**When**: Deploying main branches (develop/master)
**URL Pattern**: `https://staging.psp-p2p.trylatest.in`

### PSP-P2P Main Branch
```bash
cd /home/lkonga/codes/llm-rules/scripts/vps
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "timeout 1200 ./vps-deploy-main.sh deploy \
  --repo git@github.com:lkonga/psp-p2p.git \
  --branch develop \
  --app-type psp-p2p \
  --ppp-url https://staging.push-parser-panel.trylatest.in"

# Result: https://staging.psp-p2p.trylatest.in
```

**Note**: `--ppp-url` is **mandatory** for all main branch deployments (Refactor 1).

### Resetup (Destructive Repair) - Worktree

**⚠️ WARNING**: `--resetup` completely wipes database and environment files

```bash
cd /home/lkonga/codes/llm-rules/scripts/vps
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "./vps-deploy-worktree.sh resetup \
  --subdomain staging.psp-p2p-merchant-preview-7 \
  --app-type psp-p2p"
```

**⚠️ CRITICAL**: `--subdomain` MUST include `staging.` prefix explicitly

**What happens**:
- ❌ Database dropped and recreated (complete data loss)
- ❌ Environment file regenerated (new APP_KEY and secrets)
- ✅ Source code preserved
- ✅ SSL certificates preserved
- ✅ Requires interactive "yes" confirmation

### Resetup (Destructive Repair) - Main Branch

```bash
cd /home/lkonga/codes/llm-rules/scripts/vps
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "./vps-deploy-main.sh resetup \
  --app-type psp-p2p"
```

### Rebuild (Non-Destructive) - Worktree

**Rebuild modes preserve database data**

```bash
# Full rebuild (composer + npm + build + caches)
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "./vps-deploy-worktree.sh rebuild \
  --subdomain staging.psp-p2p-merchant-preview-7 \
  --rebuild-full"

# Frontend only (npm + build)
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "./vps-deploy-worktree.sh rebuild \
  --subdomain staging.psp-p2p-merchant-preview-7 \
  --rebuild-frontend"

# Backend only (composer + caches)
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "./vps-deploy-worktree.sh rebuild \
  --subdomain staging.psp-p2p-merchant-preview-7 \
  --rebuild-backend"

# Migrations only
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "./vps-deploy-worktree.sh rebuild \
  --subdomain staging.psp-p2p-merchant-preview-7 \
  --rebuild-migrate"

# Test-gated rebuild (add --include-tests)
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "./vps-deploy-worktree.sh rebuild \
  --subdomain staging.psp-p2p-merchant-preview-7 \
  --rebuild-full \
  --include-tests"

# Sync tracker without redeploying
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "./vps-deploy-worktree.sh rebuild \
  --subdomain staging.psp-p2p-merchant-preview-7 \
  --rebuild-full \
  --update-tracker"

# Combined: test-gated + tracker sync
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "./vps-deploy-worktree.sh rebuild \
  --subdomain staging.psp-p2p-merchant-preview-7 \
  --rebuild-full \
  --update-tracker \
  --include-tests"
```

**⚠️ CRITICAL**: `--subdomain` MUST include `staging.` prefix explicitly

**New Flags**:
- **`--update-tracker`**: Sync existing deployment with SQLite tracker (updates all 11 fields)
- **`--include-tests`**: Run test suite before deployment completes; aborts on failure

### Rebuild (Non-Destructive) - Main Branch

```bash
# Full rebuild (composer + npm + build + caches)
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "./vps-deploy-main.sh rebuild \
  --app-type psp-p2p \
  --rebuild-full"

# Frontend only (npm + build)
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "./vps-deploy-main.sh rebuild \
  --app-type psp-p2p \
  --rebuild-frontend"

# Backend only (composer + caches)
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "./vps-deploy-main.sh rebuild \
  --app-type psp-p2p \
  --rebuild-backend"

# Migrations only
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "./vps-deploy-main.sh rebuild \
  --app-type psp-p2p \
  --rebuild-migrate"

# Test-gated rebuild (add --include-tests)
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "./vps-deploy-main.sh rebuild \
  --app-type psp-p2p \
  --rebuild-full \
  --include-tests"

# Sync tracker without redeploying
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "./vps-deploy-main.sh rebuild \
  --app-type psp-p2p \
  --rebuild-full \
  --update-tracker"

# Combined: test-gated + tracker sync
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "./vps-deploy-main.sh rebuild \
  --app-type psp-p2p \
  --rebuild-full \
  --update-tracker \
  --include-tests"
```

**New Flags**:
- **`--update-tracker`**: Sync existing deployment with SQLite tracker (updates all 11 fields)
- **`--include-tests`**: Run test suite before deployment completes; aborts on failure

### PSP-Landing Main Branch
```bash
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "timeout 1200 ./vps-deploy-main.sh deploy \
  --repo git@github.com:lkonga/psp-p2p-landing.git \
  --branch develop \
  --app-type psp-landing \
  --ppp-url https://staging.push-parser-panel.trylatest.in"

# Result: https://staging.psp-landing.trylatest.in
```

### Push Parser Panel Main Branch
```bash
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "timeout 1200 ./vps-deploy-main.sh deploy \
  --repo git@github.com:lkonga/push-parser-panel.git \
  --branch develop \
  --app-type push-parser-panel \
  --ppp-url https://staging.push-parser-panel.trylatest.in"

# Result: https://staging.push-parser-panel.trylatest.in
```

**Key Difference**: Subdomain is automatically derived from app-type (no --subdomain parameter needed)

**Note**: `--ppp-url` is **mandatory** for all main branch deployments (Refactor 1).

---

## Push Parser Panel Special Cases

Push Parser Panel has unique deployment requirements due to hardcoded mobile app URLs (`push-parser-panel.trylatest.in`).

### PPP Worktree Branch to Fixed URL

When deploying a PPP worktree branch (e.g., `ppp-phone-id`) to fixed URL `push-parser-panel.trylatest.in`:

```bash
cd /home/lkonga/codes/llm-rules/scripts/vps
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "./vps-deploy-worktree.sh rebuild \
  --subdomain push-parser-panel \
  --repo git@github.com:lkonga/push-parser-panel.git \
  --branch ppp-phone-id \
  --app-type push-parser-panel \
  --rebuild-full \
  --psp-url https://staging.psp-p2p.trylatest.in \
  --landing-url https://staging.psp-landing.trylatest.in \
  --ppp-url https://push-parser-panel.trylatest.in"
```

**⚠️ CRITICAL**: Main branch deployments (like PPP `develop`) do NOT require `staging.` prefix in subdomain - this is automatically handled. Feature branches MUST include `staging.` prefix.

**Example** (deploying `ppp-phone-id` branch):
```bash
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "./vps-deploy-worktree.sh rebuild \
  --subdomain push-parser-panel \
  --repo git@github.com:lkonga/push-parser-panel.git \
  --branch ppp-phone-id \
  --app-type push-parser-panel \
  --rebuild-full \
  --psp-url https://staging.psp-p2p.trylatest.in \
  --landing-url https://staging.psp-landing.trylatest.in \
  --ppp-url https://push-parser-panel.trylatest.in"
```

**Key Points**:
- Use `--subdomain push-parser-panel` to override numbered pattern
- Use `--branch {worktree-branch}` for feature branches
- Use `--rebuild-full` for non-destructive repair
- **Always specify complete triad URLs**: `--psp-url`, `--landing-url`, `--ppp-url`
- Result: `https://push-parser-panel.trylatest.in` (same URL as main branch)

**Key Points**:
- Use `--subdomain push-parser-panel` to override numbered pattern
- Use `--branch {worktree-branch}` for feature branches
- Use `--rebuild-full` for non-destructive repair
- Triad URLs configure integration with PSP-P2P and PSP-Landing
- Result: `https://push-parser-panel.trylatest.in` (same URL as main branch)

### PPP Main Branch (Standard)

For PPP `develop`/`master` branches, use standard main branch deployment (see above).

**Note**: `vps-deploy-ppp.sh` is **deprecated**. Use `vps-deploy-main.sh` instead.

---

## Triad Deployment Order

Deploy in this sequence to ensure URL availability:

1. **PSP-P2P** first (provides pay-in API)
2. **PSP-Landing** second (needs PSP-P2P URL)
3. **Push Parser Panel** last (needs PSP-P2P URL)

Wait 2-5 minutes between deployments.

## Success Criteria

✓ Deployment completed without test failures
✓ Application accessible at HTTPS URL
✓ SSL certificate valid (Let's Encrypt)
✓ Triad URLs correctly configured in .env

## CRITICAL: Execution Pattern (MANDATORY)

⚠️ **MANDATORY**: VPS deployments **MUST** use this pattern:

### Execution Skills

- **$TmuxProtectedExecution**: Protected execution in tmux sessions
  - **Required For**: ALL VPS deployment commands
  - **Usage**: `/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "..."`

- **Monitoring**: Direct log monitoring (not ArchitectCoder for simple deployments)
  - **Usage**: `tail -20 /tmp/test_suite_output_tmux-runner-*.log`

### CORRECT Execution Pattern

**ALL VPS deployments follow this pattern**:

```bash
# STEP 1: Navigate to VPS scripts directory (MANDATORY)
cd /home/lkonga/codes/llm-rules/scripts/vps

# STEP 2: Run deployment via trunner (MANDATORY) - Direct execution preserves SSH keys
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "timeout 1200 ./vps-deploy-worktree.sh deploy ..." # Worktree
# OR
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh "timeout 1200 ./vps-deploy-main.sh deploy ..." # Main branch

# STEP 3: Monitor progress directly
sleep 10 && tail -20 /tmp/test_suite_output_tmux-runner-*.log
```

⚠️ **CRITICAL**:
- **NEVER** use sudo-runner wrapper (breaks GitHub SSH key access - runs as root)
- **ALWAYS** use trunner directly (preserves user SSH key for GitHub)
- **VPS-side sudo**: Handled internally via `vps_exec()` function
- **Monitor logs**: Use `tail -20` with sleep < 10s for responsive monitoring
- **ALWAYS** read the above skills BEFORE executing any commands

## Integration with Other Skills

- **$MainDeploy**: Main branch deployment (skips DB_PREFIX, uses vps-deploy-main.sh)
- **$LocalSudoRunner**: Automated sudo password handling (MANDATORY)
- **$TmuxProtectedExecution**: Tmux protection via --trunner flag (MANDATORY)
- **$ArchitectCoder**: Log analysis and monitoring (MANDATORY)
- **$VPSSudoPassword**: VPS sudo password for remote operations
- **$WorktreeOrchestration**: For local worktree setup
- **$SQLiteDeployTracker**: Deployment metadata tracking, PPP deploy protection, triad validation

---

## SQLite Deploy Tracker Integration

### PPP Deploy Protection (Before Deployment)

Check if PPP is already deployed before attempting to overwrite:

```bash
# Check if PPP is already deployed
PPP_URL="https://staging.push-parser-panel.trylatest.in"
IS_ACTIVE=$(./scripts/deploy-tracker-client.sh is-active --app-url "$PPP_URL")

if [[ "$IS_ACTIVE" == "1" ]]; then
    # Get existing deployment info
    INFO=$(./scripts/deploy-tracker-client.sh get --app-url "$PPP_URL")
    EXISTING_ENV=$(echo "$INFO" | jq -r '.environment')
    EXISTING_BRANCH=$(echo "$INFO" | jq -r '.branch_name')

    # Fail if env/branch mismatch
    if [[ "$EXISTING_ENV" != "$NEW_ENV" ]] || [[ "$EXISTING_BRANCH" != "$NEW_BRANCH" ]]; then
        echo "ERROR: PPP already deployed with different env/branch"
        exit 1
    fi
fi
```

### Record Deployment (After Success)

After successful deployment verification:

```bash
# After successful deployment
if [[ "${http_status}" =~ ^(200|301|302)$ ]]; then
    "${SCRIPT_DIR}/../deploy-tracker-client.sh" record \
        --app-url "https://${full_domain}" \
        --environment "vps" \
        --script-name "vps-deploy-main.sh" \
        --repo-path "${app_path}" \
        --branch-name "${BRANCH}" \
        --status "success" \
        --curl-check-passed 1 || log_warn "Failed to record deployment"
fi
```

**See**: [SQLite Deploy Tracker - Integration Examples](docs/features/sqlite-tracker/integration-examples.md)

### .env Storage Integration: Critical Technical Notes

**VPS→Local File Copy Pattern** (MANDATORY for all tracker .env operations):

When deployment scripts run on VPS via SSH but tracker client runs locally, you MUST copy VPS files to local temp files:

```bash
# Pattern used in all 4 integration points
local temp_env="/tmp/.env.{operation}.${SUBDOMAIN}.$$"
vps_exec "cat '${app_path}/.env'" > "${temp_env}"

"${tracker_client}" record-env \
    --env-file "${temp_env}" \
    --app-url "https://${full_domain}"

rm -f "${temp_env}"  # Always clean up
```

**Why This Is Required**:
- Deployment scripts use `vps_exec` to run commands ON VPS via SSH
- Tracker client (`deploy-tracker-client.sh`) runs LOCALLY on your machine
- Local script cannot access VPS file paths like `/var/www/worktrees/app/.env`
- Must stream VPS file content to local temp file, then process locally

**Variable Scope in Bash Functions**:

Always declare variables with `local` keyword at function start:

```bash
function redeploy_application() {
    local full_domain="${SUBDOMAIN}.${DOMAIN}"  # Required for .env storage
    local temp_env="/tmp/.env.redeploy.${SUBDOMAIN}.$$"
    # ... rest of function
}
```

**Bug Prevention Checklist**:
- [ ] All tracker .env operations use temp file copy pattern
- [ ] All temp files are removed after use (`rm -f "${temp_env}"`)
- [ ] All functions declare required variables at function start
- [ ] No direct VPS path access from tracker client

## Database Naming: Worktree vs Main Branch

| Deployment Type | Script | Database Pattern | Example |
|-----------------|--------|------------------|---------|
| Worktree (feature) | vps-deploy-worktree.sh | `{DB_PREFIX}_{subdomain}_testing` | `psp_p2p_preview_6_testing` |
| Main Branch | vps-deploy-main.sh | `{repo_name}_testing` | `psp_p2p_testing` |

**Key Difference**: Main branches skip `DB_PREFIX` to avoid double prefixing (e.g., `psp-p2p_psp_p2p_testing` → `psp_p2p_testing`)

## ⚠️ CRITICAL: Database Isolation (Staging vs Production)

**Problem**: Main branch deployments must preserve database isolation between staging and production environments.

**What Can Go Wrong**:
- `staging.push-parser-panel` and `push-parser-panel` using the same database ❌
- Running `resetup` on staging destroys production data ❌
- No isolation between environments ❌

**Correct Behavior** (FIXED 2026-01-02):
- `staging.push-parser-panel` → `staging_push_parser_panel_testing` ✅
- `push-parser-panel` → `push_parser_panel_testing` ✅
- Each deployment has isolated database ✅

**Verification**:
```bash
# Check database names before resetup
mysql -e "SHOW DATABASES LIKE '%push_parser%'"

# Expected output:
# staging_push_parser_panel_testing
# push_parser_panel_testing

# If both show the same name, DO NOT PROCEED - isolation is broken
```

**Prevention**:
- ✅ `get_database_name()` function preserves `staging.` prefix
- ✅ Always verify database names match expected pattern
- ✅ Never run resetup if staging and production share databases

**See**: Bootstrapping Prompt Pitfall #19 for complete details on this bug and fix.

## Recent Changes (December 2025)

- ✅ **Fail-fast dirty repo**: All VPS deployments fail if llm-rules has uncommitted changes
- ✅ **Idempotency verified**: Safe redeployment without side effects
- ✅ **Frontend build extended**: psp-p2p now builds frontend assets (like psp-landing)
- ✅ **Execution pattern clarified**: Use trunner directly (NOT sudo-runner) for SSH key preservation

## Progressive Disclosure

**References** (load only when needed):
<references>
  <reference title="VPS infrastructure" path="references/vps-infrastructure.md" description="VPS details, SSH access, database passwords, server configuration" />
  <reference title="Advanced workflows" path="references/vps-laravel-advanced-workflows.md" description="Complex deployment scenarios, multi-app setups, custom workflows" />
  <reference title="Troubleshooting" path="references/vps-laravel-troubleshooting.md" description="Common deployment errors, test failures, SSL issues, solutions" />
  <reference title="Triad architecture" path="references/triad-architecture.md" description="PSP triad structure, deployment order, URL configuration" />
  <reference title="Application architectures" path="references/vps-laravel-applications.md" description="PSP-P2P, PSP-Landing, Push Parser Panel configurations" />
  <reference title="Refactor 1: Triad URL Handling" path="/home/lkonga/codes/llm-rules/docs/refactors/refactor-1/README.md" description="Unified URL handling, breaking changes, mandatory PPP URL parameter" />
</references>
