# VPS Generic Deployment Strategies

<!-- Purpose: Document deployment strategies for different application types -->
<!-- Related: vps-generic-deployment skill -->

## Overview

This document outlines deployment strategies for various web application types on VPS environments, helping you choose the right approach for your project.

## Strategy Selection Matrix

| Application Type | Recommended Strategy | Complexity | Use Case |
|-----------------|---------------------|------------|----------|
| Static Sites | Direct file copy | Low | Simple HTML/CSS/JS sites |
| Static Site Generators (SSG) | Build + Deploy | Medium | Blogs, documentation sites |
| Single Page Apps (SPA) | Build + Nginx | Medium | React, Vue, Angular apps |
| Progressive Web Apps (PWA) | Build + Service Worker | Medium-High | Offline-capable apps |

## Deployment Strategies

### 1. Direct File Copy Strategy

**Best for:** Simple static websites with no build process

**Process:**
- Upload files directly to web root
- Configure web server (Nginx/Apache)
- Set proper permissions

**Advantages:**
- Simplest approach
- No build dependencies
- Fast deployment

**Tradeoffs:**
- No optimization
- Manual cache busting
- Limited scalability

**Example:**
```bash
# Copy files to VPS
scp -r ./public/* user@vps:/var/www/html/

# Set permissions
ssh user@vps "sudo chown -R www-data:www-data /var/www/html/"
```

### 2. Build + Deploy Strategy

**Best for:** Static site generators (Hugo, Jekyll, Eleventy)

**Process:**
1. Build locally or on VPS
2. Deploy built artifacts
3. Configure web server
4. Set up automated rebuilds

**Advantages:**
- Optimized output
- Version control integration
- Automated deployments possible

**Tradeoffs:**
- Requires build tooling
- More complex setup
- Build time overhead

**Example:**
```bash
# Build locally
npm run build

# Deploy built files
rsync -avz --delete ./dist/ user@vps:/var/www/html/

# Or build on VPS
ssh user@vps "cd /var/www/src && git pull && npm run build"
```

### 3. SPA Build + Nginx Strategy

**Best for:** React, Vue, Angular applications

**Process:**
1. Build production bundle
2. Configure Nginx for client-side routing
3. Deploy to VPS
4. Set up cache headers

**Advantages:**
- Client-side routing support
- Asset optimization
- CDN-friendly

**Tradeoffs:**
- Requires proper routing config
- Initial load time
- SEO considerations

**Example Nginx Config:**
```nginx
server {
    listen 80;
    server_name example.com;
    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### 4. Git-Based Deployment Strategy

**Best for:** Projects with continuous updates

**Process:**
1. Set up git repository on VPS
2. Clone project to web root
3. Configure post-receive hooks
4. Automate build on push

**Advantages:**
- Version control integration
- Automated deployments
- Easy rollbacks

**Tradeoffs:**
- Requires git setup
- Build dependencies on VPS
- More complex troubleshooting

**Example:**
```bash
# On VPS: Set up bare repo
git init --bare ~/deploy.git

# Create post-receive hook
cat > ~/deploy.git/hooks/post-receive << 'EOF'
#!/bin/bash
GIT_WORK_TREE=/var/www/html git checkout -f
cd /var/www/html && npm install && npm run build
EOF

chmod +x ~/deploy.git/hooks/post-receive

# On local: Add remote and push
git remote add production user@vps:deploy.git
git push production main
```

## Strategy Selection Guide

### Choose Direct File Copy When:
- Site is pure HTML/CSS/JS
- No build process needed
- Quick prototyping
- Simple content updates

### Choose Build + Deploy When:
- Using SSG (Hugo, Jekyll, Eleventy)
- Need optimization
- Content-focused sites
- Blog or documentation

### Choose SPA Build + Nginx When:
- React/Vue/Angular application
- Client-side routing required
- Rich interactive features
- Progressive Web App

### Choose Git-Based Deployment When:
- Team collaboration
- Frequent updates
- Need version control
- Automated CI/CD pipeline

## Performance Considerations

### Asset Optimization
- Minify CSS/JS
- Compress images
- Enable Brotli/Gzip
- Implement lazy loading

### Caching Strategy
```nginx
# Static assets (1 year)
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# HTML files (no cache)
location ~* \.html$ {
    expires -1;
    add_header Cache-Control "no-store, no-cache, must-revalidate";
}
```

### CDN Integration
- Use CDN for static assets
- Configure origin server
- Set proper headers
- Implement cache invalidation

## Security Best Practices

### File Permissions
```bash
# Web root ownership
sudo chown -R www-data:www-data /var/www/html/

# Directory permissions
find /var/www/html -type d -exec chmod 755 {} \;

# File permissions
find /var/www/html -type f -exec chmod 644 {} \;
```

### SSL/TLS Configuration
- Use Let's Encrypt for SSL certificates
- Configure HTTPS redirect
- Enable HTTP/2
- Set security headers

### Access Control
- Restrict sensitive files
- Disable directory listing
- Implement rate limiting
- Use firewall rules

## Monitoring and Maintenance

### Health Checks
- Monitor uptime
- Check response times
- Track error rates
- Monitor resource usage

### Backup Strategy
- Regular file backups
- Database backups (if applicable)
- Automated backup scripts
- Off-site backup storage

### Update Procedures
- Test updates locally
- Use staging environment
- Implement rollback plan
- Monitor after deployment

## Related Skills

- `vps-generic-applications` - Application-specific deployment patterns
- `vps-laravel-deployment` - Laravel-specific deployment
- `cloudflare-tunneling` - Secure tunneling for development

## References

- [Nginx Documentation](https://nginx.org/en/docs/)
- [Static Site Generators](https://jamstack.org/generators/)
- [Web Performance Best Practices](https://web.dev/performance/)
