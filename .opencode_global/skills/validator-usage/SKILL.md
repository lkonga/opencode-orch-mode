# Validator Usage

**Description**: Comprehensive guide for deployment validators - automatic integration in deploy scripts and standalone usage for troubleshooting and verification

**Triggers**:
- `validator-usage`, `deployment validators`, `validate deployment`
- "how to validate deployment", "check deployment before deploying"
- "triad validation", "validator types", "when to run validators"

**References**:
- `references/validator-workflow-analysis.md` - Detailed analysis of validator architecture
- `references/validator-quick-reference.md` - Quick command reference

---

## Overview

Deployment validators provide enterprise-grade validation for Laravel deployments with fail-fast patterns. They run automatically in deploy scripts and can be executed standalone for troubleshooting.

**Refactor 1 Note**: Validators now verify triad URL consistency. Main branch deployments require `--ppp-url` parameter (see `/home/lkonga/codes/llm-rules/docs/refactors/refactor-1/README.md`).

**Key Benefits**:
- Fail-fast validation before expensive operations (git clone, composer install, database init)
- Consistent validation across local, VPS, and worktree deployments
- Clear, actionable error messages
- Composable design - run all validators or individual ones

---

## Validator Types

There are 8 validator types, each serving a specific purpose:

| Validator | Description | When to Run | Automatic |
|-----------|-------------|-------------|-----------|
| `environment` | Checks PHP, MySQL, Apache, Cloudflare cert | Pre-deployment | ✅ deploy-worktree<br>✅ vps-deploy |
| `tunnel` | Validates Cloudflare tunnel config YAML structure | Pre-deployment | ✅ deploy-worktree<br>✅ vps-deploy |
| `directories` | Checks Laravel directory structure (storage, bootstrap) | Pre-deployment | ✅ vps-deploy |
| `env-file` | Validates .env file has required variables | Pre-deployment | ✅ deploy-worktree<br>✅ vps-deploy |
| `triad` | Validates triad wiring across all 3 services | Post-deployment | ❌ Manual only |
| `project-type` | Verifies project is Laravel/static/node | Debugging | ❌ Manual only |
| `project-name` | Verifies project name matches expected | Debugging | ❌ Manual only |
| `deployment-context` | Checks deployment context (local vs VPS) | Debugging | ❌ Manual only |

---

## Automatic vs Standalone

### Automatic Validation (Built into Deploy Scripts)

**deploy-worktree.sh** - Worktree deployments:
```bash
# Automatically runs BEFORE deployment:
./scripts/validate-deployment.sh --type environment,tunnel,env-file --env staging
```

**vps-deploy-worktree.sh** - VPS worktree deployments:
```bash
# Runs 4 validators at optimal points:
# 1. validate_vps_infrastructure (line 920) - Before all operations
# 2. validate_laravel_directories (line 510) - Before composer install
# 3. validate_triad_wiring (line 956) - Before git clone
# 4. validate_env_file (line 1159) - Before database init
```

**vps-deploy-main.sh** - VPS main branch deployments:
```bash
# Same 4 validators as vps-deploy-worktree.sh
# Runs at same optimal points
```

### Standalone Validation (Manual)

Run validators manually for:
- Pre-deployment verification
- Troubleshooting failed deployments
- Post-deployment triad validation
- Debugging configuration issues

---

## Common Workflows

### Workflow 1: Deploy New Worktree (Automatic)

Validators run automatically - no manual steps needed:

```bash
# Navigate to project root first
cd /home/lkonga/codes/psp-p2p

# Deploy worktree (validators run automatically)
./scripts/deploy-worktree.sh \
  psp-p2p-merchant-preview-6 \
  --source-worktree-type psp-p2p \
  --domain trylatest.in

# Validators run automatically:
# ✓ environment check (PHP, MySQL, Apache)
# ✓ tunnel config validation
# ✓ .env file validation
```

### Workflow 2: Deploy to VPS (Automatic)

```bash
cd /home/lkonga/codes/llm-rules
./scripts/vps/vps-deploy-worktree.sh --project psp-p2p --subdomain preview-6

# Validators run automatically at optimal points:
# ✓ VPS infrastructure (Nginx, PHP-FPM, MySQL, llm-rules)
# ✓ Laravel directories (before composer install)
# ✓ Triad wiring (before git clone)
# ✓ .env file (before database init)
```

### Workflow 3: Pre-Deployment Verification (Manual)

Run validators before deploying to catch issues early:

