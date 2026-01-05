# Implementation Patterns Reference

This document provides detailed patterns and examples for surgical code modifications.

## Phase Implementation Workflow

### Phase Processing Pattern

For each implementation phase:

1. **Read phase plan completely**
   - Understand all requirements
   - Identify affected files
   - Note verification steps

2. **Create execution plan**
   - List files to modify
   - Identify dependencies
   - Sequence operations

3. **Gather minimal context**
   - Use targeted searches
   - Read only necessary sections
   - Track line counts

4. **Apply surgical changes**
   - Use edit tool
   - Make targeted modifications
   - Preserve surrounding code

5. **Verify immediately**
   - Run build/compile
   - Execute tests
   - Check for errors

6. **Document results**
   - List changes made
   - Note any issues
   - Prepare summary

## Coder Agent Detailed Protocol

### Step 1: Create Plan of Attack

**Before Touching Code**:
```markdown
1. Read phase implementation plan fully
2. Identify all files to modify
3. List functions/classes to change
4. Note verification requirements
5. Estimate context budget needed
```

**Use Think Tool**:
```
think: "Planning phase implementation"
- Files to read: [list]
- Changes to make: [list]
- Verification steps: [list]
- Estimated context: [number] lines
```

**Budget Check**:
- Total available: 21,000 lines
- Phase plan: ~200 lines
- Context reading: max 2,000 lines
- Changes: minimal (edit tool)
- Reserve: 18,000+ lines

### Step 2: Contextual Analysis (Read-Only)

**Locate Targets**:

```bash
# Find function definitions
git grep -n "function processPayment" src/

# Find class declarations
rg -n "class UserService" src/

# Find specific imports
sg -p 'import { $X } from "$Y"' src/
```

**Controlled Reading Workflow**:

```bash
# 1. Dry-run to check size
wc -l src/services/payment-service.ts
# Output: 350 lines

# 2. Find target function
git grep -n "processPayment" src/services/payment-service.ts
# Output: 125:  processPayment(data) {

# 3. Read only relevant section (20 lines before + 50 lines of function)
sed -n '105,175p' src/services/payment-service.ts
```

**Size Management**:
- File > 500 lines: Read sections only
- File < 100 lines: Can read entire file
- Function > 100 lines: Read in chunks
- Always use line ranges with sed/head/tail

### Step 3: Propose Surgical Changes

**Edit Tool Pattern**:

```typescript
// Use edit tool with precise operations

// INSERT: Add new code
edit({
  operation: 'insert',
  file: 'src/services/user-service.ts',
  after: 'line 45',
  code: `
  async validateUser(userId: string): Promise<boolean> {
    return await this.repository.exists(userId);
  }
  `
});

// REPLACE: Modify existing code
edit({
  operation: 'replace',
  file: 'src/services/user-service.ts',
  start: 'line 67',
  end: 'line 72',
  code: `
  async deleteUser(userId: string): Promise<void> {
    await this.validateUser(userId);
    await this.repository.delete(userId);
    await this.cache.invalidate(userId);
  }
  `
});

// DELETE: Remove code
edit({
  operation: 'delete',
  file: 'src/services/user-service.ts',
  start: 'line 89',
  end: 'line 95'
});
```

**Never Overwrite Entire Files**:
- ❌ Reading entire file and writing it back
- ✅ Reading target section and editing specific lines

**Preservation Rules**:
- Keep all imports
- Preserve all comments
- Maintain formatting
- Don't touch unrelated code

### Step 4: Verification Patterns

**Build Verification**:
```bash
# TypeScript project
npm run build

# Or use specific compile command
tsc --noEmit

# Check for errors
echo $?  # Should be 0 for success
```

**Test Verification**:
```bash
# Run specific test file
npm test -- path/to/test.spec.ts

# Run tests matching pattern
npm test -- --testNamePattern="UserService"

# Run all tests in directory
npm test -- src/services/
```

**Lint Verification**:
```bash
# Check modified files only
eslint src/services/user-service.ts

# Auto-fix minor issues
eslint --fix src/services/user-service.ts
```

**Failure Response**:
1. **Don't panic** - Most errors are fixable
2. **Read error message** carefully
3. **Locate error** (line number provided)
4. **Read context** around error
5. **Apply fix** using edit tool
6. **Re-verify** immediately

### Step 5: Report Summary Pattern

