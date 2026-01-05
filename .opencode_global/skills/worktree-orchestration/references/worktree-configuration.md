# Worktree Configuration Patterns

<!-- Purpose: Configuration patterns for worktree setup including environment variables and pairing -->
<!-- Related: worktree-orchestration skill -->

## Overview

This document outlines best practices and patterns for configuring Laravel worktrees, including environment variable management, database configuration, and application URL pairing strategies.

## Environment Variable Management

### Environment File Structure

```bash
# Main repository .env (not committed)
/home/lkonga/codes/psp-p2p/.env

# Worktree-specific .env files (gitignored)
/home/lkonga/codes/psp-p2p/worktrees/psp-p2p-merchant-preview-2/.env
/home/lkonga/codes/psp-p2p/worktrees/psp-p2p-merchant-preview-3/.env
```

### Environment Template

**Main .env.example:**
```env
# Application
APP_NAME="PSP-P2P Merchant"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost

# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=psp_p2p
DB_USERNAME=root
DB_PASSWORD=

# Cache & Session
CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync

# Redis (if needed)
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
```

**Worktree .env.preview:**
```env
# Application (Preview-specific)
APP_NAME="PSP-P2P Merchant Preview ${WORKTREE_NUMBER}"
APP_ENV=staging
APP_KEY=base64:generated_key_here
APP_DEBUG=true
APP_URL=https://psp-p2p-merchant-preview-${WORKTREE_NUMBER}.trylatest.in

# Database (Worktree-specific)
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=psp_p2p_merchant_preview_${WORKTREE_NUMBER}
DB_USERNAME=root
DB_PASSWORD=your_password

# Cache & Session (Worktree-specific)
CACHE_DRIVER=redis
CACHE_PREFIX=${WORKTREE_NUMBER}:
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

# Redis with prefix
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
REDIS_PREFIX=${WORKTREE_NUMBER}:
```

### Environment Generation Script

```bash
#!/bin/bash
# scripts/generate-worktree-env.sh

set -e

WORKTREE_NAME=$1
WORKTREE_NUMBER=$(echo "$WORKTREE_NAME" | grep -oP '\d+$')

if [ -z "$WORKTREE_NUMBER" ]; then
    echo "Error: Could not extract worktree number from $WORKTREE_NAME"
    exit 1
fi

WORKTREE_PATH="worktrees/$WORKTREE_NAME"
ENV_FILE="$WORKTREE_PATH/.env"

echo "Generating .env for $WORKTREE_NAME (number: $WORKTREE_NUMBER)"

# Copy from template
cp .env.example "$ENV_FILE"

# Replace placeholders
sed -i "s/\${WORKTREE_NUMBER}/$WORKTREE_NUMBER/g" "$ENV_FILE"
sed -i "s/APP_ENV=local/APP_ENV=staging/" "$ENV_FILE"
sed -i "s|APP_URL=http://localhost|APP_URL=https://psp-p2p-merchant-preview-$WORKTREE_NUMBER.trylatest.in|" "$ENV_FILE"
sed -i "s/DB_DATABASE=psp_p2p/DB_DATABASE=psp_p2p_merchant_preview_$WORKTREE_NUMBER/" "$ENV_FILE"

# Generate APP_KEY
cd "$WORKTREE_PATH"
php artisan key:generate

echo "✅ Environment file created: $ENV_FILE"
```

---

## Database Configuration

### Database Naming Convention

**Pattern:**
```
{project}_{variant}_{environment}_{number}
```

**Examples:**
```
psp_p2p_merchant_preview_2
psp_p2p_merchant_preview_3
psp_p2p_admin_staging_1
psp_landing_preview_2
```

### Database Creation Script

