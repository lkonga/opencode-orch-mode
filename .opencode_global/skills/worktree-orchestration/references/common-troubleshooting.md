# Common Troubleshooting Reference

This document provides shared solutions for common issues across deployment workflows.

## SSH Connection Issues

### SSH Key Authentication

**Problem**: Prompted for password when connecting to VPS

**Solution**:
```bash
# Test SSH connection
ssh lkonga@37.60.247.12 "whoami"

# If prompted for password, set up SSH key:
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy key to VPS
ssh-copy-id lkonga@37.60.247.12

# Test again (should not prompt)
ssh lkonga@37.60.247.12 "whoami"
```

### Permission Denied (publickey)

**Problem**: SSH fails with "Permission denied (publickey)"

**Solution**:
```bash
# Check if private key exists
ls -la ~/.ssh/id_*

# Verify key permissions
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# Add key to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Retry connection
ssh lkonga@37.60.247.12
```

## DNS Propagation

### DNS Not Resolving

**Problem**: New subdomain doesn't resolve to VPS IP

**Check DNS Resolution**:
```bash
# Check if DNS has propagated
dig staging.{subdomain}.trylatest.in +short

# Expected output: 37.60.247.12

# If no output, DNS hasn't propagated yet
# Wait 1-5 minutes and retry
```

**Force DNS Refresh**:
```bash
# Clear local DNS cache (Linux)
sudo systemd-resolve --flush-caches

# Clear local DNS cache (macOS)
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

### DNS Propagation Taking Too Long

**Problem**: DNS not propagating after 5+ minutes

**Solution**:
```bash
# Verify CNAME record exists on Cloudflare
ssh lkonga@37.60.247.12 "cat /tmp/dns-creation.log"

# Manual CNAME check via Cloudflare API
# (requires API token)

# Alternative: Use different DNS server for testing
dig @8.8.8.8 staging.{subdomain}.trylatest.in +short
```

## SSL Certificate Issues

### Certificate Request Fails

**Problem**: "Failed to obtain SSL certificate"

**Common Causes & Solutions**:

1. **DNS Not Propagated**
   ```bash
   # Wait for DNS, then retry SSL
   dig staging.{subdomain}.trylatest.in +short
   ssh lkonga@37.60.247.12 "sudo certbot --nginx -d staging.{subdomain}.trylatest.in"
   ```

2. **Let's Encrypt Rate Limit**
   ```bash
   # Check certificate count (max 5 per week)
   ssh lkonga@37.60.247.12 "sudo certbot certificates | grep 'Domains:' | wc -l"

   # If at limit, use existing certificate or wait
   ```

3. **Port 80/443 Not Accessible**
   ```bash
   # Check firewall rules
   ssh lkonga@37.60.247.12 "sudo ufw status"

   # Check Nginx is listening
   ssh lkonga@37.60.247.12 "sudo netstat -tulpn | grep ':80\|:443'"
   ```

### Certificate Expired

**Problem**: SSL certificate has expired

**Solution**:
```bash
# Check certificate expiration
curl -vI https://staging.{subdomain}.trylatest.in 2>&1 | grep "expire"

# Renew certificate manually
ssh lkonga@37.60.247.12 "sudo certbot renew"

# Test auto-renewal
ssh lkonga@37.60.247.12 "sudo certbot renew --dry-run"
```

### Certificate Rate Limit Exceeded

**Problem**: "too many certificates already issued for: trylatest.in"

**Solutions**:
```bash
# Option 1: Wait (resets weekly)
# Let's Encrypt allows 5 certificates per week per domain

# Option 2: Use --skip-ssl for non-production deployments
./deploy-vps.sh {name} --skip-ssl

# Option 3: Use Cloudflare tunnel for local dev (no Let's Encrypt needed)
sudo ./deploy-local.sh {name}
./scripts/cf-launcher.sh --config {name}
```

## Database Connection Issues

### Can't Connect to Database

**Problem**: Application can't connect to database

**Check Database Access**:
```bash
# Test root access
ssh lkonga@37.60.247.12 "mysql -u root -p'Push@Parser2024\!Secure' -e 'SHOW DATABASES;'"

# Check if database exists
ssh lkonga@37.60.247.12 "mysql -u root -p'Push@Parser2024\!Secure' -e 'SHOW DATABASES LIKE \"%{name}%\";'"

