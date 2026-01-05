# Worktree Update & Rebuild Guide

## Overview

When your application has been updated (code changes from git), you can use rebuild flags to quickly update assets and dependencies. This guide explains when to use each rebuild mode.

## ⚡ Quick Start: Rebuild Flags (Non-Destructive)

**All rebuild modes preserve database data by default!**

```bash
# Option 1: Full rebuild (DEFAULT) - composer + npm + build + caches
./scripts/setup-worktree.sh psp-p2p-merchant-preview-5 --rebuild-full

# Option 2: Frontend only - npm run build + view:clear
./scripts/setup-worktree.sh psp-p2p-merchant-preview-5 --rebuild-frontend

# Option 3: Backend only - composer install + cache clear
./scripts/setup-worktree.sh psp-p2p-merchant-preview-5 --rebuild-backend

# Option 4: Database migration only - migrate + config:clear
./scripts/setup-worktree.sh psp-p2p-merchant-preview-5 --rebuild-migrate
```

**Note**: All rebuild modes automatically skip git worktree creation, database setup, and environment configuration. They only rebuild what's necessary.

## Scenario: App Has Been Updated

### What Happens After Code Update?

When you pull latest changes or switch branches:
- ✅ **Source code** is updated (PHP, Vue.js, etc.)
- ❌ **Dependencies** may be outdated (composer.lock, package-lock.json)
- ❌ **Build assets** are outdated (public/build/, public/hot)
- ❌ **Caches** may be stale (config, routes, views)
- ✅ **Database** is unaffected (schema unchanged unless migrations run)

### When to Use Rebuild Flags

**Use rebuild flags when:**
- Code has been updated (git pull, branch switch)
- Dependencies have changed
- Assets need rebuilding
- Caches are stale
- **You want to preserve database data**

### When to Use `--resetup` (Destructive)

**Use `--resetup` ONLY when:**
- Database schema has changed significantly
- You want a complete fresh start
- Test environment (data loss acceptable)
- Database is corrupted

**What `--resetup` does:**
```bash
# 1. Validates worktree exists
# 2. Prompts for confirmation (interactive)
# 3. Drops and recreates databases ❌ DATA LOSS
# 4. Regenerates environment files
# 5. Runs composer install (reinstalls vendor/)
# 6. Runs npm install (reinstalls node_modules/)
# 7. Runs npm run build (rebuilds public/build/)
# 8. Runs migrations and seeds
# 9. Clears all caches
# 10. Reconfigures Apache/SSL
```

## Rebuild Modes Explained

### Option 1: `--rebuild-full` (Default, Non-Destructive)

**What it does:**
- ✅ Preserves database data
- ✅ Runs `composer install` (reinstalls vendor/)
- ✅ Runs `npm install` (reinstalls node_modules/)
- ✅ Runs `npm run build` (rebuilds public/build/)
- ✅ Clears all caches (config, routes, views, application)
- ❌ Skips database operations
- ❌ Skips environment configuration
- ❌ Skips git operations

**When to use:**
- After pulling latest code
- Dependencies may have changed
- You want a complete refresh without data loss
- **This is the DEFAULT when using --resetup without specifying a mode**

**Example:**
```bash
cd /home/lkonga/codes/psp-p2p
./scripts/local-sudo-runner/sudo-runner.sh --trunner \
  "./scripts/setup-worktree.sh psp-p2p-merchant-preview-5 --rebuild-full \
    --source-worktree-type psp-p2p \
    --psp-landing-worktree psp-landing-preview-5 \
    --psp-p2p-worktree psp-p2p-merchant-preview-5 \
    --ppp-worktree push-parser-panel"
```

### Option 2: `--rebuild-frontend` (Fastest, Non-Destructive)

**What it does:**
- ✅ Preserves database data
- ✅ Runs `npm run build` (rebuilds public/build/)
- ✅ Clears view cache
- ❌ Skips composer operations
- ❌ Skips npm install
- ❌ Skips database operations
- ❌ Skips environment configuration
- ❌ Skips git operations

**When to use:**
- Only frontend code changed (Vue.js components, CSS, JS)
- Quick frontend refresh needed
- Fastest rebuild option

**Example:**
```bash
cd /home/lkonga/codes/psp-p2p
./scripts/local-sudo-runner/sudo-runner.sh --trunner \
  "./scripts/setup-worktree.sh psp-p2p-merchant-preview-5 --rebuild-frontend \
    --source-worktree-type psp-p2p"
```

### Option 3: `--rebuild-backend` (Non-Destructive)

**What it does:**
- ✅ Preserves database data
- ✅ Runs `composer install` (reinstalls vendor/)
- ✅ Clears all caches (config, routes, views, application)
- ✅ Runs `composer dump-autoload`
- ❌ Skips frontend operations
- ❌ Skips database operations
- ❌ Skips environment configuration
- ❌ Skips git operations