```bash
#!/bin/bash
# scripts/create-worktree-database.sh

set -e

WORKTREE_NAME=$1
WORKTREE_NUMBER=$(echo "$WORKTREE_NAME" | grep -oP '\d+$')
DB_NAME="psp_p2p_merchant_preview_$WORKTREE_NUMBER"

echo "Creating database: $DB_NAME"

# Create database
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Grant privileges
mysql -u root -p -e "GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO 'root'@'localhost';"
mysql -u root -p -e "FLUSH PRIVILEGES;"

echo "✅ Database created: $DB_NAME"
```

### Database Pairing Strategy

**Configuration File:**
```bash
# scripts/worktree-database-pairs.conf

# Format: worktree_name:database_name
psp-p2p-merchant-preview-2:psp_p2p_merchant_preview_2
psp-p2p-merchant-preview-3:psp_p2p_merchant_preview_3
psp-p2p-merchant-preview-4:psp_p2p_merchant_preview_4
psp-p2p-admin-staging-1:psp_p2p_admin_staging_1
psp-landing-preview-2:psp_landing_preview_2
```

**Verification Script:**
```bash
#!/bin/bash
# scripts/verify-database-pairing.sh

PAIRS_FILE="scripts/worktree-database-pairs.conf"

echo "Verifying worktree database pairings..."

while IFS=: read -r worktree database; do
    # Skip comments and empty lines
    [[ "$worktree" =~ ^#.*$ ]] && continue
    [[ -z "$worktree" ]] && continue

    echo "Checking: $worktree -> $database"

    # Check if worktree exists
    if [ ! -d "worktrees/$worktree" ]; then
        echo "  ⚠️  Worktree not found: worktrees/$worktree"
        continue
    fi

    # Check .env database setting
    ENV_DB=$(grep "^DB_DATABASE=" "worktrees/$worktree/.env" | cut -d= -f2)
    if [ "$ENV_DB" != "$database" ]; then
        echo "  ❌ Mismatch! .env has: $ENV_DB"
    else
        echo "  ✅ Paired correctly"
    fi

    # Check if database exists
    if mysql -u root -p -e "USE \`$database\`" 2>/dev/null; then
        echo "  ✅ Database exists"
    else
        echo "  ⚠️  Database not found: $database"
    fi

done < "$PAIRS_FILE"
```

---

## Application URL Configuration

### URL Naming Convention

**Pattern:**
```
{project}-{variant}-{environment}-{number}.trylatest.in
```

**Examples:**
```
psp-p2p-merchant-preview-2.trylatest.in
psp-p2p-merchant-preview-3.trylatest.in
psp-p2p-admin-staging-1.trylatest.in
psp-landing-preview-2.trylatest.in
```

### Apache Virtual Host Configuration

**Template:**
```apache
# /etc/apache2/sites-available/worktree-preview.conf.template

<VirtualHost *:443>
    ServerName ${WORKTREE_URL}
    DocumentRoot ${WORKTREE_PATH}/public

    <Directory ${WORKTREE_PATH}/public>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/${WORKTREE_NAME}-error.log
    CustomLog ${APACHE_LOG_DIR}/${WORKTREE_NAME}-access.log combined

    # SSL Configuration (managed by Certbot)
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/${WORKTREE_URL}/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/${WORKTREE_URL}/privkey.pem
    Include /etc/letsencrypt/options-ssl-apache.conf
</VirtualHost>
```