**Final Summary Template**:
```markdown
## Implementation Summary

### Files Modified
- `src/services/user-service.ts` (3 changes)
- `src/models/user.ts` (1 change)
- `tests/user-service.spec.ts` (2 changes)

### Changes Applied

#### src/services/user-service.ts
1. Added `validateUser()` method (line 45-48)
2. Updated `deleteUser()` to include validation (line 67-72)
3. Removed deprecated `legacyDelete()` method (line 89-95)

#### src/models/user.ts
1. Added `isValid` property to User interface (line 23)

#### tests/user-service.spec.ts
1. Added tests for `validateUser()` (line 156-168)
2. Updated `deleteUser()` tests to expect validation (line 180-192)

### Verification Results
- Build: ✅ Passed
- Tests: ✅ All 24 tests passed
- Lint: ✅ No issues

### Context Budget Used
- Phase plan: 180 lines
- Context reading: 420 lines
- Total: 600 lines (2.8% of budget)
```

## Common Modification Patterns

### Adding New Functions

**Pattern**:
1. Find insertion point (end of class or after related method)
2. Read surrounding context (10 lines before/after)
3. Match indentation and style
4. Insert using edit tool
5. Verify with build

**Example**:
```bash
# Find class end
git grep -n "^}" src/service.ts | tail -n 1

# Read context
sed -n '85,95p' src/service.ts

# Insert before closing brace
edit({operation: 'insert', before: 'line 94', ...})
```

### Modifying Existing Functions

**Pattern**:
1. Locate function with grep
2. Determine function boundaries
3. Read function only
4. Replace entire function
5. Verify with tests

**Example**:
```bash
# Find function
git grep -n "processOrder" src/order-service.ts
# Output: 45:  processOrder(order: Order) {

# Find function end (next function or closing brace)
sed -n '45,200p' src/order-service.ts | grep -n "^  }" | head -n 1
# Output: 23:  }
# Function ends at line 67 (45 + 23 - 1)

# Read function
sed -n '45,67p' src/order-service.ts

# Replace with edit tool
edit({operation: 'replace', start: 'line 45', end: 'line 67', ...})
```

### Updating Imports

**Pattern**:
1. Find import section
2. Read all imports
3. Add/modify/remove specific import
4. Preserve alphabetical order if used

**Example**:
```bash
# Find import section
sed -n '1,30p' src/service.ts | grep -n "import"

# Add new import
edit({
  operation: 'insert',
  after: 'line 5',
  code: "import { NewService } from './new-service';"
})
```

### Renaming Across Files

**Pattern**:
1. Use ast-grep for structural search
2. Preview all matches
3. Apply with -i flag
4. Verify with build

**Example**:
```bash
# Preview rename
sg -p 'oldFunctionName($$$)' -r 'newFunctionName($$$)' src/

# Apply rename
sg -p 'oldFunctionName($$$)' -r 'newFunctionName($$$)' -i src/

# Verify
npm run build
```

## Error Recovery Patterns

### Build Errors

**Common Issues**:
- Missing imports
- Type mismatches
- Syntax errors

**Recovery**:
1. Read error message
2. Identify file and line
3. Read context (10 lines around error)
4. Apply fix
5. Re-run build

### Test Failures

**Common Issues**:
- Unexpected behavior
- Missing mocks
- Type assertion failures

**Recovery**:
1. Read failing test
2. Understand expectation
3. Check implementation
4. Fix discrepancy
5. Re-run test

### Lint Errors

**Common Issues**:
- Unused variables
- Missing types
- Formatting issues

**Recovery**:
1. Run eslint with --fix
2. Review remaining issues
3. Apply manual fixes
4. Re-run lint

## Context Budget Optimization

### Reading Strategies

**Minimal Context**:
- Read only target functions
- Use line ranges always
- Skip comments when possible
- Ignore test files unless needed

**Efficient Search**:
- Use ast-grep for structure
- Use ripgrep for speed
- Limit results with head
- Focus on file paths first

**Progressive Loading**:
1. Start with file list
2. Read signatures only
3. Read implementation if needed
4. Load tests last

### Budget Tracking

**Mental Counter**:
```
Running Total:
+ Phase plan: 180 lines
+ Search results: 50 lines
+ File 1 context: 75 lines
+ File 2 context: 120 lines
= 425 lines (2% of 21,000)
```

**Warning Thresholds**:
- 5,000 lines (25%): Review approach
- 10,000 lines (50%): Stop reading, start editing
- 15,000 lines (75%): Emergency mode, minimal verification

## Best Practices Summary

1. **Always dry-run** before reading
2. **Use line ranges** for all reads
3. **Edit, don't rewrite** entire files
4. **Verify incrementally** after each change
5. **Track context** mentally
6. **Summarize concisely** at end
7. **Preserve all** unrelated code
8. **Match style** of existing code
9. **Test immediately** after changes
10. **Document clearly** what changed
