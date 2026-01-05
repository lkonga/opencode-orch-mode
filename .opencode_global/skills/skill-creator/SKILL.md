---
name: 'Skill Creator'
description: 'Creates high-quality agent skills following established patterns with templates, validation, and integration with Repository Analysis and Documentation PD Navigator workflows'
trigger: ['$SkillCreator', 'create skill', 'new skill', 'skill creation', 'build skill']
related_skills: ['$RepositoryAnalysis', '$DocumentationPDNavigator', '$ArchitectCoder', '$SurgicalImplementation']
references: {'Workflow': 'references/workflow.md', 'Patterns': 'references/patterns.md', 'Validation': 'references/validation.md'}
---

# Skill Creator

## Quickstart (5 minutes)

**Purpose**: Create new agent skills following established patterns and conventions.

**Core Workflow**:
1. Gather requirements (from user or codebase analysis)
2. Select appropriate template
3. Populate template with content
4. Create reference files as needed
5. Validate against quality checklist

**Trigger When**:
- User explicitly requests skill creation
- User uses `$SkillCreator` trigger
- Creating new automation or workflow skill

## Core Principle

**Copy don't invent** - Reuse successful patterns from existing skills rather than creating from scratch. Follow the Progressive Disclosure principle: keep main SKILL.md under 150 lines, move detailed content to references/.

## When to Use

- Creating new agent skills for specific workflows
- Documenting complex procedures as reusable skills
- Establishing automation patterns
- After repository analysis reveals common workflows
- After documentation navigation identifies process gaps

## Skill Creation Workflow

### Phase 1: Requirements Gathering (5-10 min)

**Option A: User Provides Requirements**
- Skill name and description
- Core workflow/purpose
- Integration points with other skills
- Key reference materials needed

**Option B: Auto-Discovery from Codebase**
1. Run <reference title="Workflow" path="references/workflow.md" description="Step-by-step skill creation process including auto-discovery patterns" /> if no PD documentation exists
2. Use `$RepositoryAnalysis` to generate codebase snapshot
3. Analyze patterns, identify common workflows
4. Propose skill structure based on findings

**Option C: Documentation-Driven**
1. Use `$DocumentationPDNavigator` to navigate existing docs
2. Identify process gaps or undocumented workflows
3. Extract workflow patterns from documentation
4. Create skill that codifies the process

### Phase 2: Template Selection (1 min)

Choose based on skill complexity:
- **Simple**: Process-oriented, linear workflow → Use `templates/skill-template.md` (basic variant)
- **Complex**: Multi-phase, tool-heavy → Use `templates/skill-template.md` (advanced variant)
- **Meta**: Orchestrator pattern → Study `architect-coder-workflow` structure

### Phase 3: Content Population (10-20 min)

**Use templates** from `templates/` folder:
1. Copy `templates/skill-template.md` to new skill folder
2. Replace all `{{PLACEHOLDERS}}` with actual content
3. Ensure SKILL.md stays under 150 lines
4. Create `references/` folder for detailed content

**Key Sections**:
- **Frontmatter**: name, description, triggers, related skills, references
- **Quickstart**: 30-second overview with core workflow
- **Core Principle**: One-sentence bold principle
- **When to Use**: 3-5 specific conditions
- **Workflow**: 3-5 phase breakdown
- **Progressive Disclosure**: Reference files for details

<reference title="Patterns" path="references/patterns.md" description="Common structural, content, and formatting patterns extracted from successful skills" />

### Phase 4: Reference File Creation (10-30 min)

Create reference files for workflows, commands, integrations, troubleshooting, and advanced patterns. Use `templates/reference-template.md` as starting point.

### Phase 5: Validation (5 min)

**Run quality checks**:
- [ ] SKILL.md under 150 lines?
- [ ] Frontmatter valid YAML?
- [ ] All references exist in `references/` folder?
- [ ] Progressive Disclosure section properly formatted?
- [ ] Examples concrete and actionable?
- [ ] Integration points clearly documented?

<reference title="Validation" path="references/validation.md" description="Comprehensive quality checklist with automated validation commands" />

## Integration Examples

**With Repository Analysis**:
```bash
# Analyze codebase first
$RepositoryAnalysis --output /tmp/repo-analysis.md

# Create skill based on findings
$SkillCreator --from-analysis /tmp/repo-analysis.md
```

**With Documentation Navigator**:
```bash
# Navigate docs to understand context
$DocumentationPDNavigator --task "deployment workflow"

# Create skill that codifies the workflow
$SkillCreator --from-docs --name "Deployment Automation"
```

**With Architect-Coder**:
```bash
# Use for complex skill implementation
$ArchitectCoder --task "create skill for database migration workflow"
```

## Success Criteria

- [ ] Skill follows established patterns from existing skills
- [ ] SKILL.md is concise (<150 lines) and scannable
- [ ] Reference files provide depth without bloating main file
- [ ] Examples are concrete and immediately actionable
- [ ] Integration with related skills is documented
- [ ] Validation checklist passes all checks

## Progressive Disclosure

**References** (load only when needed):
<references>
  <reference title="Workflow" path="references/workflow.md" description="Step-by-step skill creation process with auto-discovery and documentation-driven approaches" />
  <reference title="Patterns" path="references/patterns.md" description="Structural, content, and formatting patterns from successful existing skills" />
  <reference title="Validation" path="references/validation.md" description="Quality checklist and automated validation commands for skill verification" />
</references>