**Generation Script:**
```bash
#!/bin/bash
# scripts/create-worktree-vhost.sh

set -e

WORKTREE_NAME=$1
WORKTREE_NUMBER=$(echo "$WORKTREE_NAME" | grep -oP '\d+$')
WORKTREE_PATH="/home/lkonga/codes/psp-p2p/worktrees/$WORKTREE_NAME"
WORKTREE_URL="psp-p2p-merchant-preview-$WORKTREE_NUMBER.trylatest.in"

VHOST_FILE="/etc/apache2/sites-available/$WORKTREE_NAME.conf"

echo "Creating virtual host for $WORKTREE_NAME"

# Create vhost config
sudo tee "$VHOST_FILE" > /dev/null <<EOF
<VirtualHost *:443>
    ServerName $WORKTREE_URL
    DocumentRoot $WORKTREE_PATH/public

    <Directory $WORKTREE_PATH/public>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/$WORKTREE_NAME-error.log
    CustomLog \${APACHE_LOG_DIR}/$WORKTREE_NAME-access.log combined

    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/$WORKTREE_URL/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/$WORKTREE_URL/privkey.pem
    Include /etc/letsencrypt/options-ssl-apache.conf
</VirtualHost>

<VirtualHost *:80>
    ServerName $WORKTREE_URL
    Redirect permanent / https://$WORKTREE_URL/
</VirtualHost>
EOF

# Enable site
sudo a2ensite "$WORKTREE_NAME"

# Reload Apache
sudo systemctl reload apache2

echo "✅ Virtual host created: $WORKTREE_URL"
```

### Cloudflare Tunnel Configuration

**Tunnel Config:**
```yaml
# ~/.cloudflared/config.yml

tunnel: your-tunnel-id
credentials-file: /home/lkonga/.cloudflared/your-tunnel-id.json

ingress:
  - hostname: psp-p2p-merchant-preview-2.trylatest.in
    service: https://localhost:443
    originRequest:
      noTLSVerify: true

  - hostname: psp-p2p-merchant-preview-3.trylatest.in
    service: https://localhost:443
    originRequest:
      noTLSVerify: true

  - hostname: psp-landing-preview-2.trylatest.in
    service: https://localhost:443
    originRequest:
      noTLSVerify: true

  - service: http_status:404
```

---

## Worktree-Specific Configuration

### Storage Links

```bash
#!/bin/bash
# scripts/setup-worktree-storage.sh

WORKTREE_PATH=$1

echo "Setting up storage for $WORKTREE_PATH"

# Remove default storage symlink
rm -rf "$WORKTREE_PATH/public/storage"

# Create storage link
php "$WORKTREE_PATH/artisan" storage:link

# Set permissions
chmod -R 775 "$WORKTREE_PATH/storage"
chmod -R 775 "$WORKTREE_PATH/bootstrap/cache"

echo "✅ Storage configured"
```

### Cache Configuration

**Redis prefix strategy:**
```php
// config/database.php (per worktree)

'redis' => [
    'client' => env('REDIS_CLIENT', 'phpredis'),

    'options' => [
        'cluster' => env('REDIS_CLUSTER', 'redis'),
        'prefix' => env('REDIS_PREFIX', 'preview_2:'),
    ],

    'default' => [
        'host' => env('REDIS_HOST', '127.0.0.1'),
        'password' => env('REDIS_PASSWORD', null),
        'port' => env('REDIS_PORT', 6379),
        'database' => env('REDIS_DB', 0),
    ],
],
```

### Session Configuration

**File-based sessions (default):**
```php
// config/session.php

'driver' => env('SESSION_DRIVER', 'file'),
'files' => storage_path('framework/sessions'),
```

**Redis-based sessions (recommended for worktrees):**
```php
'driver' => env('SESSION_DRIVER', 'redis'),
'connection' => 'default',
```

---

## Configuration Validation

### Validation Script