**When to use:**
- Only backend code changed (PHP classes, controllers)
- PHP dependencies may have changed
- Backend caches need refresh

**Example:**
```bash
cd /home/lkonga/codes/psp-p2p
./scripts/local-sudo-runner/sudo-runner.sh --trunner \
  "./scripts/setup-worktree.sh psp-p2p-merchant-preview-5 --rebuild-backend \
    --source-worktree-type psp-p2p"
```

### Option 4: `--rebuild-migrate` (Non-Destructive)

**What it does:**
- ✅ Preserves existing database data (migrations are non-destructive)
- ✅ Runs `php artisan migrate --force`
- ✅ Clears config cache
- ❌ Skips composer operations
- ❌ Skips frontend operations
- ❌ Skips environment configuration
- ❌ Skips git operations

**When to use:**
- New migrations added
- Database schema needs update
- You want to preserve existing data

**Example:**
```bash
cd /home/lkonga/codes/psp-p2p
./scripts/local-sudo-runner/sudo-runner.sh --trunner \
  "./scripts/setup-worktree.sh psp-p2p-merchant-preview-5 --rebuild-migrate \
    --source-worktree-type psp-p2p"
```

## Comparison: Rebuild Modes

| Mode | Database | Composer | npm | Build | Caches | Speed | Use Case |
|------|----------|----------|-----|-------|--------|-------|----------|
| `--rebuild-full` | Preserved ✅ | ✅ | ✅ | ✅ | ✅ | Medium (2-3 min) | Complete refresh |
| `--rebuild-frontend` | Preserved ✅ | ❌ | ❌ | ✅ | View only | Fastest (30 sec) | Frontend only |
| `--rebuild-backend` | Preserved ✅ | ✅ | ❌ | ❌ | ✅ | Medium (1-2 min) | Backend only |
| `--rebuild-migrate` | Preserved ✅ | ❌ | ❌ | ❌ | Config only | Fast (1 min) | Migrations only |
| `--resetup` | **Wiped** ❌ | ✅ | ✅ | ✅ | ✅ | Slow (5-10 min) | Complete reset |

## Decision Tree

```
Has the database schema changed (new migrations)?
├─ Yes → Use --resetup (wipes data) OR manual migration (preserves data)
│  └─ php artisan migrate --force
└─ No → Continue

Have dependencies changed (composer.json, package.json)?
├─ Yes → Manual rebuild with composer install + npm install
└─ No → Continue

What type of code changed?
├─ Frontend only (Vue.js, CSS, JS) → npm run build + view:clear
├─ Backend only (PHP, routes) → config:clear + route:clear
└─ Both → Full manual rebuild
```

## Comparison: `--resetup` vs Manual Rebuild

| Aspect | `--resetup` | Manual Rebuild |
|--------|-------------|----------------|
| **Database** | Dropped and recreated ❌ | Preserved ✅ |
| **Data Loss** | Complete data loss ❌ | No data loss ✅ |
| **Dependencies** | Reinstalled ✅ | Reinstalled (if needed) ✅ |
| **Assets** | Rebuilt ✅ | Rebuilt (if needed) ✅ |
| **Caches** | Cleared ✅ | Cleared ✅ |
| **Confirmation** | Interactive prompt ❌ | No prompt (manual) |
| **Speed** | Slow (5-10 min) | Fast (1-3 min) |
| **Use Case** | Complete refresh | Quick update |

## Common Scenarios

### Scenario 1: Pulled Latest Code from Main Branch

**Situation**: You pulled latest changes from `main` branch into your worktree.

**Action**: Full manual rebuild (dependencies may have changed)

```bash
cd /home/lkonga/codes/psp-p2p/worktrees/psp-p2p-merchant-preview-5
git pull origin main
composer install
npm install
npm run build
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

### Scenario 2: Switched Branches

**Situation**: You switched from `feature-A` to `feature-B` branch.

**Action**: Full manual rebuild (different code, different dependencies)

```bash
cd /home/lkonga/codes/psp-p2p/worktrees/psp-p2p-merchant-preview-5
git checkout feature-B
composer install
npm install
npm run build
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear
```

### Scenario 3: Only Frontend Changes

**Situation**: Only Vue.js components changed, no PHP changes.

**Action**: Frontend-only rebuild

```bash
cd /home/lkonga/codes/psp-p2p/worktrees/psp-p2p-merchant-preview-5
git pull origin feature-xyz
npm run build
php artisan view:clear
```

### Scenario 4: New Migrations Added

**Situation**: New database migrations were added.

**Action**: Run migrations manually (preserves data)

```bash
cd /home/lkonga/codes/psp-p2p/worktrees/psp-p2p-merchant-preview-5
git pull origin feature-xyz
php artisan migrate --force
php artisan config:clear
```

**OR** use `--resetup` if data loss is acceptable:

```bash
cd /home/lkonga/codes/psp-p2p
./scripts/local-sudo-runner/sudo-runner.sh --trunner \
  "./scripts/setup-worktree.sh psp-p2p-merchant-preview-5 --resetup ..."
