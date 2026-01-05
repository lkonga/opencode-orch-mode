# Local Sudo Runner - Usage Examples

This directory contains practical examples for using the Local Sudo Runner skill with various types of scripts and operations.

## Setup Script Examples

### Basic Worktree Setup

```bash
# Standard worktree setup with sudo for symlinks
cd ~/codes/llm-rules
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh \
    ./scripts/setup-worktree.sh worktree-01
```

### Protected Worktree Setup

```bash
# Long-running setup with tmux protection
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh --trunner \
    ./scripts/setup-worktree.sh worktree-02 --config production
```

### Multiple Worktree Setup

```bash
# Create wrapper script for batch setup
cat > /tmp/batch-worktree-setup.sh << 'EOF'
#!/bin/bash
for i in {01..05}; do
    ./scripts/setup-worktree.sh "worktree-${i}"
    echo "Completed worktree-${i}"
done
EOF

chmod +x /tmp/batch-worktree-setup.sh

# Run with sudo and trunner
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh --trunner \
    /tmp/batch-worktree-setup.sh
```

## Deploy Script Examples

### Standard Deployment

```bash
# Deploy with sudo permissions
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh \
    ./scripts/deploy-worktree.sh prod-01
```

### Protected Deployment Pipeline

```bash
# Full deployment with monitoring
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh --trunner \
    ./scripts/deploy-worktree.sh prod-01

# Monitor in another terminal
tail -f /tmp/test_suite_output_tmux-runner-*.log
```

### Multi-Stage Deployment

```bash
# Create multi-stage deployment script
cat > /tmp/multi-stage-deploy.sh << 'EOF'
#!/bin/bash
set -e

echo "Stage 1: Setup worktree"
./scripts/setup-worktree.sh staging-01

echo "Stage 2: Run tests"
./scripts/run-tests.sh staging-01

echo "Stage 3: Deploy to VPS"
./scripts/deploy-worktree.sh staging-01

echo "Deployment complete!"
EOF

chmod +x /tmp/multi-stage-deploy.sh

# Execute with sudo and protection
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh --trunner \
    /tmp/multi-stage-deploy.sh
```

## Test Runner Examples

### Integration Test Suite

```bash
# Run integration tests requiring sudo
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh --trunner \
    ./scripts/run-integration-tests.sh
```

### Database Test Runner

```bash
# Database tests with environment setup
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh --trunner \
    ./scripts/db-test-runner.sh --reset-db
```

### End-to-End Test Pipeline

```bash
cat > /tmp/e2e-test-pipeline.sh << 'EOF'
#!/bin/bash
set -e

echo "Setting up test environment..."
./scripts/setup-test-env.sh

echo "Running E2E tests..."
./scripts/run-e2e-tests.sh

echo "Cleaning up..."
./scripts/cleanup-test-env.sh

echo "Test pipeline complete!"
EOF

chmod +x /tmp/e2e-test-pipeline.sh

./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh --trunner \
    /tmp/e2e-test-pipeline.sh
```

## System Operation Examples

### Service Management

```bash
# Restart PHP-FPM
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh \
    "systemctl restart php8.2-fpm"

# Reload Nginx
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh \
    "nginx -t && systemctl reload nginx"

# Check service status
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh \
    "systemctl status nginx php8.2-fpm redis-server"
```

### Permission Management

```bash
# Fix storage permissions
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh \
    "chown -R www-data:www-data /var/www/storage && chmod -R 775 /var/www/storage"

# Fix log permissions
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh \
    "chown -R www-data:www-data /var/www/storage/logs && chmod -R 644 /var/www/storage/logs"
```

### Package Management

```bash
# Update system packages
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh --trunner \
    "apt-get update && apt-get upgrade -y"

# Install specific packages
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh \
    "apt-get install -y redis-server nginx php8.2-fpm"

# Clean package cache
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh \
    "apt-get autoremove -y && apt-get clean"
```

## Advanced Integration Examples

### Combined with Worktree Orchestration

```bash
# Full worktree lifecycle with sudo
cat > /tmp/worktree-lifecycle.sh << 'EOF'
#!/bin/bash
set -e

WORKTREE_NAME="$1"

echo "Creating worktree: ${WORKTREE_NAME}"
./scripts/setup-worktree.sh "${WORKTREE_NAME}"

echo "Running tests..."
./scripts/run-tests.sh "${WORKTREE_NAME}"

echo "Deploying..."
./scripts/deploy-worktree.sh "${WORKTREE_NAME}"

echo "Lifecycle complete for ${WORKTREE_NAME}"
EOF

chmod +x /tmp/worktree-lifecycle.sh

./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh --trunner \
    /tmp/worktree-lifecycle.sh staging-05
```

