---
name: 'Main Branch Deployment'
description: 'Deploy and redeploy main branches (psp-p2p, psp-landing, push-parser-panel) with automated Laravel setup, testing, and Cloudflare tunnel configuration'
triggers: ['$MainDeploy', '$DeployMain']
trigger_keywords: ['deploy main branch', 'redeploy main', 'main branch setup', 'deploy production']
related_skills: ['$TmuxProtectedExecution', '$ArchitectCoder', '$CFLauncher', '$LocalSudoRunner', '$SQLiteDeployTracker']
references: {'Deployment workflow': 'references/deployment-workflow.md', 'Testing integration': 'references/testing-integration.md', 'Tunnel configuration': 'references/tunnel-configuration.md', 'Troubleshooting': 'references/main-deploy-troubleshooting.md', 'Main branch guide': '/tmp/vps-main-branch-deployment-guide.md'}
---

# Main Branch Deployment

## Purpose
Deploy and redeploy **VPS main branches** (psp-p2p, psp-landing, push-parser-panel) with full automation: Laravel setup, database migrations, testing, and SSL configuration.

**Note**: This skill covers **Group 1: VPS Main** deployments. For **Group 4: Local Main** deployments, see `$WorktreeOrchestration` skill.

## Refactor 1: Triad URL Handling

**⚠️ BREAKING CHANGE**: `--ppp-url` parameter is now **mandatory** for all main branch deployments.

**Before** (no longer works):
```bash
./scripts/vps/vps-deploy-main.sh deploy --app-type psp-p2p --repo git@github.com:lkonga/psp-p2p.git --branch develop
```

**After** (required):
```bash
./scripts/vps/vps-deploy-main.sh deploy --app-type psp-p2p --repo git@github.com:lkonga/psp-p2p.git --branch develop --ppp-url https://staging.push-parser-panel.trylatest.in
```

**What Changed**: URLs are now automatically extracted from git remote and propagated through all deployment layers. See `/home/lkonga/codes/llm-rules/docs/refactors/refactor-1/README.md` for details.

## When to Use

- Initial deployment of main branches to VPS
- Redeploy after significant code changes
- Fix broken main branch deployments on VPS
- Update main branches with latest develop changes
- Periodic maintenance deployments on VPS

## When to Use This Skill vs Worktree Orchestration

**Use This Skill ($MainDeploy)** for:
- **Group 1: VPS Main** deployments to VPS staging environment
- Deploying to `https://staging.{project}.trylatest.in`
- Using `vps-deploy-main.sh` from VPS scripts directory
- Production-like staging on VPS infrastructure

**Use Worktree Orchestration ($WorktreeOrchestration)** for:
- **Group 4: Local Main** deployments to local environment
- Deploying to `https://{project}.trylatest.in` via Cloudflare tunnel
- Using `setup-main.sh` + `deploy-main.sh` from project root
- Local testing with quick staging

**Key Differences**:
| Aspect | VPS Main (This Skill) | Local Main (Worktree Orchestration) |
|--------|----------------------|-------------------------------------|
| **Scripts** | `vps-deploy-main.sh` | `setup-main.sh` + `deploy-main.sh` |
| **Location** | VPS scripts directory | Project root |
| **URL Pattern** | `https://staging.{project}.trylatest.in` | `https://{project}.trylatest.in` |
| **Access** | Direct VPS hosting | Cloudflare tunnel to local |
| **SSL** | Let's Encrypt on VPS | Cloudflare tunnel TLS |
| **Environment** | Production staging on VPS | Local testing |

## Core Repositories

| Repository | Main Branch | Deployment URL |
|-----------|-------------|----------------|
| PSP-P2P | develop | https://psp-p2p.trylatest.in |
| PSP-Landing | develop | https://psp-landing.trylatest.in |
| Push Parser Panel | main | https://push-parser-panel.trylatest.in |

## Quick Start

```bash
# Use trunner directly (NOT sudo-runner) to preserve SSH keys
cd /home/lkonga/codes/llm-rules/scripts/vps && \
/home/lkonga/codes/llm-rules/scripts/tmux-runner/trunner.sh \
  "timeout 1200 ./vps-deploy-main.sh deploy \
    --repo git@github.com:lkonga/psp-p2p.git \
    --branch develop \
    --app-type psp-p2p \
    --ppp-url https://staging.push-parser-panel.trylatest.in"

# Monitor via $ArchitectCoder loop pattern
```

**Note**: `--ppp-url` is **mandatory** for all main branch deployments (Refactor 1).

## Deployment Workflow

<reference title="Deployment workflow" path="references/deployment-workflow.md" />

**Summary**: Pre-flight → Dependencies → Laravel Config → Database → Apache/SSL → Tunnel Config → Testing → Verification

**Typical Duration**: 11-12 minutes (734s fresh, 691s redeploy)

**Performance**: 13.8% optimization potential (~101s savings) - see references/phase-3-execution-details.md

**Key Phases**:
1. Validates environment and Laravel directories (~120s)
2. Installs composer/npm dependencies, builds assets (~250s total)
3. Generates APP_KEY, clears caches, runs tests (~180s)
4. Creates/migrates databases (staging + testing) (~30s)
5. Configures Nginx virtual hosts and SSL certificates (~100s)
6. Runs test suite to verify deployment (79s)
7. Laravel optimizations and smoke test (~81s)
8. Reports status and next steps

## Monitoring Deployment

**Use $ArchitectCoder skill** to monitor trunner logs:

```bash
# Subagent monitors using approved loop pattern
for i in {1..20}; do
  sleep 5 && tail -15 /tmp/test_suite_output_tmux-runner-SESSIONID.log
done
```

