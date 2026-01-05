# CF Launcher Troubleshooting Guide

## Common Issues and Solutions

### Issue: "No running cloudflared processes found"

**Symptom**: Status command reports no tunnels running, but you started them

**Diagnosis**:
```bash
# Check if tunnels were started correctly
./scripts/cf-launcher.sh status

# Check for cloudflared processes manually
ps aux | grep cloudflared

# Check tmux sessions
tmux list-sessions | grep cf-launcher
```

**Possible Causes**:
1. Tunnels failed to start due to configuration errors
2. Cloudflared not installed or not in PATH
3. Tunnels started but crashed immediately

**Solutions**:

**If cloudflared not found**:
```bash
# Install cloudflared
# Ubuntu/Debian
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# macOS
brew install cloudflared

# Verify installation
which cloudflared
cloudflared --version
```

**If configuration errors**:
```bash
# Test configuration manually
cloudflared tunnel --config ~/.cloudflared/psp-p2p/config-{name}.yml run

# Check configuration file syntax
cat ~/.cloudflared/psp-p2p/config-{name}.yml

# Validate tunnel exists
cloudflared tunnel list
```

### Issue: "Detected running inside tmux"

**Symptom**: Error when using `-D` flag inside tmux session

**Error Message**:
```
Error: Detected running inside tmux. Use background mode (no -D flag) instead.
Background mode creates session without attaching (safe for automation).
```

**Cause**: Using foreground mode (`-D` flag) inside an existing tmux session

**Solution**: Remove `-D` flag to use background mode

```bash
# WRONG: This fails inside tmux
./scripts/cf-launcher.sh -D --config myapp

# CORRECT: Background mode works inside tmux
./scripts/cf-launcher.sh --config myapp

# CORRECT: Also works from trunner
trunner "./scripts/cf-launcher.sh --config myapp"
```

**Why This Happens**:
- `-D` flag attempts to attach to tmux session immediately
- Nested tmux sessions are not supported
- Background mode creates session without attaching (safe)

**Prevention**:
- Always use background mode (default, no `-D`) for automation
- Only use `-D` flag for manual, interactive sessions
- Never use `-D` inside trunner or other tmux-based tools

### Issue: "Configuration file not found"

**Symptom**: Cannot find specified configuration file

**Diagnosis**:
```bash
# Check if configuration exists
ls -la ~/.cloudflared/psp-p2p/config-{name}.yml

# Check if custom directory specified
echo $CLOUDFLARED_CONFIG_DIR

# List all available configurations
ls ~/.cloudflared/psp-p2p/config-*.yml
```

**Solutions**:

**Use absolute paths**:
```bash
# Use full path for configuration file
./scripts/cf-launcher.sh --config-file /full/path/to/configs.txt
```

**Verify configuration directory**:
```bash
# Check default directory
ls -la ~/.cloudflared/psp-p2p/

# Or specify custom directory
./scripts/cf-launcher.sh --config-dir /custom/path --config myapp
```

**Create missing configuration**:
```bash
# Create configuration from template
cp ~/.cloudflared/psp-p2p/config-template.yml \
   ~/.cloudflared/psp-p2p/config-myapp.yml

# Edit configuration
nano ~/.cloudflared/psp-p2p/config-myapp.yml
```

### Issue: Tunnels Start But Not Accessible

**Symptom**: Tunnels show as running but URLs don't work

**Diagnosis**:
```bash
# Check tunnel status
./scripts/cf-launcher.sh status

# Test local service
curl http://localhost:{port}

# Check DNS resolution
dig {hostname}.example.com +short

# Test tunnel connectivity
cloudflared tunnel info {tunnel-id}
```

**Possible Causes**:
1. Local service not running
2. Port mismatch in configuration
3. DNS not configured correctly
4. Firewall blocking connections

**Solutions**:

**Verify local service**:
```bash
# Check if service is running
curl http://localhost:8080  # or your port

# Start service if needed
npm start  # or your command
```

**Check port configuration**:
```yaml
# ~/.cloudflared/psp-p2p/config-myapp.yml
ingress:
  - hostname: myapp.example.com
    service: http://localhost:8080  # Must match your service port
```

**Verify DNS**:
```bash
# Check DNS record
dig myapp.example.com +short

# Should return Cloudflare tunnel address
# If not, update DNS in Cloudflare dashboard
```

### Issue: Browser Tabs Not Opening

**Symptom**: Tunnels start but browser doesn't open

**Diagnosis**:
```bash
# Check if browser exists
which brave-browser
which google-chrome
which chromium-browser
which firefox
```

**Possible Causes**:
1. No supported browser installed
2. Running in headless environment
3. Display not available
4. `--no-browser` flag used

**Solutions**:

**Install supported browser**:
```bash
# Ubuntu/Debian
sudo apt install brave-browser
# or
sudo apt install chromium-browser
```

**Disable browser launch for headless**:
```bash
# Use --no-browser flag for servers
./scripts/cf-launcher.sh --config myapp --no-browser
```

