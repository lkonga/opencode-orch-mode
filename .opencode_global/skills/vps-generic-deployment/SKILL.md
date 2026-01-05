---
name: VPS Generic Deployment
description: Framework-agnostic deployment for static sites, blogs, and non-Laravel applications with Nginx or Apache
triggers: ['$VPSGenericDeploy', '$DeployStaticVPS']
trigger_keywords: ['deploy static site', 'vps blog deployment', 'generic vps deployment', 'deploy to vps']
related_skills: ['$VPSLaravelDeploy', '$TmuxProtectedExecution', '$VPSSudoPassword']
references: {'VPS infrastructure': 'references/vps-infrastructure.md', 'Advanced workflows': 'references/vps-generic-advanced-workflows.md', 'Troubleshooting': 'references/vps-generic-troubleshooting.md', 'Deployment strategies': 'references/vps-generic-strategies.md', 'Application patterns': 'references/vps-generic-applications.md'}
---

# VPS Generic Deployment Skill

## Purpose
Deploy non-Laravel applications to VPS or local environments using Git-based workflows. Supports static sites, blogs, Node.js apps, and other frameworks with flexible server and SSL choices.

## Core Principle
**Framework-agnostic Git-based deployment** with flexible infrastructure choices.

## When to Use This Skill

1. User requests deploying static site or non-Laravel application
2. Task involves blog deployment (WordPress, static generators)
3. Deploying Node.js, Python, or other framework applications

## Server Selection Guide

- **Deploying to VPS?** → You'll use **Nginx** (automatic)
- **Deploying locally?** → You'll use **Apache** (automatic)

## Deployment Strategies

<reference title="Deployment strategies" path="references/vps-generic-strategies.md" />
<reference title="Application patterns" path="references/vps-generic-applications.md" />

### Strategy 1: Nginx + Let's Encrypt (VPS)
**Best For**: Production static sites, SPAs, APIs on VPS
**SSL**: Let's Encrypt (trusted CA)
**Script**: `vps-asas/deploy-vps.sh`

```bash
cd /home/lkonga/codes/llm-rules/vps-asas
./deploy-vps.sh [worktree-name] [options]
```

**Advantages**:
✓ Production-grade SSL certificates
✓ Automatic HTTPS redirection
✓ Certificate auto-renewal
✓ High performance for static content

### Strategy 2: Apache + Cloudflare Tunnel (Local)
**Best For**: Local development, preview environments, testing
**SSL**: Self-signed (for Apache) + Cloudflare tunnel
**Script**: `vps-asas/deploy-local.sh`

```bash
cd /path/to/your/project
sudo /home/lkonga/codes/llm-rules/vps-asas/deploy-local.sh [worktree-name]

# Start tunnel
/home/lkonga/codes/llm-rules/scripts/cf-launcher.sh --config {name}
```

**Advantages**:
✓ No DNS propagation wait
✓ Instant HTTPS access
✓ Local testing with production-like URLs
✓ No VPS resource usage

## VPS Infrastructure

- **VPS IP**: 37.60.247.12
- **SSH User**: lkonga
- **Domain**: trylatest.in (Cloudflare managed)
- **Software Stack**: Ubuntu 24.04.3 LTS, Nginx 1.24.0, Apache 2.4.x, Node.js 16+

## Command Reference

### VPS Deployment Commands
```bash
# Basic deployment
./deploy-vps.sh [worktree-name]

# Quick update (skip DNS/SSL reconfiguration)
./deploy-vps.sh [worktree-name] --quick

# Force reinstall
./deploy-vps.sh [worktree-name] --force
```

### Local Deployment Commands
```bash
# Deploy with Apache + Cloudflare tunnel
sudo ./deploy-local.sh [worktree-name]

# Quick update
sudo ./deploy-local.sh [worktree-name] --quick
```

### Cloudflare Tunnel Management
```bash
# Start tunnel
./scripts/cf-launcher.sh --config {name}

# Stop tunnel
./scripts/cf-launcher.sh --kill-config {name}

# Check status
./scripts/cf-launcher.sh status
```

## Workflow Examples

### Deploy Static Site to VPS
```bash
cd /home/lkonga/codes/llm-rules/vps-asas
./deploy-vps.sh my-static-site

# Access at: https://my-static-site.trylatest.in
```

### Deploy to Local with Tunnel
```bash
cd /path/to/project
sudo /home/lkonga/codes/llm-rules/vps-asas/deploy-local.sh my-blog

# Start tunnel
/home/lkonga/codes/llm-rules/scripts/cf-launcher.sh --config my-blog

# Access at: https://my-blog.trylatest.in
```

## Success Criteria

✓ Application accessible at HTTPS URL
✓ SSL certificate valid (Let's Encrypt or Cloudflare)
✓ Build process completes without errors
✓ All static assets loading correctly

## Integration with Other Skills

- **$VPSSudoPassword**: Required for VPS sudo operations
- **$TmuxProtectedExecution**: For long-running deployments
- **$CFLauncher**: For tunnel management in local deployments

## Progressive Disclosure

**References** (load only when needed):
<references>
  <reference title="VPS infrastructure" path="references/vps-infrastructure.md" description="VPS details, SSH access, domain configuration, software stack" />
  <reference title="Advanced workflows" path="references/vps-generic-advanced-workflows.md" description="Complex deployment patterns, multi-site setups, custom configurations" />
  <reference title="Troubleshooting" path="references/vps-generic-troubleshooting.md" description="Common deployment issues, SSL problems, permission errors, fixes" />
</references>