**Completion Markers**:
- "Deployment complete"
- "All tests passed"
- "Cloudflare tunnel configured"
- Test execution starts

## Starting Tunnels After Deployment

<reference title="Tunnel configuration" path="references/tunnel-configuration.md" />

```bash
cd /home/lkonga/codes/llm-rules && \
./scripts/cf-launcher.sh --config psp-p2p,psp-landing,push-parser-panel
```

## Redeploy vs Fresh Deploy

Same command for both: `./scripts/deploy-main.sh` (auto-detects).
- **Redeploy**: Reuses databases, updates code/dependencies
- **Fresh Deploy**: Creates databases, full setup from scratch

**Idempotency**: ✅ Verified safe - can redeploy multiple times without issues

## Recent Changes (December 2025)

- ✅ **Phase 3 Testing**: 2/5 tests complete (fresh + idempotent redeploy)
- ✅ **Performance Verified**: 734s fresh, 691s redeploy (6% faster)
- ✅ **Idempotency Verified**: Safe redeployment without side effects
- ✅ **Fail-fast dirty repo**: VPS llm-rules must be clean (no sync fallback)
- ✅ **Frontend build extended**: psp-p2p now builds frontend assets (like psp-landing)
- ✅ **Database naming**: Main branches skip DB_PREFIX (no double prefixing)
- ✅ **Execution pattern**: Use `trunner.sh` directly (NOT `sudo-runner`) for SSH key preservation
- ✅ **Performance Analysis**: 13.8% optimization potential identified (see references/phase-3-execution-details.md)

## Non-Interactive Execution

Fully automated via $LocalSudoRunner—no prompts for passwords, configs, or tests.

## Impact on Preview Worktrees

<reference title="Troubleshooting" path="references/main-deploy-troubleshooting.md" />

**After main branch redeploy, preview worktrees may break** due to:
- Updated composer dependencies
- New database migrations
- Changed environment requirements

**Solution**: Use `$WorktreeOrchestration` with `--resetup` flag:

```bash
cd /home/lkonga/codes/psp-p2p
./scripts/setup-worktree.sh \
  psp-p2p-merchant-preview-5 \
  --resetup \
  --source-worktree-type psp-p2p \
  --psp-landing-worktree psp-landing-preview-5 \
  --psp-p2p-worktree psp-p2p-merchant-preview-5 \
  --ppp-worktree push-parser-panel
```

## Success Criteria

✓ Deployment completes without errors
✓ All tests pass (test-gated deployment)
✓ HTTP status returns 302 (redirect to login)
✓ SSL certificate valid and HTTPS enforced
✓ Laravel setup successful
✓ Frontend assets built (psp-landing and psp-p2p)
✓ Database migrations completed
✓ Smoke test passed (API authentication)

## Integration with Other Skills

- **$TmuxProtectedExecution**: Use trunner for all deployments
- **$ArchitectCoder**: Monitor deployment logs via loop pattern
- **$CFLauncher**: Start tunnels after deployment
- **$LocalSudoRunner**: Automated sudo password handling
- **$WorktreeOrchestration**: Fix affected preview worktrees with --resetup
- **$SQLiteDeployTracker**: Deployment metadata tracking, PPP deploy protection

---

## SQLite Deploy Tracker Integration

Main branch deployments are automatically tracked by the deployment scripts:

- **Records deployment metadata**: URL, environment, branch, status, timestamps
- **Provides PPP deploy protection**: Check before overwriting active PPP deployments
- **Supports triad wiring validation**: Verify triad URLs are correctly configured

**See**: [SQLite Deploy Tracker - Integration Examples](docs/features/sqlite-tracker/integration-examples.md#vps-deployment-integration)

### .env Storage for VPS Deployments

**VPS→Local File Copy Required**:

When recording .env files from VPS deployments, use temp file pattern:

```bash
local temp_env="/tmp/.env.deploy.${SUBDOMAIN}.$$"
vps_exec "cat '${app_path}/.env'" > "${temp_env}"

"${tracker_client}" record-env --env-file "${temp_env}" --app-url "${APP_URL}"
rm -f "${temp_env}"
```

**Reason**: Tracker client runs locally, cannot access VPS paths directly.

## Progressive Disclosure

<references>
  <reference title="Deployment workflow" path="references/deployment-workflow.md" description="Detailed deployment steps, pre-flight checks, Laravel setup process" />
  <reference title="Testing integration" path="references/testing-integration.md" description="Test execution, test groups, failure handling" />
  <reference title="Tunnel configuration" path="references/tunnel-configuration.md" description="Cloudflare tunnel setup, domain configuration, SSL certificates" />
  <reference title="Troubleshooting" path="references/main-deploy-troubleshooting.md" description="Common errors, preview worktree impacts, recovery procedures" />
  <reference title="Phase 3 execution" path="references/phase-3-execution-details.md" description="Phase 3 test results, performance analysis, optimization opportunities, successful deployment flows" />
ng integration" path="references/testing-integration.md" description="Test execution, test groups, failure handling" />
  <reference title="Tunnel configuration" path="references/tunnel-configuration.md" description="Cloudflare tunnel setup, domain configuration, SSL certificates" />
  <reference title="Troubleshooting" path="references/main-deploy-troubleshooting.md" description="Common errors, preview worktree impacts, recovery procedures" />
  <reference title="Phase 3 execution" path="references/phase-3-execution-details.md" description="Phase 3 test results, performance analysis, optimization opportunities, successful deployment flows" />
</references>
