# CF Launcher Advanced Usage

## Custom Configuration Directory

Instead of using the default configuration directory (`~/.cloudflared/psp-p2p/`), you can specify a custom path:

```bash
# Use custom configuration directory
./scripts/cf-launcher.sh --config-dir /path/to/configs --config myapp
```

**Use Cases**:
- Managing multiple Cloudflare accounts
- Isolating tunnel configurations per project
- Testing configuration changes without affecting defaults

**Requirements**:
- Custom directory must contain valid Cloudflare tunnel configurations
- Configuration files must follow naming pattern: `config-{name}.yml`
- Directory must have proper read permissions

## Browser Integration

### Automatic Browser Launch

CF Launcher automatically opens tunnel URLs in incognito/private mode for cleaner testing:

**Browser Priority Order**:
1. **Brave** (highest priority)
2. Google Chrome
3. Chromium
4. Firefox

**Behavior**:
- Opens each tunnel URL in a separate incognito/private window
- Prevents cookie/session conflicts between tunnels
- Allows testing multiple environments simultaneously

### Disable Browser Launch

For automation or when you don't need browser tabs:

```bash
# Create tunnels without opening browsers
./scripts/cf-launcher.sh --config myapp --no-browser
```

**When to Use**:
- CI/CD pipelines
- Automated testing
- Background tunnel management
- Server environments without GUI

## Dry Run Mode

Plan tunnel operations without actually executing them:

```bash
# See what would be executed
./scripts/cf-launcher.sh --dry-run --config test-config

# Plan append operation
./scripts/cf-launcher.sh --dry-run append --config new-tunnel

# Test configuration file parsing
./scripts/cf-launcher.sh --dry-run --config-file workspaces.txt
```

**Output Shows**:
- Tunnels that would be created
- Configuration files that would be used
- Commands that would be executed
- Browser tabs that would open (if enabled)

**Benefits**:
- Verify configuration before execution
- Test scripting changes safely
- Debug configuration file issues
- Plan complex multi-tunnel setups

## Complex Workflow Examples

### Development → Staging → Production Workflow

```bash
# 1. Start development tunnels
./scripts/cf-launcher.sh --config dev-frontend,dev-backend,dev-api

# 2. Promote to staging (append)
./scripts/cf-launcher.sh append --config staging-frontend,staging-backend,staging-api

# 3. Monitor all environments
./scripts/cf-launcher.sh status --list-configs

# 4. Clean up dev tunnels (keep staging)
./scripts/cf-launcher.sh --kill-config dev-frontend
./scripts/cf-launcher.sh --kill-config dev-backend
./scripts/cf-launcher.sh --kill-config dev-api

# 5. Staging looks good? Add production
./scripts/cf-launcher.sh append --config prod-frontend,prod-backend,prod-api
```

### Multi-Tenant Environment Management

```bash
# Create workspace file for each tenant
echo -e "tenant1-app\ntenant1-api\ntenant1-admin" > tenant1.txt
echo -e "tenant2-app\ntenant2-api\ntenant2-admin" > tenant2.txt
echo -e "tenant3-app\ntenant3-api\ntenant3-admin" > tenant3.txt

# Start all tenant 1 tunnels
./scripts/cf-launcher.sh --config-file tenant1.txt

# Add tenant 2
./scripts/cf-launcher.sh append --config-file tenant2.txt

# Add tenant 3
./scripts/cf-launcher.sh append --config-file tenant3.txt

# Check all tenants
./scripts/cf-launcher.sh status

# Remove tenant 2 for maintenance
./scripts/cf-launcher.sh --kill-config tenant2-app
./scripts/cf-launcher.sh --kill-config tenant2-api
./scripts/cf-launcher.sh --kill-config tenant2-admin

# Re-add tenant 2 after maintenance
./scripts/cf-launcher.sh append --config-file tenant2.txt
```

### Feature Branch Testing

```bash
# Main branch tunnels (persistent)
./scripts/cf-launcher.sh --config main-app,main-api

# Add feature branch tunnel for testing
./scripts/cf-launcher.sh append --config feature-123-app --no-browser

# Test feature
curl https://feature-123-app.example.com

# Remove feature tunnel when done
./scripts/cf-launcher.sh --kill-config feature-123-app

# Main tunnels remain running
```

### Canary Deployment Pattern

```bash
# Start production tunnels
./scripts/cf-launcher.sh --config prod-app,prod-api

# Add canary tunnel (new version)
./scripts/cf-launcher.sh append --config canary-app,canary-api

# Monitor both versions
./scripts/cf-launcher.sh status

# If canary stable, replace production
./scripts/cf-launcher.sh --kill-config prod-app
./scripts/cf-launcher.sh --kill-config prod-api
./scripts/cf-launcher.sh append --config prod-app-v2,prod-api-v2

# Remove canary
./scripts/cf-launcher.sh --kill-config canary-app
./scripts/cf-launcher.sh --kill-config canary-api
```

