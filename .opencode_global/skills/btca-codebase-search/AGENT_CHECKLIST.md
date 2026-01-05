# BTCA Agent Quick Reference

## Pre-Flight Check (MANDATORY)

**Before using btca, ALWAYS run this check**:

```bash
# Check if binaries are available
if ! command -v btca &> /dev/null; then
    echo "❌ ERROR: btca binary not found in PATH"
    echo ""
    echo "🔧 USER ACTION REQUIRED:"
    echo ""
    echo "Option 1 - Quick fix (current session only):"
    echo "  export PATH=\"\$HOME/.bun/bin:\$PATH\""
    echo ""
    echo "Option 2 - Permanent fix (recommended):"
    echo "  source ~/.bashrc    # For bash users"
    echo "  source ~/.zshrc     # For zsh users"
    echo "  # OR restart your terminal"
    echo ""
    echo "Option 3 - Reinstall if above don't work:"
    echo "  curl -fsSL https://bun.sh/install | bash"
    echo "  export PATH=\"\$HOME/.bun/bin:\$PATH\""
    echo "  bun add -g btca opencode-ai --force"
    echo ""
    exit 1
fi

# If we get here, btca is available
echo "✅ btca is available: $(btca --version)"
```

## Error Messages to Return to User

### If bun is missing:
```
❌ ERROR: bun package manager not found

🔧 To fix:
1. Install bun: curl -fsSL https://bun.sh/install | bash
2. Add to PATH: export PATH="$HOME/.bun/bin:$PATH"
3. Source config: source ~/.bashrc (or ~/.zshrc)
4. Verify: bun --version
```

### If btca is missing:
```
❌ ERROR: btca CLI not found in PATH

🔧 To fix:
1. Add to PATH: export PATH="$HOME/.bun/bin:$PATH"
2. Source config: source ~/.bashrc (or ~/.zshrc)
3. If still missing, reinstall: bun add -g btca opencode-ai --force
4. Verify: btca --version
```

### If both are missing:
```
❌ ERROR: Neither bun nor btca found in PATH

🔧 Complete fix:
1. Install bun: curl -fsSL https://bun.sh/install | bash
2. Add to PATH: export PATH="$HOME/.bun/bin:$PATH"
3. Source config: source ~/.bashrc (or ~/.zshrc)
4. Install btca: bun add -g btca opencode-ai
5. Verify: btca --version
```

## Verification Commands

After user reports fixing the issue:

```bash
# Check bun
command -v bun && echo "✅ bun: $(bun --version)" || echo "❌ bun still missing"

# Check btca
command -v btca && echo "✅ btca: $(btca --version)" || echo "❌ btca still missing"

# Full diagnostic
echo "PATH: $PATH"
echo "Bun location: $(command -v bun)"
echo "btca location: $(command -v btca)"
ls -la ~/.bun/bin/ | grep -E "bun|btca"
```

## Common Scenarios

### Scenario 1: Fresh Terminal Session
**Symptom**: `command not found: btca`
**Cause**: PATH not set for new session
**Fix**: `source ~/.bashrc` or `source ~/.zshrc` OR restart terminal

### Scenario 2: Installation Just Completed
**Symptom**: Binaries not found immediately after install
**Cause**: PATH not updated in current session
**Fix**: `export PATH="$HOME/.bun/bin:$PATH"`

### Scenario 3: System Restart
**Symptom**: Binaries not found after restart
**Cause**: Shell config not sourced
**Fix**: Restart terminal OR source shell config

### Scenario 4: Different Shell
**Symptom**: Works in one terminal but not another
**Cause**: Different shell (bash vs zsh)
**Fix**: Source appropriate config file

## Quick Fix Template

```bash
# One-liner to fix most issues
export PATH="$HOME/.bun/bin:$PATH" && \
command -v btca && echo "✅ btca ready" || \
(echo "❌ Still broken - reinstalling" && \
curl -fsSL https://bun.sh/install | bash && \
export PATH="$HOME/.bun/bin:$PATH" && \
bun add -g btca opencode-ai --force)
```

## Agent Workflow

1. **Check binary availability** (MANDATORY)
2. **If missing → return error with fix instructions** (STOP)
3. **If present → verify versions**
4. **Proceed with btca commands**
5. **Handle btca-specific errors normally**

## Key Points

- ✅ **ALWAYS check before using btca**
- ❌ **NEVER proceed if binaries missing**
- 🔧 **Provide clear, actionable error messages**
- ✅ **Verify fix after user applies it**
- 📝 **Include exact commands to run**

## Example Agent Response

### Bad Response (don't do this):
```
I'll use btca to search the codebase...
[proceeds to run btca commands without checking]
```

### Good Response (do this):
```
Checking btca availability...

❌ ERROR: btca binary not found in PATH

🔧 To fix this issue, please run one of these options:

Option 1 - Quick fix (current session):
  export PATH="$HOME/.bun/bin:$PATH"

Option 2 - Permanent fix:
  source ~/.bashrc    # For bash users
  source ~/.zshrc     # For zsh users
  # OR restart your terminal

Option 3 - Reinstall if needed:
  bun add -g btca opencode-ai --force

After fixing, please let me know and I'll continue with the btca search.
```

## Summary

**Pre-flight check is MANDATORY** - always verify binary availability before using btca. If missing, provide clear error messages with exact fix commands. Never proceed without verification.
