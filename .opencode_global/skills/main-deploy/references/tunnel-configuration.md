# Cloudflare Tunnel Configuration in Main Deploy

## Tunnel Setup Process

deploy-main.sh configures Cloudflare tunnels but does NOT start them. Use $CFLauncher skill to start tunnels after deployment.

## Configuration Structure

### File Locations
```
~/.cloudflared/{PROJECT}/
├── config.yml                  # Tunnel configuration
├── {TUNNEL_ID}.json           # Tunnel credentials
└── cert.pem                   # Cloudflare certificate
```

### Configuration File Template
```yaml
tunnel: {TUNNEL_ID}
credentials-file: /home/{USER}/.cloudflared/{PROJECT}/{TUNNEL_ID}.json

ingress:
  - hostname: {PROJECT}.trylatest.in
    service: https://localhost:{APACHE_PORT}
    originRequest:
      noTLSVerify: true
  - service: http_status:404
```

## Tunnel Discovery Logic

1. **Check Existing Tunnel**: Looks for tunnel with matching name
2. **Create If Missing**: Creates new tunnel if none exists
3. **Store Credentials**: Saves tunnel credentials locally
4. **Write Config**: Generates YAML configuration file

## Domain Mapping

| Project | Local Port | Cloudflare Domain |
|---------|-----------|-------------------|
| psp-p2p | 8443 | psp-p2p.trylatest.in |
| psp-landing | 8444 | psp-landing.trylatest.in |
| push-parser-panel | 8445 | push-parser-panel.trylatest.in |

## SSL/TLS Configuration

### Origin Request Settings
```yaml
originRequest:
  noTLSVerify: true  # Allows self-signed SSL certificates for .local domain
```

**Why noTLSVerify**: Local Apache uses self-signed certificates. Cloudflare tunnel connects to local Apache over HTTPS but skips certificate verification.

### SSL Chain
```
Internet → Cloudflare (Managed SSL) → Tunnel → Apache (Self-signed SSL) → Laravel
```

## Starting Tunnels After Deploy

**Deploy DOES NOT auto-start tunnels**. Use $CFLauncher:

```bash
# Start single tunnel
./scripts/cf-launcher.sh --config psp-p2p

# Start all main branch tunnels
./scripts/cf-launcher.sh --config psp-p2p,psp-landing,push-parser-panel

# Verify tunnel status
./scripts/cf-launcher.sh status
```

## Tunnel Verification

```bash
# Check configuration exists
ls -la ~/.cloudflared/psp-p2p/config.yml

# Check tunnel credentials
ls -la ~/.cloudflared/psp-p2p/*.json

# Test local endpoint (before tunnel)
curl -k https://localhost:8443  # Should return Laravel response

# Test Cloudflare endpoint (after tunnel started)
curl https://psp-p2p.trylatest.in  # Should return 302 redirect
```

## Account Configuration

### Account ID
Stored in `scripts/.cloudflare/ACCOUNT_ID`

```bash
# psp-p2p, psp-landing, push-parser-panel
ACCOUNT_ID=5203130b65da80ca22c716282cd90975
```

### Credentials Location
```bash
# Tunnel credentials
~/.cloudflared/{PROJECT}/{TUNNEL_ID}.json

# Account certificate
~/.cloudflared/cert.pem
```

## Multi-Tunnel Architecture

All three main branches can run tunnels simultaneously:

```
cf-launcher tmux session:
├── Window cf-0
│   ├── Left pane: psp-p2p tunnel
│   └── Right pane: psp-landing tunnel
└── Window cf-1
    └── Left pane: push-parser-panel tunnel
```

## Tunnel Persistence

- **Configuration**: Persists across deployments
- **Tunnel Process**: Must be restarted after reboot
- **Credentials**: Cached locally, never expires
- **Domain Mapping**: Managed by Cloudflare dashboard

## Troubleshooting Tunnel Config

### Issue: Tunnel Config Missing
```bash
# Redeploy creates config
./scripts/deploy-main.sh
```

### Issue: Tunnel Credentials Invalid
```bash
# Delete and recreate tunnel
rm -rf ~/.cloudflared/{PROJECT}/
./scripts/deploy-main.sh
```

### Issue: Wrong Account ID
```bash
# Update account ID
echo "5203130b65da80ca22c716282cd90975" > scripts/.cloudflare/ACCOUNT_ID
./scripts/deploy-main.sh
```

## Integration with $CFLauncher

1. **deploy-main.sh**: Creates tunnel configuration
2. **$CFLauncher**: Starts tunnel processes in tmux
3. **Verification**: Test HTTP endpoints return 302

See `$CFLauncher` skill for complete tunnel management workflow.