### Blue-Green Deployment

```bash
# Blue environment (current production)
./scripts/cf-launcher.sh --config blue-app,blue-api

# Deploy to green environment
./scripts/cf-launcher.sh append --config green-app,green-api

# Test green environment
curl https://green-app.example.com

# Switch traffic (DNS update, not shown)
# Then remove blue
./scripts/cf-launcher.sh --kill-config blue-app
./scripts/cf-launcher.sh --kill-config blue-api

# Green becomes new production
```

### Load Testing Setup

```bash
# Start application tunnels
./scripts/cf-launcher.sh --config app1,app2,app3,app4,app5

# Monitor all instances
./scripts/cf-launcher.sh status --list-configs

# Run load tests against tunnels
# (load testing commands not shown)

# Clean up after testing
./scripts/cf-launcher.sh --kill
```

### Temporary Preview Environments

```bash
# Create preview environment
./scripts/cf-launcher.sh --config preview-123

# Share URL with team
echo "Preview URL: https://preview-123.example.com"

# Cleanup when review complete
./scripts/cf-launcher.sh --kill-config preview-123
```

## Integration Patterns

### With Git Hooks

```bash
# .git/hooks/post-checkout
#!/bin/bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Start tunnel for feature branches
if [[ $BRANCH =~ ^feature/.+ ]]; then
    TUNNEL_NAME=$(echo "$BRANCH" | sed 's/\//-/g')
    ./scripts/cf-launcher.sh append --config "$TUNNEL_NAME"
fi
```

### With CI/CD Pipelines

```yaml
# .github/workflows/deploy.yml
- name: Start Preview Tunnel
  run: |
    ./scripts/cf-launcher.sh append --config "pr-${{ github.event.pull_request.number }}" --no-browser

- name: Cleanup Preview Tunnel
  if: always()
  run: |
    ./scripts/cf-launcher.sh --kill-config "pr-${{ github.event.pull_request.number }}"
```

### With Docker Compose

```yaml
# docker-compose.yml
services:
  app:
    build: .
    ports:
      - "8080:80"

  tunnel:
    image: cloudflare/cloudflared:latest
    command: tunnel run
    volumes:
      - ~/.cloudflared:/etc/cloudflared
    depends_on:
      - app
```

### With Monitoring Scripts

```bash
#!/bin/bash
# monitor-tunnels.sh

while true; do
    # Check tunnel status
    STATUS=$(./scripts/cf-launcher.sh status)

    # Parse and alert if tunnels down
    if echo "$STATUS" | grep -q "No running cloudflared"; then
        echo "ALERT: Tunnels are down!"
        # Send alert (email, Slack, etc.)
    fi

    sleep 60
done
```

## Advanced Configuration Examples

### Custom Tunnel Configurations

```yaml
# ~/.cloudflared/psp-p2p/config-custom.yml
tunnel: your-tunnel-id
credentials-file: /path/to/credentials.json

ingress:
  - hostname: app.example.com
    service: http://localhost:8080
    originRequest:
      connectTimeout: 30s
      noHappyEyeballs: true
      tcpKeepAlive: 30s

  - hostname: api.example.com
    service: http://localhost:3000
    originRequest:
      connectTimeout: 10s

  - service: http_status:404
```

### Multiple Tunnels Per Configuration

```yaml
# config-multi.yml
ingress:
  - hostname: app1.example.com
    service: http://localhost:8080
  - hostname: app2.example.com
    service: http://localhost:8081
  - hostname: app3.example.com
    service: http://localhost:8082
  - service: http_status:404
```

## Performance Optimization

### Tunnel Connection Pooling

```bash
# Reuse connections for multiple tunnels
export TUNNEL_TRANSPORT_PROTOCOL=quic

# Start tunnels with connection pooling
./scripts/cf-launcher.sh --config app1,app2,app3
```

### Resource Management

```bash
# Monitor resource usage
ps aux | grep cloudflared

# Limit tunnel resources if needed
# (requires systemd service configuration)
```

## Security Best Practices

### Tunnel Credential Management

```bash
# Secure credentials
chmod 600 ~/.cloudflared/psp-p2p/*.json

# Verify permissions
ls -la ~/.cloudflared/psp-p2p/
```

### Tunnel Access Control

Configure IP allowlists in Cloudflare dashboard for sensitive tunnels.

### Audit Tunnel Usage

```bash
# Log all tunnel operations
./scripts/cf-launcher.sh status | tee -a tunnel-audit.log

# Review tunnel configurations
for config in ~/.cloudflared/psp-p2p/config-*.yml; do
    echo "=== $config ==="
    cat "$config"
done
```