# Check database user permissions
ssh lkonga@37.60.247.12 "mysql -u root -p'Push@Parser2024\!Secure' -e 'SELECT user, host FROM mysql.user;'"
```

### Database Creation Fails

**Problem**: "ERROR 1007: Can't create database '{name}'; database exists"

**Solution**:
```bash
# Drop existing database (CAREFUL!)
SUDO_PASS="$$$123123"
VPS_HOST="lkonga@37.60.247.12"
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'mysql -u root -pPush@Parser2024!Secure -e \"DROP DATABASE IF EXISTS {name}_staging;\"'"

# Recreate database
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'mysql -u root -pPush@Parser2024!Secure -e \"CREATE DATABASE {name}_staging;\"'"
```

### Database Password Wrong

**Problem**: Access denied for user 'root'@'localhost'

**Solution**:
```bash
# Verify password is correct: Push@Parser2024!Secure
# Note the exclamation mark and casing

# Reset root password if needed (DANGEROUS!)
ssh lkonga@37.60.247.12 "sudo mysql -e \"ALTER USER 'root'@'localhost' IDENTIFIED BY 'Push@Parser2024!Secure';\""
```

## File Permission Issues

### Permission Denied Errors

**Problem**: Web server can't read/write application files

**Fix File Permissions**:
```bash
SUDO_PASS="$$$123123"
VPS_HOST="lkonga@37.60.247.12"

# Fix ownership for web files
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'chown -R www-data:www-data /var/www/worktrees/{name}'"

# Fix directory permissions
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'chmod -R 755 /var/www/worktrees/{name}'"

# Fix storage permissions (Laravel)
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'chmod -R 775 /var/www/worktrees/{name}/storage'"
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'chmod -R 775 /var/www/worktrees/{name}/bootstrap/cache'"
```

### Can't Write to Log Files

**Problem**: Laravel can't write to storage/logs/

**Solution**:
```bash
SUDO_PASS="$$$123123"
VPS_HOST="lkonga@37.60.247.12"

# Ensure storage directories exist
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'mkdir -p /var/www/worktrees/{name}/storage/logs'"
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'mkdir -p /var/www/worktrees/{name}/storage/framework/sessions'"
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'mkdir -p /var/www/worktrees/{name}/storage/framework/views'"

# Fix permissions
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'chown -R www-data:www-data /var/www/worktrees/{name}/storage'"
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'chmod -R 775 /var/www/worktrees/{name}/storage'"
```

## Service Management

### Nginx Not Responding

**Problem**: Website shows "502 Bad Gateway" or doesn't load

**Check Nginx Status**:
```bash
SUDO_PASS="$$$123123"
VPS_HOST="lkonga@37.60.247.12"

# Check if Nginx is running
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'systemctl status nginx'"

# Restart Nginx
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'systemctl restart nginx'"

# Check for configuration errors
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'nginx -t'"
```

### PHP-FPM Pool Not Running

**Problem**: Nginx shows "502 Bad Gateway" for PHP sites

**Check PHP-FPM Status**:
```bash
SUDO_PASS="$$$123123"
VPS_HOST="lkonga@37.60.247.12"

# Check PHP-FPM status
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'systemctl status php8.3-fpm'"

# Check if pool exists
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'ls -la /etc/php/8.3/fpm/pool.d/ | grep {name}'"

# Restart PHP-FPM
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'systemctl restart php8.3-fpm'"
```

### Service Restart Fails

**Problem**: Service won't restart or shows errors

**Diagnose and Fix**:
```bash
SUDO_PASS="$$$123123"
VPS_HOST="lkonga@37.60.247.12"

# Check service logs
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'journalctl -u nginx -n 50'"
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'journalctl -u php8.3-fpm -n 50'"

# Check for configuration errors
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'nginx -t'"
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'php-fpm8.3 -t'"

# Fix configuration and retry
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'systemctl restart nginx php8.3-fpm'"
```

## Cloudflare Tunnel Issues

### Tunnel Not Working

**Problem**: Can't access local site via Cloudflare tunnel URL

**Check Tunnel Status**:
```bash
# Check if tunnel is running
./scripts/cf-launcher.sh status

# Look for specific tunnel
./scripts/cf-launcher.sh status | grep {name}

# Check tunnel logs
tmux attach -t cf-launcher
# (Ctrl+B, D to detach)
```

**Restart Tunnel**:
```bash
# Kill stuck tunnel
./scripts/cf-launcher.sh --kill-config {name}

