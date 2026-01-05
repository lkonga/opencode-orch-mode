# VPS Generic Advanced Workflows

## Multi-Strategy Deployments

### Deploy Same Application Multiple Ways

```bash
# 1. Deploy to VPS with Nginx + Let's Encrypt
cd /home/lkonga/codes/llm-rules/vps-asas
./deploy-vps.sh my-app

# 2. Deploy locally with Apache + Cloudflare
cd /path/to/my-app
sudo /home/lkonga/codes/llm-rules/vps-asas/deploy-local.sh my-app-local

# 3. Start tunnel for local
/home/lkonga/codes/llm-rules/scripts/cf-launcher.sh --config my-app-local

# Result:
# VPS:   https://staging.my-app.trylatest.in (Nginx + Let's Encrypt)
# Local: https://my-app-local.trylatest.in (Apache + Cloudflare)
```

## Build Process Optimization

### Node.js Applications

```bash
# Deploy with build caching
./deploy-vps.sh my-react-app

# On VPS, build is cached
ssh lkonga@37.60.247.12 "
  cd /var/www/worktrees/my-react-app

  # Check node_modules cached
  ls -la node_modules/

  # Rebuild if needed
  npm run build
"
```

### Static Site Generators

```bash
# Vite/Hugo/Jekyll applications
# Build automatically runs on VPS

# For local development:
cd /path/to/project

# Build locally
npm run build  # or hugo, jekyll build

# Deploy with pre-built artifacts
sudo /home/lkonga/codes/llm-rules/vps-asas/deploy-local.sh my-site
```

## Advanced Nginx Configuration

### Custom Nginx Rules

```bash
# Deploy application
./deploy-vps.sh my-api

# Add custom nginx rules
ssh lkonga@37.60.247.12 "
  sudo nano /etc/nginx/sites-available/staging.my-api

  # Add custom location blocks, headers, etc.

  # Test configuration
  sudo nginx -t

  # Reload nginx
  sudo systemctl reload nginx
"
```

### Reverse Proxy for APIs

```bash
# Deploy Node.js API with reverse proxy
./deploy-vps.sh my-node-api

# Configure nginx as reverse proxy
ssh lkonga@37.60.247.12 "
  sudo tee /etc/nginx/sites-available/staging.my-node-api > /dev/null << 'EOF'
server {
    listen 443 ssl http2;
    server_name staging.my-node-api.trylatest.in;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

  sudo nginx -t && sudo systemctl reload nginx
"
```

## Multi-Site Deployments

### Deploy Multiple Sites

```bash
# Deploy portfolio sites
for site in portfolio-site-1 portfolio-site-2 portfolio-site-3; do
  ./deploy-vps.sh \$site &
done
wait

# Verify all sites
for site in portfolio-site-1 portfolio-site-2 portfolio-site-3; do
  echo "Checking \$site..."
  curl -I https://staging.\${site}.trylatest.in
done
```

## WordPress Deployment (Advanced)

### Deploy WordPress with Database Setup

```bash
# 1. Deploy WordPress files
./deploy-vps.sh my-wordpress-site --skip-ssl

# 2. Create WordPress database
ssh lkonga@37.60.247.12 "
  mysql -uroot -p'Push@Parser2024!Secure' -e \"
    CREATE DATABASE wp_my_site;
    CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'secure_password';
    GRANT ALL PRIVILEGES ON wp_my_site.* TO 'wp_user'@'localhost';
    FLUSH PRIVILEGES;
  \"
"

# 3. Configure wp-config.php
ssh lkonga@37.60.247.12 "
  cd /var/www/worktrees/my-wordpress-site
  sudo cp wp-config-sample.php wp-config.php
  sudo sed -i 's/database_name_here/wp_my_site/' wp-config.php
  sudo sed -i 's/username_here/wp_user/' wp-config.php
  sudo sed -i 's/password_here/secure_password/' wp-config.php
"

# 4. Setup SSL
ssh lkonga@37.60.247.12 "sudo certbot --nginx -d staging.my-wordpress-site.trylatest.in"
```

## Hybrid Deployments

### Local Development + VPS Production

```bash
# Local development with tunnels
cd /path/to/project
npm run dev &  # Start dev server

sudo /home/lkonga/codes/llm-rules/vps-asas/deploy-local.sh my-app-dev
/home/lkonga/codes/llm-rules/scripts/cf-launcher.sh --config my-app-dev

# VPS production deployment
cd /home/lkonga/codes/llm-rules/vps-asas
./deploy-vps.sh my-app-prod

# Result:
# Dev:  https://my-app-dev.trylatest.in (local with tunnel)
# Prod: https://staging.my-app-prod.trylatest.in (VPS)
```

## Blue-Green Deployment

### Deploy New Version Alongside Current

