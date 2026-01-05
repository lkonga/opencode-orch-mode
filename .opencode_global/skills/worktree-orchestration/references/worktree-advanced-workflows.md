# Worktree Advanced Workflows

## Multi-Number Batch Creation

### Sequential Creation

```bash
# Create worktrees 3, 4, 5, 6 sequentially
for i in 3 4 5 6; do
  trunner "./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-${i} \
    --setup-laravel \
    --source-worktree-type psp-p2p \
    --source-branch psp-p2p-merchant-preview-2 \
    --psp-landing-worktree psp-landing-preview-${i} \
    --ppp-worktree push-parser-panel"

  # Wait for session to initialize
  sleep 5
done

# Monitor all sessions
./tmux-runner.sh --list

# Check progress across all logs
sleep 30 && tail -30 /tmp/test_suite_output_tmux-runner-*.log | sort | uniq | tail -30
```

### Parallel Creation (Advanced)

```bash
# Launch all setups concurrently for maximum speed
for i in 3 4 5 6; do
  trunner "./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-${i} \
    --setup-laravel \
    --source-worktree-type psp-p2p \
    --source-branch psp-p2p-merchant-preview-2"
done &

# Wait for all background jobs
wait

# Monitor consolidated progress
watch -n 5 'tail -30 /tmp/test_suite_output_tmux-runner-*.log | tail -20'
```

## Cross-Repository Worktree Management

### Creating Matching Triad Sets

```bash
# Create PSP-P2P worktree
cd /home/lkonga/codes/psp-p2p
trunner "./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-10 \
  --setup-laravel \
  --source-worktree-type psp-p2p \
  --source-branch develop"

# Create matching PSP-Landing worktree
cd /home/lkonga/codes/psp-landing
trunner "./scripts/setup-worktree-with-pass.sh psp-landing-preview-10 \
  --setup-laravel \
  --source-worktree-type psp-landing \
  --source-branch main"

# PPP stays as single shared instance
# No worktree needed
```

### Synchronized Updates

```bash
# Update all worktrees in a triad
for repo in psp-p2p psp-landing; do
  cd /home/lkonga/codes/$repo
  for i in 3 4 5; do
    git -C worktrees/*-preview-${i} pull origin develop
  done
done
```

## Advanced Source Configuration

### Multi-Branch Source Strategy

```bash
# Create worktrees from different source branches
# Worktree 3 from develop
trunner "./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-3 \
  --source-branch develop"

# Worktree 4 from feature branch
trunner "./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-4 \
  --source-branch feature/payment-v2"

# Worktree 5 from release branch
trunner "./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-5 \
  --source-branch release/v1.5"
```

### Copying from Existing Worktree

```bash
# Clone configuration from preview-2
trunner "./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-7 \
  --setup-laravel \
  --source-worktree-type psp-p2p \
  --source-branch psp-p2p-merchant-preview-2 \
  --psp-landing-worktree psp-landing-preview-7 \
  --ppp-worktree push-parser-panel"

# This copies:
# - .env configuration patterns
# - Database structure
# - Triad interconnection setup
```

## Environment Isolation Patterns

### Development Environments

```bash
# Create isolated dev environments for team members
for dev in alice bob carol; do
  trunner "./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-${dev} \
    --setup-laravel \
    --source-worktree-type psp-p2p \
    --source-branch develop \
    --psp-landing-worktree psp-landing-preview-${dev}"
done

# Each developer gets:
# - Isolated database
# - Separate tunnel URL
# - Independent configuration
```

### Testing Environments

```bash
# Create test environments with different configurations
trunner "./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-test1 \
  --setup-laravel \
  --source-branch develop"

# Manual .env modifications for different test scenarios
# Then deploy
sudo ./scripts/deploy-worktree.sh psp-p2p-merchant-preview-test1 \
  --landing-url https://psp-landing-preview-test1.trylatest.in \
  --psp-url https://psp-p2p-merchant-preview-test1.trylatest.in \
  --ppp-url https://push-parser-panel.trylatest.in
```

## Database Management Workflows

### Database Migration Testing

```bash
# Create worktree for migration testing
trunner "./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-migration \
  --setup-laravel \
  --source-branch feature/new-migrations"

# Run migrations in isolated database
cd worktrees/psp-p2p-merchant-preview-migration
php artisan migrate --force

# Verify migrations
php artisan migrate:status

# Rollback if needed
php artisan migrate:rollback
```

### Database Seeding for Different Scenarios

