# VPS Laravel Troubleshooting Guide

## ⚠️ CRITICAL: Common Pitfalls

### 🚨 The `staging.` Prefix Trap

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

**How to avoid this pitfall**:
1. **Always check actual VPS paths first**:
   ```bash
   ssh lkonga@37.60.247.12 "ls -1 /var/www/worktrees/ | grep preview"
   ```
2. **Never assume path names** - always verify with `ls` before deploying
3. **Remember the pattern**: `staging.<subdomain>` not just `<subdomain>`
4. **Check existing worktrees** before creating new ones

**Example verification**:
```bash
# WRONG - assumes path without staging prefix
ssh lkonga@37.60.247.12 "cd /var/www/worktrees/psp-p2p-merchant-preview-8 && git status"
# ERROR: No such file or directory

# CORRECT - uses staging prefix
ssh lkonga@37.60.247.12 "ls -1 /var/www/worktrees/ | grep preview-8"
# Output: staging.psp-p2p-merchant-preview-8

ssh lkonga@37.60.247.12 "cd /var/www/worktrees/staging.psp-p2p-merchant-preview-8 && git status"
# SUCCESS: Shows git status
```

**When this matters**:
- VPS worktree deployments (Group 2)
- Manual VPS path operations
- Git operations on VPS worktrees
- Debugging deployment failures

---

## Test Suite Failures

### Issue: Vite Build Assets Missing (Frontend Not Built)

**Symptom**: Test suite fails with "Vite manifest not found at public/build/manifest.json"

**Root Cause**: Both `psp-p2p` and `psp-landing` use Vite for frontend compilation. Test runner requires `public/build/manifest.json` if `vite.config.js` exists.

**Diagnosis**:
```bash
# Check if vite.config.js exists
ssh lkonga@37.60.247.12 "ls -la /var/www/worktrees/staging.{subdomain}/vite.config.js"

# Check if manifest.json is missing
ssh lkonga@37.60.247.12 "ls -la /var/www/worktrees/staging.{subdomain}/public/build/manifest.json"

# Check test log
ssh lkonga@37.60.247.12 "tail -50 /home/lkonga/deploy_logs/test_staging.{subdomain}_*.log"
```

**Solution**: Ensure `vps-deploy-main.sh` builds frontend assets for BOTH `psp-p2p` AND `psp-landing`:

```bash
# Verify the fix in vps-deploy-main.sh
grep -n "Build frontend assets" /home/lkonga/codes/llm-rules/scripts/vps/vps-deploy-main.sh

# Should show:
# Line ~592: if [[ "${APP_TYPE}" == "psp-landing" ]] || [[ "${APP_TYPE}" == "psp-p2p" ]]; then
# Line ~1347: if [[ "${APP_TYPE}" == "psp-landing" ]] || [[ "${APP_TYPE}" == "psp-p2p" ]]; then
```

**Manual Fix** (if deployment script not updated):
```bash
# SSH to VPS and build manually
ssh lkonga@37.60.247.12 "
  cd /var/www/worktrees/staging.{subdomain}
  sudo -u www-data npm ci
  sudo -u www-data npm run build
"
```

### Issue: Test Suite Fails During Deployment

**Symptom**: Deployment aborts at Step 5 with test failures

**Diagnosis**:
```bash
# Check test logs on VPS
ssh lkonga@37.60.247.12 "cat /tmp/vps_test_*.log"

# Check application logs
ssh lkonga@37.60.247.12 "tail -100 /var/www/worktrees/staging.{subdomain}/storage/logs/laravel.log"
```

**Common Test Failure Causes**:

1. **Database Configuration Issues**
```bash
# Verify test database exists
ssh lkonga@37.60.247.12 "mysql -uroot -p'Push@Parser2024!Secure' -e 'SHOW DATABASES LIKE \"%testing%\";'"

# Check .env.testing configuration
ssh lkonga@37.60.247.12 "cat /var/www/worktrees/staging.{subdomain}/.env.testing | grep DB_"
```

