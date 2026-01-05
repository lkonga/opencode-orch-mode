# Skill Validation Guide

Comprehensive validation procedures for ensuring skill quality before integration.

## Validation Philosophy

**Automated first, manual last**: Run automated checks to catch common issues, then perform manual review for quality and coherence.

## Automated Validation

### 1. Line Count Validation

**Rule**: SKILL.md must be under 150 lines.

```bash
# Check line count
wc -l SKILL.md

# Expected output format:
# 142 SKILL.md

# Validation script
if [ $(wc -l < SKILL.md) -gt 150 ]; then
    echo "❌ SKILL.md exceeds 150 lines"
    exit 1
else
    echo "✓ Line count OK: $(wc -l < SKILL.md) lines"
fi
```

**Common failures**:
- Inline too much detail → Move to references
- Long examples → Extract to references/examples.md
- Multiple workflows → Keep high-level, detail in references/workflow.md

### 2. Frontmatter YAML Validation

**Required fields**: version, last_updated, applies_to, tokens

```bash
# Extract and validate frontmatter
head -7 SKILL.md > /tmp/frontmatter.txt

# Check for required fields
for field in version last_updated applies_to tokens; do
    if grep -q "^${field}:" /tmp/frontmatter.txt; then
        echo "✓ Field '${field}' present"
    else
        echo "❌ Missing field '${field}'"
    fi
done

# Validate version format (semantic versioning)
version=$(grep "^version:" SKILL.md | cut -d' ' -f2)
if [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "✓ Version format valid: $version"
else
    echo "❌ Invalid version format: $version (expected X.Y.Z)"
fi

# Validate date format (YYYY-MM-DD)
date=$(grep "^last_updated:" SKILL.md | cut -d' ' -f2)
if [[ $date =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "✓ Date format valid: $date"
else
    echo "❌ Invalid date format: $date (expected YYYY-MM-DD)"
fi
```

**Expected output**:
```
✓ Field 'version' present
✓ Field 'last_updated' present
✓ Field 'applies_to' present
✓ Field 'tokens' present
✓ Version format valid: 1.0.0
✓ Date format valid: 2025-12-19
```

**Common failures**:
```yaml
# Wrong: Missing quotes
applies_to: git-workflows  # Should be: "git-workflows"

# Wrong: Invalid version
version: 1.0  # Should be: 1.0.0

# Wrong: Date format
last_updated: Dec 19 2025  # Should be: 2025-12-19

# Wrong: Missing field
---
version: 1.0.0
last_updated: 2025-12-19
# Missing applies_to and tokens
---
```

### 3. Reference Existence Checks

**Rule**: All referenced files must exist.

```bash
# Extract reference paths from SKILL.md
grep -oP 'path="references/\K[^"]+' SKILL.md > /tmp/refs.txt

# Check each reference file exists
while read -r ref; do
    if [ -f "references/$ref" ]; then
        echo "✓ Reference exists: references/$ref"
    else
        echo "❌ Missing reference: references/$ref"
    fi
done < /tmp/refs.txt

# Count references
ref_count=$(wc -l < /tmp/refs.txt)
if [ $ref_count -ge 2 ]; then
    echo "✓ Adequate references: $ref_count files"
else
    echo "⚠ Consider adding more references: only $ref_count file(s)"
fi
```

**Expected output**:
```
✓ Reference exists: references/workflow.md
✓ Reference exists: references/patterns.md
✓ Reference exists: references/validation.md
✓ Adequate references: 3 files
```

**Common failures**:
```markdown
# Wrong: File doesn't exist
<reference title="Guide" path="references/guide.md" description="..." />
# But references/guide.md is missing

# Wrong: Wrong path
<reference title="Workflow" path="workflow.md" description="..." />
# Should be: path="references/workflow.md"

# Wrong: Typo in filename
<reference title="Patterns" path="references/pattern.md" description="..." />
# Should be: patterns.md
```

### 4. Progressive Disclosure Format Validation

**Rule**: References must be in proper XML-like format in PD section.

