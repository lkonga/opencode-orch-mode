# Worktree Cleanup and Maintenance

<!-- Purpose: Procedures for cleaning up and maintaining worktree environments -->
<!-- Related: worktree-orchestration skill -->

## Overview

This document outlines comprehensive cleanup and maintenance procedures for managing Git worktrees, databases, configurations, and associated infrastructure.

## Manual Cleanup Procedures

### 1. Remove Single Worktree

**Basic Removal:**
```bash
#!/bin/bash
# Remove worktree with full cleanup

WORKTREE_NAME="psp-p2p-merchant-preview-3"
WORKTREE_PATH="worktrees/$WORKTREE_NAME"

echo "=== Removing Worktree: $WORKTREE_NAME ==="

# Step 1: Remove Git worktree
echo "Removing Git worktree..."
git worktree remove "$WORKTREE_PATH" --force

# Step 2: Delete branch (if exists)
BRANCH_NAME=$(git branch | grep "$WORKTREE_NAME" || true)
if [ -n "$BRANCH_NAME" ]; then
    echo "Deleting branch: $BRANCH_NAME"
    git branch -D "$BRANCH_NAME"
fi

# Step 3: Prune stale references
echo "Pruning stale references..."
git worktree prune --verbose

echo "✅ Worktree removed successfully"
```

### 2. Database Cleanup

**Drop Worktree Database:**
```bash
#!/bin/bash
# scripts/cleanup-worktree-database.sh

set -e

WORKTREE_NUMBER=$1

if [ -z "$WORKTREE_NUMBER" ]; then
    echo "Usage: $0 <worktree-number>"
    echo "Example: $0 3"
    exit 1
fi

DB_NAME="psp_p2p_merchant_preview_$WORKTREE_NUMBER"

echo "⚠️  WARNING: This will permanently delete database: $DB_NAME"
read -p "Are you sure? (yes/no): " -r CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

echo "Dropping database: $DB_NAME"

mysql -u root -p << EOF
DROP DATABASE IF EXISTS \`$DB_NAME\`;
FLUSH PRIVILEGES;
EOF

echo "✅ Database dropped: $DB_NAME"
```

**Verify Database Removal:**
```bash
# List all preview databases
mysql -u root -p -e "SHOW DATABASES LIKE 'psp_p2p_merchant_preview_%';"

# Check specific database
mysql -u root -p -e "SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = 'psp_p2p_merchant_preview_3';"
```

### 3. Apache Virtual Host Cleanup

**Remove Virtual Host:**
```bash
#!/bin/bash
# scripts/cleanup-vhost.sh

set -e

WORKTREE_NAME=$1
VHOST_FILE="/etc/apache2/sites-available/$WORKTREE_NAME.conf"

echo "Removing virtual host: $WORKTREE_NAME"

# Disable site
if [ -f "$VHOST_FILE" ]; then
    sudo a2dissite "$WORKTREE_NAME"
    sudo rm "$VHOST_FILE"
    echo "  ✅ Virtual host removed"
else
    echo "  ⚠️  Virtual host not found: $VHOST_FILE"
fi

# Remove SSL certificate (optional)
WORKTREE_NUMBER=$(echo "$WORKTREE_NAME" | grep -oP '\d+$')
DOMAIN="psp-p2p-merchant-preview-$WORKTREE_NUMBER.trylatest.in"

read -p "Remove SSL certificate for $DOMAIN? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo certbot delete --cert-name "$DOMAIN"
    echo "  ✅ SSL certificate removed"
fi

# Reload Apache
sudo systemctl reload apache2

echo "✅ Virtual host cleanup complete"
```

### 4. Cloudflare Tunnel Cleanup

**Remove Tunnel Route:**
```bash
#!/bin/bash
# scripts/cleanup-tunnel-route.sh

WORKTREE_NUMBER=$1
DOMAIN="psp-p2p-merchant-preview-$WORKTREE_NUMBER.trylatest.in"
CONFIG_FILE="$HOME/.cloudflared/config.yml"

echo "Removing tunnel route for: $DOMAIN"

# Backup config
cp "$CONFIG_FILE" "$CONFIG_FILE.backup.$(date +%Y%m%d%H%M%S)"

# Remove ingress entry (manual edit required)
echo "⚠️  Manual step required:"
echo "Edit $CONFIG_FILE and remove the following lines:"
echo ""
echo "  - hostname: $DOMAIN"
echo "    service: https://localhost:443"
echo "    originRequest:"
echo "      noTLSVerify: true"
echo ""

read -p "Press Enter after you've edited the config file..."

# Restart tunnel
sudo systemctl restart cloudflared

echo "✅ Tunnel route cleanup complete"
```

