# Triad Architecture Reference

## Overview

The PSP (Payment Service Provider) system consists of three interconnected applications that work together as a functional unit:

```
┌──────────────────┐
│     PSP-P2P      │──────> LANDING_APP_URL
│   (Pay-In API)   │──────> PUSH_PARSER_API_URL
└──────────────────┘
         ↑
         │ PSP_BASE_URL
         │
┌──────────────────┐
│   PSP-Landing    │
│  (User Interface) │
└──────────────────┘
         ↓
         │ PSP_API_URL
         │
┌──────────────────┐
│  Push Parser     │
│  (Verification)  │
└──────────────────┘
```

## Three-Repository System

### 1. PSP-P2P (Payment Processing)
**Purpose**: Core payment service provider for pay-in operations
**Repository**: `lkonga/psp-p2p`
**Role**: API backend, payment gateway integration, transaction processing

**Worktree Pattern**: `psp-p2p-merchant-preview-{N}`

### 2. PSP-Landing (User Interface)
**Purpose**: Payment landing page for customer interaction
**Repository**: `lkonga/psp-landing`
**Role**: Frontend UI, customer-facing payment forms

**Worktree Pattern**: `psp-landing-preview-{N}`

### 3. Push Parser Panel (Verification)
**Purpose**: Payment verification webhook receiver
**Repository**: `lkonga/push-parser-panel`
**Role**: Admin interface, webhook processing, verification callbacks

**Worktree Pattern**: `push-parser-panel` (single shared instance)

## Numbered Pairing Strategy

**Core Concept**: Worktrees with matching numbers form functional triads across the three repositories.

### Pairing Pattern
```
psp-landing-preview-{N} ↔ psp-p2p-merchant-preview-{N} ↔ push-parser-panel
```

### Example Triads

**Triad for N=3**:
- `psp-landing-preview-3`
- `psp-p2p-merchant-preview-3`
- `push-parser-panel` (shared)

**Triad for N=13**:
- `psp-landing-preview-13`
- `psp-p2p-merchant-preview-13`
- `push-parser-panel` (shared)

**Important**: The Push Parser Panel typically uses a single shared instance across all preview environments, though it can be numbered if needed.

## Repository Locations

| Repository | Local Path |
|-----------|------------|
| PSP-Landing | `/home/lkonga/codes/psp-landing` |
| PSP-P2P | `/home/lkonga/codes/psp-p2p` |
| Push Parser Panel | `/home/lkonga/codes/push-parser-panel` |

**Worktrees Location**: `{repository}/worktrees/`

## URL Patterns

### Development/Preview Environments

**PSP-P2P**:
- Pattern: `https://staging.psp-p2p-merchant-preview-{N}.trylatest.in`
- Example: `https://staging.psp-p2p-merchant-preview-13.trylatest.in`

**PSP-Landing**:
- Pattern: `https://staging.psp-landing-preview-{N}.trylatest.in`
- Example: `https://staging.psp-landing-preview-13.trylatest.in`

**Push Parser Panel**:
- Pattern: `https://push-parser-panel.trylatest.in` (no preview number)
- Reason: Hardcoded in Android APK

### Production Environment

**PSP-P2P**: `https://api.psp-p2p.com`
**PSP-Landing**: `https://payment.psp-landing.com`
**Push Parser Panel**: `https://verify.push-parser.com`

## Interconnection Configuration

### PSP-P2P Environment Variables
```env
# Points to corresponding Landing page
LANDING_APP_URL=https://staging.psp-landing-preview-{N}.trylatest.in

# Points to Push Parser for verification callbacks
PUSH_PARSER_API_URL=https://push-parser-panel.trylatest.in
```

### PSP-Landing Environment Variables
```env
# Points to corresponding PSP-P2P API
PSP_BASE_URL=https://staging.psp-p2p-merchant-preview-{N}.trylatest.in
```

### Push Parser Panel Environment Variables
```env
# Points to corresponding PSP-P2P for API calls
PSP_API_URL=https://staging.psp-p2p-merchant-preview-{N}.trylatest.in

# Webhook callback URL for PSP-P2P
VERIFICATION_CALLBACK_BASE_URL=https://staging.psp-p2p-merchant-preview-{N}.trylatest.in
```

## Data Flow

### Payment Initiation
1. Customer accesses **PSP-Landing** UI
2. Landing sends payment request to **PSP-P2P** API
3. PSP-P2P processes payment and sends to payment gateway
4. PSP-P2P sends callback URL to **Push Parser Panel**

### Payment Verification
1. Payment gateway sends webhook to **Push Parser Panel**
2. Push Parser verifies payment details
3. Push Parser sends confirmation to **PSP-P2P**
4. PSP-P2P updates transaction status
5. PSP-Landing displays result to customer

## Workflow Integration

### Creating a New Triad (Preview 14)

**Step 1**: Create PSP-P2P worktree
```bash
cd /home/lkonga/codes/psp-p2p
./scripts/setup-worktree.sh psp-p2p-merchant-preview-14 \
  --setup-laravel \
  --source-worktree-type psp-p2p \
  --source-branch psp-p2p-merchant-preview-13 \
  --psp-landing-worktree psp-landing-preview-14 \
  --ppp-worktree push-parser-panel
```