```bash
# Check for Progressive Disclosure section
if grep -q "## Progressive Disclosure" SKILL.md; then
    echo "✓ Progressive Disclosure section exists"
else
    echo "❌ Missing Progressive Disclosure section"
fi

# Check for <references> wrapper
if grep -q "<references>" SKILL.md && grep -q "</references>" SKILL.md; then
    echo "✓ References wrapper present"
else
    echo "❌ Missing <references> wrapper"
fi

# Validate reference tag format
# Each reference should have title, path, and description
grep -o '<reference[^>]*>' SKILL.md | while read -r ref; do
    if echo "$ref" | grep -q 'title="[^"]*"'; then
        echo "✓ Title present"
    else
        echo "❌ Missing title in: $ref"
    fi

    if echo "$ref" | grep -q 'path="references/[^"]*\.md"'; then
        echo "✓ Valid path format"
    else
        echo "❌ Invalid path in: $ref"
    fi

    if echo "$ref" | grep -q 'description="[^"]*"'; then
        echo "✓ Description present"
    else
        echo "❌ Missing description in: $ref"
    fi
done
```

**Expected output**:
```
✓ Progressive Disclosure section exists
✓ References wrapper present
✓ Title present
✓ Valid path format
✓ Description present
[repeated for each reference]
```

**Common failures**:
```markdown
# Wrong: No wrapper
## Progressive Disclosure
<reference title="..." path="..." description="..." />

# Correct:
## Progressive Disclosure

**References** (load only when needed):
<references>
  <reference title="..." path="..." description="..." />
</references>

# Wrong: Missing attributes
<reference path="references/workflow.md" />

# Correct:
<reference title="Workflow" path="references/workflow.md" description="Step-by-step procedures" />

# Wrong: Not closed
<reference title="..." path="..." description="..."

# Correct:
<reference title="..." path="..." description="..." />
```

### 5. Description Quality Checks

**Rule**: Descriptions must be 5-15 words, action-oriented, specific.

```bash
# Extract descriptions
grep -oP 'description="\K[^"]+' SKILL.md | while read -r desc; do
    word_count=$(echo "$desc" | wc -w)

    if [ $word_count -ge 5 ] && [ $word_count -le 15 ]; then
        echo "✓ Description length OK: $word_count words - '$desc'"
    else
        echo "❌ Description length invalid: $word_count words - '$desc'"
    fi

    # Check for action words (verbs, specific terms)
    if echo "$desc" | grep -qiE "(step-by-step|guide|reference|procedures|patterns|examples|validation|workflow)"; then
        echo "✓ Contains action-oriented terms"
    else
        echo "⚠ Consider more specific terms: '$desc'"
    fi
done
```

**Expected output**:
```
✓ Description length OK: 8 words - 'Complete step-by-step procedures with decision trees and examples'
✓ Contains action-oriented terms
✓ Description length OK: 7 words - 'Common skill creation patterns extracted from high-quality skills'
✓ Contains action-oriented terms
```

**Good descriptions**:
```markdown
description="Complete step-by-step procedures with decision trees and examples"
description="Common patterns extracted from surgical-implementation and tmux-protected-execution skills"
description="Automated validation checks and quality criteria for skill integrity"
description="Ripgrep and ast-grep command patterns for safe code modifications"
```

**Bad descriptions**:
```markdown
description="More info"  # Too short
description="This reference contains comprehensive detailed information about every single aspect of the workflow"  # Too long
description="Details about stuff"  # Vague
description="See this for help"  # Not action-oriented
```

### 6. Token Count Validation

**Rule**: Token estimate in frontmatter should match actual.

```bash
# Calculate estimated tokens (words * 1.3)
actual_tokens=$(wc -w SKILL.md | awk '{print int($1 * 1.3)}')

# Extract claimed tokens from frontmatter
claimed_tokens=$(grep "^tokens:" SKILL.md | grep -oP '\d+')

# Compare
difference=$((claimed_tokens - actual_tokens))
if [ ${difference#-} -lt 50 ]; then  # Within 50 tokens
    echo "✓ Token count accurate: claimed=$claimed_tokens, actual=$actual_tokens"
else
    echo "⚠ Token count mismatch: claimed=$claimed_tokens, actual=$actual_tokens (diff: $difference)"
fi
```

**Expected output**:
```
✓ Token count accurate: claimed=850, actual=847
```

## Automated Validation Script

Complete validation script combining all checks:

