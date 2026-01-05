# Main Branch Deployment Modes

## Available Modes

### Fresh Deploy (Default)
Creates databases from scratch, full setup.

```bash
./vps-deploy-main.sh deploy --repo git@github.com:lkonga/psp-p2p.git --branch develop --app-type psp-p2p
```

**Duration**: 734s (~12 minutes)
**Use When**: First deployment or after database corruption

### Redeploy (Idempotent)
Reuses existing databases, updates code only.

```bash
# Same command - auto-detects existing deployment
./vps-deploy-main.sh deploy --repo git@github.com:lkonga/psp-p2p.git --branch develop --app-type psp-p2p
```

**Duration**: 691s (~11.5 minutes) - 6% faster
**Use When**: Code updates, dependency changes
**Safety**: ✅ Idempotent - can run multiple times

### Resetup (Destructive)
Drops and recreates databases.

```bash
./vps-deploy-main.sh deploy --repo git@github.com:lkonga/psp-p2p.git --branch develop --app-type psp-p2p --resetup --auto-confirm
```

**Duration**: ~750s (~12.5 minutes)
**Use When**: Database corruption, schema changes, clean slate needed
**Warning**: ⚠️ Destroys all data

### Rebuild (Non-Destructive)
Rebuilds artifacts without touching databases.

```bash
./vps-deploy-main.sh deploy --repo git@github.com:lkonga/psp-p2p.git --branch develop --app-type psp-p2p --rebuild-full
```

**Duration**: ~400s (~6.5 minutes)
**Use When**: Frontend/backend changes, asset updates
**Safety**: ✅ Preserves database data

### Skip Tests (Fast)
Quick deployment without test suite.

```bash
./vps-deploy-main.sh deploy --repo git@github.com:lkonga/psp-p2p.git --branch develop --app-type psp-p2p --skip-tests --skip-migrations
```

**Duration**: ~300s (~5 minutes)
**Use When**: Emergency fixes, non-critical updates
**Warning**: ⚠️ No test verification

## Mode Selection Guide

| Situation | Mode | Duration |
|-----------|------|----------|
| First deployment | Fresh | 12 min |
| Code update | Redeploy | 11.5 min |
| Database issue | Resetup | 12.5 min |
| Asset rebuild | Rebuild | 6.5 min |
| Emergency fix | Skip Tests | 5 min |

## Verification

All modes should return HTTP 302:

```bash
curl -I https://psp-p2p.trylatest.in
# Expected: HTTP/2 302
```
