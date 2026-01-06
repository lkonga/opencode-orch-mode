# OpenCode Structure Cleanup Summary

## Date
January 6, 2026

## Issues Identified

### 1. Redundant Symlink: `.opencode/skills-opencode`
**Status**: ✅ **REMOVED**

The `.opencode/skills-opencode` symlink was redundant. According to OpenCode standards:
- ✅ Correct: `.opencode/skill/` (singular)
- ❌ Incorrect: `.opencode/skills-opencode/` (redundant)

**Action Taken**:
```bash
rm .opencode/skills-opencode
```

### 2. Legacy Directory: `.opencode_global/`
**Status**: ⚠️ **NEEDS EVALUATION**

The `.opencode_global/` directory appears to be an old/legacy structure that has been superseded by `.opencode/`.

## Comparison: `.opencode/` vs `.opencode_global/`

| File/Directory | `.opencode/` | `.opencode_global/` | Notes |
|----------------|--------------|---------------------|-------|
| `agent/` | ✅ Active (11 agents) | ❌ Empty (broken symlinks removed) | Use `.opencode/agent/` |
| `skill/` | ✅ Symlink to `llm-rules/skills-opencode/` | ❌ Redundant symlink removed | Use `.opencode/skill/` |
| `CLAUDE.md` | ✅ Symlink to `llm-rules/skills-opencode/CLAUDE.md` | ✅ Same symlink | Duplicate (OK) |
| `opencode.json` | ✅ Active config | ✅ Same config (with backups) | Duplicate |
| `command/` | ❌ Not present | ✅ `multi.md` (custom command) | **Unique content** |
| `GEMINI_LOCAL_README.md` | ❌ Not present | ✅ Documentation | **Unique content** |
| `package.json` | ✅ Present | ✅ Same | Duplicate (OK) |
| `node_modules/` | ✅ Present | ✅ Same | Duplicate (OK) |

## Recommendations

### Option A: Keep `.opencode_global/` for Custom Content
**If you want to keep the custom command:**

```bash
# Move unique content to .opencode/
mv .opencode_global/command .opencode/
mv .opencode_global/GEMINI_LOCAL_README.md .opencode/

# Remove the rest of .opencode_global/
rm -rf .opencode_global/agent
rm .opencode_global/skills-opencode
rm .opencode_global/opencode.json.backup*
rm .opencode_global/bun.lock
rm .opencode_global/package.json
rm -rf .opencode_global/node_modules

# Optionally keep .opencode_global/ as minimal dir
# or remove it entirely after moving unique content
```

**Result**: `.opencode/` becomes the single source of truth

### Option B: Keep `.opencode_global/` as Legacy Reference
**If you want to preserve the old structure for reference:**

```bash
# Add to .gitignore
echo ".opencode_global/agent/" >> .gitignore
echo ".opencode_global/skills-opencode" >> .gitignore
echo ".opencode_global/opencode.json.backup*" >> .gitignore

# Keep unique files
# - command/multi.md
# - GEMINI_LOCAL_README.md
```

**Result**: Both directories exist but `.opencode/` is the active one

### Option C: Complete Cleanup (Recommended)
**Remove `.opencode_global/` entirely after preserving unique content:**

```bash
# 1. Backup unique content
cp .opencode_global/command/multi.md /tmp/multi.md.backup
cp .opencode_global/GEMINI_LOCAL_README.md /tmp/GEMINI_LOCAL_README.md.backup

# 2. Move unique content to .opencode/
mkdir -p .opencode/command
mv .opencode_global/command/multi.md .opencode/command/
mv .opencode_global/GEMINI_LOCAL_README.md .opencode/

# 3. Remove .opencode_global/
rm -rf .opencode_global/

# 4. Update any references
# (Check if any docs reference .opencode_global)
```

**Result**: Clean, single-directory structure

## Current State (After Removing Redundant Symlink)

```
opencode-orch-mode/
├── .opencode/                    # ✅ Active OpenCode directory
│   ├── agent/                   # ✅ 11 agent files
│   ├── skill → llm-rules/skills-opencode/  # ✅ Correct symlink
│   ├── CLAUDE.md → llm-rules/skills-opencode/CLAUDE.md
│   ├── opencode.json            # ✅ Active config
│   ├── package.json
│   ├── bun.lock
│   ├── node_modules/
│   └── prompts/
│
└── .opencode_global/             # ⚠️ Legacy directory
    ├── agent/                   # ❌ Empty (broken symlinks removed)
    ├── skill → (same as .opencode/skill)  # ❌ Duplicate
    ├── CLAUDE.md → (same)        # ❌ Duplicate
    ├── opencode.json            # ⚠️ Has backups
    ├── command/multi.md          # ✅ Unique custom command
    ├── GEMINI_LOCAL_README.md    # ✅ Unique documentation
    ├── package.json             # ❌ Duplicate
    ├── bun.lock                 # ❌ Duplicate
    ├── node_modules/            # ❌ Duplicate
    └── skills-opencode → (same)  # ❌ Duplicate
```

## OpenCode Standard Structure

According to OpenCode documentation:
```
.opencode/
├── skill/                      # Skills (symlink to central source)
│   └── <skill-name>/
│       └── SKILL.md
├── agent/                      # Agents (project-specific or symlinked)
│   └── <agent-name>.md
├── opencode.json              # Configuration
└── CLAUDE.md                  # Documentation
```

**NOT**:
- ❌ `.opencode/skills/` (plural)
- ❌ `.opencode/skills-opencode/` (redundant)
- ❌ `.opencode_global/` (legacy)

## Decision Needed

Please choose one of the following:

1. **Option A**: Move unique content to `.opencode/` and minimize `.opencode_global/`
2. **Option B**: Keep both but document `.opencode_global/` as legacy
3. **Option C**: Complete cleanup - remove `.opencode_global/` entirely

Which approach would you prefer?
