# Worktree Orchestration Troubleshooting

## Common Issues and Solutions

### Issue: Setup Appears Stuck

**Symptom**: `trunner` session created but no progress for >5 minutes

**Diagnosis**:
```bash
# Check if session exists
./tmux-runner.sh --list

# Check log file
tail -50 /tmp/test_suite_output_tmux-runner-*.log

# Attach to session to see real-time status
tmux attach -t tmux-runner-{SESSION_ID}
```

**Possible Causes**:
1. Waiting for user input (password, confirmation)
2. Package installation taking long time
3. Network connectivity issues
4. Disk space exhausted

**Solutions**:

**If waiting for password**:
```bash
# The script should handle sudo automatically
# If you see password prompt, detach and check script
# Press Ctrl+b then d to detach

# Check if setup-worktree-with-pass.sh is used
ls -la scripts/setup-worktree-with-pass.sh
```

**If package installation slow**:
```bash
# Wait longer (composer install can take 3-5 minutes)
# Monitor progress
watch -n 10 'tail -20 /tmp/test_suite_output_tmux-runner-*.log'
```

**If disk space issue**:
```bash
# Check disk space
df -h

# Clean up if needed
sudo apt clean
docker system prune -af
```

### Issue: Database Creation Fails

**Symptom**: Setup fails with database-related errors

**Error Messages**:
- "Access denied for user"
- "Can't connect to MySQL server"
- "Database already exists"

**Diagnosis**:
```bash
# Check MySQL service
systemctl status mysql

# Test database connection
mysql -uroot -p'$$$123123' -e "SHOW DATABASES;"

# Check if database already exists
mysql -uroot -p'$$$123123' -e "SHOW DATABASES LIKE '%preview%';"
```

**Solutions**:

**If MySQL not running**:
```bash
# Start MySQL
sudo systemctl start mysql

# Enable on boot
sudo systemctl enable mysql
```

**If database already exists**:
```bash
# Drop existing databases
mysql -uroot -p'$$$123123' -e "DROP DATABASE IF EXISTS psp_p2p_merchant_preview_3_staging;"
mysql -uroot -p'$$$123123' -e "DROP DATABASE IF EXISTS psp_p2p_merchant_preview_3_testing;"

# Retry setup
trunner "./scripts/setup-worktree-with-pass.sh ..."
```

**If password incorrect**:
```bash
# Verify root password
mysql -uroot -p'$$$123123' -e "SELECT 1;"

# If fails, reset password (careful!)
# sudo mysql
# ALTER USER 'root'@'localhost' IDENTIFIED BY '$$$123123';
```

### Issue: Worktree Already Exists

**Symptom**: "fatal: 'worktrees/name' already exists"

**Diagnosis**:
```bash
# Check if worktree directory exists
ls -la worktrees/psp-p2p-merchant-preview-3

# Check git worktree list
git worktree list
```

**Solutions**:

**Complete cleanup and recreate**:
```bash
# Use teardown with cleanup
sudo ./scripts/deploy-worktree.sh psp-p2p-merchant-preview-3 --teardown --cleanup

# Verify removed
ls worktrees/ | grep preview-3  # Should return nothing
git worktree list | grep preview-3  # Should return nothing

# Recreate
trunner "./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-3 ..."
```

**Manual cleanup if script fails**:
```bash
# Remove worktree from git
git worktree remove worktrees/psp-p2p-merchant-preview-3 --force

# Prune references
git worktree prune

# Remove directory
sudo rm -rf worktrees/psp-p2p-merchant-preview-3

# Drop databases
mysql -uroot -p'$$$123123' -e "DROP DATABASE IF EXISTS psp_p2p_merchant_preview_3_staging;"
mysql -uroot -p'$$$123123' -e "DROP DATABASE IF EXISTS psp_p2p_merchant_preview_3_testing;"

# Remove branch
git branch -D psp-p2p-merchant-preview-3

# Now recreate
trunner "./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-3 ..."
```

### Issue: Tunnel Configuration Fails

**Symptom**: Deployment script reports tunnel configuration errors

**Diagnosis**:
```bash
# Check if Cloudflare config directory exists
ls -la ~/.cloudflared/psp-p2p/

# Check tunnel configurations
ls ~/.cloudflared/psp-p2p/config-*.yml

# Verify cloudflared installed
which cloudflared
cloudflared --version
```

**Solutions**:

**If cloudflared not installed**:
```bash
# Install cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Verify
cloudflared --version
```

**If config directory missing**:
```bash
# Create config directory
mkdir -p ~/.cloudflared/psp-p2p/

# Create template config
cat > ~/.cloudflared/psp-p2p/config-template.yml << 'EOF'
tunnel: YOUR_TUNNEL_ID
credentials-file: /path/to/credentials.json

ingress:
  - hostname: example.trylatest.in
    service: http://localhost:8080
  - service: http_status:404
EOF
```

