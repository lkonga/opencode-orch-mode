# VALIDATOR QUICK REFERENCE

## AUTOMATIC VALIDATION (Built into Deploy Scripts)

### deploy-worktree.sh
```bash
# Automatically runs:
./scripts/validate-deployment.sh --type environment,tunnel,env-file
```

### deploy_main.sh
```bash
# Currently: NO VALIDATION ❌
# Should add:
./scripts/validate-deployment.sh --type environment,tunnel,env-file --env production
```

---

## STANDALONE VALIDATION (Manual Commands)

### Pre-Deployment Checks
```bash
# Check environment:
./scripts/validate-deployment.sh --type environment --env staging

# Check tunnel config:
./scripts/validate-deployment.sh --type tunnel --env staging

# Check .env files:
./scripts/validate-deployment.sh --type env-file --env staging

# Check all core validators:
./scripts/validate-deployment.sh --type environment,tunnel,env-file --env staging

# Check everything:
./scripts/validate-deployment.sh --type all --env staging
```

### Triad Validation (After All 3 Services Deployed)
```bash
# Check PSP-P2P triad wiring:
cd /home/lkonga/codes/psp-p2p
./scripts/validate-deployment.sh --type triad --env staging

# Check PSP-Landing triad wiring:
cd /home/lkonga/codes/psp-landing
./scripts/validate-deployment.sh --type triad --env staging

# Check Push Parser Panel triad wiring:
cd /home/lkonga/codes/push-parser-panel
./scripts/validate-deployment.sh --type triad --env staging
```

---

## VALIDATOR TYPES

| Type | Description | When to Run |
|------|-------------|-------------|
| `environment` | Check PHP, MySQL, Apache, Cloudflare | Pre-deployment |
| `tunnel` | Check Cloudflare tunnel config structure | Pre-deployment |
| `directories` | Check Laravel directory structure | Pre-deployment |
| `env-file` | Check .env file variables | Pre-deployment |
| `triad` | Check triad wiring across all 3 services | Post-deployment |
| `project-type` | Verify project type (Laravel/static) | Debugging |
| `project-name` | Verify project name | Debugging |
| `deployment-context` | Check deployment context | Debugging |

---

## COMMON WORKFLOWS

### Workflow 1: Deploy New Worktree
```bash
# 1. Deploy (validators run automatically):
./scripts/deploy-worktree.sh psp-p2p-merchant-preview-6 --domain trylatest.in

# 2. Verify tunnel is accessible:
curl -I https://psp-p2p-merchant-preview-6.trylatest.in
```

### Workflow 2: Deploy Main Branch
```bash
# 1. Run validators manually:
./scripts/validate-deployment.sh --type environment,tunnel,env-file --env production

# 2. Deploy if validation passes:
./scripts/deploy_main.sh --domain trylatest.in
```

### Workflow 3: Validate Triad After Full Deployment
```bash
# After all three services deployed:
cd /home/lkonga/codes/psp-p2p && ./scripts/validate-deployment.sh --type triad --env staging
cd /home/lkonga/codes/psp-landing && ./scripts/validate-deployment.sh --type triad --env staging
cd /home/lkonga/codes/push-parser-panel && ./scripts/validate-deployment.sh --type triad --env staging
```

### Workflow 4: Troubleshoot Failed Deployment
```bash
# Check what's wrong:
./scripts/validate-deployment.sh --type all --env staging

# Check specific component:
./scripts/validate-deployment.sh --type tunnel --env staging
```

---

## KEY POINTS

1. **Automatic**: deploy-worktree.sh runs core validators automatically
2. **Manual**: All validators can be run standalone for debugging
3. **Triad**: Run manually AFTER all three services deployed
4. **No New Script Needed**: Use `--type triad` with existing validate-deployment.sh

---

**RULES**
**RULES**
