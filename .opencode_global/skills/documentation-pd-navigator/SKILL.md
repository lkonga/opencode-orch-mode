---
name: 'Documentation PD Navigator'
description: 'Efficient documentation discovery using progressive disclosure principles to locate and read only the necessary documentation for a given task'
trigger: ['$DocumentationPDNavigator', '$DocsPD', 'analyze documentation', 'find relevant docs', 'locate documentation']
references: {'Navigation flows': 'references/navigation-flows.md', 'Fallback strategies': 'references/fallback-strategies.md', 'Common principles': 'references/common-principles.md'}
---

# Documentation PD Navigator

## Quickstart (30 seconds)

**Purpose**: Navigate project documentation efficiently using progressive disclosure—read only what's needed for your task.

**Core Workflow**:
1. Locate `DOCUMENTATION-HUB.md` (5s)
2. Parse D0 hub to find relevant component (30s)
3. Read D1 component guide (2-5 min)
4. Stop if sufficient, or continue to D2/D3 as needed

**Trigger When**:
- User mentions analyzing documented codebase
- Task requires understanding project structure/patterns
- User explicitly uses `$DocsPD` or `$DocumentationPDNavigator`

## Phase 1: Locate Hub (5 seconds)

**Priority order**:
1. `./DOCUMENTATION-HUB.md` (project root)
2. `./docs/DOCUMENTATION-HUB.md`
3. `./documentation/DOCUMENTATION-HUB.md`
4. Search `**/DOCUMENTATION-HUB.md`

**Fallbacks** (if hub not found):
1. `./DOCS-INDEX.md`
2. `./docs/README.md`
3. `./ARCHITECTURE.md`
4. `./README.md` (check for "Documentation" section)

**If no docs found**: Notify user, fall back to code exploration, suggest creating PD docs.

## Phase 2: Parse Hub - D0 (30 seconds)

**Read**: Complete `DOCUMENTATION-HUB.md` (200-400 lines, ~800 tokens)

**Extract**:
- Component list with `[D1-DX]` depth indicators
- Task-based navigation mapping
- Depth level definitions

**Task Analysis**:
- What am I doing? (action verb)
- Which component? (target)
- What depth? (patterns/architecture/reference)

**Create Plan**:
```
Task: "Fix auth bug in JWT validation"
→ Hub shows: Authentication → AUTH-GUIDE.md [D1-D3]
→ Plan: Read D1, proceed to D2 only if needed
```

## Phase 3: Navigate to D1 (2-5 minutes)

**Read D1 guide** (~1500 tokens):
1. **What** (30s): Purpose and scope
2. **Why** (30s): Problem solved
3. **How** (1 min): Key approach
4. **Quick Reference** (1 min): Entry points, dependencies
5. **Common Operations** (1 min): Usage patterns

**Evaluate Stop Condition**:

✓ **Stop at D1 if**:
- Understand component purpose and interfaces
- Have entry points and basic patterns
- Task is minor fix or simple integration

✗ **Continue to D2 if**:
- Need implementation details
- Need internal patterns/organization
- Modifying core logic
- Need complex code examples

## Phase 4: Conditional D2 (5-15 minutes)

**Only if D1 insufficient**

**Read D2 selectively** (~4000 tokens):
- Core Patterns (implementation with code)
- Code Organization (structure and boundaries)
- Integration Points (dependencies and interfaces)

**Evaluate Stop Condition**:

✓ **Stop at D2 if**:
- Have needed implementation patterns
- Understand code organization
- Have sufficient examples

✗ **Continue to D3 if**:
- Need architectural context for major changes
- Need design decisions and tradeoffs
- Refactoring with system-wide impact
- Performance implications critical

## Phase 5: Conditional D3+ (15+ minutes)

**Only if D2 insufficient**

**Read D3 Architecture selectively** (~7000 tokens):
- System Context diagrams
- Design Decisions (relevant to task)
- Data Flow (if modifying data paths)
- Performance Characteristics (if optimizing)

**Rarely proceed to**:
- **D4** (Complete Reference): Comprehensive API needed
- **D5** (Historical Context): Legacy decisions critical

## Decision Matrix

| Task Type | Depth Needed | Stop Condition | Tokens |
|-----------|-------------|----------------|--------|
| Bug fix (minor) | D0-D1 | Component + entry point | ~2K |
| Bug fix (complex) | D1-D2 | Implementation patterns | ~6K |
| New feature (simple) | D1-D2 | Patterns + integration | ~6K |
| New feature (complex) | D2-D3 | Architecture + design | ~13K |
| Refactoring | D2-D3 | Patterns + dependencies | ~13K |
| Performance work | D3-D4 | Bottlenecks + API | ~25K |
| Architecture review | D3-D4 | Full system understanding | ~25K |

## Token Efficiency Rules

**Do's**:
- ✓ Always start at D0 (designed for 30s scan)
- ✓ Read only relevant sections at each depth
- ✓ Stop at first sufficient depth
- ✓ Use "Stop here if" conditions as checkpoints
- ✓ Trust PD structure

**Don'ts**:
- ✗ Never read all docs preemptively
- ✗ Never skip D0 (essential for navigation)
- ✗ Never jump to D3+ without D1
- ✗ Never ignore stop conditions
- ✗ Never continue deeper "just in case"

## Output Format

After navigation:

```markdown
**Documentation Navigation Complete**

**Depth Reached**: D[X]
**Documents Read**: [List]
**Key Findings**:
- Entry Point: [path]
- Patterns: [names]
- Integration Points: [interfaces]
- Constraints: [limitations]

**Sufficient Context**: [Yes/No]
**Recommendation**: [Ready/Need clarification]
```

## Integration with Other Skills

- **$CreatePDDocs**: Creates documentation this skill navigates
- **$SurgicalImplementation**: Use docs context for precise changes
- **$ArchitectCoder**: Implement changes after doc navigation

## Success Criteria

✓ Located hub in < 5 seconds
✓ Navigated to component in < 1 minute
✓ Reached optimal depth without over-reading
✓ Token usage aligned with task complexity
✓ Ready to proceed immediately

---

**Remember**: Progressive disclosure = read LESS, not more. Trust stop conditions.

## Progressive Disclosure

**References** (load only when needed):
<references>
  <reference title="Navigation flows" path="references/navigation-flows.md" description="Step-by-step navigation workflows, decision trees, optimization patterns" />
  <reference title="Fallback strategies" path="references/fallback-strategies.md" description="Hub not found scenarios, alternative structures, recovery procedures" />
  <reference title="Common principles" path="references/common-principles.md" description="Progressive disclosure theory, token efficiency rules, best practices" />
</references>
