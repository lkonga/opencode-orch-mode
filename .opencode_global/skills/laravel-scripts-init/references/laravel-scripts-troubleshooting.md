# Laravel Scripts Initialization Troubleshooting

## Common Issues and Solutions

### Issue: "Permission Denied" Error

**Symptom**: Cannot execute init-scripts command

**Error Message**:
```
bash: ./init-scripts.sh: Permission denied
```

**Diagnosis**:
```bash
# Check script permissions
ls -la .vscode/skills/laravel-scripts-init/scripts/init-scripts.sh

# Check if file is executable
stat .vscode/skills/laravel-scripts-init/scripts/init-scripts.sh | grep Access
```

**Solution**:
```bash
# Make script executable
chmod +x .vscode/skills/laravel-scripts-init/scripts/init-scripts.sh

# Verify fix
ls -la .vscode/skills/laravel-scripts-init/scripts/init-scripts.sh
# Should show: -rwxr-xr-x
```

### Issue: "Scripts Directory Already Exists"

**Symptom**: Script reports existing scripts directory

**What Happens**:
The script automatically handles this by:
1. Detecting if `scripts/` is a directory (not symlink)
2. Backing it up to `scripts.backup.{timestamp}`
3. Creating proper symlink

**No Action Needed**: Script handles this automatically

**Verification**:
```bash
# Check if symlink was created
ls -la scripts/

# Should show symlink: scripts -> /home/lkonga/codes/llm-rules/scripts

# Check backup if it exists
ls -la scripts.backup.*
```

### Issue: "Git Operations Failed"

**Symptom**: Cannot update .gitignore or remove from git index

**Possible Causes**:
1. Directory is not a git repository
2. No write permissions to .gitignore
3. Git not installed

**Diagnosis**:
```bash
# Check if directory is a git repository
cd /path/to/laravel-project
git status

# Check .gitignore permissions
ls -la .gitignore
```

**Solutions**:

**If not a git repository**:
```bash
# Initialize git
git init

# Re-run init-scripts
./init-scripts.sh
```

**If .gitignore doesn't exist**:
```bash
# Script will create it automatically
# Just re-run
./init-scripts.sh
```

**If git not installed**:
```bash
# Install git
sudo apt install git  # Ubuntu/Debian
# or
brew install git      # macOS

# Verify installation
git --version
```

### Issue: "Scripts Not Found After Initialization"

**Symptom**: Cannot access scripts after running init-scripts

**Diagnosis**:
```bash
# Verify symlink was created correctly
ls -la scripts/

# Check symlink target
readlink scripts

# Should point to: /home/lkonga/codes/llm-rules/scripts

# Check if target exists
ls -la /home/lkonga/codes/llm-rules/scripts/
```

**Possible Causes**:
1. Symlink created but target doesn't exist
2. Symlink target path is incorrect
3. Permissions issue on target directory

**Solutions**:

**If target directory doesn't exist**:
```bash
# Check if llm-rules repository exists
ls -la /home/lkonga/codes/llm-rules/

# If not, clone it
cd /home/lkonga/codes/
git clone git@github.com:yzgyzinc/llm-rules.git
# or
git clone https://github.com/yzgyzinc/llm-rules.git

# Re-run init-scripts
cd /path/to/laravel-project
./init-scripts.sh
```

**If wrong target path**:
```bash
# Remove incorrect symlink
rm scripts

# Create correct symlink manually
ln -s /home/lkonga/codes/llm-rules/scripts scripts

# Verify
readlink scripts
```

### Issue: "Command Not Found: init-scripts"

**Symptom**: Cannot find init-scripts command

**Possible Causes**:
1. Script not in PATH
2. Script not installed globally
3. Wrong working directory

**Solutions**:

**Use full path**:
```bash
# Navigate to Laravel project
cd /path/to/laravel-project

# Use relative path
./.vscode/skills/laravel-scripts-init/scripts/init-scripts.sh
```

**Or create alias**:
```bash
# Add to ~/.bashrc or ~/.zshrc
alias init-scripts='/home/lkonga/codes/llm-rules/.vscode/skills/laravel-scripts-init/scripts/init-scripts.sh'

# Reload shell
source ~/.bashrc

# Now you can use
init-scripts
```

### Issue: Symlink Not Tracked by Git

**Symptom**: Git shows symlink as modified or untracked

**What Should Happen**:
Git should ignore the symlink because:
1. `.gitignore` contains `scripts/` and `scripts`
2. Symlink removed from git index by init-scripts

