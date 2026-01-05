# VPS Laravel Advanced Workflows

## Multi-Application Deployment

### Deploy Entire Triad

```bash
# Deploy all three applications in sequence
# Ensure branches are pushed first

# 1. Deploy PSP-P2P
trunner "./vps-deploy-worktree.sh deploy \
  --subdomain psp-p2p-merchant-preview-15 \
  --repo git@github.com:lkonga/psp-p2p.git \
  --branch psp-p2p-merchant-preview-15 \
  --app-type psp-p2p \
  --landing-url https://staging.psp-landing-preview-15.trylatest.in \
  --psp-url https://staging.psp-p2p-merchant-preview-15.trylatest.in \
  --ppp-url https://staging.push-parser-panel.trylatest.in"

# Wait for completion
sleep 300  # 5 minutes

# 2. Deploy PSP-Landing
trunner "./vps-deploy-worktree.sh deploy \
  --subdomain psp-landing-preview-15 \
  --repo git@github.com:lkonga/psp-p2p-landing.git \
  --branch psp-landing-preview-15 \
  --app-type psp-landing \
  --landing-url https://staging.psp-landing-preview-15.trylatest.in \
  --psp-url https://staging.psp-p2p-merchant-preview-15.trylatest.in \
  --ppp-url https://staging.push-parser-panel.trylatest.in"

# Wait for completion
sleep 300

# 3. Deploy Push Parser Panel
trunner "./vps-deploy-worktree.sh deploy \
  --subdomain push-parser-panel \
  --repo git@github.com:lkonga/push-parser-panel.git \
  --branch develop \
  --app-type push-parser-panel \
  --landing-url https://staging.psp-landing-preview-15.trylatest.in \
  --psp-url https://staging.psp-p2p-merchant-preview-15.trylatest.in \
  --ppp-url https://staging.push-parser-panel.trylatest.in"

# Verify all applications
for app in psp-p2p-merchant-preview-15 psp-landing-preview-15 push-parser-panel; do
  URL="https://${app}.trylatest.in"
  [[ "$app" =~ psp-(p2p|landing) ]] && URL="https://staging.${app}.trylatest.in"
  echo "Checking $app..."
  curl -I "$URL" | head -1
done
```

### Parallel Deployment (Advanced)

```bash
# Deploy multiple preview environments concurrently
for i in 16 17 18; do
  (
    ./vps-deploy-worktree.sh deploy \
      --subdomain psp-p2p-merchant-preview-${i} \
      --repo git@github.com:lkonga/psp-p2p.git \
      --branch psp-p2p-merchant-preview-${i} \
      --app-type psp-p2p \
      --landing-url https://staging.psp-landing-preview-${i}.trylatest.in \
      --psp-url https://staging.psp-p2p-merchant-preview-${i}.trylatest.in \
      --ppp-url https://staging.push-parser-panel.trylatest.in
  ) &
done

# Wait for all deployments
wait

# Verify all deployed
for i in 16 17 18; do
  curl -I "https://staging.psp-p2p-merchant-preview-${i}.trylatest.in"
done
```

## Blue-Green Deployment

### Setup Blue-Green Environment

```bash
# Blue environment (current production)
# Already deployed: psp-p2p-merchant-preview-10

# Deploy Green environment (new version)
trunner "./vps-deploy-worktree.sh deploy \
  --subdomain psp-p2p-merchant-preview-11 \
  --repo git@github.com:lkonga/psp-p2p.git \
  --branch feature/new-payment-flow \
  --app-type psp-p2p"

# Test Green environment
curl -I https://staging.psp-p2p-merchant-preview-11.trylatest.in

# Run smoke tests against Green
# (your test commands here)

# Switch traffic (update load balancer/DNS)
# (external tool/script)

# Verify new production
curl -I https://production.example.com

# Clean up Blue environment
./vps-deploy-worktree.sh undeploy \
  --subdomain staging.psp-p2p-merchant-preview-10 \
  --remove-files
```

## Canary Deployment

### Deploy Canary Release