```bash
# Blue (current version)
# Already deployed: my-app

# Green (new version)
./deploy-vps.sh my-app-v2

# Test green version
curl https://staging.my-app-v2.trylatest.in

# Switch DNS/load balancer to point to v2
# Then remove v1

./deploy-vps.sh my-app --remove  # (if undeploy command exists)
```

## Monitoring Workflows

### Health Check All Deployments

```bash
#!/bin/bash
# check-all-sites.sh

SITES=(
  "staging.my-app-1.trylatest.in"
  "staging.my-app-2.trylatest.in"
  "staging.my-api.trylatest.in"
)

for SITE in "${SITES[@]}"; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://$SITE")
  echo "$SITE: HTTP $STATUS"
done
```

### Monitor Build Logs

```bash
# For deployments with build processes
ssh lkonga@37.60.247.12 "
  tail -f /var/www/worktrees/my-app/.build.log
"
```

## Performance Optimization

### Enable Gzip Compression

```bash
# Add to nginx configuration
ssh lkonga@37.60.247.12 "
  sudo tee -a /etc/nginx/sites-available/staging.my-app > /dev/null << 'EOF'

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_types text/plain text/css application/json application/javascript text/xml;
EOF

  sudo nginx -t && sudo systemctl reload nginx
"
```

### Browser Caching

```bash
# Add cache headers
ssh lkonga@37.60.247.12 "
  sudo tee -a /etc/nginx/sites-available/staging.my-app > /dev/null << 'EOF'

    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control \"public, immutable\";
    }
EOF

  sudo nginx -t && sudo systemctl reload nginx
"
```

## Security Enhancements

### Add Security Headers

```bash
ssh lkonga@37.60.247.12 "
  sudo tee -a /etc/nginx/sites-available/staging.my-app > /dev/null << 'EOF'

    # Security headers
    add_header X-Frame-Options \"SAMEORIGIN\" always;
    add_header X-Content-Type-Options \"nosniff\" always;
    add_header X-XSS-Protection \"1; mode=block\" always;
    add_header Referrer-Policy \"no-referrer-when-downgrade\" always;
EOF

  sudo nginx -t && sudo systemctl reload nginx
"
```

### Rate Limiting

```bash
ssh lkonga@37.60.247.12 "
  sudo tee /etc/nginx/conf.d/rate-limit.conf > /dev/null << 'EOF'
limit_req_zone \$binary_remote_addr zone=mylimit:10m rate=10r/s;
EOF

  # Add to site config
  sudo tee -a /etc/nginx/sites-available/staging.my-api > /dev/null << 'EOF'

    location /api/ {
        limit_req zone=mylimit burst=20;
        proxy_pass http://localhost:3000;
    }
EOF

  sudo nginx -t && sudo systemctl reload nginx
"
```

## Backup and Restore

### Backup Deployed Application

```bash
# Backup files
ssh lkonga@37.60.247.12 "
  cd /var/www/worktrees
  sudo tar -czf my-app.backup.tar.gz my-app/
"

# Download backup
scp lkonga@37.60.247.12:/var/www/worktrees/my-app.backup.tar.gz .
```

### Restore from Backup

```bash
# Upload backup
scp my-app.backup.tar.gz lkonga@37.60.247.12:/tmp/

# Restore
ssh lkonga@37.60.247.12 "
  cd /var/www/worktrees
  sudo rm -rf my-app
  sudo tar -xzf /tmp/my-app.backup.tar.gz
  sudo systemctl reload nginx
"
```

## CI/CD Integration

### GitHub Actions for Static Site

```yaml
name: Deploy Static Site

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Build
        run: npm run build

      - name: Deploy to VPS
        run: |
          ssh lkonga@37.60.247.12 "
            cd /home/lkonga/codes/llm-rules/vps-asas
            ./deploy-vps.sh my-static-site --quick
          "
```

## Advanced Cloudflare Tunnel Management

### Multiple Tunnels for Different Environments

```bash
# Development tunnel
./scripts/cf-launcher.sh --config my-app-dev

# Staging tunnel
./scripts/cf-launcher.sh append --config my-app-staging

# Production tunnel
./scripts/cf-launcher.sh append --config my-app-prod

# Check all tunnels
./scripts/cf-launcher.sh status --list-configs
```

## Best Practices Summary

**Strategy Selection**:
- VPS + Nginx: Production static sites, SPAs, APIs
- Local + Apache: Development, preview environments
- Hybrid: Local dev + VPS production

**Build Optimization**:
- Use caching for dependencies
- Minimize build artifacts
- Leverage CDN for assets

**Security**:
- Always use HTTPS (Let's Encrypt or Cloudflare)
- Add security headers
- Implement rate limiting for APIs
- Keep dependencies updated

**Performance**:
- Enable gzip compression
- Configure browser caching
- Use reverse proxy for APIs
- Monitor resource usage

**Maintenance**:
- Regular backups before major changes
- Clean up old deployments
- Monitor SSL certificate expiry
- Update nginx configurations as needed