**If tunnel not authenticated**:
```bash
# Authenticate cloudflared
cloudflared tunnel login

# Create tunnel
cloudflared tunnel create my-tunnel

# Configure tunnel
cloudflared tunnel route dns my-tunnel example.trylatest.in
```

### Issue: Paired Worktree Names Mismatch

**Symptom**: Triad configuration fails, URLs don't match

**Diagnosis**:
```bash
# Check .env files in all worktrees
for wt in worktrees/*-preview-3*; do
  echo "=== $wt ==="
  grep -E "PSP_BASE_URL|LANDING_APP_URL|PUSH_PARSER_API_URL" "$wt/.env" || echo "Not found"
  echo ""
done
```

**Possible Causes**:
1. Mismatched preview numbers
2. Wrong worktree names in flags
3. Typos in configuration

**Solutions**:

**Verify triad configuration**:
```bash
# PSP-P2P should have:
# LANDING_APP_URL=https://staging.psp-landing-preview-3.trylatest.in

# PSP-Landing should have:
# PSP_BASE_URL=https://staging.psp-p2p-merchant-preview-3.trylatest.in

# Both should have:
# PUSH_PARSER_API_URL=https://push-parser-panel.trylatest.in
```

**Fix manually if needed**:
```bash
# Edit .env files directly
nano worktrees/psp-p2p-merchant-preview-3/.env
nano worktrees/psp-landing-preview-3/.env

# Or recreate worktrees with correct flags
```

### Issue: Permission Denied Errors

**Symptom**: "Permission denied" when accessing worktree files

**Diagnosis**:
```bash
# Check ownership
ls -la worktrees/psp-p2p-merchant-preview-3/

# Check current user
whoami

# Check file permissions
ls -la worktrees/psp-p2p-merchant-preview-3/storage/
```

**Solutions**:

**Fix ownership**:
```bash
# Set correct ownership
sudo chown -R $USER:$USER worktrees/psp-p2p-merchant-preview-3

# For web server
sudo chown -R www-data:www-data worktrees/psp-p2p-merchant-preview-3/storage
sudo chown -R www-data:www-data worktrees/psp-p2p-merchant-preview-3/bootstrap/cache
```

**Fix permissions**:
```bash
# Set Laravel permissions
cd worktrees/psp-p2p-merchant-preview-3
chmod -R 755 .
chmod -R 775 storage bootstrap/cache
```

### Issue: Composer Install Fails

**Symptom**: Setup fails during composer install

**Error Messages**:
- "Your requirements could not be resolved"
- "Package not found"
- "Out of memory"

**Diagnosis**:
```bash
# Check composer version
composer --version

# Check PHP version
php --version

# Check available memory
free -h
```

**Solutions**:

**If memory issue**:
```bash
# Increase memory limit temporarily
COMPOSER_MEMORY_LIMIT=-1 composer install

# Or in setup script, this should be automatic
```

**If package not found**:
```bash
# Update composer
composer self-update

# Clear cache
composer clear-cache

# Retry
composer install
```

**If dependency conflicts**:
```bash
# Check composer.json for version constraints
cat composer.json | jq '.require'

# Try updating
composer update

# Or reset composer.lock
rm composer.lock
composer install
```

### Issue: Source Branch Doesn't Exist

**Symptom**: "fatal: invalid reference: source-branch-name"

**Diagnosis**:
```bash
# Check if branch exists locally
git branch -a | grep source-branch-name

# Check if branch exists remotely
git ls-remote --heads origin | grep source-branch-name
```

**Solutions**:

**If branch exists remotely but not locally**:
```bash
# Fetch branch
git fetch origin source-branch-name

# Create local tracking branch
git checkout -b source-branch-name origin/source-branch-name
```

**If branch doesn't exist**:
```bash
# Create branch from develop
git checkout -b source-branch-name develop

# Push to remote
git push -u origin source-branch-name

# Then create worktree
```

### Issue: API Timeout During Tests

**Symptom**: Setup fails with timeout errors during Laravel testing

**Important**: This is now handled automatically by API timeout middleware

**Diagnosis**:
```bash
# Check middleware configuration
grep -A5 "runningInConsole" worktrees/psp-p2p-merchant-preview-3/app/Http/Middleware/ApiTimeoutMiddleware.php

# Verify timeout config
grep "testing_timeout" worktrees/psp-p2p-merchant-preview-3/config/timeouts.php
```

**What Should Happen Automatically**:
- CLI/test detection via `app()->runningInConsole()`
- 60s timeout for tests (provides 62% safety margin over 35s baseline)
- 30s timeout for web requests (production-safe)
- No environment variables needed

