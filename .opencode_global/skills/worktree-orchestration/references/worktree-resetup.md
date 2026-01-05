# Worktree Resetup Patterns

## Purpose
Repair existing worktrees without recreating Git worktree structure. Use when tunnels fail or Laravel setup needs refresh.

## ⚠️ CRITICAL WARNING: DESTRUCTIVE OPERATION

**`--resetup` is a DESTRUCTIVE operation that will:**

### ❌ COMPLETELY WIPE
- **All database data** (merchants, transactions, payments, user data)
- **Database users** (dropped and recreated with new passwords)
- **Environment files** (deleted and regenerated from templates)

### ✅ PRESERVE
- **Git worktree** (no changes to git state)
- **API credentials** (loaded from central secrets files)
- **Source code** (no modifications to files)

### 🔄 REINSTALL
- Composer dependencies (PHP packages)
- npm dependencies (frontend packages)
- Frontend assets (npm run build)
- Laravel setup (APP_KEY, caches, migrations)
- Apache configuration
- SSL certificates

## When to Use --resetup

✅ **Safe to use when:**
- Worktree is corrupted/broken
- You don't care about existing data
- You want a completely fresh start
- Test environment that should be wiped

❌ **DO NOT use when:**
- You have important data in the database
- You need to preserve merchant/transaction records
- You've made manual data changes you want to keep

## Interactive Confirmation

**`--resetup` REQUIRES interactive confirmation**:

```
⚠️  RESETUP MODE: DESTRUCTIVE OPERATION ⚠️

This will COMPLETELY WIPE:
  ✓ Database: psp-p2p_merchant_preview_5_staging (ALL DATA WILL BE LOST)
  ✓ Database: psp-p2p_merchant_preview_5_testing (ALL DATA WILL BE LOST)
  ✓ Database users: psp_p2p_merchant_preview_5_s_user, psp_p2p_merchant_preview_5_t_user
  ✓ Environment files: .env.merchant_preview_5.*

This will PRESERVE:
  ✓ Git worktree and source code
  ✓ API credentials (from central secrets files)

This will REINSTALL:
  ✓ Composer dependencies
  ✓ npm dependencies and frontend assets
  ✓ Laravel setup (migrations, seeds, caches)
  ✓ Apache configuration and SSL certificates

Type 'yes' to confirm, or anything else to cancel:
```

## How --resetup Works

1. **Validates** existing worktree directory and Git worktree
2. **Prompts** user for interactive confirmation
3. **Skips** Git worktree creation, backup, and LLM rules setup
4. **Proceeds** directly to database setup and Laravel configuration
5. **Drops and recreates** databases (unconditional)
6. **Reruns** composer install, migrations, and asset builds
7. **Fixes** permissions and Apache configuration

## Resetup vs Fresh Setup

| Operation | Fresh Setup | Resetup |
|-----------|-------------|---------|
| Git worktree creation | ✓ | ✗ (skipped) |
| Database backup | ✓ | ✗ (skipped) |
| LLM rules setup | ✓ | ✗ (skipped) |
| Database setup | ✓ | ✓ |
| Database data | Empty (seeded) | **Completely wiped** |
| Laravel dependencies | ✓ | ✓ |
| Migrations/seeds | ✓ | ✓ |
| Apache config | ✓ | ✓ |
| Permissions | ✓ | ✓ |
| Confirmation | None required | **Interactive prompt** |

## Usage Examples

### PSP-P2P Worktree Resetup
```bash
cd /home/lkonga/codes/psp-p2p && \
./scripts/local-sudo-runner/sudo-runner.sh --trunner \
  "./scripts/setup-worktree.sh psp-p2p-merchant-preview-5 --resetup \
    --source-worktree-type psp-p2p \
    --psp-landing-worktree psp-landing-preview-5 \
    --psp-p2p-worktree psp-p2p-merchant-preview-5 \
    --ppp-worktree push-parser-panel"
```

### PSP-Landing Worktree Resetup
```bash
cd /home/lkonga/codes/psp-landing && \
./scripts/local-sudo-runner/sudo-runner.sh --trunner \
  "./scripts/setup-worktree.sh psp-landing-preview-5 --resetup \
    --source-worktree-type psp-landing \
    --psp-landing-worktree psp-landing-preview-5 \
    --psp-p2p-worktree psp-p2p-merchant-preview-5 \
    --ppp-worktree push-parser-panel"
```

### Resetup with Laravel Setup
```bash
./scripts/local-sudo-runner/sudo-runner.sh --trunner \
  "./scripts/setup-worktree.sh psp-p2p-merchant-preview-5 \
    --resetup --setup-laravel \
    --source-worktree-type psp-p2p ..."
```