---

## Automated Cleanup

### Comprehensive Cleanup Script

```bash
#!/bin/bash
# scripts/cleanup-worktree-complete.sh

set -e

WORKTREE_NAME=$1

if [ -z "$WORKTREE_NAME" ]; then
    echo "Usage: $0 <worktree-name>"
    echo "Example: $0 psp-p2p-merchant-preview-3"
    exit 1
fi

WORKTREE_NUMBER=$(echo "$WORKTREE_NAME" | grep -oP '\d+$')
WORKTREE_PATH="worktrees/$WORKTREE_NAME"
DB_NAME="psp_p2p_merchant_preview_$WORKTREE_NUMBER"
DOMAIN="psp-p2p-merchant-preview-$WORKTREE_NUMBER.trylatest.in"

echo "========================================="
echo "WORKTREE COMPLETE CLEANUP"
echo "========================================="
echo "Worktree: $WORKTREE_NAME"
echo "Number: $WORKTREE_NUMBER"
echo "Database: $DB_NAME"
echo "Domain: $DOMAIN"
echo "========================================="
echo ""

read -p "⚠️  This will remove EVERYTHING. Continue? (yes/no): " -r CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

# 1. Remove Git worktree
echo ""
echo "1. Removing Git worktree..."
if [ -d "$WORKTREE_PATH" ]; then
    git worktree remove "$WORKTREE_PATH" --force
    echo "  ✅ Worktree removed"
else
    echo "  ⚠️  Worktree directory not found"
fi

# 2. Delete branch
echo ""
echo "2. Deleting Git branch..."
BRANCH_NAME=$(git branch | grep "preview.*$WORKTREE_NUMBER" | xargs || true)
if [ -n "$BRANCH_NAME" ]; then
    git branch -D "$BRANCH_NAME"
    echo "  ✅ Branch deleted: $BRANCH_NAME"
else
    echo "  ⚠️  No matching branch found"
fi

# 3. Prune Git references
echo ""
echo "3. Pruning Git references..."
git worktree prune --verbose
git fetch --prune origin

# 4. Drop database
echo ""
echo "4. Dropping database..."
mysql -u root -p -e "DROP DATABASE IF EXISTS \`$DB_NAME\`;" && echo "  ✅ Database dropped" || echo "  ⚠️  Database cleanup failed"

# 5. Remove virtual host
echo ""
echo "5. Removing Apache virtual host..."
VHOST_FILE="/etc/apache2/sites-available/$WORKTREE_NAME.conf"
if [ -f "$VHOST_FILE" ]; then
    sudo a2dissite "$WORKTREE_NAME"
    sudo rm "$VHOST_FILE"
    sudo systemctl reload apache2
    echo "  ✅ Virtual host removed"
else
    echo "  ⚠️  Virtual host not found"
fi

# 6. Clean logs
echo ""
echo "6. Cleaning Apache logs..."
sudo rm -f "/var/log/apache2/$WORKTREE_NAME-*"
echo "  ✅ Logs removed"

# 7. Clean storage
echo ""
echo "7. Cleaning storage directory..."
if [ -d "$WORKTREE_PATH/storage" ]; then
    rm -rf "$WORKTREE_PATH/storage/logs/*"
    rm -rf "$WORKTREE_PATH/storage/framework/cache/*"
    rm -rf "$WORKTREE_PATH/storage/framework/sessions/*"
    rm -rf "$WORKTREE_PATH/storage/framework/views/*"
    echo "  ✅ Storage cleaned"
fi

echo ""
echo "========================================="
echo "✅ CLEANUP COMPLETE"
echo "========================================="
echo ""
echo "Manual steps remaining:"
echo "  1. Update Cloudflare tunnel config to remove $DOMAIN"
echo "  2. Remove SSL certificate: sudo certbot delete --cert-name $DOMAIN"
echo "  3. Update documentation/tracking files"
```

### Batch Cleanup Script

