# CF Launcher + VPS Deployment Integration

This guide shows how to integrate CF Launcher with VPS deployment workflows for local testing and hybrid deployments.

## Use Cases

### 1. Local Development with VPS-like URLs
Test local deployments with public URLs before pushing to VPS

### 2. Hybrid VPS + Cloudflare Setup
Deploy to VPS but use Cloudflare tunnels for specific services

### 3. Staging Environment Access
Provide temporary public access to VPS staging sites

## Local Testing Before VPS Deployment

### Static Site Testing

```bash
# 1. Deploy locally (Apache/Nginx)
# Configure server to serve site on localhost:8080

# 2. Create tunnel for testing
./scripts/cf-launcher.sh --config my-site-local --no-browser

# 3. Check status
./scripts/cf-launcher.sh status

# 4. Test with public URL provided by tunnel

# 5. Clean up after testing
./scripts/cf-launcher.sh --kill-config my-site-local
```

### Node.js Application Testing

```bash
# 1. Start Node.js app locally
npm run dev  # Running on localhost:3000

# 2. Create tunnel with specific configuration
./scripts/cf-launcher.sh --config nodejs-app-local

# 3. Test API endpoints through tunnel
curl https://nodejs-app-local.trylatest.in/api/test

# 4. Verify functionality before VPS deployment
```

## Hybrid VPS + Cloudflare Deployment

### Option 1: VPS as Origin, Cloudflare for Access

```bash
# 1. Deploy application to VPS
# Application running on VPS at port 8080

# 2. Create tunnel pointing to VPS
# Configuration in ~/.cloudflared/psp-p2p/config-vps-app.yml:
# tunnel: VPS_TUNNEL_ID
# credentials-file: /path/to/credentials.json
# ingress:
#   - hostname: vps-app.trylatest.in
#     service: http://37.60.247.12:8080

# 3. Start tunnel
./scripts/cf-launcher.sh --config vps-app

# 4. Access through Cloudflare edge
# https://vps-app.trylatest.in
```

### Option 2: Local Development, VPS Database

```bash
# 1. Start application locally with VPS database
# DATABASE_URL=mysql://user:pass@37.60.247.12/dbname
npm run dev

# 2. Create tunnel for local app
./scripts/cf-launcher.sh --config local-app-vps-db

# 3. Test with VPS database
```

## Staging Environment Access

### Temporary Public Access

```bash
# 1. Deploy staging version to VPS
# Staging running on port 8081

# 2. Create temporary tunnel
./scripts/cf-launcher.sh --config staging-temp --no-browser

# 3. Share URL with stakeholders
# URL: https://staging-temp.trylatest.in

# 4. Remove access after review
./scripts/cf-launcher.sh --kill-config staging-temp
```

### Multiple Staging Environments

```bash
# 1. Create configuration file for multiple staging sites
cat > staging-sites.txt << EOF
staging-frontend
staging-api
staging-admin
EOF

# 2. Start all staging tunnels
./scripts/cf-launcher.sh --config-file staging-sites.txt

# 3. Review all staging sites
./scripts/cf-launcher.sh status --list-configs

# 4. Clean up after review
./scripts/cf-launcher.sh --kill
```

## Configuration Examples

### Basic Local Development Config

```yaml
# ~/.cloudflared/psp-p2p/config-local-dev.yml
tunnel: LOCAL_TUNNEL_ID
credentials-file: /home/user/.cloudflared/LOCAL_TUNNEL_ID.json

ingress:
  - hostname: local-dev.trylatest.in
    service: http://localhost:8080
  - service: http_status:404
```

### VPS Origin Config

```yaml
# ~/.cloudflared/psp-p2p/config-vps-origin.yml
tunnel: VPS_TUNNEL_ID
credentials-file: /home/user/.cloudflared/VPS_TUNNEL_ID.json

ingress:
  - hostname: vps-app.trylatest.in
    service: http://37.60.247.12:8080
  - service: http_status:404
```

### Multi-Service Config

```yaml
# ~/.cloudflared/psp-p2p/config-multi-service.yml
tunnel: MULTI_TUNNEL_ID
credentials-file: /home/user/.cloudflared/MULTI_TUNNEL_ID.json

ingress:
  - hostname: api.trylatest.in
    service: http://localhost:3000
  - hostname: app.trylatest.in
    service: http://localhost:8080
  - hostname: admin.trylatest.in
    service: http://localhost:9090
  - service: http_status:404
```

## Deployment Workflow Integration

### Pre-Deployment Testing

```bash
#!/bin/bash
# pre-deploy-test.sh

SITE_NAME="$1"
LOCAL_PORT="$2"

# Start local server
npm run dev &

# Create tunnel
./scripts/cf-launcher.sh --config "$SITE_NAME-test" --no-browser

# Get tunnel URL
TUNNEL_URL=$(./scripts/cf-launcher.sh status --list-configs | grep "$SITE_NAME-test" | awk '{print $3}')

# Run tests against tunnel URL
npm run test:remote -- --base-url="$TUNNEL_URL"

# Clean up
./scripts/cf-launcher.sh --kill-config "$SITE_NAME-test"
```

### Deployment Verification

```bash
#!/bin/bash
# verify-deployment.sh

SITE_NAME="$1"
VPS_IP="37.60.247.12"
VPS_PORT="$2"

# Create tunnel to VPS deployment
./scripts/cf-launcher.sh --config "$SITE_NAME-vps" --no-browser

# Get tunnel URL
TUNNEL_URL=$(./scripts/cf-launcher.sh status --list-configs | grep "$SITE_NAME-vps" | awk '{print $3}')

# Run smoke tests
curl -f "$TUNNEL_URL/health" || {
    echo "Health check failed"
    ./scripts/cf-launcher.sh --kill-config "$SITE_NAME-vps"
    exit 1
}

echo "Deployment verified successfully"
./scripts/cf-launcher.sh --kill-config "$SITE_NAME-vps"
```

## Best Practices

### Security
- Use HTTPS for all tunneled services
- Implement authentication on staging sites
- Limit tunnel exposure duration
- Use different subdomains for different environments

### Performance
- Test locally before VPS deployment
- Monitor tunnel performance
- Use appropriate timeouts
- Consider caching for static assets

### Management
- Label tunnels clearly (local, staging, vps)
- Clean up unused tunnels
- Document tunnel purposes
- Use configuration files for batch operations

## Troubleshooting

### VPS Connection Issues
```bash
# Check VPS service is running
ssh lkonga@37.60.247.12 "curl -I http://localhost:8080"

# Verify tunnel configuration
cat ~/.cloudflared/psp-p2p/config-vps-app.yml

# Check tunnel status
./scripts/cf-launcher.sh status | grep vps-app
```

### Local Port Conflicts
```bash
# Check what's using the port
lsof -i :8080

# Use different port for tunnel
# Update ingress service: http://localhost:8081
```

### DNS Propagation
```bash
# Check DNS resolution
dig vps-app.trylatest.in

# Force DNS refresh
sudo systemctl flush-dns  # macOS
```