## Manual Database Backup (Before Resetup)

If you need to preserve database data:

```bash
# Set variables
WORKTREE_NAME="merchant-preview-5"
PROJECT_NAME="psp-p2p"
MYSQL_ROOT_PASSWORD="fhWvoT0GyNuR"

# Backup staging database
mysqldump -uroot -p${MYSQL_ROOT_PASSWORD} \
  ${PROJECT_NAME}_${WORKTREE_NAME}_staging \
  > /tmp/backup_${WORKTREE_NAME}_staging_$(date +%Y%m%d_%H%M%S).sql

# Backup testing database
mysqldump -uroot -p${MYSQL_ROOT_PASSWORD} \
  ${PROJECT_NAME}_${WORKTREE_NAME}_testing \
  > /tmp/backup_${WORKTREE_NAME}_testing_$(date +%Y%m%d_%H%M%S).sql

# Run resetup
./scripts/local-sudo-runner/sudo-runner.sh --trunner \
  "./scripts/setup-worktree.sh psp-p2p-${WORKTREE_NAME} --resetup ..."

# Restore if needed
STAGING_BACKUP=$(ls -t /tmp/backup_${WORKTREE_NAME}_staging_*.sql | head -1)
TESTING_BACKUP=$(ls -t /tmp/backup_${WORKTREE_NAME}_testing_*.sql | head -1)

mysql -uroot -p${MYSQL_ROOT_PASSWORD} \
  ${PROJECT_NAME}_${WORKTREE_NAME}_staging \
  < ${STAGING_BACKUP}

mysql -uroot -p${MYSQL_ROOT_PASSWORD} \
  ${PROJECT_NAME}_${WORKTREE_NAME}_testing \
  < ${TESTING_BACKUP}
```

## Non-Interactive Requirements

**CRITICAL**: `--resetup` requires all triad worktrees specified via parameters for non-interactive execution.

**Required Parameters**:
- `--source-worktree-type`: Which repo type (psp-p2p, psp-landing, push-parser-panel)
- `--psp-landing-worktree`: PSP-Landing worktree name
- `--psp-p2p-worktree`: PSP-P2P worktree name
- `--ppp-worktree`: Push Parser Panel worktree name

## Monitoring Resetup Progress

Use $ArchitectCoder skill to monitor via loop pattern:

```bash
# Monitor log file using approved pattern
for i in {1..15}; do
  sleep 5 && tail -15 /tmp/test_suite_output_tmux-runner-SESSIONID.log
done
```

Look for completion markers:
- "Setup completed successfully"
- "Worktree validated. Skipping Git worktree creation"
- "Proceeding with database and Laravel setup"
- "Type 'yes' to confirm" (confirmation prompt)

## Common Resetup Scenarios

### After Main Branch Redeploy
```bash
# Main branches redeployed, preview worktrees may break
# Fix with resetup:
./scripts/setup-worktree.sh WORKTREE_NAME --resetup [triad-params]
```

### HTTP 500 on Tunnel
```bash
# Tunnel returns 500 instead of 302
# Resetup fixes Laravel setup:
./scripts/setup-worktree.sh FAILING_WORKTREE --resetup [triad-params]
```

### Vendor Directory Corruption
```bash
# Composer dependencies broken
# Resetup reinstalls:
./scripts/setup-worktree.sh WORKTREE_NAME --resetup [triad-params]
```

## Validation After Resetup

```bash
# Check HTTP status
curl -I https://WORKTREE_NAME.trylatest.in | grep "HTTP"

# Should return HTTP 302 (success)
```

## Error Handling

If resetup fails validation:
```
Error: Worktree directory does not exist: /path/to/worktree
Cannot resetup a non-existent worktree. Use normal setup mode to create it.
```

This means the worktree was never created - use normal setup without `--resetup`.

## No "Safe Repair" Mode

**Currently there is NO less aggressive repair flag** that preserves database data. The `--resetup` flag is the only repair option and it always drops and recreates databases.

**Future Enhancement Needed**:
- `--repair` flag (preserves databases, only reinstalls artifacts)
- `--soft-repair` flag (preserves databases and environment files)
- `--safe-repair` flag (minimal repairs, maximum preservation)

## Integration with Other Workflows

- **$MainDeploy**: After main branch redeploy, use resetup on affected preview worktrees
- **$CFLauncher**: Start tunnels after resetup completes
- **$TmuxProtectedExecution**: Always use trunner for resetup operations