```bash
#!/bin/bash
# validate-skill.sh - Complete skill validation

SKILL_FILE="SKILL.md"
SKILL_DIR=$(dirname "$SKILL_FILE")
ERRORS=0
WARNINGS=0

echo "=== Skill Validation Report ==="
echo ""

# 1. Line count
echo "📏 Line Count Check"
line_count=$(wc -l < "$SKILL_FILE")
if [ $line_count -le 150 ]; then
    echo "  ✓ Line count OK: $line_count lines"
else
    echo "  ❌ SKILL.md exceeds 150 lines: $line_count"
    ((ERRORS++))
fi
echo ""

# 2. Frontmatter
echo "📋 Frontmatter Validation"
for field in version last_updated applies_to tokens; do
    if grep -q "^${field}:" "$SKILL_FILE"; then
        echo "  ✓ Field '$field' present"
    else
        echo "  ❌ Missing field '$field'"
        ((ERRORS++))
    fi
done
echo ""

# 3. Reference existence
echo "📚 Reference File Checks"
grep -oP 'path="references/\K[^"]+' "$SKILL_FILE" | while read -r ref; do
    if [ -f "references/$ref" ]; then
        echo "  ✓ Reference exists: references/$ref"
    else
        echo "  ❌ Missing reference: references/$ref"
        ((ERRORS++))
    fi
done
echo ""

# 4. Progressive Disclosure section
echo "🔍 Progressive Disclosure Format"
if grep -q "## Progressive Disclosure" "$SKILL_FILE"; then
    echo "  ✓ Progressive Disclosure section exists"

    if grep -q "<references>" "$SKILL_FILE"; then
        echo "  ✓ References wrapper present"
    else
        echo "  ❌ Missing <references> wrapper"
        ((ERRORS++))
    fi
else
    echo "  ❌ Missing Progressive Disclosure section"
    ((ERRORS++))
fi
echo ""

# 5. Description quality
echo "📝 Description Quality"
grep -oP 'description="\K[^"]+' "$SKILL_FILE" | while read -r desc; do
    word_count=$(echo "$desc" | wc -w)

    if [ $word_count -ge 5 ] && [ $word_count -le 15 ]; then
        echo "  ✓ Description OK ($word_count words)"
    else
        echo "  ⚠ Description length: $word_count words (expected 5-15)"
        ((WARNINGS++))
    fi
done
echo ""

# Summary
echo "=== Summary ==="
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo "✅ Validation passed!"
    exit 0
else
    echo "❌ Validation failed with $ERRORS error(s)"
    exit 1
fi
```

**Usage**:
```bash
cd /path/to/skill-name
bash ../../scripts/validate-skill.sh
```

## Manual Validation Checklist

After automated checks pass, perform manual review:

### Content Quality

- [ ] **Quickstart is actionable**: Can user copy-paste and run immediately?
- [ ] **Core Principle is clear**: One fundamental concept, well-articulated?
- [ ] **When to Use is specific**: 5-8 concrete scenarios, not generic?
- [ ] **Workflow is complete**: All steps numbered, clear outcomes?
- [ ] **Success Criteria is objective**: Can each item be checked yes/no?

### Coherence

- [ ] **Consistent terminology**: Same terms used throughout?
- [ ] **Logical flow**: Sections build on each other?
- [ ] **No contradictions**: Instructions don't conflict?
- [ ] **Examples match workflow**: Code examples align with described steps?

### Reference Quality

- [ ] **References are substantial**: Each 50+ lines of content?
- [ ] **No stub references**: All contain real content, not "TBD"?
- [ ] **Cross-references are valid**: Inline references point to real sections?
- [ ] **Examples are complete**: Real commands that actually work?

### Integration Readiness

- [ ] **Skill listed in AGENTS.md**: Added to skill registry?
- [ ] **SKILLS.instruction.md updated**: New patterns documented?
- [ ] **No duplicate skills**: Doesn't overlap existing skill's purpose?
- [ ] **Templates provided**: If skill creates files, templates exist?

## Common Validation Failures

### Failure 1: Line Count Exceeded

**Detection**:
```bash
wc -l SKILL.md
# Output: 187 SKILL.md ❌
```

**Diagnosis**:
```bash
# Find longest sections
awk '/^##/ {print NR": "$0}' SKILL.md
# Shows section line numbers

# Count lines per section
awk '/^## / {if (title) print lines" lines: "title; title=$0; lines=0; next} {lines++} END {print lines" lines: "title}' SKILL.md
```

