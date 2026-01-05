# Worktree Commands Cheatsheet

<!-- Purpose: Quick reference for common Git worktree commands and operations -->
<!-- Related: worktree-orchestration skill -->

## Overview

This cheatsheet provides quick reference for all Git worktree commands, from basic operations to advanced troubleshooting.

## Basic Worktree Operations

### Create Worktree

```bash
# Create worktree from existing branch
git worktree add path/to/worktree branch-name

# Create worktree with new branch
git worktree add path/to/worktree -b new-branch

# Create worktree from specific commit
git worktree add path/to/worktree commit-hash

# Create worktree in organized structure
git worktree add worktrees/feature-name -b feature/new-feature
```

**Example:**
```bash
# Create preview worktree
git worktree add worktrees/psp-p2p-merchant-preview-3 -b preview/merchant-3

# Create from existing branch
git worktree add worktrees/psp-p2p-hotfix hotfix/critical-bug
```

### List Worktrees

```bash
# List all worktrees
git worktree list

# List with more details
git worktree list --porcelain

# Show only paths
git worktree list | awk '{print $1}'
```

**Output example:**
```
/home/lkonga/codes/psp-p2p                    abc1234 [main]
/home/lkonga/codes/psp-p2p/worktrees/preview-2  def5678 [preview/2]
/home/lkonga/codes/psp-p2p/worktrees/preview-3  ghi9012 [preview/3]
```

### Switch Between Worktrees

```bash
# Navigate to worktree (simple)
cd worktrees/psp-p2p-merchant-preview-3

# Using absolute path
cd /home/lkonga/codes/psp-p2p/worktrees/psp-p2p-merchant-preview-3

# Quick switch with alias (add to ~/.bashrc)
alias wtcd='cd /home/lkonga/codes/psp-p2p/worktrees'
wtcd/psp-p2p-merchant-preview-3
```

### Remove Worktree

```bash
# Remove worktree (safe - fails if there are uncommitted changes)
git worktree remove path/to/worktree

# Force remove (ignores uncommitted changes)
git worktree remove --force path/to/worktree

# Remove and delete branch
git worktree remove path/to/worktree
git branch -D branch-name
```

**Example:**
```bash
# Safe removal
git worktree remove worktrees/psp-p2p-merchant-preview-3

# Force removal with cleanup
git worktree remove --force worktrees/psp-p2p-merchant-preview-3
git branch -D preview/merchant-3
```

### Move Worktree

```bash
# Move worktree to new location
git worktree move old-path new-path

# Example
git worktree move worktrees/preview-2 worktrees/psp-p2p-merchant-preview-2
```

### Prune Worktrees

```bash
# Remove stale worktree administrative files
git worktree prune

# Dry run - show what would be pruned
git worktree prune --dry-run

# Verbose output
git worktree prune --verbose
```

---

## Branch Operations in Worktrees

### Create Branch in Worktree

```bash
# Create and switch to new branch
cd worktrees/psp-p2p-merchant-preview-3
git checkout -b feature/new-feature

# Create branch from specific commit
git checkout -b hotfix/bug-fix abc1234
```

### Switch Branches in Worktree

```bash
# Switch to existing branch
git checkout branch-name

# Create and switch
git checkout -b new-branch

# Switch to previous branch
git checkout -
```

### Update Worktree from Main

```bash
# Pull latest changes
git pull origin main

# Rebase on main
git fetch origin
git rebase origin/main

# Merge main into current branch
git merge origin/main
```

---

## Status and Information Commands

### Check Worktree Status

```bash
# Show worktree status
git status

# Show short status
git status -s

# Show status with branch info
git status -sb
```

### Show Worktree Information

```bash
# Show all worktrees with details
git worktree list

# Show current worktree info
git rev-parse --show-toplevel
git branch --show-current

# Show worktree configuration
git config --get-regexp worktree
```

### Check for Locked Worktrees

```bash
# List locked worktrees
git worktree list | grep locked

# Check specific worktree
git worktree list --porcelain | grep -A 5 "worktree $(pwd)"
```

---

## Advanced Operations

### Lock/Unlock Worktree

```bash
# Lock worktree (prevents removal)
git worktree lock path/to/worktree

# Lock with reason
git worktree lock path/to/worktree --reason "In active development"

# Unlock worktree
git worktree unlock path/to/worktree
```

**Use case:**
```bash
# Lock production worktree
git worktree lock worktrees/production --reason "Production environment"

# List locked worktrees
git worktree list --porcelain | grep -B 1 "locked"
```

### Repair Worktree

```bash
# Repair corrupted worktree links
git worktree repair

# Repair specific worktree
git worktree repair path/to/worktree
```

### Share Worktree Configuration