2. **Missing Dependencies**
```bash
# Check if all Composer packages installed
ssh lkonga@37.60.247.12 "cd /var/www/worktrees/staging.{subdomain} && composer check-platform-reqs"
```

3. **Environment Variable Mismatch**
```bash
# Compare .env and .env.testing
ssh lkonga@37.60.247.12 "diff /var/www/worktrees/staging.{subdomain}/.env{,.testing}"
```

**Solutions**:

Fix tests locally first, then redeploy:
```bash
# Run tests locally
php artisan test

# Fix issues in code
# Commit and push

# Redeploy
trunner "./vps-deploy-worktree.sh deploy ..."
```

## SSL Certificate Issues

### Issue: Failed to Obtain SSL Certificate

**Symptom**: "Failed to obtain SSL certificate" during deployment

**Common Causes**:
1. DNS not propagated
2. Port 80/443 blocked
3. Let's Encrypt rate limit (5 per week)
4. Existing certificate conflicts

**Diagnosis**:
```bash
# Check DNS resolution
dig staging.{subdomain}.trylatest.in +short
# Should return: 37.60.247.12

# Check port accessibility
telnet 37.60.247.12 80
telnet 37.60.247.12 443

# Check rate limit status
ssh lkonga@37.60.247.12 "sudo certbot certificates | grep -A5 {subdomain}"
```

**Solutions**:

**Wait for DNS propagation**:
```bash
# DNS propagation can take 5-10 minutes
# Check multiple DNS servers
dig @8.8.8.8 staging.{subdomain}.trylatest.in +short
dig @1.1.1.1 staging.{subdomain}.trylatest.in +short
```

**Manual SSL setup after DNS propagates**:
```bash
ssh lkonga@37.60.247.12 "sudo certbot --nginx -d staging.{subdomain}.trylatest.in"
```

**Skip SSL temporarily**:
```bash
# Deploy without SSL (HTTP only)
./vps-deploy-worktree.sh deploy --subdomain {name} --skip-ssl ...

# Add SSL later manually
```

## Database Problems

### Issue: Database Connection Fails

**Symptom**: "SQLSTATE[HY000] [1045] Access denied"

**Diagnosis**:
```bash
# Test database connection
ssh lkonga@37.60.247.12 "mysql -uroot -p'Push@Parser2024!Secure' -e 'SELECT 1;'"

# Check database exists
ssh lkonga@37.60.247.12 "mysql -uroot -p'Push@Parser2024!Secure' -e 'SHOW DATABASES;' | grep {subdomain}"
```

**Solutions**:

Verify database password in .env matches:
```bash
ssh lkonga@37.60.247.12 "
  cd /var/www/worktrees/staging.{subdomain}
  grep DB_PASSWORD .env
"
# Should be: Push@Parser2024!Secure
```

### Issue: Database Not Created

**Symptom**: "SQLSTATE[HY000] [1049] Unknown database"

**Solution**:
```bash
# Create databases manually
ssh lkonga@37.60.247.12 "
  mysql -uroot -p'Push@Parser2024!Secure' -e \"
    CREATE DATABASE IF NOT EXISTS {db_name}_staging;
    CREATE DATABASE IF NOT EXISTS {db_name}_testing;
  \"
"
```

## Nginx Configuration Issues

### Issue: 502 Bad Gateway

**Symptom**: Nginx returns 502 error

**Common Causes**:
1. PHP-FPM pool not running
2. Socket connection issues
3. Insufficient PHP-FPM workers

**Diagnosis**:
```bash
# Check PHP-FPM pool status
ssh lkonga@37.60.247.12 "sudo systemctl status php8.3-fpm"

# Check if pool exists
ssh lkonga@37.60.247.12 "sudo ls -la /etc/php/8.3/fpm/pool.d/ | grep {subdomain}"

# Check nginx error logs
ssh lkonga@37.60.247.12 "sudo tail -50 /var/log/nginx/error.log"
```

**Solutions**:

Restart PHP-FPM:
```bash
ssh lkonga@37.60.247.12 "sudo systemctl restart php8.3-fpm"
```

Verify pool configuration:
```bash
ssh lkonga@37.60.247.12 "sudo cat /etc/php/8.3/fpm/pool.d/staging.{subdomain}.conf"
```

### Issue: 404 Not Found

**Symptom**: Nginx returns 404 for all routes

**Cause**: Incorrect document root or missing index.php

**Solution**:
```bash
# Check nginx configuration
ssh lkonga@37.60.247.12 "sudo cat /etc/nginx/sites-available/staging.{subdomain}"

# Verify document root points to /public
# Should be: root /var/www/worktrees/staging.{subdomain}/public;

# Check if index.php exists
ssh lkonga@37.60.247.12 "ls -la /var/www/worktrees/staging.{subdomain}/public/index.php"
```

## Test Runner Not Found

### Issue: Centralized Test Runner Missing

**Symptom**: "Centralized test runner not found or not executable"

**Diagnosis**:
```bash
# Check if llm-rules repository exists
ssh lkonga@37.60.247.12 "ls -la /opt/llm-rules"

# Check test runner
ssh lkonga@37.60.247.12 "ls -la /opt/llm-rules/scripts/templates/run_full_test_suite.sh"
```

**Solution**:
```bash
# Re-clone llm-rules repository
ssh lkonga@37.60.247.12 "
  sudo rm -rf /opt/llm-rules
  sudo git clone -b develop git@github.com:yzgyzinc/llm-rules.git /opt/llm-rules
  sudo chmod +x /opt/llm-rules/scripts/templates/run_full_test_suite.sh
"
```

## VPS Management Scripts Missing

### Issue: Management Scripts Not Found

**Symptom**: "Script not found: /opt/scripts/{script}.sh"

**Solution**:
```bash
# Sync management scripts from local repository
cd /home/lkonga/codes/llm-rules/scripts/vps

# Copy to VPS
scp db-manager.sh dns-manager.sh nginx-manager.sh ssl-manager.sh lkonga@37.60.247.12:/tmp/

# Move to /opt/scripts/
ssh lkonga@37.60.247.12 "
  sudo mkdir -p /opt/scripts
  sudo mv /tmp/{db,dns,nginx,ssl}-manager.sh /opt/scripts/
  sudo chmod +x /opt/scripts/*.sh
"
```

## Automated Sudo Issues

### Issue: Sudo Password Prompt Interrupts Automation

**Symptom**: Deployment hangs waiting for password

**Correct Pattern**:
```bash
# Use echo with variable method
SUDO_PASS="$$$123123"
VPS_HOST="lkonga@37.60.247.12"
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'command'"
```

