# Laravel Scripts Initialization

This directory contains the `init-scripts.sh` script used to initialize Laravel projects with centralized DevOps scripts.

## Purpose

The `init-scripts.sh` script creates a symlink from a Laravel project root to the central scripts directory (`/home/lkonga/codes/llm-rules/scripts/`), providing access to specialized deployment, worktree management, and tunnel automation tools.

## Usage

```bash
# Initialize scripts in current directory
init-scripts

# Initialize scripts for specific project
init-scripts --project /path/to/laravel-project

# Show help
init-scripts --help
```

## What It Does

1. Creates a `scripts` symlink pointing to the central scripts directory
2. Adds `scripts/` and `scripts` to `.gitignore`
3. Removes any previously tracked scripts directory from git
4. Commits the .gitignore changes

## Backward Compatibility

The original `scripts-symlink.sh` in the root directory remains as a symlink to this script for backward compatibility.

## Integration

This script is automatically used by:
- Laravel Scripts Initialization skill (`$LaravelScriptsInit`)
- VPS Laravel Deployment skill (`$VPSLaravelDeploy`)
- Worktree Orchestration skill (`$WorktreeOrchestration`)

## Requirements

- Target directory must be a Laravel project
- Git repository must be initialized
- Write permissions to the project directory
- Access to central scripts directory