```bash
# Show worktree configuration
git config --list | grep worktree

# Set worktree-specific configuration
git config worktree.guessRemote true

# Disable worktree config inheritance
git config worktree.inheritFrom none
```

---

## Maintenance Commands

### Clean Stale References

```bash
# Remove stale worktree references
git worktree prune

# Also clean up branches
git fetch --prune origin
git branch --merged | grep -v "main\|master" | xargs git branch -d
```

### Verify Worktree Integrity

```bash
# Check for issues
git fsck

# Verify worktree links
for worktree in worktrees/*; do
    if [ -d "$worktree" ]; then
        cd "$worktree"
        echo "Checking: $worktree"
        git status > /dev/null 2>&1 && echo "  ✅ OK" || echo "  ❌ ERROR"
        cd - > /dev/null
    fi
done
```

### Cleanup Script

```bash
#!/bin/bash
# scripts/cleanup-worktrees.sh

echo "=== Worktree Cleanup ==="

# Prune stale references
echo "Pruning stale worktree references..."
git worktree prune --verbose

# Find and list orphaned worktree directories
echo ""
echo "Checking for orphaned worktree directories..."
git worktree list | awk '{print $1}' > /tmp/active-worktrees.txt

for dir in worktrees/*; do
    if [ -d "$dir" ]; then
        if ! grep -q "$dir" /tmp/active-worktrees.txt; then
            echo "  ⚠️  Orphaned: $dir"
            read -p "Remove? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm -rf "$dir"
                echo "  ✅ Removed: $dir"
            fi
        fi
    fi
done

rm /tmp/active-worktrees.txt

echo ""
echo "Cleanup complete!"
```

---

## Troubleshooting Commands

### Worktree Not Recognized

```bash
# Check Git configuration
git config --list | grep worktree

# Verify worktree exists
git worktree list

# Repair if needed
git worktree repair

# Force re-add
git worktree add --force path/to/worktree branch-name
```

### Cannot Remove Worktree

```bash
# Check for locks
git worktree list --porcelain | grep -A 5 "locked"

# Unlock if needed
git worktree unlock path/to/worktree

# Force remove
git worktree remove --force path/to/worktree

# Manual cleanup
rm -rf path/to/worktree
git worktree prune
```

### Branch Already Checked Out

```bash
# Error: 'branch-name' is already checked out at 'path/to/worktree'

# Option 1: Use different branch
git worktree add new-path -b new-branch-name

# Option 2: Remove existing worktree first
git worktree remove path/to/existing-worktree
git worktree add new-path existing-branch

# Option 3: Use --force (use with caution)
git worktree add --force new-path existing-branch
```

### Worktree Path Conflicts

```bash
# Error: 'path' already exists

# Check if it's a valid worktree
git worktree list | grep path

# If not listed, remove manually
rm -rf path
git worktree prune

# Then recreate
git worktree add path branch-name
```

---

## Workflow Patterns

### Feature Development Workflow

```bash
# 1. Create feature worktree
git worktree add worktrees/feature-xyz -b feature/xyz

# 2. Work on feature
cd worktrees/feature-xyz
# ... make changes ...
git add .
git commit -m "feat: implement xyz"

# 3. Push and create PR
git push origin feature/xyz

# 4. After merge, cleanup
cd ../../
git worktree remove worktrees/feature-xyz
git branch -D feature/xyz
```

### Preview/Staging Workflow

```bash
# 1. Create preview worktree
git worktree add worktrees/psp-p2p-merchant-preview-3 -b preview/merchant-3

# 2. Deploy preview
cd worktrees/psp-p2p-merchant-preview-3
./scripts/deploy.sh

# 3. Update preview
git pull origin main
./scripts/deploy.sh

# 4. Cleanup when done
cd ../../
git worktree remove worktrees/psp-p2p-merchant-preview-3
```

### Hotfix Workflow

```bash
# 1. Create hotfix worktree from production
git worktree add worktrees/hotfix-critical -b hotfix/critical-bug main

# 2. Fix and test
cd worktrees/hotfix-critical
# ... fix bug ...
git add .
git commit -m "fix: critical bug"

# 3. Deploy immediately
git push origin hotfix/critical-bug
# ... deploy to production ...

# 4. Merge back to main
git checkout main
git merge hotfix/critical-bug
git push origin main

# 5. Cleanup
git worktree remove worktrees/hotfix-critical
git branch -D hotfix/critical-bug
```

---

## Integration with Other Tools

### VS Code Workspace

```json
{
  "folders": [
    {
      "name": "Main",
      "path": "."
    },
    {
      "name": "Preview 2",
      "path": "worktrees/psp-p2p-merchant-preview-2"
    },
    {
      "name": "Preview 3",
      "path": "worktrees/psp-p2p-merchant-preview-3"
    }
  ]
}
```

