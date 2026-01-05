# Surgical Commands Reference

This document provides detailed usage patterns for command-line tools used during surgical implementation phases.

## Git Commands

### Basic Operations
```bash
# View recent commits
git log --oneline -n 15

# Show file changes statistics
git diff --stat

# Search for patterns in tracked files
git grep -n "pattern"
```

### Pattern Search Examples
```bash
# Find function definitions
git grep -n "function myFunction"

# Find class declarations
git grep -n "class MyClass"

# Find imports
git grep -n "import.*Module"
```

## GitHub Repository Search

Use the `githubRepo` tool for pattern discovery in remote repositories:

### Usage Pattern
- Limit to 7 results per query
- Use specific search terms
- Focus on code patterns, not broad searches

### Example Queries
```
githubRepo('owner/repo', 'function authentication')
githubRepo('owner/repo', 'class UserService')
githubRepo('owner/repo', 'export const API_ENDPOINT')
```

## Grep Tools

### ripgrep (rg)

**Basic Search**:
```bash
# Search for pattern with line numbers
rg -n "pattern" src/

# Case-insensitive search
rg -i -n "pattern" src/

# Search specific file types
rg -n -t typescript "pattern" src/
```

**Context Control**:
```bash
# Show 3 lines before and after match
rg -n -C 3 "pattern" src/

# Show only filenames
rg -l "pattern" src/

# Count matches per file
rg -c "pattern" src/
```

**Performance Tips**:
- Use file type filters (`-t`) to reduce scope
- Combine with line count limits for large codebases
- Use `-l` flag when you only need file paths

### ast-grep (sg)

ast-grep provides structural pattern matching for code.

**Search Patterns**:
```bash
# Find if statements
sg -p 'if ($C) { $B }' src/

# Find function calls
sg -p 'myFunction($$$)' src/

# Find class methods
sg -p 'class $X { $M() { $$$ } }' src/
```

**Rewrite Operations**:
```bash
# Basic replacement
sg -p 'console.log($X)' -r 'logger.info($X)' src/

# Variable declaration updates
sg -p 'var $X=$V' -r 'let $X=$V' --lang ts src/

# Function signature changes
sg -p 'function $F($A)' -r 'function $F($A): void' --lang ts src/
```

**In-place Edits**:
```bash
# Apply changes directly to files
sg -p 'console.log($X)' -r 'logger.info($X)' --lang ts -i src/

# Confirm changes before applying
sg -p 'var $X=$V' -r 'let $X=$V' --lang ts src/
# Review output, then:
sg -p 'var $X=$V' -r 'let $X=$V' --lang ts -i src/
```

**Common Flags**:
- `-p` - Search pattern
- `-r` - Replacement pattern
- `--lang` - Force language (ts, js, py, etc.)
- `-i` - Apply edits in-place
- `--json` - Output in JSON format for parsing

**Workflow**:
1. **Search**: Run with `-p` only to see matches
2. **Test**: Add `-r` to preview replacements
3. **Apply**: Add `-i` to make changes
4. **Verify**: Run build/tests to confirm

**Pattern Variables**:
- `$X` - Single identifier
- `$$X` - Multiple statements
- `$$$` - Zero or more arguments
- `$C` - Condition
- `$B` - Block
- `$V` - Value

## Controlled Reading Techniques

### File Size Check (Dry-Run)
```bash
# Count lines before reading
wc -l src/file.ts

# Check multiple files
wc -l src/*.ts
```

### Selective Reading
```bash
# Read specific line range
sed -n '10,30p' src/file.ts

# Read first N lines
head -n 50 src/file.ts

# Read last N lines
tail -n 50 src/file.ts

# Read around a match
grep -n -A 5 -B 5 "pattern" src/file.ts
```

### Combined Approach
```bash
# Find line number, then read context
LINE=$(grep -n "function myFunc" src/file.ts | cut -d: -f1)
sed -n "$((LINE-5)),$((LINE+20))p" src/file.ts
```

## Token Budget Management

### Pre-Read Checks
```bash
# Assess total line count
find src/ -name "*.ts" -exec wc -l {} + | tail -n 1

# Count files
find src/ -name "*.ts" | wc -l

# Size of specific directories
du -sh src/*/
```

### Command Output Limits

**Per-Command Maximum**: 200 lines

**Enforcement Strategies**:
```bash
# Limit output with head
rg -n "pattern" src/ | head -n 200

# Use file count limits
git grep -n "pattern" | head -n 200

# Scope to specific directories
sg -p 'pattern' src/specific-module/
```

## Emergency Context Reduction

If approaching context limits:

1. **Stop reading immediately**
2. **Summarize what you've learned**
3. **Use targeted queries** instead of broad searches
4. **Apply changes** based on current knowledge
5. **Verify incrementally**

## Best Practices

1. **Always dry-run** before reading large files
2. **Use ast-grep** for structural changes
3. **Prefer ripgrep** over git grep for speed
4. **Limit context** with line ranges
5. **Count tokens** mentally as you read
6. **Stop at 200 lines** per command output
