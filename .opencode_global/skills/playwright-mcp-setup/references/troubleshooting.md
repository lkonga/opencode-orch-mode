````markdown
# Advanced Troubleshooting Guide

## Quick Issues (From Main Setup Guide)

### Issue 1: "Browser not found" or "Chrome not installed"

**Symptoms**: Error messages about missing Chrome/Chromium, browser tools fail to launch

**Quick Fix**:
```bash
# Check if Chrome is installed
which google-chrome || which chromium-browser

# Install Chrome (Ubuntu/Debian)
sudo apt-get install -y google-chrome-stable

# Reinstall Playwright browsers
npx playwright install --force
```

**See Also**: `references/os-specific-installation.md` for Pop! OS manual Chrome installation

### Issue 2: "Missing system dependencies"

**Symptoms**: Library loading errors, display/GUI related errors

**Quick Fix**:
```bash
# Auto-install Playwright system dependencies
npx playwright install-deps

# Or manually (Ubuntu/Debian):
sudo apt-get install -y libnss3 libatk-bridge2.0-0 libdrm2 libxcomposite1 \
  libxdamage1 libxrandr2 libgbm1 libxss1 libasound2
```

### Issue 3: "Permission denied" errors

**Symptoms**: Unable to install browsers, permission errors during installation

**Quick Fix**:
```bash
# Use npx instead of global installation
npx playwright install

# Or fix npm global permissions
sudo chown -R $(whoami) ~/.npm
npm install -g @playwright/mcp
```

---

## Troubleshooting Decision Tree

```
Problem?
├── Browser won't start
│   ├── Check browser installation → Issue 1
│   ├── Check system dependencies → Issue 2
│   └── Check permissions → Issue 3
├── Browser starts but won't navigate
│   ├── Check network connectivity → Issue 4
│   ├── Check browser version → Issue 1
│   └── Try different browser → Issue 1
├── MCP server not responding
│   ├── Check server installation → Issue 5
│   ├── Check server process → Issue 5
│   └── Check port conflicts → Issue 5
└── Intermittent failures
    ├── Check resource limits → Maintenance section
    ├── Check browser cache → Cleanup section
    └── Monitor system resources → Best Practices
```

## Issue 4: Browser Launches But Can't Navigate

### Symptoms
- Browser opens successfully
- Fails to load pages
- Timeout errors during navigation
- Network-related errors

### Diagnostic Steps

```bash
# Step 1: Check browser installation integrity
npx playwright install --dry-run

# Step 2: Test browser manually
npx playwright codegen --device="Desktop Chrome" https://example.com
```

### Solutions

#### Solution 4.1: Reinstall Browsers
```bash
# Force reinstall all browsers
npx playwright install --force

# Install with dependencies
npx playwright install --with-deps
```

#### Solution 4.2: Network Configuration
```bash
# Check network connectivity
ping -c 3 example.com

# Test with different DNS
# Add to /etc/resolv.conf:
# nameserver 8.8.8.8

# Test with proxy bypass
export NO_PROXY=localhost,127.0.0.1
```

#### Solution 4.3: Browser Launch Options
```javascript
// playwright.config.js
module.exports = {
  use: {
    launchOptions: {
      args: [
        '--disable-web-security',
        '--disable-features=IsolateOrigins,site-per-process',
        '--no-sandbox', // Use cautiously
      ],
    },
  },
};
```

#### Solution 4.4: Increase Timeouts
```javascript
// playwright.config.js
module.exports = {
  timeout: 60000, // 60 seconds
  use: {
    navigationTimeout: 30000,
    actionTimeout: 15000,
  },
};
```

## Issue 5: MCP Server Problems

### Symptoms
- MCP tools not available
- Server connection errors
- "Module not found" errors
- Port binding failures

### Diagnostic Steps

```bash
# Step 1: Check if MCP is installed
npm list -g @playwright/mcp

# Step 2: Check running processes
ps aux | grep playwright

# Step 3: Check port availability
lsof -i :8000 # Replace with your MCP port
```

### Solutions

#### Solution 5.1: Reinstall MCP Server
```bash
# Uninstall cleanly
npm uninstall -g @playwright/mcp
npm cache clean --force

# Reinstall
npm install -g @playwright/mcp

# Verify installation
npx @playwright/mcp --version
```

#### Solution 5.2: Fix NPM Global Permissions
```bash
# Fix permissions (Linux/macOS)
sudo chown -R $(whoami) ~/.npm
sudo chown -R $(whoami) /usr/local/lib/node_modules

# Alternative: Use nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install node
npm install -g @playwright/mcp
```

#### Solution 5.3: Port Conflicts
```bash
# Find process using the port
lsof -ti:8000 | xargs kill -9

# Or configure different port
export PLAYWRIGHT_MCP_PORT=8001
```

#### Solution 5.4: Module Resolution Issues
```bash
# Clear require cache
rm -rf node_modules/.cache

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Link global module locally
npm link @playwright/mcp
```

## Custom Browser Paths

### When to Use
- Non-standard browser installations
- Multiple browser versions
- Containerized environments
- Restricted file systems

### Configuration

```bash
# Set custom browser path
export PLAYWRIGHT_BROWSERS_PATH=/path/to/custom/browsers

# Install to custom path
npx playwright install --browser-path=/path/to/custom/browsers

# Verify browsers location
ls -la /path/to/custom/browsers
```