# Restart tunnel
./scripts/cf-launcher.sh --config {name}

# Verify tunnel is running
./scripts/cf-launcher.sh status
```

### Tunnel Configuration Not Found

**Problem**: "Configuration file not found"

**Solution**:
```bash
# Check if configuration exists
ls -la ~/.cloudflared/psp-p2p/config-{name}.yml

# Create configuration if missing
# (See CF Launcher skill for configuration template)

# Verify configuration syntax
cloudflared tunnel info {tunnel-id}
```

### Multiple Tunnels Conflicting

**Problem**: New tunnel won't start, port already in use

**Solution**:
```bash
# List all running tunnels
./scripts/cf-launcher.sh status

# Kill all tunnels
./scripts/cf-launcher.sh --kill

# Check for stuck processes
ps aux | grep cloudflared

# Kill stuck processes
sudo killall cloudflared

# Restart needed tunnels
./scripts/cf-launcher.sh --config {name}
```

## Git Repository Issues

### Repository Not Found

**Problem**: "fatal: repository '{url}' not found"

**Check and Fix**:
```bash
# Verify repository URL
git remote get-url origin

# Update URL if wrong
git remote set-url origin git@github.com:user/repo.git

# Test SSH to GitHub
ssh -T git@github.com
```

### Branch Doesn't Exist

**Problem**: "fatal: couldn't find remote ref {branch}"

**Solution**:
```bash
# List all branches
git branch -a

# Create branch if missing
git checkout -b {branch-name}

# Push branch to remote
git push -u origin {branch-name}

# Verify branch exists remotely
git ls-remote --heads origin | grep {branch-name}
```

### Can't Push to Remote

**Problem**: "Permission denied (publickey)" when pushing

**Solution**:
```bash
# Check SSH key is added to GitHub
ssh -T git@github.com

# Add SSH key to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Verify SSH key is on GitHub
# Go to: https://github.com/settings/keys

# Retry push
git push origin {branch}
```

## Build and Deployment Issues

### Build Fails on VPS

**Problem**: npm/composer install fails during deployment

**Check Node.js/PHP Version**:
```bash
# Check versions on VPS
ssh lkonga@37.60.247.12 "node --version"
ssh lkonga@37.60.247.12 "php --version"
ssh lkonga@37.60.247.12 "composer --version"

# Test build locally first
npm install && npm run build
composer install --no-dev
```

### Out of Memory During Build

**Problem**: Build process killed due to memory

**Solution**:
```bash
# Check VPS memory
ssh lkonga@37.60.247.12 "free -m"

# Increase Node.js memory limit for build
NODE_OPTIONS=--max_old_space_size=4096 npm run build

# Or use local build + deploy
npm run build
rsync -avz dist/ lkonga@37.60.247.12:/var/www/worktrees/{name}/
```

### Dependencies Not Installing

**Problem**: Composer/npm fails to install dependencies

**Solution**:
```bash
# Clear caches
composer clear-cache
npm cache clean --force

# Delete lock files and retry
rm -f composer.lock package-lock.json
composer install
npm install

# Check for version conflicts
composer why-not php 8.3
npm outdated
```

## Quick Reference Commands

### VPS Health Check
```bash
SUDO_PASS="$$$123123"
VPS_HOST="lkonga@37.60.247.12"

# Services
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'systemctl status nginx php8.3-fpm mysql'"

# Disk space
ssh lkonga@37.60.247.12 "df -h"

# Memory
ssh lkonga@37.60.247.12 "free -m"

# Load average
ssh lkonga@37.60.247.12 "uptime"
```

### Deployment Health Check
```bash
# Check application is accessible
curl -I https://staging.{subdomain}.trylatest.in

# Check SSL certificate
curl -vI https://staging.{subdomain}.trylatest.in 2>&1 | grep "expire"

# Check DNS
dig staging.{subdomain}.trylatest.in +short

# Check database
ssh lkonga@37.60.247.12 "mysql -u root -p'Push@Parser2024\!Secure' -e 'SHOW DATABASES LIKE \"%{name}%\";'"
```

## Related Documentation

**VPS Infrastructure**: See `vps-infrastructure.md` for detailed VPS information
**Automated Sudo**: See `$VPSSudoPassword` skill for sudo automation
**Triad Architecture**: See `triad-architecture.md` for multi-app troubleshooting
