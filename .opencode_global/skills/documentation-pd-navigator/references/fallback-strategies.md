# Fallback Strategies for Documentation Navigation

## When DOCUMENTATION-HUB.md is Missing

### Step 1: Check Alternative Entry Points
Try these in order:
1. `./DOCUMENTATION-HUB.md` (project root)
2. `./docs/DOCUMENTATION-HUB.md`
3. `./documentation/DOCUMENTATION-HUB.md`
4. `**/DOCUMENTATION-HUB.md` (search recursively)

### Step 2: Look for Fallback Indices
```
Priority order:
1. ./DOCS-INDEX.md
2. ./docs/README.md
3. ./docs/INDEX.md
4. ./ARCHITECTURE.md
5. ./README.md (check for "Documentation" section)
```

### Step 3: Evaluate What's Available
```markdown
If found README with documentation section:
→ Extract documentation links
→ Navigate to referenced docs
→ Note: "Using README as navigation hub"

If found ARCHITECTURE.md:
→ Read architecture overview
→ Look for component references
→ Note: "Using architecture doc as entry point"

If found docs/ directory:
→ List contents
→ Identify entry point file
→ Note: "Navigating docs directory manually"
```

### Step 4: Manual Documentation Discovery
If no structured entry point exists:
```bash
# Search for markdown files
find . -name "*.md" -type f | grep -E "(doc|guide|readme)"

# Look for common documentation patterns
ls docs/ 2>/dev/null || ls documentation/ 2>/dev/null

# Check for wiki or gh-pages
git branch -a | grep -E "(wiki|gh-pages|docs)"
```

### Step 5: Notify User
```markdown
**Documentation Navigation: Fallback Mode**

No PD-structured documentation hub found.

**Available Alternatives**:
- README.md: Basic project overview
- docs/ directory: 15 markdown files (unstructured)
- ARCHITECTURE.md: System design document

**Recommendation**:
1. Proceeding with available documentation
2. Consider running $CreatePDDocs to structure documentation
3. Navigation will be less efficient without PD structure

**Action**: Reading [most relevant alternative] for context
```

## When Documentation Exists But Not PD-Structured

### Recognition Patterns
Documentation exists but lacks PD structure if:
- No [D0-D5] depth markers
- No explicit stop conditions
- No task-based navigation
- No token budget estimates
- No progressive disclosure organization

### Adaptation Strategy

**Step 1: Assess Available Structure**
```markdown
Check for:
- Component-based organization (docs per component)
- Feature-based organization (docs per feature)
- Role-based organization (dev, ops, architect)
- Technology-based organization (backend, frontend, infra)
```

**Step 2: Create Mental PD Map**
```markdown
Map existing docs to PD levels:
- README or overview → D0-D1 equivalent
- Component guides → D1-D2 equivalent
- Architecture docs → D2-D3 equivalent
- API reference → D3-D4 equivalent
- Historical/changelog → D5 equivalent
```

**Step 3: Navigate with PD Principles**
```markdown
Even without PD structure:
1. Start with high-level docs (README, overview)
2. Identify relevant component/section
3. Read component guide
4. Go deeper only if needed
5. Stop when have sufficient context
```

**Step 4: Document Gaps**
```markdown
**Documentation Status: Non-PD Structure**

**Available Docs**:
- README.md: Project overview
- docs/components/: 8 component guides
- docs/architecture/: System design
- docs/api/: API reference

**PD Mapping**:
- D0/D1: README.md + docs/components/*
- D2/D3: docs/architecture/*
- D4: docs/api/*
- D5: CHANGELOG.md

**Recommendation**: Consider PD restructuring for efficiency
```

## When Documentation is Incomplete

### Gap Identification
Common gaps:
- Component documented but patterns missing
- Architecture exists but integration unclear
- API reference incomplete
- No examples or code snippets
- Historical context missing

### Progressive Fallback

**Step 1: Extract What Exists**
```markdown
Read available documentation:
- Component A: Overview only (D1 equivalent)
- Component B: Complete (D1-D3)
- Component C: Missing

Context from available docs:
- Entry points identified
- Basic patterns understood
- Gaps noted
```

**Step 2: Supplement with Code Exploration**
```markdown
For missing documentation:
1. Locate relevant source files
2. Read code comments and docstrings
3. Identify patterns from code
4. Extract integration points
5. Note findings
```

**Step 3: Combine Docs + Code**
```markdown
**Context Assembled**:

From Documentation:
- Component A: Purpose, entry points
- Component B: Complete patterns

From Code Exploration:
- Component A: Implementation patterns (reverse-engineered)
- Component C: Discovered from imports

**Sufficient for Task**: Yes/No
**Gaps Remaining**: [list if any]
```