```bash
# Create worktree
trunner "./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-seed-test \
  --setup-laravel \
  --source-branch develop"

# Seed with different datasets
cd worktrees/psp-p2p-merchant-preview-seed-test

# Scenario 1: Minimal data
php artisan db:seed --class=MinimalSeeder

# Or Scenario 2: Full dataset
php artisan db:seed --class=FullSeeder
```

## Deployment Workflows

### Staged Deployment Pipeline

```bash
# Stage 1: Create worktree
trunner "./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-8 \
  --setup-laravel \
  --source-worktree-type psp-p2p \
  --source-branch develop"

# Stage 2: Wait for completion
sleep 60 && tail -30 /tmp/test_suite_output_tmux-runner-*.log

# Stage 3: Deploy tunnel
# Deploy the worktree
sudo ./scripts/deploy-worktree.sh psp-p2p-merchant-preview-8 \
  --landing-url https://psp-landing-preview-8.trylatest.in \
  --psp-url https://psp-p2p-merchant-preview-8.trylatest.in \
  --ppp-url https://push-parser-panel.trylatest.in

# Stage 4: Start tunnel
./scripts/cf-launcher.sh append --config psp-p2p-merchant-preview-8

# Stage 5: Verify
curl -I https://psp-p2p-merchant-preview-8.trylatest.in
```

### Blue-Green Deployment

```bash
# Blue environment (current)
# Exists: psp-p2p-merchant-preview-10

# Create Green environment
trunner "./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-11 \
  --setup-laravel \
  --source-worktree-type psp-p2p \
  --source-branch develop \
  --psp-landing-worktree psp-landing-preview-11"

# Test Green
./scripts/cf-launcher.sh append --config psp-p2p-merchant-preview-11
# Manual testing...

# Switch traffic (update DNS/load balancer)
# Then cleanup Blue
sudo ./scripts/deploy-worktree.sh psp-p2p-merchant-preview-10 --teardown --cleanup
```

### Canary Deployment

```bash
# Production: psp-p2p-merchant-preview-5
# Create canary with new version
trunner "./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-canary \
  --setup-laravel \
  --source-branch feature/performance-improvements"

# Deploy canary
# Deploy the canary worktree
sudo ./scripts/deploy-worktree.sh psp-p2p-merchant-preview-canary \
  --landing-url https://psp-landing-preview-canary.trylatest.in \
  --psp-url https://psp-p2p-merchant-preview-canary.trylatest.in \
  --ppp-url https://push-parser-panel.trylatest.in
./scripts/cf-launcher.sh append --config psp-p2p-merchant-preview-canary

# Route 10% traffic to canary (external load balancer)
# Monitor metrics...

# If successful, promote canary to production
# If failed, rollback by killing canary
```

## Monitoring and Maintenance

### Health Check Automation

```bash
#!/bin/bash
# check-worktree-health.sh

WORKTREES=$(ls worktrees/ | grep "psp-p2p-merchant-preview-")

for wt in $WORKTREES; do
  echo "Checking $wt..."

  # Check if .env exists
  if [ ! -f "worktrees/$wt/.env" ]; then
    echo "  ⚠ Missing .env"
  fi

  # Check database connectivity
  cd worktrees/$wt
  php artisan db:show > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "  ✓ Database OK"
  else
    echo "  ✗ Database connection failed"
  fi

  cd ../..
done
```

### Log Aggregation

```bash
# Collect logs from all worktrees
for wt in worktrees/psp-p2p-merchant-preview-*; do
  echo "=== $wt ==="
  tail -20 "$wt/storage/logs/laravel.log"
  echo ""
done
```

### Resource Usage Monitoring

```bash
# Monitor disk usage per worktree
du -sh worktrees/psp-p2p-merchant-preview-* | sort -h

# Monitor database sizes
mysql -uroot -p'$$$123123' -e "
  SELECT
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
  FROM information_schema.tables
  WHERE table_schema LIKE 'psp_%preview%'
  GROUP BY table_schema
  ORDER BY SUM(data_length + index_length) DESC;
"
```

## Cleanup and Maintenance Workflows

### Bulk Cleanup

```bash
# Clean up worktrees 3-6
for i in 3 4 5 6; do
  echo "Cleaning up preview-${i}..."
  sudo ./scripts/deploy-worktree.sh psp-p2p-merchant-preview-${i} --teardown --cleanup

  # Verify cleanup
  ls worktrees/ | grep -q "preview-${i}" && echo "  ⚠ Still exists" || echo "  ✓ Removed"
done
```

### Selective Cleanup (Keep Files)