```

### Scenario 5: Dependencies Changed

**Situation**: `composer.json` or `package.json` was modified.

**Action**: Reinstall dependencies

```bash
cd /home/lkonga/codes/psp-p2p/worktrees/psp-p2p-merchant-preview-5
git pull origin feature-xyz
composer install
npm install
npm run build
php artisan clear-compiled
php artisan config:clear
```

## Quick Reference Commands

### Check What Changed

```bash
# Compare with remote
cd /home/lkonga/codes/psp-p2p/worktrees/psp-p2p-merchant-preview-5
git fetch origin
git diff HEAD origin/main --name-only | grep -E "(composer\.json|package\.json|database/migrations)"
```

### Full Rebuild Script

```bash
#!/bin/bash
# rebuild-worktree.sh - Quick rebuild without database wipe

WORKTREE_PATH="/home/lkonga/codes/psp-p2p/worktrees/psp-p2p-merchant-preview-5"
TARGET_USER="lkonga"

cd "$WORKTREE_PATH" || exit 1

echo "Updating code..."
git pull origin branch-name

echo "Reinstalling dependencies..."
sudo -u "$TARGET_USER" composer install
sudo -u "$TARGET_USER" npm install

echo "Rebuilding assets..."
sudo -u "$TARGET_USER" npm run build

echo "Clearing caches..."
sudo -u "$TARGET_USER" php artisan config:clear
sudo -u "$TARGET_USER" php artisan route:clear
sudo -u "$TARGET_USER" php artisan view:clear
sudo -u "$TARGET_USER" php artisan cache:clear
sudo -u "$TARGET_USER" php artisan clear-compiled

echo "Rebuild complete!"
```

### Verify Rebuild Success

```bash
# Check HTTP status
curl -I https://psp-p2p-merchant-preview-5.trylatest.in | grep "HTTP"

# Check Laravel version
php artisan --version

# Check database connection
php artisan db:show --env=staging

# Check cache status
php artisan cache:status
```

## Troubleshooting

### Issue: Assets Not Updating

**Symptom**: Frontend changes not visible after `npm run build`

**Solution**:
```bash
# Force clear all caches
rm -rf public/build/*
rm -rf public/hot
rm -rf storage/framework/views/*
php artisan view:clear
npm run build
```

### Issue: Dependencies Out of Sync

**Symptom**: Class not found, version conflicts

**Solution**:
```bash
# Remove and reinstall dependencies
rm -rf vendor/ composer.lock
composer install
rm -rf node_modules/ package-lock.json
npm install
```

### Issue: Migration Conflicts

**Symptom**: Migrations fail after code update

**Solution**:
```bash
# Check migration status
php artisan migrate:status --env=staging

# Run specific migration
php artisan migrate --force --env=staging

# Or rollback and rerun
php artisan migrate:rollback --env=staging
php artisan migrate --force --env=staging
```

### Issue: Permissions After Rebuild

**Symptom**: Permission denied errors

**Solution**:
```bash
# Reset permissions
sudo chown -R lkonga:www-data /home/lkonga/codes/psp-p2p/worktrees/psp-p2p-merchant-preview-5
sudo chmod -R 775 storage bootstrap/cache
```

## Best Practices

1. **Always pull before rebuilding**
   ```bash
   git pull origin branch-name
   ```

2. **Check what changed first**
   ```bash
   git diff HEAD~1 --name-only
   ```

3. **Use manual rebuild for quick updates**
   - Preserves database data
   - Faster than `--resetup`
   - More control over what gets rebuilt

4. **Use `--resetup` for complete refresh**
   - Test environment only
   - When data loss is acceptable
   - When database schema changed significantly

5. **Clear caches after any code change**
   ```bash
   php artisan config:clear
   php artisan route:clear
   php artisan view:clear
   ```

6. **Verify rebuild success**
   ```bash
   curl -I https://worktree-name.trylatest.in
   ```

## Integration with Worktree Orchestration

**After Manual Rebuild**:
- No need to redeploy tunnels
- Apache configuration unchanged
- SSL certificates unchanged
- Just restart PHP-FPM if needed:
  ```bash
  sudo systemctl restart php8.3-fpm
  ```

**After `--resetup`**:
- Tunnels already running
- Apache reconfigured automatically
- SSL regenerated automatically
- No additional steps needed

## Summary

| Scenario | Recommended Approach |
|----------|---------------------|
| Quick code update | Manual rebuild (Option 1) |
| Frontend only | Frontend rebuild (Option 2) |
| Backend only | Backend rebuild (Option 3) |
| New migrations | Manual migration (Option 4) |
| Complete refresh | `--resetup` (with confirmation) |
| Test environment | `--resetup` (data loss acceptable) |
| Production-like | Manual rebuild (preserve data) |
