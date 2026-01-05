# VPS Laravel Application Deployment Patterns

<!-- Purpose: Laravel-specific deployment patterns for various architectures -->
<!-- Related: vps-laravel-deployment skill -->

## Overview

This document outlines deployment patterns for different Laravel application architectures, from simple API-only services to complex full-stack applications with queue workers and schedulers.

## Architecture Patterns

### 1. API-Only Laravel Application

**Characteristics:**
- No frontend assets
- RESTful or GraphQL API
- JWT/Sanctum authentication
- Optimized for performance

**Directory Structure:**
```
/var/www/laravel-api/
├── current -> releases/20231219120000
├── releases/
│   └── 20231219120000/
├── shared/
│   ├── .env
│   └── storage/
└── repo/
```

**Nginx Configuration:**
```nginx
server {
    listen 80;
    server_name api.example.com;
    root /var/www/laravel-api/current/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

**Optimization:**
```bash
# .env configuration
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.example.com

# Cache optimization
php artisan config:cache
php artisan route:cache
php artisan view:cache

# OPcache configuration
php artisan optimize
```

**Deployment Script:**
```bash
#!/bin/bash
# deploy-api.sh

set -e

DEPLOY_PATH="/var/www/laravel-api"
RELEASE_NAME=$(date +%Y%m%d%H%M%S)
RELEASE_PATH="$DEPLOY_PATH/releases/$RELEASE_NAME"

echo "Creating new release: $RELEASE_NAME"

# Clone repository
git clone --depth 1 --branch main /path/to/repo.git "$RELEASE_PATH"

# Install dependencies
cd "$RELEASE_PATH"
composer install --no-dev --optimize-autoloader --no-interaction

# Link shared files
rm -rf storage
ln -s "$DEPLOY_PATH/shared/storage" storage
ln -s "$DEPLOY_PATH/shared/.env" .env

# Run migrations
php artisan migrate --force

# Optimize
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Switch current symlink
ln -sfn "$RELEASE_PATH" "$DEPLOY_PATH/current"

# Reload PHP-FPM
sudo systemctl reload php8.3-fpm

# Cleanup old releases (keep last 5)
cd "$DEPLOY_PATH/releases"
ls -1dt * | tail -n +6 | xargs rm -rf