```bash
# Remove tunnels but keep worktrees for later
for i in 7 8 9; do
  sudo ./scripts/deploy-worktree.sh psp-p2p-merchant-preview-${i} --teardown
done

# Worktree files remain for future use
```

### Archive Old Worktrees

```bash
# Archive instead of delete
for wt in worktrees/psp-p2p-merchant-preview-{1,2}; do
  if [ -d "$wt" ]; then
    tar -czf "${wt##*/}.tar.gz" "$wt"
    sudo ./scripts/deploy-worktree.sh "${wt##*/}" --teardown --cleanup
  fi
done

# Restore if needed later
# tar -xzf psp-p2p-merchant-preview-1.tar.gz
```

## Integration with CI/CD

### GitHub Actions Workflow

```yaml
name: Create Preview Environment

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  preview:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Setup SSH
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.SSH_PRIVATE_KEY }}" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa

      - name: Create Worktree
        run: |
          PR_NUMBER=${{ github.event.pull_request.number }}
          ssh lkonga@37.60.247.12 "
            cd /home/lkonga/codes/psp-p2p
            ./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-pr-${PR_NUMBER} \
              --setup-laravel \
              --source-branch ${{ github.head_ref }}
          "

      - name: Comment PR
        uses: actions/github-script@v5
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: 'Preview environment: https://psp-p2p-merchant-preview-pr-${{ github.event.pull_request.number }}.trylatest.in'
            })
```

### GitLab CI Pipeline

```yaml
preview:
  stage: deploy
  script:
    - ssh lkonga@37.60.247.12 "
        cd /home/lkonga/codes/psp-p2p &&
        ./scripts/setup-worktree-with-pass.sh psp-p2p-merchant-preview-mr-$CI_MERGE_REQUEST_IID
          --setup-laravel
          --source-branch $CI_COMMIT_REF_NAME
      "
  environment:
    name: preview/mr-$CI_MERGE_REQUEST_IID
    url: https://psp-p2p-merchant-preview-mr-$CI_MERGE_REQUEST_IID.trylatest.in
    on_stop: cleanup_preview
  only:
    - merge_requests

cleanup_preview:
  stage: cleanup
  script:
    - ssh lkonga@37.60.247.12 "
        cd /home/lkonga/codes/psp-p2p &&
        sudo ./scripts/deploy-worktree.sh psp-p2p-merchant-preview-mr-$CI_MERGE_REQUEST_IID --teardown --cleanup
      "
  when: manual
  environment:
    name: preview/mr-$CI_MERGE_REQUEST_IID
    action: stop
```

## Advanced Troubleshooting Workflows

### Debug Stuck Setup

```bash
# If setup appears stuck
# 1. Check tmux session
tmux list-sessions | grep tmux-runner

# 2. Attach to see what's happening
tmux attach -t tmux-runner-{SESSION_ID}

# 3. Check for prompts or errors

# 4. If truly stuck, kill and restart
./tmux-runner.sh --kill {SESSION_ID}
trunner "./scripts/setup-worktree-with-pass.sh ..." # retry
```

### Repair Broken Worktree

```bash
# If worktree is in bad state
WORKTREE="psp-p2p-merchant-preview-5"

# 1. Remove from git
git worktree remove worktrees/$WORKTREE --force

# 2. Prune worktree references
git worktree prune

# 3. Clean up files manually if needed
sudo rm -rf worktrees/$WORKTREE

# 4. Drop databases
mysql -uroot -p'$$$123123' -e "DROP DATABASE IF EXISTS ${WORKTREE//-/_}_staging;"
mysql -uroot -p'$$$123123' -e "DROP DATABASE IF EXISTS ${WORKTREE//-/_}_testing;"

# 5. Recreate clean
trunner "./scripts/setup-worktree-with-pass.sh $WORKTREE --setup-laravel ..."
```

## Best Practices Summary

**Token Efficiency**:
- Always use `trunner` for PSP-Landing and PSP-P2P setups
- Monitor via log files, not continuous polling
- Batch operations when possible
- Use parallel creation for multiple worktrees

**Numbered Pairing**:
- Always match numbers across triad (PSP-P2P-3 ↔ PSP-Landing-3)
- Document which numbers are in use
- Keep tracking spreadsheet for active worktrees

**Resource Management**:
- Clean up unused worktrees regularly
- Monitor disk and database usage
- Archive instead of delete for important worktrees
- Set up automated cleanup for temporary previews

**Security**:
- Each worktree has isolated database
- Never share database credentials across worktrees
- Use separate .env files with different APP_KEYs
- Regularly rotate database passwords