**Verification**:
```bash
# Check if .gitignore is updated
cat .gitignore | grep scripts

# Should contain:
# scripts/
# scripts

# Check git status
git status

# Should not show scripts/ as modified
```

**If Still Showing**:
```bash
# Manually remove from git index
git rm --cached -r scripts/

# Add to .gitignore if not there
echo "scripts/" >> .gitignore
echo "scripts" >> .gitignore

# Commit
git add .gitignore
git commit -m "Ignore scripts symlink"
```

## Verification Steps

### Complete Verification Checklist

```bash
# 1. Check symlink exists
ls -la scripts/
# Expected: scripts -> /home/lkonga/codes/llm-rules/scripts

# 2. Verify symlink target
readlink scripts
# Expected: /home/lkonga/codes/llm-rules/scripts

# 3. Check scripts are accessible
ls scripts/
# Should list all deployment scripts

# 4. Test a script
./scripts/setup-worktree.sh --help
# Should show help text

# 5. Verify .gitignore
cat .gitignore | grep scripts
# Should show: scripts/ and scripts

# 6. Check git status
git status
# Should not show scripts/ as modified

# 7. Test execution
./scripts/cf-launcher.sh status
# Should execute without errors
```

### Automated Verification Script

```bash
#!/bin/bash
# verify-scripts-init.sh

echo "Verifying Laravel Scripts Initialization..."

# Check 1: Symlink exists
if [ -L "scripts" ]; then
    echo "✓ Symlink exists"
else
    echo "✗ Symlink missing"
    exit 1
fi

# Check 2: Symlink target
TARGET=$(readlink scripts)
if [ "$TARGET" = "/home/lkonga/codes/llm-rules/scripts" ]; then
    echo "✓ Symlink target correct"
else
    echo "✗ Symlink target incorrect: $TARGET"
    exit 1
fi

# Check 3: Target directory exists
if [ -d "$TARGET" ]; then
    echo "✓ Target directory exists"
else
    echo "✗ Target directory missing"
    exit 1
fi

# Check 4: Scripts accessible
if [ -x "scripts/setup-worktree.sh" ]; then
    echo "✓ Scripts are executable"
else
    echo "✗ Scripts not executable"
    exit 1
fi

# Check 5: .gitignore updated
if grep -q "^scripts/$" .gitignore && grep -q "^scripts$" .gitignore; then
    echo "✓ .gitignore updated"
else
    echo "✗ .gitignore missing entries"
    exit 1
fi

# Check 6: Not tracked by git
if git ls-files | grep -q "^scripts/"; then
    echo "✗ Scripts still tracked by git"
    exit 1
else
    echo "✓ Scripts not tracked by git"
fi

echo ""
echo "All checks passed! Scripts initialization successful."
```

## Common Workflows

### Workflow 1: New Machine Setup

```bash
# 1. Clone llm-rules repository
cd /home/lkonga/codes/
git clone git@github.com:yzgyzinc/llm-rules.git

# 2. Clone Laravel projects
git clone git@github.com:user/psp-p2p.git
git clone git@github.com:user/psp-landing.git
git clone git@github.com:user/push-parser-panel.git

# 3. Initialize scripts for each project
cd psp-p2p && /home/lkonga/codes/llm-rules/.vscode/skills/laravel-scripts-init/scripts/init-scripts.sh
cd ../psp-landing && /home/lkonga/codes/llm-rules/.vscode/skills/laravel-scripts-init/scripts/init-scripts.sh
cd ../push-parser-panel && /home/lkonga/codes/llm-rules/.vscode/skills/laravel-scripts-init/scripts/init-scripts.sh

# 4. Verify all projects
for dir in psp-p2p psp-landing push-parser-panel; do
    echo "=== $dir ==="
    cd /home/lkonga/codes/$dir
    ls -la scripts/
    echo ""
done
```

### Workflow 2: Project Recovery

```bash
# After git clone or when scripts are missing
cd /path/to/laravel-project

# Run init-scripts
/home/lkonga/codes/llm-rules/.vscode/skills/laravel-scripts-init/scripts/init-scripts.sh

# Verify scripts are accessible
./scripts/setup-worktree.sh --help
./scripts/cf-launcher.sh status
./scripts/deploy-worktree.sh --help
```

### Workflow 3: CI/CD Pipeline Setup