```bash
#!/bin/bash
# scripts/cleanup-multiple-worktrees.sh

set -e

echo "=== Batch Worktree Cleanup ==="
echo ""

# Find all preview worktrees
WORKTREES=$(git worktree list | grep "preview" | awk '{print $1}' | xargs -n1 basename)

if [ -z "$WORKTREES" ]; then
    echo "No preview worktrees found."
    exit 0
fi

echo "Found worktrees:"
echo "$WORKTREES"
echo ""

read -p "Select worktrees to remove (space-separated numbers or 'all'): " -r SELECTION

if [ "$SELECTION" = "all" ]; then
    for worktree in $WORKTREES; do
        echo ""
        echo "Processing: $worktree"
        ./scripts/cleanup-worktree-complete.sh "$worktree"
    done
else
    for num in $SELECTION; do
        worktree=$(echo "$WORKTREES" | sed -n "${num}p")
        if [ -n "$worktree" ]; then
            echo ""
            echo "Processing: $worktree"
            ./scripts/cleanup-worktree-complete.sh "$worktree"
        fi
    done
fi

echo ""
echo "✅ Batch cleanup complete"
```

---

## Scheduled Maintenance

### Daily Maintenance Script

```bash
#!/bin/bash
# scripts/daily-worktree-maintenance.sh

LOG_FILE="/var/log/worktree-maintenance.log"

echo "=== Daily Worktree Maintenance - $(date) ===" | tee -a "$LOG_FILE"

# 1. Prune stale worktree references
echo "Pruning stale worktree references..." | tee -a "$LOG_FILE"
git worktree prune --verbose 2>&1 | tee -a "$LOG_FILE"

# 2. Clean merged branches
echo "Cleaning merged branches..." | tee -a "$LOG_FILE"
git fetch --prune origin 2>&1 | tee -a "$LOG_FILE"
git branch --merged | grep -v "main\|master\|develop" | xargs -r git branch -d 2>&1 | tee -a "$LOG_FILE"

# 3. Find orphaned worktree directories
echo "Checking for orphaned directories..." | tee -a "$LOG_FILE"
ACTIVE_WORKTREES=$(git worktree list | awk '{print $1}')
for dir in worktrees/*; do
    if [ -d "$dir" ]; then
        if ! echo "$ACTIVE_WORKTREES" | grep -q "$(readlink -f "$dir")"; then
            echo "  ⚠️  Orphaned: $dir" | tee -a "$LOG_FILE"
        fi
    fi
done

# 4. Check disk usage
echo "Checking disk usage..." | tee -a "$LOG_FILE"
du -sh worktrees/* 2>&1 | tee -a "$LOG_FILE"

# 5. Optimize Git repository
echo "Optimizing Git repository..." | tee -a "$LOG_FILE"
git gc --auto 2>&1 | tee -a "$LOG_FILE"

echo "=== Maintenance Complete ===" | tee -a "$LOG_FILE"
```

**Cron Setup:**
```bash
# Add to crontab
crontab -e

# Run daily at 2 AM
0 2 * * * cd /home/lkonga/codes/psp-p2p && ./scripts/daily-worktree-maintenance.sh
```

### Weekly Cleanup Script

```bash
#!/bin/bash
# scripts/weekly-worktree-cleanup.sh

LOG_FILE="/var/log/worktree-weekly-cleanup.log"

echo "=== Weekly Worktree Cleanup - $(date) ===" | tee -a "$LOG_FILE"

# 1. Find stale worktrees (not updated in 30 days)
echo "Finding stale worktrees..." | tee -a "$LOG_FILE"
find worktrees -maxdepth 1 -type d -mtime +30 -exec basename {} \; | while read worktree; do
    if [ "$worktree" != "worktrees" ]; then
        echo "  ⚠️  Stale worktree: $worktree (last modified: $(stat -c %y "worktrees/$worktree"))" | tee -a "$LOG_FILE"
    fi
done

# 2. Clean old preview databases
echo "Checking for old preview databases..." | tee -a "$LOG_FILE"
mysql -u root -p -e "
    SELECT SCHEMA_NAME,
           CREATE_TIME,
           DATEDIFF(NOW(), CREATE_TIME) as AGE_DAYS
    FROM information_schema.SCHEMATA
    WHERE SCHEMA_NAME LIKE 'psp_p2p_%preview_%'
    HAVING AGE_DAYS > 30
    ORDER BY AGE_DAYS DESC;
" 2>&1 | tee -a "$LOG_FILE"

# 3. Compress old logs
echo "Compressing old logs..." | tee -a "$LOG_FILE"
find worktrees/*/storage/logs -name "*.log" -mtime +7 -exec gzip {} \; 2>&1 | tee -a "$LOG_FILE"

# 4. Clean old SSL certificates
echo "Checking SSL certificates..." | tee -a "$LOG_FILE"
sudo certbot certificates | grep "preview" | tee -a "$LOG_FILE"

echo "=== Weekly Cleanup Complete ===" | tee -a "$LOG_FILE"
```

---

## Verification Steps

### Pre-Cleanup Checklist