### Parallel Execution

```bash
# Create parallel execution wrapper
cat > /tmp/parallel-setup.sh << 'EOF'
#!/bin/bash

# Run multiple setups in parallel (each in own trunner session)
for i in {01..03}; do
    ./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh --trunner \
        ./scripts/setup-worktree.sh "parallel-${i}" &
done

wait
echo "All parallel setups complete"
EOF

chmod +x /tmp/parallel-setup.sh
bash /tmp/parallel-setup.sh
```

### With Error Handling

```bash
cat > /tmp/robust-deploy.sh << 'EOF'
#!/bin/bash

deploy_with_retry() {
    local max_attempts=3
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        echo "Deployment attempt $attempt of $max_attempts"

        if ./scripts/deploy-worktree.sh "$1"; then
            echo "Deployment successful!"
            return 0
        fi

        echo "Deployment failed, retrying..."
        attempt=$((attempt + 1))
        sleep 5
    done

    echo "Deployment failed after $max_attempts attempts"
    return 1
}

deploy_with_retry "$1"
EOF

chmod +x /tmp/robust-deploy.sh

./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh --trunner \
    /tmp/robust-deploy.sh prod-01
```

## Monitoring and Debugging Examples

### Real-time Log Monitoring

```bash
# Start deployment in background
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh --trunner \
    ./scripts/deploy-worktree.sh prod-01

# Monitor logs in real-time
watch -n 1 "tail -20 /tmp/test_suite_output_tmux-runner-*.log"
```

### Session Management

```bash
# List all active sessions
~/codes/llm-rules/scripts/tmux-runner/trunner.sh --list

# View specific session log
SESSION_ID="tmux-runner-1702825200-12345"
tail -f "/tmp/test_suite_output_${SESSION_ID}.log"

# Kill specific session if stuck
~/codes/llm-rules/scripts/tmux-runner/trunner.sh --kill "${SESSION_ID}"
```

### Debug Mode

```bash
# Run with debug output
cat > /tmp/debug-deploy.sh << 'EOF'
#!/bin/bash
set -x  # Enable debug output

echo "Starting deployment..."
./scripts/deploy-worktree.sh "$1"
echo "Deployment finished"
EOF

chmod +x /tmp/debug-deploy.sh

./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh --trunner \
    /tmp/debug-deploy.sh debug-01
```

## Best Practices

### 1. Always Use Trunner for Long Operations

```bash
# Good: Long-running operations protected
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh --trunner \
    ./scripts/long-running-setup.sh

# Bad: Long operations can be interrupted
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh \
    ./scripts/long-running-setup.sh
```

### 2. Verify Before Executing

```bash
# Test script without sudo first
bash ./scripts/deploy-worktree.sh --dry-run prod-01

# Then run with sudo
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh \
    ./scripts/deploy-worktree.sh prod-01
```

### 3. Monitor Critical Operations

```bash
# Start operation
SESSION_ID=$(./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh --trunner \
    ./scripts/critical-deploy.sh prod-01 2>&1 | grep -oP 'tmux-runner-\d+-\d+')

# Monitor immediately
tail -f "/tmp/test_suite_output_${SESSION_ID}.log"
```

### 4. Handle Failures Gracefully

```bash
cat > /tmp/safe-deploy.sh << 'EOF'
#!/bin/bash
set -e

cleanup() {
    echo "Cleaning up on exit..."
    # Cleanup logic
}

trap cleanup EXIT

# Main deployment logic
./scripts/deploy-worktree.sh "$1"
EOF

chmod +x /tmp/safe-deploy.sh

./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh --trunner \
    /tmp/safe-deploy.sh prod-01
```

## Troubleshooting Examples

### Permission Issues

```bash
# If script fails with permission denied
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh \
    "chmod +x ./scripts/problematic-script.sh && ./scripts/problematic-script.sh"
```

### Sudo Timeout

```bash
# Reset sudo timestamp before long operation
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh "sudo -v"

# Then run actual operation
./.vscode/skills/local-sudo-runner/scripts/sudo-runner.sh --trunner \
    ./scripts/long-operation.sh
```

### Trunner Session Cleanup

```bash
# Kill all stuck sessions
~/codes/llm-rules/scripts/tmux-runner/trunner.sh --kill-all

# Clean old logs
~/codes/llm-rules/scripts/tmux-runner/trunner.sh --clean-logs
```