**If Still Experiencing Timeouts**:
```bash
# Check if middleware is registered
grep "ApiTimeoutMiddleware" worktrees/psp-p2p-merchant-preview-3/app/Http/Kernel.php

# Verify middleware is in correct middleware group
cat worktrees/psp-p2p-merchant-preview-3/app/Http/Kernel.php | grep -A10 "protected \$middlewareGroups"
```

**Manual Verification**:
```bash
# Run tests manually to confirm timeout handling
cd worktrees/psp-p2p-merchant-preview-3
php artisan test --filter=TimeoutTest
```

## Verification Checklist After Setup

```bash
#!/bin/bash
# verify-worktree.sh

WORKTREE="$1"

echo "Verifying worktree: $WORKTREE"
echo ""

# Check 1: Directory exists
if [ -d "worktrees/$WORKTREE" ]; then
  echo "✓ Worktree directory exists"
else
  echo "✗ Worktree directory missing"
  exit 1
fi

# Check 2: Git worktree registered
if git worktree list | grep -q "$WORKTREE"; then
  echo "✓ Git worktree registered"
else
  echo "✗ Git worktree not registered"
fi

# Check 3: .env files exist
if [ -f "worktrees/$WORKTREE/.env" ] && [ -f "worktrees/$WORKTREE/.env.testing" ]; then
  echo "✓ Environment files exist"
else
  echo "✗ Environment files missing"
fi

# Check 4: Databases created
DB_STAGING="${WORKTREE//-/_}_staging"
DB_TESTING="${WORKTREE//-/_}_testing"

if mysql -uroot -p'$$$123123' -e "USE $DB_STAGING;" 2>/dev/null; then
  echo "✓ Staging database exists"
else
  echo "✗ Staging database missing"
fi

if mysql -uroot -p'$$$123123' -e "USE $DB_TESTING;" 2>/dev/null; then
  echo "✓ Testing database exists"
else
  echo "✗ Testing database missing"
fi

# Check 5: Vendor directory
if [ -d "worktrees/$WORKTREE/vendor" ]; then
  echo "✓ Composer dependencies installed"
else
  echo "✗ Vendor directory missing"
fi

# Check 6: Tunnel configuration
if [ -f "$HOME/.cloudflared/psp-p2p/config-$WORKTREE.yml" ]; then
  echo "✓ Tunnel configuration exists"
else
  echo "✗ Tunnel configuration missing"
fi

# Check 7: Triad URLs in .env
cd "worktrees/$WORKTREE"
if grep -q "LANDING_APP_URL" .env && grep -q "PUSH_PARSER_API_URL" .env; then
  echo "✓ Triad URLs configured"
else
  echo "✗ Triad URLs missing"
fi

echo ""
echo "Verification complete!"
```

## Recovery Procedures

### Complete Worktree Recovery

```bash
#!/bin/bash
# recover-worktree.sh

WORKTREE="$1"

echo "Recovering worktree: $WORKTREE"

# Step 1: Clean up existing
echo "1. Cleaning up existing worktree..."
sudo ./scripts/deploy-worktree.sh "$WORKTREE" --teardown --cleanup 2>/dev/null
git worktree remove "worktrees/$WORKTREE" --force 2>/dev/null
git worktree prune
sudo rm -rf "worktrees/$WORKTREE"

# Step 2: Drop databases
echo "2. Dropping databases..."
DB_NAME="${WORKTREE//-/_}"
mysql -uroot -p'$$$123123' -e "DROP DATABASE IF EXISTS ${DB_NAME}_staging;" 2>/dev/null
mysql -uroot -p'$$$123123' -e "DROP DATABASE IF EXISTS ${DB_NAME}_testing;" 2>/dev/null

# Step 3: Remove branch
echo "3. Removing branch..."
git branch -D "$WORKTREE" 2>/dev/null

# Step 4: Recreate
echo "4. Recreating worktree..."
trunner "./scripts/setup-worktree-with-pass.sh $WORKTREE \
  --setup-laravel \
  --source-worktree-type psp-p2p \
  --source-branch develop"

echo "5. Monitor progress:"
echo "   tail -f /tmp/test_suite_output_tmux-runner-*.log"
```

## Best Practices for Troubleshooting

**Preventive Measures**:
- Always verify disk space before creating worktrees
- Check MySQL service is running
- Ensure source branches are pushed to origin
- Use descriptive, consistent naming patterns
- Document custom configurations

**Diagnostic Workflow**:
1. Check tmux session status
2. Review log files
3. Verify database connectivity
4. Check file permissions
5. Validate git worktree references
6. Test tunnel configurations

**When to Use Manual Cleanup**:
- Automated cleanup fails
- Partial worktree creation (incomplete state)
- Git worktree corruption
- Database connection issues during teardown

**When to Use Complete Recovery**:
- Multiple failed creation attempts
- Unknown worktree state
- Testing cleanup procedures
- Switching from manual to automated setup