```bash
# Production: psp-p2p-merchant-preview-10
# Create canary with new version

trunner "./vps-deploy-worktree.sh deploy \
  --subdomain psp-p2p-merchant-preview-canary \
  --repo git@github.com:lkonga/psp-p2p.git \
  --branch feature/performance-improvements \
  --app-type psp-p2p"

# Route 10% of traffic to canary (external load balancer configuration)

# Monitor metrics for canary vs production
# If metrics good, gradually increase canary traffic
# If metrics bad, rollback by undeploying canary

./vps-deploy-worktree.sh undeploy \
  --subdomain staging.psp-p2p-merchant-preview-canary \
  --remove-files
```

## Staged Rollout

### Progressive Deployment to Multiple Environments

```bash
# Stage 1: Deploy to dev environment
trunner "./vps-deploy-worktree.sh deploy \
  --subdomain psp-p2p-merchant-preview-dev \
  --repo git@github.com:lkonga/psp-p2p.git \
  --branch develop \
  --app-type psp-p2p"

# Wait for tests to pass and manual verification
sleep 300

# Stage 2: Deploy to QA environment
trunner "./vps-deploy-worktree.sh deploy \
  --subdomain psp-p2p-merchant-preview-qa \
  --repo git@github.com:lkonga/psp-p2p.git \
  --branch develop \
  --app-type psp-p2p"

# Wait for QA testing
# Manual testing...

# Stage 3: Deploy to staging
trunner "./vps-deploy-worktree.sh deploy \
  --subdomain psp-p2p-merchant-preview-staging \
  --repo git@github.com:lkonga/psp-p2p.git \
  --branch develop \
  --app-type psp-p2p"

# Stage 4: Deploy to production
# (after all tests pass and approvals obtained)
```

## Database Migration Workflows

### Deploy with Fresh Migrations

```bash
# Deploy application
trunner "./vps-deploy-worktree.sh deploy \
  --subdomain psp-p2p-merchant-preview-migration-test \
  --repo git@github.com:lkonga/psp-p2p.git \
  --branch feature/new-migrations \
  --app-type psp-p2p"

# Wait for deployment
sleep 300

# SSH to VPS and verify migrations
ssh lkonga@37.60.247.12 "
  cd /var/www/worktrees/staging.psp-p2p-merchant-preview-migration-test
  php artisan migrate:status
"
```

### Rollback Migrations

```bash
# SSH to VPS
ssh lkonga@37.60.247.12

# Navigate to application
cd /var/www/worktrees/staging.psp-p2p-merchant-preview-{N}

# Rollback last migration
sudo -u www-data php artisan migrate:rollback

# Or rollback to specific batch
sudo -u www-data php artisan migrate:rollback --step=2

# Verify
sudo -u www-data php artisan migrate:status
```

## Configuration Management

### Deploy with Custom Environment Variables

```bash
# Deploy normally first
trunner "./vps-deploy-worktree.sh deploy \
  --subdomain psp-p2p-merchant-preview-custom \
  --repo git@github.com:lkonga/psp-p2p.git \
  --branch develop \
  --app-type psp-p2p"

# Wait for deployment
sleep 300

# Update .env with custom values
ssh lkonga@37.60.247.12 "
  cd /var/www/worktrees/staging.psp-p2p-merchant-preview-custom

  # Backup original .env
  sudo cp .env .env.backup

  # Add custom variables
  echo 'CUSTOM_API_KEY=secret123' | sudo tee -a .env
  echo 'FEATURE_FLAG_NEW_UI=true' | sudo tee -a .env

  # Clear Laravel cache
  sudo -u www-data php artisan config:clear
  sudo -u www-data php artisan cache:clear
"
```

### Deploy with Different Triad URLs

```bash
# Deploy PSP-P2P pointing to different PSP-Landing
trunner "./vps-deploy-worktree.sh deploy \
  --subdomain psp-p2p-merchant-preview-20 \
  --repo git@github.com:lkonga/psp-p2p.git \
  --branch psp-p2p-merchant-preview-20 \
  --app-type psp-p2p \
  --landing-url https://staging.psp-landing-preview-99.trylatest.in"
```

## Monitoring and Health Checks

### Automated Health Check Script

```bash
#!/bin/bash
# health-check-all.sh

APPS=(
  "staging.psp-p2p-merchant-preview-10.trylatest.in"
  "staging.psp-landing-preview-10.trylatest.in"
  "push-parser-panel.trylatest.in"
)

for APP in "${APPS[@]}"; do
  echo "Checking $APP..."

  # Check HTTP status
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://$APP")

  if [[ "$STATUS" =~ ^(200|302)$ ]]; then
    echo "  ✓ HTTP $STATUS"
  else
    echo "  ✗ HTTP $STATUS (expected 200 or 302)"
  fi

  # Check SSL certificate
  EXPIRY=$(echo | openssl s_client -servername "$APP" -connect "$APP:443" 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
  echo "  ℹ SSL expires: $EXPIRY"

  echo ""
done
```

