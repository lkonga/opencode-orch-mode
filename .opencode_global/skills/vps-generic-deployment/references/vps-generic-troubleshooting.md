# VPS Generic Deployment Troubleshooting

## Build Failures

### Issue: npm Build Fails

**Symptom**: Build errors during VPS deployment

**Common Causes**:
1. Missing package.json build script
2. Node.js version mismatch
3. Out of memory
4. Missing dependencies

**Diagnosis**:
```bash
# Check Node.js version on VPS
ssh lkonga@37.60.247.12 "node --version"

# Check build script exists
cat package.json | grep '"build"'

# Test build locally
npm run build
```

**Solutions**:

**If build script missing**:
```json
// Add to package.json
{
  "scripts": {
    "build": "vite build"  // or your build command
  }
}
```

**If memory issue**:
```bash
# Increase Node.js memory
export NODE_OPTIONS="--max-old-space-size=4096"
npm run build
```

**If dependency issue**:
```bash
# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm install
npm run build
```

### Issue: Build Output in Wrong Directory

**Symptom**: Nginx serves 404 for all routes

**Diagnosis**:
```bash
# Check where build outputs
ls -la dist/  # or build/, public/, out/

# Check nginx document root
ssh lkonga@37.60.247.12 "cat /etc/nginx/sites-available/staging.{name} | grep root"
```

**Solution**:

Update nginx configuration to match build output:
```bash
ssh lkonga@37.60.247.12 "
  sudo sed -i 's|root .*;|root /var/www/worktrees/{name}/dist;|' \
    /etc/nginx/sites-available/staging.{name}
  sudo nginx -t && sudo systemctl reload nginx
"
```

## Nginx Configuration Issues

### Issue: 404 Not Found

**Symptom**: All routes return 404

**Common Causes**:
1. Incorrect document root
2. Missing index file
3. Missing try_files for SPAs

**Diagnosis**:
```bash
# Check nginx config
ssh lkonga@37.60.247.12 "cat /etc/nginx/sites-available/staging.{name}"

# Check if files exist
ssh lkonga@37.60.247.12 "ls -la /var/www/worktrees/{name}/dist/"
```

**Solutions**:

**For SPAs (React/Vue/etc.)**:
```bash
ssh lkonga@37.60.247.12 "
  sudo tee /etc/nginx/sites-available/staging.{name} > /dev/null << 'EOF'
server {
    listen 80;
    server_name staging.{name}.trylatest.in;
    root /var/www/worktrees/{name}/dist;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
EOF
  sudo nginx -t && sudo systemctl reload nginx
"
```

### Issue: 502 Bad Gateway

**Symptom**: Nginx returns 502

**Cause**: Backend service not running (for reverse proxy setups)

**Solution**:
```bash
# Check if backend is running
ssh lkonga@37.60.247.12 "ps aux | grep node"  # for Node.js
ssh lkonga@37.60.247.12 "ps aux | grep python"  # for Python

# Start backend if needed
ssh lkonga@37.60.247.12 "
  cd /var/www/worktrees/{name}
  npm start &  # or python app.py, etc.
"
```

## SSL Certificate Issues

### Issue: Certificate Validation Failed

**Symptom**: Cannot obtain Let's Encrypt certificate

**Common Causes**:
1. DNS not propagated
2. Port 80 not accessible
3. Rate limit exceeded

**Diagnosis**:
```bash
# Check DNS
dig staging.{name}.trylatest.in +short

# Check port accessibility
telnet 37.60.247.12 80

# Check rate limit
ssh lkonga@37.60.247.12 "sudo certbot certificates"
```

**Solutions**:

**Wait for DNS**:
```bash
# Check from multiple locations
dig @8.8.8.8 staging.{name}.trylatest.in
dig @1.1.1.1 staging.{name}.trylatest.in

# Wait 5-10 minutes for propagation
```

**Manual certificate request**:
```bash
ssh lkonga@37.60.247.12 "
  sudo certbot --nginx -d staging.{name}.trylatest.in
"
```

**Skip SSL temporarily**:
```bash
# Deploy without SSL
./deploy-vps.sh {name} --skip-ssl

# Add SSL later
ssh lkonga@37.60.247.12 "
  sudo certbot --nginx -d staging.{name}.trylatest.in
"
```

## Cloudflare Tunnel Issues

### Issue: Tunnel Not Working

**Symptom**: Cannot access site via tunnel URL

**Diagnosis**:
```bash
# Check tunnel status
./scripts/cf-launcher.sh status

# Check if tunnel configuration exists
ls ~/.cloudflared/psp-p2p/config-{name}.yml

# Check local service
curl http://localhost:{port}
```

**Solutions**:

**If tunnel not started**:
```bash
# Start tunnel
./scripts/cf-launcher.sh --config {name}
```

**If local service not running**:
```bash
# Start local service
cd /path/to/project
npm run dev  # or your start command
```