```bash
cd /home/lkonga/codes/psp-p2p

# Check environment:
./scripts/validate-deployment.sh --type environment --env staging

# Check tunnel config:
./scripts/validate-deployment.sh --type tunnel --env staging

# Check .env files:
./scripts/validate-deployment.sh --type env-file --env staging

# Check all core validators:
./scripts/validate-deployment.sh --type environment,tunnel,env-file --env staging
```

### Workflow 4: Triad Validation (Manual - Post-Deployment)

Run AFTER all three services are deployed:

```bash
# Validate PSP-P2P triad wiring:
cd /home/lkonga/codes/psp-p2p
./scripts/validate-deployment.sh --type triad --env staging

# Validate PSP-Landing triad wiring:
cd /home/lkonga/codes/psp-landing
./scripts/validate-deployment.sh --type triad --env staging

# Validate Push Parser Panel triad wiring:
cd /home/lkonga/codes/push-parser-panel
./scripts/validate-deployment.sh --type triad --env staging
```

**Why Manual**: Triad validator checks all 3 services are deployed and wired correctly. Can't run during single-service deployment.

### Workflow 5: Troubleshoot Failed Deployment

```bash
cd /home/lkonga/codes/psp-p2p

# Run all validators to find issues:
./scripts/validate-deployment.sh --type all --env staging

# Check specific component:
./scripts/validate-deployment.sh --type tunnel --env staging

# Check with verbose output:
bash -x ./scripts/validate-deployment.sh --type environment --env staging
```

---

## Validator Details

### Environment Validator

**What it checks**:
- Apache2 installed and running
- PHP 8.3 FPM installed and running
- MySQL accessible with configured credentials
- Cloudflare origin certificate exists

**When to use**: Pre-deployment verification

**Example**:
```bash
./scripts/validate-deployment.sh --type environment --env staging
```

### Tunnel Validator

**What it checks**:
- Cloudflare tunnel config file exists
- YAML structure is correct (origincert, ingress sections)
- originRequest not at global level
- origincert file exists

**When to use**: Pre-deployment, troubleshooting tunnel startup issues

**Example**:
```bash
./scripts/validate-deployment.sh --type tunnel --env staging
```

### Directories Validator

**What it checks**:
- Laravel directories exist: storage/app/public, storage/framework/sessions, storage/framework/views, storage/framework/cache, storage/logs, bootstrap/cache

**When to use**: Pre-deployment, after fresh Laravel install

**Example**:
```bash
./scripts/validate-deployment.sh --type directories --env staging
```

### Env-File Validator

**What it checks**:
- .env files exist for environment
- Required variables set: APP_NAME, APP_ENV, APP_KEY, DB_CONNECTION
- Database variables set:
  - `.env.*.testing` files: DB_DATABASE_TESTING, DB_USERNAME_TESTING
  - Other .env files: DB_DATABASE, DB_USERNAME
- No placeholder values (except allowed testing placeholders)

**When to use**: Pre-deployment, after .env file changes

**Example**:
```bash
./scripts/validate-deployment.sh --type env-file --env staging
```

### Triad Validator

**What it checks**:
- PSP_BASE_URL points to valid deployment
- LANDING_APP_URL points to valid deployment
- PUSH_PARSER_API_URL points to valid deployment
- VERIFICATION_CALLBACK_BASE_URL points to valid deployment
- Deployments exist at expected paths:
  - Local: `$HOME/codes/*/worktrees/*`
  - VPS: `/var/www/worktrees/*`

**When to use**: AFTER all three services deployed

**Example**:
```bash
./scripts/validate-deployment.sh --type triad --env staging
```

**Note**: Does NOT run automatically in deploy scripts because it checks all 3 services, but deploy scripts only deploy one service at a time.

---

## VPS vs Local Validation

Validators work on both local and VPS environments with automatic detection:

### Local Deployments
- Path: `$HOME/codes/*/worktrees/*`
- Environment: Auto-detected as "local"
- Validators run: Direct execution

### VPS Deployments
- Path: `/var/www/worktrees/*`
- Environment: Auto-detected as "vps"
- Validators run: Via SSH with `vps_exec "source /opt/llm-rules/scripts/validators/deployment-validators.sh && <validator>"`
- Synced to: `/opt/llm-rules/scripts/validators/`

### Environment Detection

Validators automatically detect deployment environment:

```bash
# Local worktree:
cd /home/lkonga/codes/psp-p2p/worktrees/psp-p2p-preview-6
./scripts/validate-deployment.sh --type environment --env staging
# Detects: local environment
# Checks: $HOME/codes/psp-p2p/worktrees/psp-p2p-preview-6

# VPS deployment:
./scripts/vps/vps-deploy-worktree.sh --project psp-p2p --subdomain preview-6
# Detects: vps environment
# Checks: /var/www/worktrees/psp-p2p-preview-6
```