**Step 4: Recommend Documentation Improvements**
```markdown
**Documentation Gaps Identified**:

1. Component A Implementation Guide (D2)
   - Need: Pattern examples
   - Impact: Slows feature development

2. Component C Documentation (all levels)
   - Need: Complete component guide
   - Impact: High - core component undocumented

**Suggested Priority**:
1. High: Component C D1 guide
2. Medium: Component A D2 patterns
3. Low: Historical context for legacy modules
```

## Code Exploration Fallback Patterns

### When Documentation is Absent

**Pattern 1: Entry Point Discovery**
```bash
# Find main entry points
grep -r "main\|index\|app\|server" --include="*.{ts,js,py,php}"

# Find route definitions
grep -r "route\|router\|@app\|@get\|@post" --include="*.{ts,js,py,php}"

# Find API controllers
find . -name "*Controller*" -o -name "*Handler*" -o -name "*Service*"
```

**Pattern 2: Component Discovery**
```bash
# Identify major components
ls -d src/*/ app/*/ lib/*/

# Find component relationships
grep -r "import.*from" --include="*.{ts,js}" | head -20
```

**Pattern 3: Pattern Extraction**
```markdown
1. Read 2-3 similar files
2. Identify common patterns
3. Extract conventions
4. Document findings in temp notes
5. Use patterns for task
```

### When Documentation is Outdated

**Detection Signs**:
- File paths don't match codebase
- Referenced files/functions don't exist
- Patterns don't match current code
- Version numbers outdated

**Validation Steps**:
```markdown
1. Check if mentioned files exist
2. Verify code matches documented patterns
3. Compare version numbers (docs vs package.json)
4. Test documented examples
```

**Hybrid Approach**:
```markdown
Use documentation as:
- Conceptual guidance (usually still valid)
- Architecture understanding (changes slowly)
- Historical context (explains decisions)

Validate with code for:
- Current file paths
- Active patterns
- Working examples
- Current APIs
```

## Recovery Patterns

### Scenario 1: Dead-End Navigation
```markdown
Problem: Followed doc link, file doesn't exist

Recovery:
1. Search for similar filename
2. Check git history for moves
3. Search codebase for mentioned concept
4. Ask: Is this feature removed or renamed?
5. Find alternative documentation path
```

### Scenario 2: Circular References
```markdown
Problem: Doc A → Doc B → Doc A (circular)

Recovery:
1. Break cycle: Read both once
2. Extract unique info from each
3. Synthesize understanding
4. Continue with task
5. Note documentation issue
```

### Scenario 3: Overwhelming Options
```markdown
Problem: Hub lists 50+ components, unclear which is relevant

Recovery:
1. Use task description keywords
2. Search hub for keywords
3. Pick most relevant 2-3 components
4. Read D1 of each quickly
5. Identify correct component
6. Continue with focused navigation
```

### Scenario 4: Insufficient Depth
```markdown
Problem: Reached D4, still unclear how to proceed

Recovery:
1. Review task requirements
2. Check if misunderstood problem
3. Re-read relevant sections
4. Look for examples in code
5. Consider alternative approaches
6. Ask for clarification if needed
```

## Success Metrics Despite Fallbacks

### Efficiency Targets
Even with fallbacks, aim for:
- Hub located (or alternative): < 2 minutes
- Relevant component identified: < 5 minutes
- Sufficient context gathered: < 15 minutes
- Total tokens used: < 10,000 (for typical task)

### Quality Indicators
- Found entry points for task
- Understand component purpose
- Have patterns or examples
- Know integration points
- Aware of constraints/limitations

### When to Stop Searching
```markdown
Stop doc navigation when:
✓ Have enough context for task
✓ Spent 15+ minutes searching
✓ Exhausted reasonable doc sources
✓ Can proceed with available info + code
✗ Don't keep searching "just in case"
```

## Documentation Quality Assessment

### Quick Quality Check
```markdown
Documentation Quality: [High/Medium/Low]

✓ PD-structured with depth levels
✓ Explicit stop conditions
✓ Task-based navigation
✓ Code examples present
✓ Up-to-date with codebase
✓ Clear entry points
✓ Integration patterns documented

Score: X/7

High (6-7): Follow PD navigation
Medium (3-5): Use with code validation
Low (0-2): Rely primarily on code exploration
```

### Adaptation by Quality Level

**High Quality (PD-structured)**:
- Follow PD workflow exactly
- Trust stop conditions
- Use token estimates
- Navigate efficiently

**Medium Quality (Structured but not PD)**:
- Apply PD principles
- Create mental depth map
- Set own stop conditions
- Validate with code

**Low Quality (Minimal/Outdated)**:
- Use as conceptual guide only
- Rely on code exploration
- Build understanding bottom-up
- Note gaps for improvement