### Path Priority
1. `PLAYWRIGHT_BROWSERS_PATH` environment variable
2. Project-local `.playwright` directory
3. Global cache: `~/.cache/ms-playwright` (Linux/macOS)
4. Global cache: `%USERPROFILE%\AppData\Local\ms-playwright` (Windows)

### Docker Configuration
```dockerfile
# Dockerfile
FROM node:18-bullseye

# Set browser path
ENV PLAYWRIGHT_BROWSERS_PATH=/browsers

# Install dependencies
RUN apt-get update && apt-get install -y \
    libnss3 libatk-bridge2.0-0 libdrm2 \
    libxcomposite1 libxdamage1 libxrandr2 \
    libgbm1 libxss1 libasound2

# Install Playwright and browsers
RUN npm install -g @playwright/mcp && \
    npx playwright install --browser-path=/browsers

WORKDIR /app
```

## Maintenance and Updates

### Regular Maintenance Tasks

#### Weekly Maintenance
```bash
# Update Playwright browsers to latest
npx playwright install

# Update MCP server
npm update -g @playwright/mcp

# Clear browser cache
rm -rf ~/.cache/ms-playwright/browserType-*/
npx playwright install --force
```

#### Monthly Maintenance
```bash
# Check for outdated packages
npm outdated -g

# Update all global packages
npm update -g

# Verify installations
npx playwright install --dry-run
npx @playwright/mcp --version
```

### Browser Version Management

```bash
# Check installed browser versions
npx playwright install --dry-run

# Install specific browser version
npx playwright install chromium@91.0.4472.0

# List available versions
npx playwright install --list-versions
```

### Cleanup Strategies

#### Complete Cleanup
```bash
# Remove all browsers
rm -rf ~/.cache/ms-playwright

# Remove MCP server
npm uninstall -g @playwright/mcp

# Clear npm cache
npm cache clean --force

# Reinstall fresh
npm install -g @playwright/mcp
npx playwright install
```

#### Selective Cleanup
```bash
# Remove specific browser
rm -rf ~/.cache/ms-playwright/chromium-*

# Reinstall only that browser
npx playwright install chromium

# Remove unused browser versions
npx playwright install --force
```

#### Disk Space Monitoring
```bash
# Check Playwright cache size
du -sh ~/.cache/ms-playwright

# Check per-browser size
du -sh ~/.cache/ms-playwright/*

# Remove old versions (keep latest 2)
ls -t ~/.cache/ms-playwright/chromium-* | tail -n +3 | xargs rm -rf
```

## Production Environment Considerations

### Docker Deployment

```yaml
# docker-compose.yml
version: '3.8'
services:
  playwright:
    image: mcr.microsoft.com/playwright:v1.40.0-focal
    environment:
      - PLAYWRIGHT_BROWSERS_PATH=/browsers
    volumes:
      - ./app:/app
      - playwright-browsers:/browsers
    command: npm start

volumes:
  playwright-browsers:
```

### CI/CD Integration

```yaml
# .github/workflows/tests.yml
name: Playwright Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - name: Install dependencies
        run: npm ci
      - name: Install Playwright Browsers
        run: npx playwright install --with-deps
      - name: Run tests
        run: npm test
```

### Resource Limits

```bash
# Check current limits
ulimit -a

# Increase file descriptor limit
ulimit -n 4096

# Increase process limit
ulimit -u 4096

# Make permanent in /etc/security/limits.conf:
# * soft nofile 4096
# * hard nofile 8192
```

### Monitoring

```bash
# Monitor browser processes
watch -n 5 'ps aux | grep -E "(chrome|firefox|webkit)" | grep -v grep'

# Monitor memory usage
watch -n 5 'free -h'

# Monitor Playwright cache growth
watch -n 60 'du -sh ~/.cache/ms-playwright'
```

## Advanced Debugging

### Enable Debug Logging

```bash
# Enable Playwright debug output
export DEBUG=pw:api

# Enable browser protocol logging
export DEBUG=pw:protocol

# Enable all Playwright logs
export DEBUG=pw:*

# Run with logging
npx playwright test
```

### Capture Browser Logs

```javascript
// playwright.config.js
module.exports = {
  use: {
    browserName: 'chromium',
    video: 'on', // Record video
    trace: 'on', // Capture trace
  },
};
```

### Network Debugging

```javascript
// Capture network traffic
page.on('request', request => {
  console.log('>>', request.method(), request.url());
});

page.on('response', response => {
  console.log('<<', response.status(), response.url());
});
```

### Performance Profiling

```javascript
// Enable Chrome DevTools Protocol
const browser = await chromium.launch({
  args: ['--remote-debugging-port=9222'],
});

// Access DevTools at http://localhost:9222
```

## Emergency Recovery

### When Everything Fails

```bash
# Step 1: Complete system cleanup
npm uninstall -g @playwright/mcp
rm -rf ~/.cache/ms-playwright
rm -rf ~/.npm
rm -rf node_modules package-lock.json

# Step 2: Fresh system dependencies
# Ubuntu/Debian:
sudo apt-get update
sudo apt-get install --reinstall -y libnss3 libatk-bridge2.0-0 libdrm2 \
  libxcomposite1 libxdamage1 libxrandr2 libgbm1 libxss1 libasound2

# Step 3: Reinstall Node.js (via nvm recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install --lts

# Step 4: Fresh installation
npm install -g @playwright/mcp
cd /path/to/project
npm install
npx playwright install --with-deps

# Step 5: Verification
npx playwright codegen https://example.com
```