**If configuration missing**:
```bash
# Create configuration
cat > ~/.cloudflared/psp-p2p/config-{name}.yml << EOF
tunnel: YOUR_TUNNEL_ID
credentials-file: /path/to/credentials.json

ingress:
  - hostname: {name}.trylatest.in
    service: http://localhost:8080
  - service: http_status:404
EOF
```

### Issue: DNS CNAME Not Created

**Symptom**: DNS doesn't resolve to tunnel

**Solution**:

Create DNS record manually in Cloudflare:
```
Type: CNAME
Name: {name}
Target: {tunnel-id}.cfargotunnel.com
Proxied: Yes (orange cloud)
```

## Apache Configuration Issues (Local)

### Issue: Permission Denied

**Symptom**: Apache returns 403 Forbidden

**Cause**: Incorrect file permissions or ownership

**Solution**:
```bash
# Fix ownership
sudo chown -R www-data:www-data /path/to/project/dist

# Fix permissions
sudo chmod -R 755 /path/to/project/dist
sudo chmod -R 775 /path/to/project/dist/storage  # if exists

# Restart Apache
sudo systemctl restart apache2
```

### Issue: .htaccess Not Working

**Symptom**: Rewrites don't work

**Cause**: AllowOverride not enabled

**Solution**:
```bash
# Check Apache config
sudo cat /etc/apache2/sites-available/{name}.conf | grep AllowOverride

# Should be: AllowOverride All

# If not, edit config
sudo nano /etc/apache2/sites-available/{name}.conf

# Add or change:
<Directory /path/to/project>
    AllowOverride All
</Directory>

# Restart Apache
sudo systemctl restart apache2
```

## Server Selection Issues

### Issue: Wrong Server Used

**Symptom**: Expected Nginx but got Apache (or vice versa)

**Explanation**:
- VPS deployments always use Nginx
- Local deployments always use Apache
- This is by design for optimal performance

**Solution**: No action needed, behavior is correct

If you need different server:
- For Nginx locally: Manual configuration required
- For Apache on VPS: Not recommended (use Nginx for production)

## Deployment Script Issues

### Issue: Deploy Script Not Found

**Symptom**: "No such file or directory"

**Solution**:
```bash
# Verify script location
ls -la /home/lkonga/codes/llm-rules/vps-asas/

# Should contain: deploy-vps.sh and deploy-local.sh

# If missing, clone repository
cd /home/lkonga/codes
git clone git@github.com:yzgyzinc/llm-rules.git
```

### Issue: Deploy Script Not Executable

**Symptom**: "Permission denied"

**Solution**:
```bash
# Make scripts executable
chmod +x /home/lkonga/codes/llm-rules/vps-asas/deploy-vps.sh
chmod +x /home/lkonga/codes/llm-rules/vps-asas/deploy-local.sh
```

## Build Artifact Issues

### Issue: Build Artifacts Not Found

**Symptom**: Deployment completes but site shows empty directory

**Diagnosis**:
```bash
# Check if build created artifacts
ls -la dist/  # or build/, public/, out/

# Check build command output
npm run build
```

**Solution**:

Verify build configuration:
```javascript
// vite.config.js (example)
export default {
  build: {
    outDir: 'dist'  // Should match nginx document root
  }
}
```

## Recovery Procedures

### Complete Redeployment

```bash
# For VPS:
ssh lkonga@37.60.247.12 "
  sudo rm -rf /var/www/worktrees/{name}
  sudo rm /etc/nginx/sites-enabled/staging.{name}
  sudo rm /etc/nginx/sites-available/staging.{name}
  sudo certbot delete --cert-name staging.{name}.trylatest.in
  sudo systemctl reload nginx
"

# Redeploy
cd /home/lkonga/codes/llm-rules/vps-asas
./deploy-vps.sh {name}
```

```bash
# For Local:
sudo rm -rf /path/to/project
sudo rm /etc/apache2/sites-enabled/{name}.conf
sudo rm /etc/apache2/sites-available/{name}.conf
sudo systemctl reload apache2

# Redeploy
cd /path/to/project
sudo /home/lkonga/codes/llm-rules/vps-asas/deploy-local.sh {name}
```

## Best Practices

**Prevention**:
- Test builds locally before VPS deployment
- Verify build output directory
- Check nginx/apache configurations
- Test SSL certificates before going live
- Monitor tunnel status regularly

**Diagnosis Workflow**:
1. Check application logs
2. Verify web server configuration
3. Test backend services
4. Check DNS resolution
5. Validate SSL certificates
6. Review deployment scripts

**Quick Fixes**:
- Restart web server: `sudo systemctl restart nginx` or `apache2`
- Clear build cache: `rm -rf node_modules && npm install`
- Regenerate SSL: `sudo certbot renew --force-renewal`
- Restart tunnel: `./scripts/cf-launcher.sh --kill && ./scripts/cf-launcher.sh --config {name}`

**When to Use Manual Cleanup**:
- Automated scripts fail
- Partial deployment state
- Configuration corruption
- SSL certificate issues
- DNS problems
