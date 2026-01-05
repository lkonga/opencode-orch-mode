# Main Deploy Troubleshooting

## Common Issues and Solutions

### Issue: Vendor Creation Failure
**Symptom**: "vendor does not exist and could not be created"

**Root Cause**: Permissions set AFTER composer tries to create vendor/

**Solution**: Implemented surgical pre-flight checks in deploy-main.sh
```bash
# Pre-flight creates vendor/ with correct ownership BEFORE composer
mkdir -p vendor
chown "$TARGET_USER:www-data" vendor
chmod 775 vendor
```

**Fixed in**: deploy-main.sh (surgical pre-flight section)

### Issue: Tests Fail After Deployment
**Symptom**: Deployment completes but tests fail

**Possible Causes**:
1. Database migrations incomplete
2. Environment variables incorrect
3. Dependencies out of sync
4. Cache corruption

**Solution**:
```bash
# Re-run deployment
cd /home/lkonga/codes/{PROJECT} && \
./scripts/local-sudo-runner/sudo-runner.sh --trunner "./scripts/deploy-main.sh"
```

### Issue: HTTP 500 on Main Branch
**Symptom**: https://psp-p2p.trylatest.in returns 500

**Diagnostic Steps**:
1. Check Laravel logs: `tail -50 storage/logs/laravel.log`
2. Check Apache logs: `sudo tail -50 /var/log/apache2/psp-p2p-staging-error.log`
3. Verify APP_KEY exists: `grep APP_KEY .env.psp-p2p.staging`
4. Check database connection: `php artisan migrate:status --env=staging`

**Solution**:
```bash
# Redeploy fixes most issues
./scripts/deploy-main.sh
```

### Issue: Preview Worktrees Break After Main Deploy
**Symptom**: Preview worktrees return 500 after main branch redeploy

**Root Cause**: Main branch updated dependencies or migrations that preview worktrees need

**Solution**: Use `--resetup` flag on affected worktrees
```bash
cd /home/lkonga/codes/psp-p2p && \
./scripts/local-sudo-runner/sudo-runner.sh --trunner \
  "./scripts/setup-worktree.sh psp-p2p-merchant-preview-5 --resetup \
    --source-worktree-type psp-p2p \
    --psp-landing-worktree psp-landing-preview-5 \
    --psp-p2p-worktree psp-p2p-merchant-preview-5 \
    --ppp-worktree push-parser-panel"
```

### Issue: Cloudflare Tunnel Not Starting
**Symptom**: Tunnel configured but not accessible

**Root Cause**: deploy-main.sh only configures tunnels, doesn't start them

**Solution**: Use $CFLauncher to start tunnels
```bash
cd /home/lkonga/codes/llm-rules && \
./scripts/cf-launcher.sh --config psp-p2p,psp-landing,push-parser-panel
```

### Issue: Permission Denied Errors
**Symptom**: "Permission denied" during deployment

**Solution**: Ensure using sudo-runner wrapper
```bash
# WRONG (causes permission errors)
./scripts/deploy-main.sh

# CORRECT (automated sudo)
./scripts/local-sudo-runner/sudo-runner.sh --trunner "./scripts/deploy-main.sh"
```

### Issue: Git Pollution After Deploy
**Symptom**: 984 files tracked as changes after deploy

**Root Cause**: Broad permission changes affecting tracked files

**Solution**: deploy-main.sh uses surgical pre-flight checks (only vendor, node_modules, storage)
```bash
# Verify surgical approach (should affect 0 tracked files)
git status --porcelain | wc -l  # Should be 0
```

### Issue: Database Already Exists Error
**Symptom**: "Database already exists" during deployment

**This is NORMAL for redeployments**:
- Script detects existing database
- Reuses database (preserves data)
- Runs migrations (safe)
- Continues deployment

**No action needed** - this is expected behavior.

### Issue: Tmux Session Still Running
**Symptom**: Need to check if deployment finished

**Solution**: Check tmux sessions
```bash
tmux list-sessions | grep tmux-runner

# If session exists, deployment still running
# Monitor log:
tail -f /tmp/test_suite_output_tmux-runner-SESSIONID.log
```

## Emergency Recovery

### Full Reset (Last Resort)
```bash
# 1. Stop all tunnels
./scripts/cf-launcher.sh --kill

# 2. Kill hanging tmux sessions
./scripts/tmux-runner/trunner.sh --kill-all

# 3. Fresh deploy
cd /home/lkonga/codes/{PROJECT} && \
./scripts/local-sudo-runner/sudo-runner.sh --trunner "./scripts/deploy-main.sh"

# 4. Restart tunnels
./scripts/cf-launcher.sh --config psp-p2p,psp-landing,push-parser-panel
```

## Impact Analysis: Main Deploy → Preview Worktrees

### When Main Deploy Affects Previews

| Main Deploy Change | Preview Impact | Fix Required |
|-------------------|----------------|--------------|
| Composer dependency update | High | --resetup |
| New migration | High | --resetup |
| .env variable added | Medium | --resetup |
| Code changes only | Low | None |
| Asset build changes | Medium | --resetup |

### Systematic Preview Fix After Main Deploy

```bash
# Fix all affected preview worktrees
for N in 2 3 4 5 6; do
  echo "Fixing preview-$N..."

  # PSP-P2P
  cd /home/lkonga/codes/psp-p2p && \
  ./scripts/setup-worktree.sh psp-p2p-merchant-preview-$N --resetup \
    --source-worktree-type psp-p2p \
    --psp-landing-worktree psp-landing-preview-$N \
    --psp-p2p-worktree psp-p2p-merchant-preview-$N \
    --ppp-worktree push-parser-panel

  # PSP-Landing
  cd /home/lkonga/codes/psp-landing && \
  ./scripts/setup-worktree.sh psp-landing-preview-$N --resetup \
    --source-worktree-type psp-landing \
    --psp-landing-worktree psp-landing-preview-$N \
    --psp-p2p-worktree psp-p2p-merchant-preview-$N \
    --ppp-worktree push-parser-panel
done
```

## Preventive Measures

1. **Always use trunner**: Prevents interruption during deployment
2. **Monitor logs**: Use $ArchitectCoder loop pattern
3. **Verify tunnels**: Check HTTP status after deploy
4. **Document changes**: Note dependency updates for preview worktree awareness
5. **Test before main deploy**: Run tests locally before deploying to main

## Rollback Strategy

Deploy-main.sh does NOT have built-in rollback. For rollback:

```bash
# 1. Git reset to previous commit
git reset --hard PREVIOUS_COMMIT_HASH

# 2. Redeploy
./scripts/deploy-main.sh

# Note: Database migrations are NOT rolled back
# Handle schema changes manually if needed
```