```bash
#!/bin/bash
# scripts/pre-cleanup-checklist.sh

WORKTREE_NAME=$1

echo "=== Pre-Cleanup Checklist for $WORKTREE_NAME ==="
echo ""

# 1. Check for uncommitted changes
echo "1. Checking for uncommitted changes..."
cd "worktrees/$WORKTREE_NAME"
if [ -n "$(git status --porcelain)" ]; then
    echo "  ⚠️  WARNING: Uncommitted changes detected!"
    git status --short
else
    echo "  ✅ No uncommitted changes"
fi
cd ../..

# 2. Check for active processes
echo ""
echo "2. Checking for active processes..."
PROCESSES=$(ps aux | grep "$WORKTREE_NAME" | grep -v grep || true)
if [ -n "$PROCESSES" ]; then
    echo "  ⚠️  WARNING: Active processes detected!"
    echo "$PROCESSES"
else
    echo "  ✅ No active processes"
fi

# 3. Check database size
echo ""
echo "3. Checking database size..."
WORKTREE_NUMBER=$(echo "$WORKTREE_NAME" | grep -oP '\d+$')
DB_NAME="psp_p2p_merchant_preview_$WORKTREE_NUMBER"
DB_SIZE=$(mysql -u root -p -sN -e "
    SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 2)
    FROM information_schema.TABLES
    WHERE table_schema = '$DB_NAME';
" 2>/dev/null || echo "0")
echo "  Database size: ${DB_SIZE}MB"

# 4. Check for important data
echo ""
echo "4. Checking for important data..."
IMPORTANT_FILES=$(find "worktrees/$WORKTREE_NAME/storage/app" -type f -not -path "*/cache/*" | wc -l)
echo "  Uploaded files: $IMPORTANT_FILES"

# 5. Check Apache access
echo ""
echo "5. Checking Apache access logs..."
RECENT_ACCESS=$(sudo tail -n 100 "/var/log/apache2/$WORKTREE_NAME-access.log" 2>/dev/null | wc -l)
echo "  Recent requests: $RECENT_ACCESS"

echo ""
echo "=== Checklist Complete ==="
```

### Post-Cleanup Verification

```bash
#!/bin/bash
# scripts/post-cleanup-verification.sh

WORKTREE_NAME=$1
WORKTREE_NUMBER=$(echo "$WORKTREE_NAME" | grep -oP '\d+$')

echo "=== Post-Cleanup Verification ==="
echo ""

# 1. Verify worktree removed
echo "1. Verifying worktree removal..."
if git worktree list | grep -q "$WORKTREE_NAME"; then
    echo "  ❌ FAIL: Worktree still exists"
else
    echo "  ✅ PASS: Worktree removed"
fi

# 2. Verify directory removed
echo ""
echo "2. Verifying directory removal..."
if [ -d "worktrees/$WORKTREE_NAME" ]; then
    echo "  ❌ FAIL: Directory still exists"
else
    echo "  ✅ PASS: Directory removed"
fi

# 3. Verify database dropped
echo ""
echo "3. Verifying database removal..."
DB_NAME="psp_p2p_merchant_preview_$WORKTREE_NUMBER"
if mysql -u root -p -e "USE \`$DB_NAME\`" 2>/dev/null; then
    echo "  ❌ FAIL: Database still exists"
else
    echo "  ✅ PASS: Database dropped"
fi

# 4. Verify virtual host removed
echo ""
echo "4. Verifying virtual host removal..."
if [ -f "/etc/apache2/sites-available/$WORKTREE_NAME.conf" ]; then
    echo "  ❌ FAIL: Virtual host still exists"
else
    echo "  ✅ PASS: Virtual host removed"
fi

# 5. Verify Git references
echo ""
echo "5. Verifying Git references..."
if git branch | grep -q "$WORKTREE_NAME"; then
    echo "  ⚠️  WARNING: Branch still exists"
else
    echo "  ✅ PASS: Branch removed"
fi

echo ""
echo "=== Verification Complete ==="
```

---

## Emergency Recovery

### Recover Accidentally Deleted Worktree

