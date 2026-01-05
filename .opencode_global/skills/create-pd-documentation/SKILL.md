---
name: 'Create PD Documentation'
description: 'Generate comprehensive progressive disclosure documentation systems for codebases of any size with granular depth control (D0-D5) and token-efficient navigation'
trigger: ['$CreatePDDocs', '$CreatePDDocumentation', 'create documentation hub', 'generate PD docs', 'create progressive disclosure documentation']
references: {'Depth templates': 'references/depth-templates.md', 'Subagent patterns': 'references/subagent-patterns.md', 'Validation checklists': 'references/validation-checklists.md'}
related_skills: ['$ArchitectCoder', '$DocumentationPDNavigator', '$RepositoryAnalysis', '$RelentlessWebResearch']
---

# Create Progressive Disclosure Documentation

## Quickstart (30 seconds)

**Purpose**: Build progressive disclosure (PD) documentation with D0-D5 depth levels for token-efficient navigation.

**Core Structure**:
- **D0 Hub**: 200-400 line entry point (30s scan)
- **D1 Guides**: Role-based overviews (2-5 min read)
- **D2-D5**: Progressive depth as needed (on-demand)

**When to Use**:
- New project needs documentation
- Existing docs are overwhelming/inefficient
- User mentions `$CreatePDDocs` or "create documentation hub"

## Phase 1: Repository Analysis (10-30 min)

Use `$ArchitectCoder` for token-efficient analysis: Architect surveys project structure,
identifies boundaries, creates task breakdown. Subagents (via run_glm_prompt) analyze
assigned areas. Architect integrates findings into coherent picture.

**For Large Codebases (>50 files):**
Architect creates analysis plan, subagents execute (read files, extract structure, identify
patterns), condensed reports returned (<200 lines each). <reference title="Subagent patterns" path="references/subagent-patterns.md" description="Large codebase analysis delegation, task breakdown, report integration" /> for detailed workflow.

**For Small Projects (<20 files):**
Direct read-and-analyze approach. Create architecture notes as you discover patterns.

**Stop Condition:**
Clear understanding of: project structure, major components, technologies/frameworks,
architectural patterns, documentation needs.

## Phase 2: Create D0 Hub (30-60 min)

**File**: `DOCUMENTATION-HUB.md` at project root

**Requirements**:
- **Length**: 200-400 lines
- **Token Budget**: 500-1000 tokens
- **Scan Time**: 30 seconds to find components

**Essential Sections**:

### Quick Orientation (30s scan)
What/Why/How/Stack format—see <reference title="Depth templates" path="references/depth-templates.md" description="Complete D0-D5 templates, structure examples, formatting" /> for structure.

### Project Map (1 min scan)
Components [D1-Dx] with brief descriptions → doc paths. Technology Stack with versions → stack doc.
Structure details in <reference title="Depth templates" path="references/depth-templates.md" description="Complete D0-D5 templates, structure examples, formatting" />.

### Task-Based Navigation
Development tasks (fix bug, add feature) and Operations tasks (deploy, debug) mapped to relevant
docs with depth indicators. Template in `references/depth-templates.md`.

### Depth Level Guide
**[D0]** Hub (30s, ~800 tokens) • **[D1]** Overview (2-5 min, ~1500 tokens) •
**[D2]** Implementation (5-15 min, ~3500 tokens) • **[D3]** Architecture (15-30 min, ~7500 tokens) •
**[D4]** Reference (30-60 min, ~15000 tokens) • **[D5]** Historical (as needed, ~7500 tokens)

**Stop Condition**: Hub provides enough signposting to navigate to D1 docs

## Phase 3: Create D1 Entry Points (1-3 hours)

**Requirements**:
- One D1 file per major component/concept
- Focused on component overview (not deep implementation)
- Clear navigation links to D2+ details
- Consistent template structure

**Template Structure:**
See <reference title="depth templates" path="references/depth-templates.md" /> for complete template.
Key sections: Purpose, Quick Start, Architecture, Core Concepts, Navigation.

**Stop Condition:**
All major components/concepts have D1 entry point files. D1 content stays at overview level—
detailed specs, architecture deep-dives, and reference implementations deferred to D2+.

## Phase 4: Build D2-D5 (As Needed)

**Create based on project complexity**

### D2 Implementation (600-1500 lines, 2000-5000 tokens)
- Detailed patterns with complete code
- Integration examples
- Testing approaches
- **Stop**: Sufficient for most development

### D3 Architecture (1500-3000 lines, 5000-10000 tokens)
- System design and decisions
- Component relationships
- Design patterns
- **Stop**: Sufficient for complex features/refactoring

### D4 Complete Reference (3000-6000 lines, 10000-20000 tokens)
- Complete API specifications
- Configuration reference
- Error codes
- **Stop**: Rarely needed beyond this

### D5 Historical Context (1500-3000 lines, 5000-10000 tokens)
- Evolution timeline
- Legacy decisions
- Technical debt
- **Stop**: Only when history critical

**See**: <reference title="depth templates" path="references/depth-templates.md" /> for complete templates

## Depth Decision Matrix

| Task Type | Depth | Stop Condition | Tokens |
|-----------|-------|---------------|--------|
| Bug fix (minor) | D0-D1 | Component + entry | ~2K |
| Bug fix (complex) | D1-D2 | Patterns | ~6K |
| Feature (simple) | D1-D2 | Patterns + integration | ~6K |
| Feature (complex) | D2-D3 | Architecture | ~13K |
| Refactoring | D2-D3 | Dependencies | ~13K |
| Performance | D3-D4 | Complete API | ~25K |
| Architecture review | D3-D4 | Full system | ~25K |

## Output Structure

```
docs/
  D0-HUB.md          # 300-400 lines: Quickstart, map, depth guide
  [component]/       # D1 overviews (150-200 lines each)
    D2-[detail].md   # Deep dives (200-300 lines)
```

Complete structure with examples in <reference title="depth templates" path="references/depth-templates.md" />.

## Validation Checklist

Validate complete documentation using <reference title="validation checklists" path="references/validation-checklists.md" />:
✓ Hub ≤400 lines • Depth markers • Stop conditions • Cross-references •
D1 components • Navigation structure • Template compliance • References valid

## Integration with Other Skills

**$ArchitectCoder**: Large codebases → Architect plans → Subagents analyze →
Integration (see <reference title="subagent patterns" path="references/subagent-patterns.md" /> for workflow)

**$DocumentationPDNavigator**: Created docs → Navigator reads hub → Navigates to
optimal depth for task

**$RepositoryAnalysis**: Pre-analysis → Snapshot → Structure extraction →
PD docs generation

## Success Criteria

✓ 30-second hub scan finds components
✓ 2-minute navigation to D1 docs
✓ Stop at first sufficient level
✓ Typical bug fix uses ~2K tokens (D0-D1 only)
✓ Clear progression markers
✓ Agent-friendly navigation

---

**Remember**: PD documentation = read LESS, not more. Build stop conditions into every level.

## Progressive Disclosure

**References** (load only when needed):
<references>
  <reference title="Depth templates" path="references/depth-templates.md" description="Complete D0-D5 templates, structure examples, formatting" />
  <reference title="Subagent patterns" path="references/subagent-patterns.md" description="Large codebase analysis delegation, task breakdown, report integration" />
  <reference title="Validation checklists" path="references/validation-checklists.md" description="D0 hub validation, D1 guide checks, depth compliance verification" />
</references>