**Manual URL access**:
```bash
# Get URLs from status
./scripts/cf-launcher.sh status

# Open manually in browser
```

### Issue: Tunnel Session Not Found

**Symptom**: "Session not found: cf-launcher"

**Diagnosis**:
```bash
# List all tmux sessions
tmux list-sessions

# Check for cf-launcher session specifically
tmux has-session -t cf-launcher 2>/dev/null && echo "Exists" || echo "Not found"
```

**Possible Causes**:
1. Session was never created
2. Session crashed or was killed
3. tmux server not running

**Solutions**:

**Recreate session**:
```bash
# Start fresh tunnel session
./scripts/cf-launcher.sh --config myapp
```

**Check tmux server**:
```bash
# Start tmux server if needed
tmux start-server

# List sessions
tmux list-sessions
```

### Issue: Permission Denied Errors

**Symptom**: Cannot create or access configuration files

**Diagnosis**:
```bash
# Check permissions
ls -la ~/.cloudflared/psp-p2p/

# Check ownership
ls -la ~/scripts/cf-launcher.sh
```

**Solutions**:

**Fix script permissions**:
```bash
chmod +x ./scripts/cf-launcher.sh
```

**Fix configuration directory permissions**:
```bash
chmod 755 ~/.cloudflared/psp-p2p/
chmod 644 ~/.cloudflared/psp-p2p/config-*.yml
chmod 600 ~/.cloudflared/psp-p2p/*.json
```

## Debug Mode

### Enable Debug Output

```bash
# Run with debug output
DEBUG=1 ./scripts/cf-launcher.sh --config myapp

# Check what commands would be executed
./scripts/cf-launcher.sh --dry-run --config myapp
```

### Verbose Cloudflared Logging

```bash
# Start tunnel with verbose logging
cloudflared tunnel --loglevel debug --config ~/.cloudflared/psp-p2p/config-myapp.yml run
```

### Inspect Tmux Session

```bash
# Attach to tunnel session
tmux attach -t cf-launcher

# View session panes
tmux list-panes -t cf-launcher

# Detach without stopping
# Press: Ctrl+b, then d
```

## Process Inspection

### Check Running Tunnels

```bash
# List all cloudflared processes
ps aux | grep cloudflared

# Show process tree
pstree -p | grep cloudflared

# Check process details
ps -fp $(pgrep cloudflared)
```

### Monitor Tunnel Connections

```bash
# Check network connections
netstat -tunlp | grep cloudflared

# Or using ss
ss -tunlp | grep cloudflared
```

### Check Resource Usage

```bash
# Monitor CPU/memory usage
top -p $(pgrep cloudflared | tr '\n' ',')

# Or using htop
htop -p $(pgrep cloudflared | tr '\n' ',' | sed 's/,$//')
```

## Log Analysis

### View Tunnel Logs

```bash
# Attach to tmux session to see logs
tmux attach -t cf-launcher

# Check systemd logs (if using systemd)
journalctl -u cloudflared -f

# Check application logs
tail -f ~/.cloudflared/*.log
```

### Parse Status Output

```bash
# Get detailed status
./scripts/cf-launcher.sh status --list-configs

# Filter for specific tunnel
./scripts/cf-launcher.sh status | grep myapp

# Count running tunnels
./scripts/cf-launcher.sh status | grep -c "http://localhost"
```

## Error Recovery Patterns

### Restart Stuck Tunnels

```bash
# Kill all tunnels
./scripts/cf-launcher.sh --kill

# Wait for cleanup
sleep 2

# Restart with same configuration
./scripts/cf-launcher.sh --config myapp
```

### Clean Stale Sessions

```bash
# Kill stale tmux session
tmux kill-session -t cf-launcher 2>/dev/null

# Clean up any remaining processes
pkill cloudflared

# Restart fresh
./scripts/cf-launcher.sh --config myapp
```

### Reset Tunnel State

```bash
# Complete reset
./scripts/cf-launcher.sh --kill
tmux kill-session -t cf-launcher 2>/dev/null
pkill cloudflared

# Verify clean state
ps aux | grep cloudflared  # Should return nothing
tmux list-sessions | grep cf-launcher  # Should return nothing

# Restart tunnels
./scripts/cf-launcher.sh --config myapp
```

## Best Practices for Troubleshooting

**Before Reporting Issues**:
1. Check tunnel status: `./scripts/cf-launcher.sh status`
2. Verify configuration files exist
3. Test local service accessibility
4. Check DNS resolution
5. Review tmux session logs

**For Persistent Issues**:
1. Enable debug mode
2. Capture full error output
3. Test with minimal configuration
4. Verify Cloudflare tunnel settings
5. Check network connectivity

**Prevention**:
1. Use descriptive tunnel names
2. Keep configurations organized
3. Document custom setups
4. Monitor tunnel health
5. Regular cleanup of unused tunnels