### Tmux Session Management

```bash
# Create tmux session per worktree
tmux new-session -d -s main -c "/home/lkonga/codes/psp-p2p"
tmux new-session -d -s preview-2 -c "/home/lkonga/codes/psp-p2p/worktrees/psp-p2p-merchant-preview-2"
tmux new-session -d -s preview-3 -c "/home/lkonga/codes/psp-p2p/worktrees/psp-p2p-merchant-preview-3"

# Switch between sessions
tmux attach -t preview-2
```

### Shell Aliases

```bash
# Add to ~/.bashrc or ~/.zshrc

# Quick navigation
alias cdm='cd /home/lkonga/codes/psp-p2p'
alias cdp2='cd /home/lkonga/codes/psp-p2p/worktrees/psp-p2p-merchant-preview-2'
alias cdp3='cd /home/lkonga/codes/psp-p2p/worktrees/psp-p2p-merchant-preview-3'

# Worktree operations
alias wtls='git worktree list'
alias wtprune='git worktree prune --verbose'
alias wtclean='git worktree prune && git fetch --prune origin'

# Status check all worktrees
alias wtstat='for wt in worktrees/*; do echo "=== $wt ==="; cd $wt; git status -sb; cd -; done'
```

---

## Performance Tips

### Sparse Checkout for Large Repos

```bash
# Enable sparse checkout
git sparse-checkout init --cone

# Add only needed paths
git sparse-checkout set src/ config/ public/

# Add worktree with sparse checkout
git worktree add --no-checkout worktrees/preview-sparse preview/branch
cd worktrees/preview-sparse
git sparse-checkout init --cone
git sparse-checkout set src/ config/
```

### Shallow Worktrees

```bash
# Create worktree with shallow history (not recommended for development)
git worktree add --detach worktrees/shallow-preview
cd worktrees/shallow-preview
git checkout --orphan preview-branch
```

### Disk Space Management

```bash
# Check worktree sizes
du -sh worktrees/*

# Share object database (automatic by default)
git config worktree.shareObjectPool true

# Compress Git objects
git gc --aggressive --prune=now
```

---

## Automation Scripts

### Create Preview Worktree Script

```bash
#!/bin/bash
# scripts/create-preview-worktree.sh

set -e

PREVIEW_NUMBER=$1

if [ -z "$PREVIEW_NUMBER" ]; then
    echo "Usage: $0 <preview-number>"
    exit 1
fi

WORKTREE_NAME="psp-p2p-merchant-preview-$PREVIEW_NUMBER"
BRANCH_NAME="preview/merchant-$PREVIEW_NUMBER"

echo "Creating preview worktree: $WORKTREE_NAME"

# Create worktree
git worktree add "worktrees/$WORKTREE_NAME" -b "$BRANCH_NAME"

# Setup environment
cd "worktrees/$WORKTREE_NAME"
cp .env.example .env
sed -i "s/preview-X/preview-$PREVIEW_NUMBER/g" .env
php artisan key:generate

# Install dependencies
composer install
npm install

echo "✅ Preview worktree created: $WORKTREE_NAME"
```

### List All Worktrees Script

```bash
#!/bin/bash
# scripts/list-worktrees.sh

echo "=== Active Worktrees ==="
git worktree list --porcelain | while read line; do
    if [[ $line == worktree* ]]; then
        path=${line#worktree }
        echo ""
        echo "Path: $path"
    elif [[ $line == HEAD* ]]; then
        commit=${line#HEAD }
        echo "  Commit: ${commit:0:7}"
    elif [[ $line == branch* ]]; then
        branch=${line#branch }
        echo "  Branch: ${branch#refs/heads/}"
    fi
done
```

---

## Quick Reference

### Most Common Commands

```bash
# Create worktree
git worktree add worktrees/name -b branch

# List worktrees
git worktree list

# Remove worktree
git worktree remove worktrees/name

# Prune stale references
git worktree prune

# Repair worktrees
git worktree repair
```

### Emergency Commands

```bash
# Force remove stuck worktree
git worktree remove --force worktrees/name
rm -rf worktrees/name
git worktree prune

# Fix corrupted worktree
git worktree repair
git fsck

# Recover from bad state
git worktree prune
git reflog expire --expire=now --all
git gc --prune=now
```

---

## Related Skills

- `worktree-configuration` - Environment and configuration setup
- `worktree-cleanup` - Cleanup and maintenance procedures
- `vps-laravel-deployment` - Deployment patterns for worktrees

## References

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- [Git SCM Book - Worktrees](https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging#_git_worktrees)
- [Atlassian Git Worktree Tutorial](https://www.atlassian.com/git/tutorials/git-worktree)