**Step 2**: Create PSP-Landing worktree
```bash
cd /home/lkonga/codes/psp-landing
./scripts/setup-worktree.sh psp-landing-preview-14 \
  --setup-laravel \
  --source-worktree-type psp-landing \
  --source-branch psp-landing-preview-13 \
  --psp-p2p-worktree psp-p2p-merchant-preview-14 \
  --ppp-worktree push-parser-panel
```

**Step 3**: Configure Push Parser Panel
```bash
cd /home/lkonga/codes/push-parser-panel
# Update .env with preview 14 URLs
# Usually no new worktree needed
```

**Step 4**: Deploy triad to VPS
```bash
# Deploy PSP-P2P
cd /home/lkonga/codes/llm-rules/scripts/vps
./vps-deploy-worktree.sh deploy \
  --subdomain psp-p2p-merchant-preview-14 \
  --repo git@github.com:lkonga/psp-p2p.git \
  --branch psp-p2p-merchant-preview-14 \
  --app-type psp-p2p \
  --landing-url https://staging.psp-landing-preview-14.trylatest.in \
  --psp-url https://staging.psp-p2p-merchant-preview-14.trylatest.in \
  --ppp-url https://staging.push-parser-panel.trylatest.in

# Deploy PSP-Landing
./vps-deploy-worktree.sh deploy \
  --subdomain psp-landing-preview-14 \
  --repo git@github.com:lkonga/psp-p2p-landing.git \
  --branch psp-landing-preview-14 \
  --app-type psp-landing \
  --landing-url https://staging.psp-landing-preview-14.trylatest.in \
  --psp-url https://staging.psp-p2p-merchant-preview-14.trylatest.in \
  --ppp-url https://staging.push-parser-panel.trylatest.in
```

### Verifying Triad Interconnection

**Check PSP-P2P configuration**:
```bash
ssh lkonga@37.60.247.12 "cat /var/www/worktrees/staging.psp-p2p-merchant-preview-14/.env | grep -E 'LANDING_APP_URL|PUSH_PARSER_API_URL'"
```

**Check PSP-Landing configuration**:
```bash
ssh lkonga@37.60.247.12 "cat /var/www/worktrees/staging.psp-landing-preview-14/.env | grep PSP_BASE_URL"
```

**Check Push Parser configuration**:
```bash
ssh lkonga@37.60.247.12 "cat /var/www/worktrees/push-parser-panel/.env | grep -E 'PSP_API_URL|VERIFICATION_CALLBACK_BASE_URL'"
```

**Test end-to-end flow**:
1. Access Landing UI: `https://staging.psp-landing-preview-14.trylatest.in`
2. Initiate test payment
3. Verify API call reaches PSP-P2P
4. Confirm webhook received by Push Parser
5. Check transaction status in all three applications

## Common Patterns

### Preview Environment Naming
- Always use matching numbers across PSP-P2P and PSP-Landing
- Push Parser Panel typically shared (no number)
- Use descriptive branch names that include the preview number

### URL Construction
- VPS deployments: `staging.{worktree-name}.trylatest.in`
- Local tunnels: `{worktree-name}.trylatest.in`
- Production: Custom domains without staging prefix

### Configuration Synchronization
- Update all three `.env` files when creating new triad
- Verify URLs are correctly cross-referenced
- Test API connectivity before running full tests

## Best Practices

**Do's**:
✓ Always use matching numbers for PSP-P2P and PSP-Landing
✓ Configure all environment variables before deployment
✓ Test interconnection after creating new triad
✓ Use version control for environment configurations
✓ Document any deviations from standard patterns

**Don'ts**:
✗ Never create PSP-P2P preview without matching Landing preview
✗ Never hardcode URLs directly in application code
✗ Never skip verification testing after configuration changes
✗ Never mix preview numbers across triad components
✗ Never deploy to production without testing in preview environment

## Troubleshooting

### Issue: API calls failing between components
**Check**:
1. Verify all `.env` URLs are correct and match deployment URLs
2. Check SSL certificates are valid on all domains
3. Verify firewall rules allow inter-service communication
4. Check logs for connection errors

### Issue: Webhook not received by Push Parser
**Check**:
1. Verify `PUSH_PARSER_API_URL` in PSP-P2P `.env`
2. Check Push Parser is accessible from payment gateway
3. Verify webhook endpoint is correctly configured
4. Check Push Parser logs for incoming requests

### Issue: Landing page can't reach PSP-P2P
**Check**:
1. Verify `PSP_BASE_URL` in PSP-Landing `.env`
2. Check PSP-P2P API is running and accessible
3. Verify CORS configuration allows Landing domain
4. Check network connectivity between services

## Related Documentation

**Worktree Orchestration**: See `$WorktreeOrchestration` skill for creating triads
**VPS Deployment**: See `$VPSLaravelDeploy` skill for deploying triads
**Tunnel Management**: See `$CFLauncher` skill for local development tunnels