```yaml
# .github/workflows/deploy.yml
name: Deploy

on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Initialize Scripts
        run: |
          # Check if scripts symlink exists
          if [ ! -L "scripts" ]; then
            # Clone llm-rules repository
            git clone https://github.com/yzgyzinc/llm-rules.git /tmp/llm-rules

            # Create symlink
            ln -s /tmp/llm-rules/scripts scripts

            # Update .gitignore
            echo "scripts/" >> .gitignore
            echo "scripts" >> .gitignore
          fi

      - name: Verify Scripts
        run: |
          ls -la scripts/
          ./scripts/setup-worktree.sh --help
```

### Workflow 4: Team Collaboration

**Setup Documentation**:
```markdown
# Project Setup

## Prerequisites
1. Git installed
2. Access to llm-rules repository
3. SSH keys configured

## Steps

1. Clone repositories:
   ```bash
   git clone git@github.com:yzgyzinc/llm-rules.git
   git clone git@github.com:user/psp-p2p.git
   ```

2. Initialize scripts:
   ```bash
   cd psp-p2p
   /path/to/llm-rules/.vscode/skills/laravel-scripts-init/scripts/init-scripts.sh
   ```

3. Verify:
   ```bash
   ./scripts/setup-worktree.sh --help
   ```

## Troubleshooting

If scripts not found:
- Check symlink: `ls -la scripts/`
- Re-run: `init-scripts`
- Contact team lead if issues persist
```

## Best Practices

**Do's**:
✓ Run init-scripts immediately after cloning Laravel project
✓ Include in project setup documentation
✓ Verify scripts are accessible before deployment
✓ Keep central scripts repository (llm-rules) up to date
✓ Document any custom script modifications

**Don'ts**:
✗ Never commit scripts symlink to version control
✗ Never modify scripts directly in Laravel project
✗ Never use absolute paths in scripts (use relative paths)
✗ Never skip verification after initialization
✗ Never assume scripts are initialized on new machines

## Maintenance

### Updating Central Scripts

```bash
# Pull latest scripts
cd /home/lkonga/codes/llm-rules
git pull origin develop

# No action needed in Laravel projects
# Symlinks automatically point to updated scripts
```

### Adding New Scripts

```bash
# Add new script to central repository
cd /home/lkonga/codes/llm-rules/scripts
nano new-script.sh
chmod +x new-script.sh
git add new-script.sh
git commit -m "Add new deployment script"
git push

# Available immediately in all Laravel projects via symlink
```

### Removing Scripts Symlink

If you need to remove the symlink (not recommended):

```bash
# Remove symlink
rm scripts

# Remove from .gitignore
sed -i '/^scripts\/$/d' .gitignore
sed -i '/^scripts$/d' .gitignore

# Commit changes
git add .gitignore
git commit -m "Remove scripts symlink"
```

## Integration with Other Skills

### With $WorktreeOrchestration

Scripts must be initialized before creating worktrees:

```bash
# 1. Initialize scripts
init-scripts

# 2. Create worktree
./scripts/setup-worktree.sh psp-p2p-merchant-preview-3 \
  --setup-laravel \
  --source-worktree-type psp-p2p
```

### With $VPSLaravelDeploy

Scripts must be initialized before VPS deployment:

```bash
# 1. Initialize scripts
init-scripts

# 2. Deploy to VPS
cd /home/lkonga/codes/llm-rules/scripts/vps
./vps-deploy-worktree.sh deploy \
  --subdomain psp-p2p-merchant-preview-13 \
  --repo git@github.com:lkonga/psp-p2p.git \
  --branch psp-p2p-merchant-preview-13 \
  --app-type psp-p2p \
  --landing-url https://staging.psp-landing-preview-13.trylatest.in \
  --psp-url https://staging.psp-p2p-merchant-preview-13.trylatest.in \
  --ppp-url https://staging.push-parser-panel.trylatest.in
```

### With $CFLauncher

Tunnel management requires scripts:

```bash
# 1. Initialize scripts
init-scripts

# 2. Manage tunnels
./scripts/cf-launcher.sh --config worktree-name
```

## Success Indicators

✓ Symlink `scripts -> /home/lkonga/codes/llm-rules/scripts` exists
✓ All scripts executable and accessible
✓ .gitignore contains scripts/ and scripts entries
✓ Git does not track scripts directory
✓ Can execute `./scripts/setup-worktree.sh --help` without errors
✓ Can create worktrees using scripts
✓ Can deploy using scripts
✓ Can manage tunnels using scripts
