# VPS Infrastructure Reference

## Access Information

**VPS IP**: 37.60.247.12
**SSH User**: lkonga
**Sudo Password**: $$$123123
**Database Root Password**: Push@Parser2024!Secure
**Domain**: trylatest.in (Cloudflare managed)

## SSH Key Authentication

Ensure SSH keys are set up for passwordless SSH connection:
```bash
# Test SSH connection
ssh lkonga@37.60.247.12 "whoami"

# If prompted for password, set up SSH key:
ssh-keygen -t ed25519
ssh-copy-id lkonga@37.60.247.12
```

## Software Stack

**Operating System**: Ubuntu 24.04.3 LTS

**Web Servers**:
- Nginx 1.24.0 + PHP-FPM 8.3.27 (default for Laravel/PHP)
- Apache 2.4.x (available for specific needs)

**Database**: MariaDB 10.11.13

**Runtime & Tools**:
- Composer 2.9.1+
- Node.js 16+ (for build processes)
- Let's Encrypt Certbot (SSL certificates)
- Git (repository management)

## VPS Paths

### Application Directories
- **Worktrees**: `/var/www/worktrees/`
  - All deployed applications live here
  - Each worktree is a subdirectory: `/var/www/worktrees/{name}/`

### Management Scripts
- **Central Scripts**: `/opt/llm-rules/`
  - Repository: yzgyzinc/llm-rules (develop branch)
  - Test runner: `/opt/llm-rules/scripts/templates/run_full_test_suite.sh`
- **VPS Scripts**: `/opt/scripts/`
  - `db-manager.sh` - Database operations
  - `dns-manager.sh` - DNS CNAME management
  - `nginx-manager.sh` - Nginx configuration
  - `ssl-manager.sh` - SSL certificate management

### Configuration Directories
- **Nginx Config**: `/etc/nginx/sites-available/`
- **Apache Config**: `/etc/apache2/sites-available/`
- **SSL Certificates**: `/etc/letsencrypt/live/`
- **PHP-FPM Pools**: `/etc/php/8.3/fpm/pool.d/`

### Local Development Paths
- **Source Scripts**: `/home/lkonga/codes/llm-rules/scripts/vps/`
  - Local copy of VPS deployment scripts
  - Sync to VPS when needed

## Server Configuration

### Nginx Virtual Host Template
```nginx
server {
    listen 80;
    server_name staging.{name}.trylatest.in;
    root /var/www/worktrees/{name}/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm-{name}.sock;
    }
}
```

### Apache Virtual Host Template
```apache
<VirtualHost *:80>
    ServerName {name}.trylatest.in
    DocumentRoot /var/www/worktrees/{name}/public

    <Directory /var/www/worktrees/{name}/public>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

## Automated Sudo Operations

For automated workflows without interactive prompts, use these methods:

### Method 1: Using echo with variable (Recommended)
```bash
# Working pattern from production scripts
SUDO_PASS="$$$123123"
VPS_HOST="lkonga@37.60.247.12"
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'command'"
```

**Example Operations**:
```bash
SUDO_PASS="$$$123123"
VPS_HOST="lkonga@37.60.247.12"

# List worktrees
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'ls -la /var/www/worktrees/'"

# Restart services
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'systemctl restart nginx php8.3-fpm'"

# Check database
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'mysql -u root -pPush@Parser2024!Secure -e \"SHOW DATABASES;\"'"
```

### Method 2: Using vps_exec wrapper
```bash
# Requires sshpass: sudo apt install sshpass
source /home/lkonga/codes/llm-rules/scripts/vps/helpers/vps-common.sh
vps_exec "command"
```

**Example Operations**:
```bash
source /home/lkonga/codes/llm-rules/scripts/vps/helpers/vps-common.sh

# List worktrees
vps_exec "ls -la /var/www/worktrees/"

# Restart services
vps_exec "systemctl restart nginx php8.3-fpm"
```

### Method 3: Using expect script (VPSSudoPassword skill)
```bash
/home/lkonga/codes/llm-rules/scripts/vps/helpers/vps-sudo.sh "command"
```

## Database Management

### Root Access
```bash
mysql -u root -p'Push@Parser2024!Secure'
```

### Database Naming Convention
- **Staging databases**: `{app_name}_staging`
- **Testing databases**: `{app_name}_testing`

### Common Operations
```bash
# Show all databases
ssh lkonga@37.60.247.12 "mysql -u root -p'Push@Parser2024\!Secure' -e 'SHOW DATABASES;'"

# Check specific database
ssh lkonga@37.60.247.12 "mysql -u root -p'Push@Parser2024\!Secure' -e 'SHOW DATABASES LIKE \"%{name}%\";'"

# Create database
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'mysql -u root -pPush@Parser2024!Secure -e \"CREATE DATABASE app_db;\"'"
```

## DNS Management

**Cloudflare Configuration**:
- All DNS records managed through Cloudflare API
- Automatic CNAME creation for new deployments
- Pattern: `staging.{name}.trylatest.in` → `37.60.247.12`

**Propagation Time**: 1-5 minutes

**Verification**:
```bash
dig staging.{name}.trylatest.in +short
# Should return: 37.60.247.12
```

## SSL Certificate Management

**Let's Encrypt via Certbot**:
- Automatic SSL certificates for all deployments
- 90-day validity with auto-renewal
- Rate limit: 5 certificates per week per domain

**Manual Certificate Operations**:
```bash
# Obtain certificate
ssh lkonga@37.60.247.12 "sudo certbot --nginx -d staging.{name}.trylatest.in"

# Check expiration
curl -vI https://staging.{name}.trylatest.in 2>&1 | grep "expire"

# Test renewal
ssh lkonga@37.60.247.12 "sudo certbot renew --dry-run"
```

## File Permissions

**Standard Ownership**:
```bash
# Web files
sudo chown -R www-data:www-data /var/www/worktrees/{name}

# Application directories
sudo chmod -R 755 /var/www/worktrees/{name}
sudo chmod -R 775 /var/www/worktrees/{name}/storage
sudo chmod -R 775 /var/www/worktrees/{name}/bootstrap/cache
```

## Service Management

**Restart Services**:
```bash
SUDO_PASS="$$$123123"
VPS_HOST="lkonga@37.60.247.12"

# Nginx + PHP-FPM
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'systemctl restart nginx php8.3-fpm'"

# Check service status
echo "$SUDO_PASS" | ssh "$VPS_HOST" "sudo -S bash -c 'systemctl status nginx php8.3-fpm'"
```

## Reference Documentation

**Official VPS Deployment Documentation**:
- `/home/lkonga/codes/llm-rules/scripts/vps/README-VPS-DEPLOYMENT-NEW.md`

**Helper Scripts Location**:
- `/home/lkonga/codes/llm-rules/scripts/vps/helpers/`