**Fix**:
```markdown
# Before (in SKILL.md)
## Commands

### ripgrep options
-A, -B, -C: context lines
--type: filter by file type
[... 50 more lines ...]

# After (in SKILL.md)
## Commands

Use <reference title="Command reference" path="references/commands.md" description="Complete ripgrep and ast-grep option reference" /> for full details.

Quick reference:
- `rg "pattern"`: Basic search
- `sg --pattern 'code'`: Structural search

# Move detail to references/commands.md
```

### Failure 2: Missing Frontmatter Field

**Detection**:
```bash
head -7 SKILL.md
# Output shows missing field
```

**Fix**:
```yaml
# Before
---
version: 1.0.0
last_updated: 2025-12-19
---

# After
---
version: 1.0.0
last_updated: 2025-12-19
applies_to: "git-workflows"
tokens: 850
---
```

### Failure 3: Reference File Missing

**Detection**:
```bash
ls references/
# Output: workflow.md patterns.md
# But SKILL.md references validation.md
```

**Fix**:
```bash
# Create missing reference
cat > references/validation.md << 'EOF'
# Validation

## Automated Checks
[Content here...]

## Manual Review
[Content here...]
EOF
```

### Failure 4: Invalid Reference Format

**Detection**:
```bash
grep '<reference' SKILL.md
# Output shows malformed tags
```

**Fix**:
```markdown
# Before
<reference path="references/workflow.md" />

# After
<reference title="Workflow details" path="references/workflow.md" description="Step-by-step procedures with examples" />
```

### Failure 5: Description Too Short/Long

**Detection**:
```bash
grep -oP 'description="\K[^"]+' SKILL.md | while read d; do
    echo "$(echo $d | wc -w) words: $d"
done
# Output: 3 words: More details
# Output: 22 words: This is a very long description that...
```

**Fix**:
```markdown
# Before
description="More details"  # Too short

# After
description="Complete step-by-step procedures with decision trees and examples"  # 9 words

# Before
description="This reference contains comprehensive detailed information about every single aspect of the workflow including all possible edge cases"  # 19 words

# After
description="Comprehensive workflow guide with troubleshooting and edge cases"  # 9 words
```

## Validation Workflow

```
1. Run automated validation script
   │
   ├─ PASS → Continue to manual review
   │
   └─ FAIL → Fix errors → Rerun validation
      │
      └─ Still failing? → Check common failures above

2. Manual review checklist
   │
   ├─ All items checked → Ready for integration
   │
   └─ Issues found → Fix → Return to step 1

3. Integration validation
   │
   ├─ Update AGENTS.md
   ├─ Update SKILLS.instruction.md
   └─ Create PR

4. Final verification
   │
   ├─ PR passes CI checks
   └─ Manual review by maintainer
```

## Quick Validation Commands

One-liners for rapid checks:

```bash
# Line count
wc -l SKILL.md | awk '{print ($1 <= 150) ? "✓ OK" : "❌ TOO LONG"}'

# Frontmatter complete
[ $(head -7 SKILL.md | grep -c "version:\|last_updated:\|applies_to:\|tokens:") -eq 4 ] && echo "✓ Frontmatter OK" || echo "❌ Missing fields"

# All references exist
grep -oP 'path="references/\K[^"]+' SKILL.md | xargs -I {} [ -f references/{} ] && echo "✓ All refs exist" || echo "❌ Missing refs"

# PD section present
grep -q "## Progressive Disclosure" SKILL.md && echo "✓ PD section OK" || echo "❌ No PD section"

# Token count estimate
echo "Estimated tokens: $(wc -w SKILL.md | awk '{print int($1 * 1.3)}')"
```

## Pre-Commit Hook

Automate validation on commit:

```bash
#!/bin/bash
# .git/hooks/pre-commit

if [ -f "SKILL.md" ]; then
    echo "Validating SKILL.md..."

    # Run validation
    bash scripts/validate-skill.sh

    if [ $? -ne 0 ]; then
        echo ""
        echo "❌ Skill validation failed. Commit rejected."
        echo "Fix errors and try again."
        exit 1
    fi

    echo "✅ Skill validation passed"
fi
```

**Install**:
```bash
chmod +x .git/hooks/pre-commit
```