```bash
#!/bin/bash
# scripts/recover-worktree.sh

set -e

WORKTREE_NAME=$1
BRANCH_NAME=$2

if [ -z "$BRANCH_NAME" ]; then
    echo "Usage: $0 <worktree-name> <branch-name>"
    echo "Example: $0 psp-p2p-merchant-preview-3 preview/merchant-3"
    exit 1
fi

echo "Attempting to recover worktree: $WORKTREE_NAME"

# 1. Check if branch still exists
if ! git branch --all | grep -q "$BRANCH_NAME"; then
    echo "❌ ERROR: Branch not found: $BRANCH_NAME"
    echo "Checking reflog for recovery options..."
    git reflog | grep "$BRANCH_NAME"
    exit 1
fi

# 2. Recreate worktree
echo "Recreating worktree from branch: $BRANCH_NAME"
git worktree add "worktrees/$WORKTREE_NAME" "$BRANCH_NAME"

# 3. Restore environment
echo "Restoring environment configuration..."
cd "worktrees/$WORKTREE_NAME"
cp .env.example .env
php artisan key:generate

echo "✅ Worktree recovered: $WORKTREE_NAME"
echo "⚠️  Note: You may need to restore the database separately"
```

### Restore Database from Backup

```bash
#!/bin/bash
# scripts/restore-worktree-database.sh

set -e

WORKTREE_NUMBER=$1
BACKUP_FILE=$2

if [ -z "$BACKUP_FILE" ] || [ ! -f "$BACKUP_FILE" ]; then
    echo "Usage: $0 <worktree-number> <backup-file>"
    echo "Example: $0 3 /backups/psp_p2p_merchant_preview_3.sql"
    exit 1
fi

DB_NAME="psp_p2p_merchant_preview_$WORKTREE_NUMBER"

echo "Restoring database: $DB_NAME"
echo "From backup: $BACKUP_FILE"

# Create database
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Restore backup
mysql -u root -p "$DB_NAME" < "$BACKUP_FILE"

echo "✅ Database restored"
```

---

## Monitoring and Alerts

### Disk Space Monitor

```bash
#!/bin/bash
# scripts/monitor-worktree-disk-usage.sh

THRESHOLD=80  # Alert at 80% usage
ALERT_EMAIL="admin@example.com"

USAGE=$(df -h /home | tail -1 | awk '{print $5}' | sed 's/%//')

if [ "$USAGE" -gt "$THRESHOLD" ]; then
    echo "⚠️  WARNING: Disk usage at ${USAGE}%"

    # Show worktree sizes
    echo "Worktree sizes:"
    du -sh worktrees/* | sort -hr

    # Send alert (if mail is configured)
    echo "Disk usage at ${USAGE}%" | mail -s "Worktree Disk Alert" "$ALERT_EMAIL"
fi
```

### Stale Worktree Detector

```bash
#!/bin/bash
# scripts/detect-stale-worktrees.sh

STALE_DAYS=30

echo "=== Detecting Stale Worktrees (>${STALE_DAYS} days) ==="
echo ""

find worktrees -maxdepth 1 -type d -mtime +$STALE_DAYS | while read worktree; do
    if [ "$(basename "$worktree")" != "worktrees" ]; then
        LAST_MODIFIED=$(stat -c %y "$worktree" | cut -d' ' -f1)
        DAYS_OLD=$(( ($(date +%s) - $(stat -c %Y "$worktree")) / 86400 ))

        echo "Stale worktree: $(basename "$worktree")"
        echo "  Last modified: $LAST_MODIFIED ($DAYS_OLD days ago)"
        echo "  Size: $(du -sh "$worktree" | cut -f1)"
        echo ""
    fi
done
```

---

## Best Practices

### 1. Always Backup Before Cleanup
```bash
# Create backup before cleanup
./scripts/backup-worktree.sh psp-p2p-merchant-preview-3

# Then cleanup
./scripts/cleanup-worktree-complete.sh psp-p2p-merchant-preview-3
```

### 2. Use Checklist
```bash
# Run pre-cleanup checklist
./scripts/pre-cleanup-checklist.sh psp-p2p-merchant-preview-3

# Review output before proceeding
```

### 3. Document Cleanup
```bash
# Log cleanup actions
echo "$(date): Cleaned up psp-p2p-merchant-preview-3" >> cleanup-log.txt
```

### 4. Verify After Cleanup
```bash
# Always verify
./scripts/post-cleanup-verification.sh psp-p2p-merchant-preview-3
```

### 5. Keep Cleanup Scripts Updated
```bash
# Version control your cleanup scripts
git add scripts/cleanup-*.sh
git commit -m "Update cleanup scripts"
```

---

## Related Skills

- `worktree-configuration` - Configuration patterns
- `worktree-commands` - Command reference
- `vps-laravel-deployment` - Deployment patterns

## References

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- [MySQL Backup and Recovery](https://dev.mysql.com/doc/refman/8.0/en/backup-and-recovery.html)
- [Apache Virtual Host Management](https://httpd.apache.org/docs/2.4/vhosts/)