---

## Command Reference

### Basic Usage

```bash
# Single validator:
./scripts/validate-deployment.sh --type <type> --env <environment>

# Multiple validators:
./scripts/validate-deployment.sh --type <type1>,<type2>,<type3> --env <environment>

# All validators:
./scripts/validate-deployment.sh --type all --env <environment>

# With custom project path:
./scripts/validate-deployment.sh --type <type> --env <environment> --project /path/to/project
```

### Environment Types

- `development` - Local development
- `staging` - Worktree deployments (default)
- `production` - Main branch deployments

### Examples

```bash
# Check environment for staging:
./scripts/validate-deployment.sh --type environment --env staging

# Check tunnel and env-file for production:
./scripts/validate-deployment.sh --type tunnel,env-file --env production

# Run all validators:
./scripts/validate-deployment.sh --type all --env staging

# Check specific project:
./scripts/validate-deployment.sh --type triad --env staging --project /home/lkonga/codes/psp-p2p
```

---

## Troubleshooting

### Validator Fails Silently

**Problem**: Validator exits with code 1 but no error message

**Solution**: Run with bash debug mode
```bash
bash -x ./scripts/validate-deployment.sh --type environment --env staging
```

### Env-File Validator Fails

**Problem**: "Variable 'DB_DATABASE' not found" in testing environment

**Solution**: Validator checks for environment-specific variables:
- `.env.*.testing` files: DB_DATABASE_TESTING
- Other files: DB_DATABASE

Check your .env file has the correct variable names.

### Triad Validator Fails

**Problem**: "Triad service not found"

**Solution**:
1. Ensure all three services are deployed
2. Check URLs in .env are correct
3. Verify deployments exist at expected paths

### Tunnel Validator Fails

**Problem**: "Tunnel configuration validation failed"

**Solution**:
1. Check config file exists: `~/.cloudflared/psp-p2p/config-*.yml`
2. Verify YAML structure (origincert, ingress sections)
3. Ensure origincert file exists: `~/.cloudflared/cert.pem`

---

## Best Practices

1. **Run Validators Before Deployment**: Catch issues before expensive operations
2. **Fix Validation Failures Immediately**: Don't skip validators
3. **Use Triad Validator After Full Deployment**: Only when all 3 services are up
4. **Check Validator Output**: Read error messages carefully
5. **Test Locally First**: Run validators locally before VPS deployment

---

## Integration with Deploy Scripts

### deploy-worktree.sh

```bash
# Line 203:
if ! "$SCRIPT_DIR/validate-deployment.sh" --env "$ENV_TYPE" \
  --project "$WORKTREE_PATH" \
  --type "environment,tunnel,env-file"; then
    echo "❌ ERROR: Validation failed" >&2
    exit 1
fi
```

### vps-deploy-worktree.sh & vps-deploy-main.sh

```bash
# 4 integration points:

# 1. Infrastructure validation (line 920):
if ! vps_exec "source /opt/llm-rules/scripts/validators/deployment-validators.sh && validate_vps_infrastructure 2>&1"; then
    log_error "VPS infrastructure validation failed"
    exit 1
fi

# 2. Laravel directories (line 510):
if ! vps_exec "source /opt/llm-rules/scripts/validators/deployment-validators.sh && validate_laravel_directories 'staging' '${app_path}' 2>&1"; then
    log_error "Laravel directory validation failed"
    exit 1
fi

# 3. Triad wiring (line 956):
if ! vps_exec "source /opt/llm-rules/scripts/validators/deployment-validators.sh && validate_triad_wiring 'staging' '${app_path}' 2>&1"; then
    log_error "Triad wiring validation failed"
    exit 1
fi

# 4. Env-file (line 1159):
if ! vps_exec "source /opt/llm-rules/scripts/validators/deployment-validators.sh && validate_env_file 'staging' '${app_path}' 2>&1"; then
    log_error "Environment file validation failed"
    exit 1
fi
```

---

## Summary

**Automatic Validation**: Built into deploy-worktree, vps-deploy-worktree, vps-deploy-main
**Standalone Validation**: All validators can be run manually
**Triad Validation**: Manual only, run after all 3 services deployed
**Environment Detection**: Automatic (local vs VPS)
**Fail-Fast**: Validators run before expensive operations

**Key Point**: Validators provide enterprise-grade validation with clear error messages. Use them!