echo "Deployment complete!"
```

---

### 2. Full-Stack Laravel Application

**Characteristics:**
- Frontend assets (Blade/Inertia/Livewire)
- Asset compilation (Vite/Mix)
- Session management
- File uploads

**Nginx Configuration:**
```nginx
server {
    listen 80;
    server_name example.com;
    root /var/www/laravel-app/current/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    # Frontend assets
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_buffer_size 32k;
        fastcgi_buffers 8 16k;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

**Asset Compilation (Vite):**
```javascript
// vite.config.js
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.js'],
            refresh: true,
        }),
    ],
    build: {
        manifest: true,
        outDir: 'public/build',
        rollupOptions: {
            output: {
                manualChunks: undefined,
            },
        },
    },
});
```

**Deployment Script:**
```bash
#!/bin/bash
# deploy-fullstack.sh

set -e

DEPLOY_PATH="/var/www/laravel-app"
RELEASE_NAME=$(date +%Y%m%d%H%M%S)
RELEASE_PATH="$DEPLOY_PATH/releases/$RELEASE_NAME"

echo "Creating new release: $RELEASE_NAME"

# Clone repository
git clone --depth 1 --branch main /path/to/repo.git "$RELEASE_PATH"

# Install PHP dependencies
cd "$RELEASE_PATH"
composer install --no-dev --optimize-autoloader --no-interaction

# Install Node dependencies and build assets
npm ci
npm run build

# Link shared directories
rm -rf storage
ln -s "$DEPLOY_PATH/shared/storage" storage
ln -s "$DEPLOY_PATH/shared/.env" .env

# Run migrations
php artisan migrate --force

# Clear and cache
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache

# Switch current symlink
ln -sfn "$RELEASE_PATH" "$DEPLOY_PATH/current"

# Reload services
sudo systemctl reload php8.3-fpm
sudo systemctl reload nginx

# Cleanup old releases
cd "$DEPLOY_PATH/releases"
ls -1dt * | tail -n +6 | xargs rm -rf

echo "Deployment complete!"
```

---

### 3. Microservices Architecture

**Characteristics:**
- Multiple Laravel applications
- Shared authentication
- Inter-service communication
- Independent deployments

**Service Structure:**
```
/var/www/
├── auth-service/
│   └── current/
├── user-service/
│   └── current/
├── order-service/
│   └── current/
└── shared/
    ├── cache/
    └── sessions/
```

**API Gateway Nginx:**
```nginx
upstream auth_service {
    server 127.0.0.1:8001;
}

upstream user_service {
    server 127.0.0.1:8002;
}

upstream order_service {
    server 127.0.0.1:8003;
}

server {
    listen 80;
    server_name api.example.com;

    location /api/auth/ {
        proxy_pass http://auth_service/;
        include proxy_params;
    }

    location /api/users/ {
        proxy_pass http://user_service/;
        include proxy_params;
    }

    location /api/orders/ {
        proxy_pass http://order_service/;
        include proxy_params;
    }
}
```

**Service Discovery:**
```php
// config/services.php
return [
    'auth' => [
        'url' => env('AUTH_SERVICE_URL', 'http://127.0.0.1:8001'),
        'key' => env('AUTH_SERVICE_KEY'),
    ],
    'user' => [
        'url' => env('USER_SERVICE_URL', 'http://127.0.0.1:8002'),
        'key' => env('USER_SERVICE_KEY'),
    ],
    'order' => [
        'url' => env('ORDER_SERVICE_URL', 'http://127.0.0.1:8003'),
        'key' => env('ORDER_SERVICE_KEY'),
    ],
];
```

---

## Queue Workers

### Single Queue Worker

**Supervisor Configuration:**
```ini
[program:laravel-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/laravel-app/current/artisan queue:work --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/laravel-app/current/storage/logs/worker.log
stopwaitsecs=3600
```

**Management Commands:**
```bash
# Reload supervisor after deployment
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl restart laravel-worker:*

# Check worker status
sudo supervisorctl status laravel-worker:*
```

### Multiple Queue Workers

**Supervisor Configuration:**
```ini
[program:laravel-worker-default]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/laravel-app/current/artisan queue:work --queue=default --sleep=3 --tries=3
autostart=true
autorestart=true
user=www-data
numprocs=3
redirect_stderr=true
stdout_logfile=/var/www/laravel-app/current/storage/logs/worker-default.log

[program:laravel-worker-high]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/laravel-app/current/artisan queue:work --queue=high --sleep=1 --tries=5
autostart=true
autorestart=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/laravel-app/current/storage/logs/worker-high.log

[program:laravel-worker-low]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/laravel-app/current/artisan queue:work --queue=low --sleep=5 --tries=2
autostart=true
autorestart=true
user=www-data
numprocs=1
redirect_stderr=true
stdout_logfile=/var/www/laravel-app/current/storage/logs/worker-low.log
```

### Horizon (Redis Queue Manager)

**Installation:**
```bash
composer require laravel/horizon
php artisan horizon:install
```

**Configuration:**
```php
// config/horizon.php
'environments' => [
    'production' => [
        'supervisor-1' => [
            'connection' => 'redis',
            'queue' => ['default'],
            'balance' => 'auto',
            'processes' => 10,
            'tries' => 3,
            'timeout' => 60,
        ],
    ],
],
```

**Supervisor Configuration:**
```ini
[program:laravel-horizon]
process_name=%(program_name)s
command=php /var/www/laravel-app/current/artisan horizon
autostart=true
autorestart=true
user=www-data
redirect_stderr=true
stdout_logfile=/var/www/laravel-app/current/storage/logs/horizon.log
stopwaitsecs=3600
```

---

## Scheduler Setup

### Cron Configuration

```bash
# Edit crontab
sudo crontab -e -u www-data

# Add Laravel scheduler
* * * * * cd /var/www/laravel-app/current && php artisan schedule:run >> /dev/null 2>&1
```

### Monitoring Scheduler

**Scheduled Tasks:**
```php
// app/Console/Kernel.php
protected function schedule(Schedule $schedule)
{
    // Daily backup
    $schedule->command('backup:run')->daily()->at('02:00');

    // Hourly cache cleanup
    $schedule->command('cache:prune-stale-tags')->hourly();

    // Every 5 minutes queue check
    $schedule->command('queue:monitor redis:default --max=100')
        ->everyFiveMinutes();

    // Weekly report
    $schedule->command('report:weekly')->weekly()->mondays()->at('09:00');
}
```

**Health Checks:**
```bash
# Check if scheduler is running
php artisan schedule:list

# Test scheduler manually
php artisan schedule:run

# Monitor scheduler output
php artisan schedule:work
```

---

## Optimization Techniques

### Database Optimization

**Connection Pool:**
```php
// config/database.php
'mysql' => [
    'driver' => 'mysql',
    'host' => env('DB_HOST', '127.0.0.1'),
    'port' => env('DB_PORT', '3306'),
    'database' => env('DB_DATABASE', 'forge'),
    'username' => env('DB_USERNAME', 'forge'),
    'password' => env('DB_PASSWORD', ''),
    'charset' => 'utf8mb4',
    'collation' => 'utf8mb4_unicode_ci',
    'prefix' => '',
    'strict' => true,
    'engine' => 'InnoDB',
    'options' => [
        PDO::ATTR_PERSISTENT => true,
        PDO::ATTR_EMULATE_PREPARES => false,
    ],
],
```

**Query Optimization:**
```php
// Use eager loading
$users = User::with(['posts', 'comments'])->get();

// Use chunk for large datasets
User::chunk(200, function ($users) {
    foreach ($users as $user) {
        // Process user
    }
});

// Use select to limit columns
User::select('id', 'name', 'email')->get();
```

### Cache Strategy

**Configuration:**
```php
// config/cache.php
'default' => env('CACHE_DRIVER', 'redis'),

'stores' => [
    'redis' => [
        'driver' => 'redis',
        'connection' => 'cache',
        'lock_connection' => 'default',
    ],
],
```

**Usage Patterns:**
```php
// Cache query results
$users = Cache::remember('users:active', 3600, function () {
    return User::where('active', true)->get();
});

// Cache with tags (Redis/Memcached only)
Cache::tags(['users', 'active'])->put('users:active', $users, 3600);

// Invalidate tagged cache
Cache::tags(['users'])->flush();
```

### PHP-FPM Optimization

```ini
; /etc/php/8.3/fpm/pool.d/www.conf

; Dynamic process manager
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 500

; Performance
pm.process_idle_timeout = 10s

; Status endpoint
pm.status_path = /fpm-status
```

### OPcache Configuration

```ini
; /etc/php/8.3/fpm/conf.d/10-opcache.ini

opcache.enable=1
opcache.memory_consumption=256
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=20000
opcache.revalidate_freq=0
opcache.validate_timestamps=0
opcache.save_comments=1
opcache.fast_shutdown=1
```

---

## Monitoring and Logging

### Application Monitoring

**Laravel Telescope:**
```bash
composer require laravel/telescope --dev
php artisan telescope:install
php artisan migrate
```

**Production Configuration:**
```php
// config/telescope.php
'enabled' => env('TELESCOPE_ENABLED', false),

'middleware' => [
    'web',
    Authorize::class,
],
```

### Performance Monitoring

**Laravel Debugbar (Development):**
```bash
composer require barryvdh/laravel-debugbar --dev
```

**New Relic (Production):**
```bash
# Install New Relic PHP agent
wget -O - https://download.newrelic.com/548C16BF.gpg | sudo apt-key add -
echo "deb http://apt.newrelic.com/debian/ newrelic non-free" | sudo tee /etc/apt/sources.list.d/newrelic.list
sudo apt-get update
sudo apt-get install newrelic-php5
```

### Log Management

**Configuration:**
```php
// config/logging.php
'channels' => [
    'stack' => [
        'driver' => 'stack',
        'channels' => ['single', 'slack'],
        'ignore_exceptions' => false,
    ],

    'single' => [
        'driver' => 'single',
        'path' => storage_path('logs/laravel.log'),
        'level' => env('LOG_LEVEL', 'debug'),
    ],

    'slack' => [
        'driver' => 'slack',
        'url' => env('LOG_SLACK_WEBHOOK_URL'),
        'username' => 'Laravel Log',
        'emoji' => ':boom:',
        'level' => 'critical',
    ],
],
```

**Log Rotation:**
```bash
# /etc/logrotate.d/laravel
/var/www/laravel-app/current/storage/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data www-data
    sharedscripts
    postrotate
        /usr/bin/systemctl reload php8.3-fpm > /dev/null 2>&1 || true
    endscript
}
```

---

## Security Best Practices

### Environment Variables

```bash
# Never commit .env files
# Use environment-specific .env files
.env.production
.env.staging
.env.local
```

### File Permissions

```bash
# Set correct ownership
sudo chown -R www-data:www-data /var/www/laravel-app/current

# Set directory permissions
find /var/www/laravel-app/current -type d -exec chmod 755 {} \;

# Set file permissions
find /var/www/laravel-app/current -type f -exec chmod 644 {} \;

# Storage and cache need write permissions
chmod -R 775 /var/www/laravel-app/current/storage
chmod -R 775 /var/www/laravel-app/current/bootstrap/cache
```

### Security Headers

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
```

---

## Related Skills

- `vps-generic-deployment` - Generic VPS deployment patterns
- `worktree-orchestration` - Multi-environment setup with worktrees
- `cloudflare-tunneling` - Secure development tunneling

## References

- [Laravel Deployment Documentation](https://laravel.com/docs/deployment)
- [Laravel Forge](https://forge.laravel.com/docs)
- [Envoyer Deployment](https://envoyer.io/docs)
- [Laravel Horizon Documentation](https://laravel.com/docs/horizon)
- [Laravel Telescope Documentation](https://laravel.com/docs/telescope)
