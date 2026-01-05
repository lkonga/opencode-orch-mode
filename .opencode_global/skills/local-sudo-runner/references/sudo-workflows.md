# Advanced Workflow Integration

## Worktree Orchestration

Enhances `$WorktreeOrchestration` by enabling sudo operations in worktree lifecycle.

### Standard Worktree Setup with Sudo

```bash
# Complete worktree setup requiring sudo
./scripts/sudo-runner.sh --trunner ./scripts/setup-worktree.sh worktree-04 \
  --setup-laravel \
  --source-branch main

# Monitor progress
tail -f /tmp/test_suite_output_tmux-runner-*.log
```

### Deployment with Sudo

```bash
# Deploy with sudo permissions
./scripts/sudo-runner.sh --trunner ./scripts/deploy-worktree.sh worktree-04

# With additional flags
./scripts/sudo-runner.sh --trunner ./scripts/deploy-worktree.sh \
  worktree-04 \
  --production \
  --restart-services
```

## Complex Deployment Pipelines

### Multi-Step Pipeline

```bash
# Full deployment pipeline with sudo
./scripts/sudo-runner.sh --trunner bash -c "
  ./scripts/setup-worktree.sh prod-01 &&
  ./scripts/deploy-worktree.sh prod-01 &&
  systemctl reload nginx &&
  systemctl status nginx
"
```

### Parallel Deployments

```bash
# Deploy multiple worktrees concurrently
for i in 1 2 3; do
  ./scripts/sudo-runner.sh --trunner ./scripts/deploy-worktree.sh prod-0${i} &
done

# Wait for all to complete
wait

# Verify all services
for i in 1 2 3; do
  echo "Checking prod-0${i}:"
  tail -20 /tmp/test_suite_output-*prod-0${i}*.log | grep -i "success\|complete"
done
```

### Rolling Updates

```bash
# Deploy with zero downtime
./scripts/sudo-runner.sh --trunner bash -c "
  ./scripts/setup-worktree.sh blue &&
  ./scripts/deploy-worktree.sh blue &&
  ./scripts/switch-traffic.sh blue &&
  sleep 30 &&
  ./scripts/teardown-worktree.sh green
"
```

## Test Suite Integration

### Protected Test Execution

```bash
# Run tests requiring sudo for environment setup
./scripts/sudo-runner.sh --trunner ./scripts/run-integration-tests.sh

# Database tests requiring sudo
./scripts/sudo-runner.sh --trunner ./scripts/db-test-runner.sh --full-reset
```

### Pre-Deployment Testing

```bash
# Complete test pipeline
./scripts/sudo-runner.sh --trunner bash -c "
  ./run_full_test_suite.sh &&
  ./scripts/integration-tests.sh &&
  ./scripts/e2e-tests.sh
"

# Monitor progress
tail -f /tmp/test_suite_output-*.log
```

## System Operations

### Service Management

```bash
# Restart services in sequence
./scripts/sudo-runner.sh "systemctl restart php8.2-fpm && systemctl restart nginx"

# With verification
./scripts/sudo-runner.sh --trunner bash -c "
  systemctl restart php8.2-fpm &&
  systemctl status php8.2-fpm &&
  systemctl restart nginx &&
  systemctl status nginx
"
```

### Permission Management

```bash
# Fix permissions for Laravel storage
./scripts/sudo-runner.sh "chown -R www-data:www-data storage/ bootstrap/cache/"

# With verification
./scripts/sudo-runner.sh bash -c "
  chown -R www-data:www-data storage/ &&
  chmod -R 775 storage/ &&
  ls -la storage/
"
```

### Package Installation

```bash
# Install required packages
./scripts/sudo-runner.sh --trunner bash -c "
  apt-get update &&
  apt-get install -y redis-server &&
  systemctl enable redis-server &&
  systemctl start redis-server
"
```

## Architect-Coder Integration

### Orchestrator Pattern

```bash
# Orchestrator delegates to coder
# Coder uses sudo-runner for setup phases

# Phase 1: Environment setup (requires sudo)
./scripts/sudo-runner.sh --trunner ./scripts/setup-environment.sh

# Phase 2: Code deployment (minimal sudo)
./scripts/sudo-runner.sh --trunner ./scripts/deploy-code.sh

# Phase 3: Service restart (requires sudo)
./scripts/sudo-runner.sh "systemctl restart nginx"
```

### Token-Efficient Delegation

```bash
# Architect delegates long operations
# Coder wraps in sudo-runner + trunner for efficiency

# Step 1: Launch protected operation
SESSION_ID=$(./scripts/sudo-runner.sh --trunner ./scripts/long-setup.sh | grep -oP 'tmux-runner-\d+-\d+')

# Step 2: Continue other work
# ... architect delegates other tasks ...

# Step 3: Check completion
tail -50 /tmp/test_suite_output_${SESSION_ID}.log
```

## CI/CD Integration

### GitLab CI Example

```yaml
deploy:
  script:
    - ./scripts/sudo-runner.sh --trunner ./scripts/deploy-production.sh
    - sleep 30  # Wait for completion
    - tail -50 /tmp/test_suite_output-*.log
```

### GitHub Actions Example

```yaml
- name: Deploy with sudo
  run: |
    ./scripts/sudo-runner.sh --trunner ./scripts/deploy.sh
    sleep 30
    tail -50 /tmp/test_suite_output-*.log | grep -i "success"
```

## Error Handling Workflows

### Retry Pattern

```bash
# Retry failed operations
for i in {1..3}; do
  ./scripts/sudo-runner.sh --trunner ./scripts/deploy.sh && break
  echo "Attempt $i failed, retrying..."
  sleep 10
done
```

### Rollback Pattern

```bash
# Deploy with automatic rollback on failure
./scripts/sudo-runner.sh --trunner bash -c "
  ./scripts/deploy.sh || (
    echo 'Deploy failed, rolling back...' &&
    ./scripts/rollback.sh &&
    exit 1
  )
"
```

### Cleanup Pattern

```bash
# Ensure cleanup even on failure
./scripts/sudo-runner.sh --trunner bash -c "
  trap './scripts/cleanup.sh' EXIT
  ./scripts/deploy.sh
"
```

## Monitoring Workflows

### Progress Tracking

```bash
# Launch operation
SESSION_ID=$(./scripts/sudo-runner.sh --trunner ./scripts/long-deploy.sh | grep -oP 'tmux-runner-\d+-\d+')

# High-frequency monitoring
for i in {1..24}; do
  sleep 5
  echo "=== Check $i ==="
  tail -20 /tmp/test_suite_output_${SESSION_ID}.log
done
```

### Health Checks

```bash
# Deploy with health checks
./scripts/sudo-runner.sh --trunner bash -c "
  ./scripts/deploy.sh &&
  sleep 10 &&
  curl -f http://localhost/health || exit 1
"
```

## Related Documentation

- Trunner monitoring: See `$TmuxProtectedExecution/references/tmux-advanced-sessions.md`
- Worktree operations: See `$WorktreeOrchestration` skill
- CI/CD patterns: See project-specific deployment documentation