### Monitor Deployment Progress

```bash
# Monitor deployment in real-time
watch -n 5 'tail -30 /tmp/test_suite_output_tmux-runner-*.log | tail -15'

# Check for completion
while true; do
  if tail -20 /tmp/test_suite_output_tmux-runner-*.log | grep -q "Deployment complete"; then
    echo "Deployment finished!"
    break
  fi
  sleep 10
done
```

## Backup and Restore

### Backup Before Deployment

```bash
# Create backup of existing deployment
ssh lkonga@37.60.247.12 "
  cd /var/www/worktrees
  sudo tar -czf staging.psp-p2p-merchant-preview-10.backup.tar.gz \
    staging.psp-p2p-merchant-preview-10/

  # Backup database
  mysqldump -uroot -p'Push@Parser2024!Secure' \
    psp_p2p_merchant_preview_10_staging \
    | gzip > psp_p2p_merchant_preview_10_staging.sql.gz
"

# Now deploy new version
trunner "./vps-deploy-worktree.sh deploy ..."
```

### Restore from Backup

```bash
# Restore files
ssh lkonga@37.60.247.12 "
  cd /var/www/worktrees

  # Remove current version
  sudo rm -rf staging.psp-p2p-merchant-preview-10/

  # Extract backup
  sudo tar -xzf staging.psp-p2p-merchant-preview-10.backup.tar.gz
"

# Restore database
ssh lkonga@37.60.247.12 "
  gunzip -c psp_p2p_merchant_preview_10_staging.sql.gz | \
    mysql -uroot -p'Push@Parser2024!Secure' psp_p2p_merchant_preview_10_staging
"

# Restart services
ssh lkonga@37.60.247.12 "
  sudo systemctl restart php8.3-fpm
  sudo systemctl reload nginx
"
```

## Performance Optimization

### Deploy with OPcache Preloading

```bash
# Deploy normally
trunner "./vps-deploy-worktree.sh deploy ..."

# Wait for completion
sleep 300

# Enable OPcache preloading
ssh lkonga@37.60.247.12 "
  cd /var/www/worktrees/staging.psp-p2p-merchant-preview-{N}

  # Generate preload file
  sudo -u www-data php artisan config:cache
  sudo -u www-data php artisan route:cache
  sudo -u www-data php artisan view:cache

  # Configure PHP-FPM pool for preloading
  sudo nano /etc/php/8.3/fpm/pool.d/staging.psp-p2p-merchant-preview-{N}.conf
  # Add: php_admin_value[opcache.preload] = /var/www/worktrees/.../preload.php

  # Restart PHP-FPM
  sudo systemctl restart php8.3-fpm
"
```

### Deploy with Redis Caching

```bash
# Deploy application
trunner "./vps-deploy-worktree.sh deploy ..."

# Configure Redis for caching
ssh lkonga@37.60.247.12 "
  cd /var/www/worktrees/staging.psp-p2p-merchant-preview-{N}

  # Update .env for Redis
  sudo sed -i 's/CACHE_DRIVER=file/CACHE_DRIVER=redis/' .env
  sudo sed -i 's/SESSION_DRIVER=file/SESSION_DRIVER=redis/' .env
  sudo sed -i 's/QUEUE_CONNECTION=sync/QUEUE_CONNECTION=redis/' .env

  # Clear caches
  sudo -u www-data php artisan config:clear
  sudo -u www-data php artisan cache:clear

  # Test Redis connection
  sudo -u www-data php artisan tinker --execute=\"Redis::ping()\"
"
```

## Security Workflows

### Deploy with Enhanced Security

```bash
# Deploy application
trunner "./vps-deploy-worktree.sh deploy ..."

# Wait for deployment
sleep 300

# Harden security
ssh lkonga@37.60.247.12 "
  cd /var/www/worktrees/staging.psp-p2p-merchant-preview-{N}

  # Set strict permissions
  sudo find . -type f -exec chmod 644 {} \;
  sudo find . -type d -exec chmod 755 {} \;
  sudo chmod -R 775 storage bootstrap/cache

  # Remove sensitive files
  sudo rm -f .env.example .env.backup

  # Disable directory indexing
  echo 'Options -Indexes' | sudo tee -a .htaccess

  # Verify permissions
  ls -la
"
```

