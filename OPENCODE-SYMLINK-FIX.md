# .opencode Symlink Structure Fix

## Date
January 6, 2026

## Issue Identified

The `.opencode/` directory was a regular directory instead of a symlink to `.opencode_global/`. This meant:
- When removing OpenCode skills, the `.opencode/` directory remained
- The directory wasn't properly cleaned up by the init-skills script

## Solution Implemented

### 1. Restructured Directories

**Before**:
```
.opencode/                    (regular directory)
├── agent/                   (11 agent files)
├── opencode.json
└── ...

.opencode_global/            (legacy/backup)
├── agent/                   (empty)
└── ...
```

**After**:
```
.opencode -> .opencode_global/ (symlink)
└── resolves to:
    ├── agent/               (11 agent files)
    ├── opencode.json
    └── ...

.opencode_global/            (actual directory)
├── agent/                   (11 agent files)
├── opencode.json
└── ...
```

### 2. Updated init-skills Script

**ensure_opencode_dir() function**:
- Now creates `.opencode` as a symlink to `.opencode_global`
- Detects if already in opencode-orch-mode source project
- Skips creation in source projects

**remove_opencode_skills() function**:
- Now removes the `.opencode` symlink when removing all OpenCode skills
- Properly cleans up the symlink

### 3. Steps Taken

```bash
# 1. Move agent files to .opencode_global
mv .opencode/agent/* .opencode_global/agent/
rmdir .opencode/agent

# 2. Remove .opencode directory
rm -rf .opencode/

# 3. Create symlink
ln -s .opencode_global .opencode

# 4. Updated init-skills script to handle .opencode symlink
```

## Verification

### Mount Test
```bash
cd opencode-orch-mode
init-skills --opencode --force
```

**Result**: ✅ Creates `.opencode → .opencode_global` symlink

### Remove Test
```bash
init-skills --opencode --remove-all
```

**Result**: ✅ Removes `.opencode` symlink completely

**Output**:
```
[SUCCESS] Removed .opencode/skill symlink
[SUCCESS] Removed CLAUDE.md symlink
[SUCCESS] Removed .opencode symlink
[SUCCESS] All OpenCode skills removal complete
```

### Final State After Removal

```
opencode-orch-mode/
├── .opencode_global/        ✅ Exists (actual directory)
├── .opencode/               ❌ Does not exist (symlink removed)
├── CLAUDE.md                ❌ Does not exist (symlink removed)
└── .opencode/skill/         ❌ Does not exist (symlink removed)
```

## Benefits

1. **Clean Removal**: When removing OpenCode skills, `.opencode/` is completely removed
2. **Proper Structure**: Follows the pattern where `.opencode` is a symlink, not a directory
3. **Source Preserved**: `.opencode_global/` remains with all actual content
4. **Idempotent**: Can mount/remove repeatedly without issues

## Current Directory Structure

### opencode-orch-mode (Source Project)
```
├── .opencode_global/        (actual directory - source of truth)
│   ├── agent/               (11 agent files)
│   ├── opencode.json
│   ├── command/
│   ├── prompts/
│   └── ...
│
└── [when mounted via init-skills]
    └── .opencode -> .opencode_global/  (symlink)
        ├── skill -> llm-rules/skills-opencode.source/  (symlink)
        └── CLAUDE.md -> llm-rules/skills-opencode.source/CLAUDE.source.md  (symlink)
```

### When Skills Are Mounted

```bash
init-skills --opencode
```

Creates:
- `.opencode` → `.opencode_global/` (directory symlink)
- `.opencode/skill` → `llm-rules/skills-opencode.source/` (skills symlink)
- `CLAUDE.md` → `llm-rules/skills-opencode.source/CLAUDE.source.md` (docs symlink)

### When Skills Are Removed

```bash
init-skills --opencode --remove-all
```

Removes:
- `.opencode/skill` symlink
- `CLAUDE.md` symlink
- `.opencode` symlink (the directory itself!)

Leaving:
- `.opencode_global/` (actual content - preserved)

## Script Behavior

### Source Project Detection

When running `init-skills --opencode` in opencode-orch-mode:
- Script detects it as source of OpenCode agents
- Skips `.opencode` symlink creation (already exists or should exist)
- Only creates `.opencode/skill` and `CLAUDE.md` symlinks

### Force Flag

Using `--force`:
- Overwrites existing symlinks
- Still respects source project detection
- Ensures `.opencode/skill` and `CLAUDE.md` are properly linked

## Conclusion

✅ `.opencode` is now a symlink to `.opencode_global/`
✅ Script properly removes `.opencode` symlink when removing skills
✅ Clean removal verified
✅ Full mount/remove cycle works correctly

**Status**: Complete and verified