**Wrong Patterns (Don't Use)**:
```bash
# These don't work in this environment:
ssh lkonga@37.60.247.12 "sudo command"  # Prompts for password
ssh lkonga@37.60.247.12 "echo '\$\$\$123123' | sudo -S command"  # Escaping issues
```

### Issue: Sudo Operations Fail with Permission Denied

**Solution**:
```bash
# Verify sudo works
ssh lkonga@37.60.247.12 "echo '\$\$\$123123' | sudo -S whoami"

# Check sudoers configuration
ssh lkonga@37.60.247.12 "echo '\$\$\$123123' | sudo -S cat /etc/sudoers | grep lkonga"
```

## Deployment Stuck

### Issue: Deployment Appears Stuck

**Symptom**: Log file stops updating for >10 minutes

**Solution**:
```bash
# List tmux sessions
trunner --list

# Kill stuck session
trunner --kill {SESSION_ID}

# Clean up partial deployment
ssh lkonga@37.60.247.12 "
  # Using working sudo pattern
  SUDO_PASS='$$$123123'
  echo \"\$SUDO_PASS\" | sudo -S bash -c 'rm -rf /var/www/worktrees/staging.{subdomain}'
"

# Retry deployment
trunner "./vps-deploy-worktree.sh deploy ..."
```

## Triad Configuration Issues

### Issue: Triad URLs Not Configured

**Symptom**: Applications can't communicate

**Diagnosis**:
```bash
# Check .env files on VPS
ssh lkonga@37.60.247.12 "
  grep -E 'LANDING_APP_URL|PSP_BASE_URL|PUSH_PARSER_API_URL' \
    /var/www/worktrees/staging.psp-*/.env
"
```

**Solution**:
```bash
# Fix PSP-P2P .env
ssh lkonga@37.60.247.12 "
  cd /var/www/worktrees/staging.psp-p2p-merchant-preview-{N}
  sudo sed -i 's|LANDING_APP_URL=.*|LANDING_APP_URL=https://staging.psp-landing-preview-{N}.trylatest.in|' .env
  sudo -u www-data php artisan config:clear
"

# Fix PSP-Landing .env
ssh lkonga@37.60.247.12 "
  cd /var/www/worktrees/staging.psp-landing-preview-{N}
  sudo sed -i 's|PSP_BASE_URL=.*|PSP_BASE_URL=https://staging.psp-p2p-merchant-preview-{N}.trylatest.in|' .env
  sudo -u www-data php artisan config:clear
"
```

## Recovery Procedures

### Complete Cleanup and Redeploy

```bash
# 1. Undeploy completely
./vps-deploy-worktree.sh undeploy --subdomain staging.{subdomain} --remove-files

# 2. Verify cleanup on VPS
ssh lkonga@37.60.247.12 "
  # Check files removed
  ls /var/www/worktrees/ | grep {subdomain}

  # Check databases dropped
  mysql -uroot -p'Push@Parser2024!Secure' -e 'SHOW DATABASES;' | grep {subdomain}

  # Check nginx config removed
  ls /etc/nginx/sites-available/ | grep {subdomain}
"

# 3. Redeploy fresh
trunner "./vps-deploy-worktree.sh deploy \
  --subdomain {subdomain} \
  --repo {repo} \
  --branch {branch} \
  --app-type {type} \
  --landing-url https://staging.{landing-subdomain}.trylatest.in \
  --psp-url https://staging.{psp-subdomain}.trylatest.in \
  --ppp-url https://staging.push-parser-panel.trylatest.in"
```

### Manual Recovery Steps

```bash
# If automated undeploy fails, manual cleanup:
ssh lkonga@37.60.247.12 "
  # Remove application files
  sudo rm -rf /var/www/worktrees/staging.{subdomain}

  # Drop databases
  mysql -uroot -p'Push@Parser2024!Secure' -e \"
    DROP DATABASE IF EXISTS {db_name}_staging;
    DROP DATABASE IF EXISTS {db_name}_testing;
  \"

  # Remove nginx config
  sudo rm /etc/nginx/sites-enabled/staging.{subdomain}
  sudo rm /etc/nginx/sites-available/staging.{subdomain}

  # Remove PHP-FPM pool
  sudo rm /etc/php/8.3/fpm/pool.d/staging.{subdomain}.conf

  # Remove DNS CNAME (via Cloudflare API or dashboard)

  # Remove SSL certificate
  sudo certbot delete --cert-name staging.{subdomain}.trylatest.in

  # Restart services
  sudo systemctl reload nginx
  sudo systemctl restart php8.3-fpm
"
```

## Prevention Best Practices

**Before Deployment**:
- Ensure branch is pushed to origin
- Run tests locally first
- Verify disk space on VPS
- Check DNS records are ready

**During Deployment**:
- Use `trunner` for all deployments
- Monitor via log files
- Don't interrupt sessions
- Keep terminal open until completion

**After Deployment**:
- Verify HTTP status (200 or 302)
- Check SSL certificate
- Test triad interconnection
- Monitor application logs

**Regular Maintenance**:
- Clean up old deployments
- Monitor disk usage
- Rotate logs
- Update SSL certificates before expiry
- Keep management scripts updated