### Rotate Application Keys

```bash
# Generate new application key
ssh lkonga@37.60.247.12 "
  cd /var/www/worktrees/staging.psp-p2p-merchant-preview-{N}

  # Backup old key
  OLD_KEY=\$(grep APP_KEY .env | cut -d= -f2)
  echo \$OLD_KEY > .app_key.backup

  # Generate new key
  sudo -u www-data php artisan key:generate --force

  # Clear caches
  sudo -u www-data php artisan config:clear
  sudo -u www-data php artisan cache:clear
"
```

## CI/CD Integration

### GitHub Actions Workflow

```yaml
name: Deploy to VPS

on:
  push:
    branches:
      - psp-p2p-merchant-preview-*

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Extract Preview Number
        id: preview
        run: |
          BRANCH=${GITHUB_REF#refs/heads/}
          echo "branch=$BRANCH" >> $GITHUB_OUTPUT

      - name: Deploy to VPS
        run: |
          ssh lkonga@37.60.247.12 "
            cd /home/lkonga/codes/llm-rules/scripts/vps
            ./vps-deploy-worktree.sh deploy \
              --subdomain ${{ steps.preview.outputs.branch }} \
              --repo git@github.com:lkonga/psp-p2p.git \
              --branch ${{ steps.preview.outputs.branch }} \
              --app-type psp-p2p
          "

      - name: Health Check
        run: |
          sleep 300  # Wait for deployment
          curl -f https://staging.${{ steps.preview.outputs.branch }}.trylatest.in || exit 1
```

## Advanced Troubleshooting Workflows

### Debug Failed Deployment

```bash
# Check deployment logs
tail -100 /tmp/test_suite_output_tmux-runner-*.log

# SSH to VPS for detailed inspection
ssh lkonga@37.60.247.12

# Check nginx error logs
sudo tail -50 /var/log/nginx/error.log

# Check PHP-FPM logs
sudo tail -50 /var/log/php8.3-fpm.log

# Check application logs
sudo tail -50 /var/www/worktrees/staging.{subdomain}/storage/logs/laravel.log

# Check database connection
mysql -uroot -p'Push@Parser2024!Secure' -e "SHOW DATABASES LIKE '%preview%';"
```

### Fix Stuck Deployment

```bash
# Kill stuck tmux session
trunner --kill {SESSION_ID}

# Clean up partial deployment on VPS
ssh lkonga@37.60.247.12 "
  # Remove partial application files
  sudo rm -rf /var/www/worktrees/staging.{subdomain}

  # Drop partial databases
  mysql -uroot -p'Push@Parser2024!Secure' -e \"DROP DATABASE IF EXISTS {db_name}_staging;\"
  mysql -uroot -p'Push@Parser2024!Secure' -e \"DROP DATABASE IF EXISTS {db_name}_testing;\"

  # Remove nginx config
  sudo rm /etc/nginx/sites-enabled/staging.{subdomain}
  sudo rm /etc/nginx/sites-available/staging.{subdomain}

  # Remove PHP-FPM pool
  sudo rm /etc/php/8.3/fpm/pool.d/staging.{subdomain}.conf

  # Restart services
  sudo systemctl reload nginx
  sudo systemctl restart php8.3-fpm
"

# Retry deployment
trunner "./vps-deploy-worktree.sh deploy ..."
```

## Best Practices Summary

**Deployment Strategy**:
- Always use `trunner` for deployments (prevents interruption)
- Test locally before VPS deployment
- Deploy matching preview numbers for triads
- Monitor deployment progress periodically
- Verify HTTP status after deployment

**Security**:
- Rotate application keys regularly
- Use strict file permissions
- Keep SSL certificates up to date
- Regularly update dependencies
- Monitor security logs

**Performance**:
- Enable OPcache
- Use Redis for caching
- Optimize database queries
- Monitor resource usage
- Scale horizontally when needed

**Maintenance**:
- Clean up old deployments regularly
- Backup before major changes
- Document custom configurations
- Keep deployment scripts updated
- Monitor disk space and database size
