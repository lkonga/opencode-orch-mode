---
name: 'Laravel Scripts Initialization'
description: 'Initialize Laravel projects with centralized DevOps scripts symlink for triad architecture setup and deployment automation'
trigger: ['$LaravelScriptsInit', '$initScripts', 'init-scripts', 'laravel scripts setup', 'setup laravel scripts', 'scripts symlink']
related_skills: ['$VPSLaravelDeploy', '$WorktreeOrchestration', '$CFLauncher']
references: {'Troubleshooting': 'references/laravel-scripts-troubleshooting.md', 'Init scripts': 'scripts/init-scripts.sh', 'Triad architecture': 'references/triad-architecture.md', 'Scripts documentation': 'scripts/README.md'}
---

# Laravel Scripts Initialization Skill

## Purpose
Initialize Laravel projects with a symlink to the centralized scripts directory, providing access to specialized deployment, worktree management, and tunnel automation tools essential for the Laravel triad architecture.

## Core Principle
**Centralized DevOps for Laravel**: Provide all Laravel projects in the triad (psp-p2p, psp-landing, push-parser-panel) with consistent access to shared deployment and management scripts without duplicating code.

## When to Use This Skill

1. Setting up a new Laravel project in the triad architecture
2. After cloning a Laravel project that lacks the scripts symlink
3. When deployment scripts are not found in a Laravel project
4. User explicitly mentions `$LaravelScriptsInit` or "init-scripts"

## Core Operations

### Initialize Current Directory
```bash
# Initialize scripts symlink in current Laravel project
init-scripts
```

### Initialize Specific Project
```bash
# Initialize scripts symlink for specific Laravel project
init-scripts --project /path/to/laravel-project

# Example for psp-p2p
init-scripts --project /path/to/psp-p2p
```

### Batch Initialization for Triad
```bash
# Initialize all triad projects
./scripts/init-scripts.sh --project /path/to/psp-p2p
./scripts/init-scripts.sh --project /path/to/psp-landing
./scripts/init-scripts.sh --project /path/to/push-parser-panel
```

## What the Script Does

1. **Creates Symlink**: Creates a `scripts` symlink in the Laravel project root pointing to `/home/lkonga/codes/llm-rules/scripts/`
2. **Updates .gitignore**: Adds entries to `.gitignore` to prevent symlink from being committed
3. **Git Cleanup**: Removes previously tracked scripts directory from git index

## Available Scripts After Initialization

<reference title="Scripts documentation" path="scripts/README.md" />

### Laravel Setup Scripts
- `setup-worktree.sh` - Create Laravel worktrees with database isolation
- `deploy-worktree.sh` - Deploy worktrees to VPS with SSL
- `laravel_env.sh` - Laravel environment management

### VPS Deployment
- `setup-vps-server.sh` - VPS initialization
- `deploy-to-vps.sh` - Application deployment
- `setup-ssl.sh` - SSL certificate management

### Tunnel Management
- `cf-launcher.sh` - Cloudflare tunnel management
- `deploy-tunnel.sh` - Tunnel deployment

## Common Workflows

### New Machine Setup
```bash
# Clone and initialize Laravel projects
git clone git@github.com:user/psp-p2p.git
cd psp-p2p && init-scripts
```

### Project Recovery
```bash
# After git clone when scripts are missing
cd /path/to/laravel-project
init-scripts
```

## Success Criteria

✓ Scripts symlink created in Laravel project root
✓ Symlink points to central scripts directory
✓ .gitignore updated to exclude symlink
✓ All deployment and management scripts accessible

## Integration with Other Skills

- **$VPSLaravelDeploy**: Requires scripts initialization before VPS deployment
- **$WorktreeOrchestration**: Depends on scripts for worktree operations
- **$CFLauncher**: Tunnel management accessible through scripts

## Progressive Disclosure

**References** (load only when needed):
<references>
  <reference title="Troubleshooting" path="references/laravel-scripts-troubleshooting.md" description="Common initialization issues, symlink problems, solutions" />
  <reference title="Init scripts" path="scripts/init-scripts.sh" description="Main initialization script implementation" />
  <reference title="Triad architecture" path="references/triad-architecture.md" description="Laravel triad structure, project relationships, architecture" />
  <reference title="Scripts documentation" path="scripts/README.md" description="Complete scripts reference, available tools, usage" />
</references>