```bash
#!/bin/bash
# scripts/validate-worktree-config.sh

WORKTREE_PATH=$1

echo "Validating configuration for: $WORKTREE_PATH"

# Check .env exists
if [ ! -f "$WORKTREE_PATH/.env" ]; then
    echo "❌ .env file not found"
    exit 1
fi

# Check APP_KEY is set
APP_KEY=$(grep "^APP_KEY=" "$WORKTREE_PATH/.env" | cut -d= -f2)
if [ -z "$APP_KEY" ] || [ "$APP_KEY" = "" ]; then
    echo "❌ APP_KEY not set"
    exit 1
fi

# Check database connection
DB_NAME=$(grep "^DB_DATABASE=" "$WORKTREE_PATH/.env" | cut -d= -f2)
if ! mysql -u root -p -e "USE \`$DB_NAME\`" 2>/dev/null; then
    echo "❌ Database not accessible: $DB_NAME"
    exit 1
fi

# Check APP_URL is set
APP_URL=$(grep "^APP_URL=" "$WORKTREE_PATH/.env" | cut -d= -f2)
if [ -z "$APP_URL" ] || [ "$APP_URL" = "http://localhost" ]; then
    echo "⚠️  APP_URL not configured for preview"
fi

# Check storage link
if [ ! -L "$WORKTREE_PATH/public/storage" ]; then
    echo "⚠️  Storage link not created"
fi

# Check permissions
if [ ! -w "$WORKTREE_PATH/storage" ]; then
    echo "⚠️  Storage directory not writable"
fi

echo "✅ Configuration validation complete"
```

---

## Multi-Environment Setup

### Development vs Staging vs Production

**Environment Matrix:**

| Setting | Development | Staging (Preview) | Production |
|---------|-------------|-------------------|------------|
| APP_ENV | local | staging | production |
| APP_DEBUG | true | true | false |
| Cache Driver | file | redis | redis |
| Queue Driver | sync | redis | redis |
| Session Driver | file | redis | redis |
| Log Channel | stack | daily | slack |

### Conditional Configuration

```php
// config/app.php

'debug' => (bool) env('APP_DEBUG', false),

'log_level' => env('LOG_LEVEL', 'debug'),

'providers' => [
    // ...

    // Development only
    App\Providers\LocalServiceProvider::class,

    // Production only
    // App\Providers\ProductionServiceProvider::class,
],
```

---

## Configuration Best Practices

### 1. Never Commit .env Files
```gitignore
.env
.env.*
!.env.example
```

### 2. Use Environment-Specific Defaults
```php
// Good
'cache_ttl' => env('CACHE_TTL', 3600),

// Bad - no default
'cache_ttl' => env('CACHE_TTL'),
```

### 3. Document Required Variables
```env
# .env.example

# Required: Application encryption key (generate with: php artisan key:generate)
APP_KEY=

# Required: Database credentials
DB_DATABASE=
DB_USERNAME=
DB_PASSWORD=

# Optional: Redis configuration (defaults to localhost)
REDIS_HOST=127.0.0.1
```

### 4. Use Configuration Caching
```bash
# Production only
php artisan config:cache

# Development - clear cache after changes
php artisan config:clear
```

### 5. Validate Configuration on Boot
```php
// app/Providers/AppServiceProvider.php

public function boot()
{
    if (app()->environment('production')) {
        $this->validateProductionConfig();
    }
}

private function validateProductionConfig()
{
    $required = ['APP_KEY', 'DB_DATABASE', 'REDIS_HOST'];

    foreach ($required as $key) {
        if (empty(env($key))) {
            throw new \RuntimeException("Missing required environment variable: $key");
        }
    }
}
```

---

## Troubleshooting

### Configuration Cache Issues
```bash
# Clear all caches
php artisan optimize:clear

# Individual cache clearing
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear
```

### Environment Variable Not Loading
```bash
# Check .env file permissions
ls -la .env

# Verify .env is in project root
pwd
ls -la .env

# Test environment variable
php artisan tinker
>>> env('YOUR_VARIABLE')
```

### Database Connection Issues
```bash
# Test database connection
php artisan tinker
>>> DB::connection()->getPdo()

# Check database exists
mysql -u root -p -e "SHOW DATABASES LIKE 'psp%';"
```

---

## Related Skills

- `worktree-commands` - Git worktree command reference
- `worktree-cleanup` - Cleanup and maintenance procedures
- `vps-laravel-deployment` - Laravel deployment patterns

## References

- [Laravel Environment Configuration](https://laravel.com/docs/configuration)
- [Laravel Database Configuration](https://laravel.com/docs/database#configuration)
- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
