# Skill Creation Patterns

Common patterns extracted from high-quality skills for consistent, effective skill creation.

## Structural Patterns

### Pattern 1: Token-Efficient Main File

**Principle**: SKILL.md under 150 lines, comprehensive content in references.

**Good Example** (surgical-implementation):
```markdown
# Surgical Implementation

Precise, minimal-change code modifications using advanced tooling.

## Quickstart

\`\`\`bash
# Find exact match
rg "functionName" --type ts

# Make surgical change
sg --pattern 'old code' --rewrite 'new code' path/to/file.ts
\`\`\`

## Workflow

1. **Locate precisely** with ripgrep
2. **Plan minimal change**
3. **Apply with ast-grep** for safety
4. **Verify** with tests

## Progressive Disclosure

<references>
  <reference title="Surgical commands" path="references/surgical-commands.md" description="Complete ripgrep and ast-grep command reference with advanced patterns" />
</references>
```

**Why it works**:
- 42 lines total in SKILL.md
- Immediate value in Quickstart
- Clear workflow without bloat
- Detailed commands in references

**Anti-pattern**:
```markdown
# Don't inline everything
## Workflow

1. Use ripgrep to search:
   - Option -A for after context
   - Option -B for before context
   - Option -C for both
   - Use --type to filter by file type
   - Available types: ts, js, py, rb, etc.
   [... 50 more lines of options ...]
```

### Pattern 2: Progressive Disclosure Structure

**Principle**: Main content inline, deep dives in references.

**Good Example** (tmux-protected-execution):
```markdown
## Core Principle

**Terminal persistence + crash recovery**: Long-running commands survive disconnects through tmux sessions with automatic logging and error capture.

[Main content here - principles, when to use, basic workflow]

## Progressive Disclosure

**References** (load only when needed):
<references>
  <reference title="Recovery procedures" path="references/recovery.md" description="Step-by-step recovery from crashes failures and disconnections with examples" />
  <reference title="Session management" path="references/sessions.md" description="Tmux session creation attachment management and cleanup workflows" />
</references>
```

**Reference distribution**:
- **SKILL.md**: What, Why, When (principles)
- **references/**: How (detailed procedures)

**Anti-pattern**:
```markdown
# Don't create reference stubs
## Progressive Disclosure

<references>
  <reference title="Info" path="references/info.md" description="More information" />
  <reference title="Details" path="references/details.md" description="Additional details" />
</references>

# References contain:
# references/info.md: "See main file"
# references/details.md: "TBD"
```

### Pattern 3: Frontmatter Metadata

**Standard format**:
```yaml
---
version: 1.0.0          # Semantic versioning
last_updated: 2025-12-19 # ISO date format
applies_to: "domain"    # Quoted string, kebab-case
tokens: 850             # Estimated tokens (words * 1.3)
---
```

**Good Examples**:

```yaml
# Specific domain
---
version: 2.1.0
last_updated: 2025-12-15
applies_to: "laravel-testing-workflows"
tokens: 1240
---

# Multiple domains
---
version: 1.0.0
last_updated: 2025-12-19
applies_to: "git-workflows,code-analysis"
tokens: 680
---

# Framework-agnostic
---
version: 1.3.0
last_updated: 2025-12-10
applies_to: "documentation-navigation"
tokens: 920
---
```

**Anti-pattern**:
```yaml
# Vague or missing metadata
---
version: 1
last_updated: Dec 2025
applies_to: everything
tokens: ?
---

# Or missing entirely (breaks tooling)
# Skill Creation
```

## Content Patterns

### Pattern 4: Quickstart Section

**Principle**: Show most common usage immediately.

**Good Example** (documentation-pd-navigator):
```markdown
## Quickstart

\`\`\`bash
# Load PD documentation progressively
cat docs/architecture/INDEX.md  # Start with index
# Read referenced sections only as needed
cat docs/architecture/authentication.md  # Load on-demand
\`\`\`

**Result**: Minimal token usage, load only what's needed for current task.
```

**Elements**:
- Concrete command/code
- Expected outcome
- Common use case

**Anti-pattern**:
```markdown
## Quickstart

To get started, first familiarize yourself with the documentation structure. Then, depending on your needs, you might want to consider various approaches. See the workflow section for details.

# Problems:
# - No concrete example
# - No code/commands
# - Requires reading more sections
```

### Pattern 5: Core Principle Section

**Principle**: One fundamental concept, 1-2 paragraphs max.

**Good Examples**:

**Surgical Implementation**:
```markdown
## Core Principle

**Precision over scope**: Make the smallest possible change that achieves the goal. Use AST-aware tools (ast-grep) for structural changes to avoid regex pitfalls. Always verify the exact location before editing.
```

**Tmux Protected Execution**:
```markdown
## Core Principle

**Terminal persistence + crash recovery**: Long-running commands survive disconnects through tmux sessions with automatic logging and error capture. All output is preserved for post-mortem analysis.
```

**Pattern**:
- Bold key concept
- One-sentence essence
- One-sentence elaboration or implication

**Anti-pattern**:
```markdown
## Core Principle

This skill is about creating things. Creating things is important. There are many ways to create things. Some ways are better than others. The best way depends on context. Consider your requirements carefully. Always validate your approach. Testing is important. Documentation helps too.

# Problems:
# - No clear core concept
# - Multiple vague statements
# - No actionable insight
```

### Pattern 6: When to Use Section

**Principle**: Specific scenarios, not generic statements.

**Good Example** (surgical-implementation):
```markdown
## When to Use

- **Exact match required**: Changing specific function signature across files
- **Structural changes**: Renaming class properties in TypeScript/PHP
- **Avoid side effects**: Regex would match unintended code
- **Large codebase**: Need fast, accurate search before editing
- **Safety critical**: Changes must not break syntax
```

**Pattern**:
- Bold scenario type
- Colon separator
- Concrete example/context
- 5-8 specific scenarios

**Anti-pattern**:
```markdown
## When to Use

- When you need to work with code
- When editing files
- When making changes
- Anytime you want to improve code
- For development tasks

# Problems:
# - Too generic
# - Applies to everything
# - No guidance on specificity
```

### Pattern 7: Workflow Section

**Principle**: Numbered steps with clear outcomes.

**Good Example** (skill-creator):
```markdown
## Workflow

1. **Discovery**: Repository Analysis (no docs) or PD Navigator (has docs)
2. **Extract patterns**: Identify core operations, workflows, success criteria
3. **Create from template**: Fill SKILL.md with <150 lines, key content
4. **Add references**: Create workflow.md, patterns.md, validation.md
5. **Validate**: Line count, frontmatter, references exist, descriptions 5-15 words
6. **Integrate**: Update AGENTS.md, commit, create PR

**Result**: Complete, validated skill ready for use.
```

**Pattern**:
- Number each step
- Bold action verb
- Brief description
- Optional substeps if needed
- End with outcome statement

**Anti-pattern**:
```markdown
## Workflow

First, you'll want to think about what you're doing. Then, consider the various approaches. Next, implement something. After that, check if it works. Finally, finish up and move on.

# Problems:
# - Vague actions
# - No concrete steps
# - No validation criteria
# - No clear outcome
```

### Pattern 8: Success Criteria Section

**Principle**: Checkable items, objective validation.

**Good Example** (skill-creator):
```markdown
## Success Criteria

- [ ] SKILL.md exists and is under 150 lines
- [ ] Valid frontmatter with version, date, applies_to, tokens
- [ ] All referenced files exist in references/ folder
- [ ] Reference descriptions are 5-15 words, action-oriented
- [ ] Quickstart section shows concrete usage
- [ ] Workflow is numbered with clear steps
- [ ] Integrated into AGENTS.md skill registry
```

**Pattern**:
- Checkbox format `- [ ]`
- Specific metric or file
- Objective (can answer yes/no)
- 5-10 criteria

**Anti-pattern**:
```markdown
## Success Criteria

- Code quality is good
- Documentation is adequate
- Tests pass mostly
- Users are satisfied
- No major issues

# Problems:
# - Subjective criteria
# - No specific metrics
# - Cannot objectively verify
```

## Formatting Patterns

### Pattern 9: Code Block Formatting

**Principle**: Language-specific syntax highlighting, context comments.

**Good Examples**:

**Bash commands**:
```markdown
\`\`\`bash
# Search for pattern in TypeScript files
rg "functionName" --type ts -A 3 -B 3

# Apply surgical change with ast-grep
sg --pattern 'const $VAR = $VALUE' --rewrite 'let $VAR = $VALUE' src/
\`\`\`
```

**Configuration**:
```markdown
\`\`\`yaml
---
version: 1.0.0
last_updated: 2025-12-19
applies_to: "skill-domain"
tokens: 850
---
\`\`\`
```

**Code with output**:
```markdown
\`\`\`bash
wc -l SKILL.md
# Output: 142 SKILL.md ✓
\`\`\`
```

**Pattern**:
- Always specify language after triple backticks
- Add context comments inline
- Show expected output when helpful
- Use real, tested examples

**Anti-pattern**:
```markdown
\`\`\`
some command here
maybe this works?
try it and see
\`\`\`

# Problems:
# - No language specification
# - No syntax highlighting
# - Vague comments
# - Uncertain example
```

### Pattern 10: Reference Tag Formatting

**Inline Reference** (used within content):
```markdown
Apply changes using <reference title="Surgical commands" path="references/surgical-commands.md" description="Ripgrep and ast-grep patterns for safe code modifications" /> for safety.
```

**Progressive Disclosure Reference** (section at end):
```markdown
## Progressive Disclosure

**References** (load only when needed):
<references>
  <reference title="Workflow details" path="references/workflow.md" description="Complete step-by-step procedures with decision trees and examples" />
  <reference title="Pattern catalog" path="references/patterns.md" description="Common skill creation patterns extracted from high-quality skills" />
  <reference title="Validation guide" path="references/validation.md" description="Automated and manual validation checks for skill quality" />
</references>
```

**Formatting rules**:
- **Title**: 2-5 words, capitalize main words
- **Path**: Always `references/filename.md`
- **Description**: 5-15 words, action-oriented, specific
- **Inline**: Single `<reference />` tag
- **PD**: Wrapped in `<references>` block, one per line

**Anti-pattern**:
```markdown
# Wrong: No description
<reference title="Commands" path="references/commands.md" />

# Wrong: Too vague
<reference title="Info" path="references/info.md" description="More information" />

# Wrong: Too long
<reference title="Details" path="references/details.md" description="This reference contains comprehensive detailed information about every single aspect of the workflow including all possible edge cases and troubleshooting steps" />

# Wrong: Wrong path
<reference title="Guide" path="guide.md" description="Usage guide" />
```

### Pattern 11: Decision Trees

**Principle**: Visual branching logic for workflow decisions.

**Good Example**:
```markdown
## Decision Tree: Choose Your Path

\`\`\`
Start
  │
  ├─ Fresh PD documentation exists? ────YES──→ Documentation-Driven
  │                                               │
  │                                               └─ Load docs → Extract → Create
  │
  └─ No documentation? ────────────────NO───→ Auto-Discovery
                                                  │
                                                  └─ Analyze repo → Patterns → Create
\`\`\`
```

**Pattern**:
- ASCII art for clarity
- Clear decision points with YES/NO
- Branch outcomes on same line
- Indentation shows hierarchy
- Terminal outcomes clearly marked

**Anti-pattern**:
```markdown
# Wrong: No visual structure
If you have docs, use them. If not, analyze the code. Then create the skill.

# Wrong: Unclear branches
Start -> Docs? -> Maybe -> Do something -> End
```

## Reference Patterns

### Pattern 12: Reference Content Structure

**Principle**: Comprehensive, example-driven, cross-referenced.

**Good Example** (workflow.md structure):
```markdown
# [Topic]

Brief introduction (1 paragraph)

## [Primary Section]

Detailed explanation with examples

\`\`\`bash
# Concrete command
command --option value
\`\`\`

**Result**: What to expect

## [Secondary Section]

Related content

## Real-World Example

Complete scenario walkthrough from start to finish

## Troubleshooting

Common issues with solutions
```

**Pattern**:
- Start with brief intro
- Section per major topic
- Include code/command examples
- End with complete real-world example
- Add troubleshooting section

**Anti-pattern**:
```markdown
# Topic

Some information here.

More stuff.

The end.

# Problems:
# - No structure
# - No examples
# - No practical guidance
```

### Pattern 13: Cross-Referencing

**Principle**: Link related content without duplication.

**Good Example**:
```markdown
## Validation

For complete validation workflow, see <reference title="Validation guide" path="references/validation.md" description="Automated validation checks and quality criteria" />.

Quick checks:
- Line count under 150
- Valid frontmatter
- References exist
```

**Pattern**:
- Inline reference to detailed content
- Brief summary of key points
- Reader can dive deep if needed

**Anti-pattern**:
```markdown
# Wrong: Full duplication
## Validation

[Copies entire validation.md content here]

# Wrong: No context
## Validation

See validation.md for details.

# Wrong: Broken reference
See the validation guide (link TBD)
```

### Pattern 14: Example Quality

**Principle**: Real, tested, complete examples.

**Good Example**:
```markdown
## Creating a Git Workflow Skill

### Step 1: Discovery

\`\`\`bash
cd project-repo
git log --oneline --graph -10
cat .git/config
\`\`\`

**Findings**:
- Uses feature branch workflow
- Squash merges to main
- Semantic commit messages

### Step 2: Create SKILL.md

\`\`\`markdown
---
version: 1.0.0
last_updated: 2025-12-19
applies_to: "git-workflows"
tokens: 720
---

# Git Feature Branch Workflow

[Complete example...]
\`\`\`

### Step 3: Validate

\`\`\`bash
wc -l SKILL.md
# Output: 118 SKILL.md ✓

grep "version:" SKILL.md
# Output: version: 1.0.0 ✓
\`\`\`
```

**Pattern**:
- Complete scenario
- Real commands that work
- Show actual output
- Walk through all steps
- Verify at the end

**Anti-pattern**:
```markdown
## Example

1. Do something
2. Do another thing
3. It works

# Problems:
# - No concrete commands
# - No code/output
# - No verification
# - Too generic
```

## Common Anti-Patterns

### Anti-Pattern 1: The Mega-File

**Problem**: Everything in SKILL.md, no references.

```markdown
# SKILL.md (450 lines)

## Workflow

[100 lines of detailed steps]

## Commands

[150 lines of command reference]

## Patterns

[100 lines of patterns]

## Examples

[100 lines of examples]
```

**Fix**: Extract to references
```markdown
# SKILL.md (140 lines)

## Workflow

1. Discover patterns
2. Extract core operations
[Brief overview]

## Progressive Disclosure

<references>
  <reference title="Detailed workflow" path="references/workflow.md" />
  <reference title="Command reference" path="references/commands.md" />
  <reference title="Pattern catalog" path="references/patterns.md" />
</references>
```

### Anti-Pattern 2: The Stub

**Problem**: Main file is complete, references are empty.

```markdown
# SKILL.md
[Complete, good content]

# references/workflow.md
# Workflow
TBD

# references/patterns.md
# Patterns
Coming soon
```

**Fix**: Comprehensive references
```markdown
# references/workflow.md (150+ lines)
# Workflow

Complete step-by-step procedures with examples...

# references/patterns.md (200+ lines)
# Patterns

Extensive pattern catalog with real examples...
```

### Anti-Pattern 3: The Generic

**Problem**: Could apply to anything.

```markdown
# Code Management Skill

## When to Use
- When working with code
- When you need to make changes
- For development work

## Workflow
1. Plan your changes
2. Make the changes
3. Test the changes
4. Deploy the changes
```

**Fix**: Be specific
```markdown
# Laravel Migration Management

## When to Use
- Adding columns to existing tables
- Creating database indexes for performance
- Rolling back failed schema changes
- Seeding test data in development

## Workflow
1. Create migration: `php artisan make:migration add_phone_to_users`
2. Edit up()/down() methods
3. Test locally: `php artisan migrate`
4. Verify rollback: `php artisan migrate:rollback`
5. Deploy: Run migration on staging then production
```

### Anti-Pattern 4: The Novel

**Problem**: References are too long, unfocused.

```markdown
# references/everything.md (2000 lines)

Contains history, philosophy, every edge case, unrelated topics, extended discussions...
```

**Fix**: Split focused references
```markdown
# references/workflow.md (150 lines)
Core procedures

# references/patterns.md (180 lines)
Common patterns

# references/advanced.md (120 lines)
Advanced topics

# references/troubleshooting.md (100 lines)
Common issues
```

### Anti-Pattern 5: The Mystery

**Problem**: Unclear what skill does or when to use it.

```markdown
# Helper Skill

This skill helps with tasks.

## Usage
Use this skill when you need help.
```

**Fix**: Clear purpose and scope
```markdown
# Database Migration Management

Safe, reversible database schema changes with Laravel migrations.

## When to Use
- Adding columns to users table for new feature
- Creating index on orders.created_at for dashboard query
- Rolling back failed deployment that broke schema
- Seeding product catalog for local testing
```

## Pattern Checklist

Use when creating any skill:

**Structure**:
- [ ] SKILL.md under 150 lines
- [ ] Valid frontmatter with all fields
- [ ] Progressive Disclosure section at end
- [ ] 3-5 reference files with substantial content

**Content**:
- [ ] Quickstart with concrete example
- [ ] Core Principle in 1-2 paragraphs
- [ ] When to Use with 5-8 specific scenarios
- [ ] Workflow with numbered steps
- [ ] Success Criteria with checkable items

**Formatting**:
- [ ] Code blocks specify language
- [ ] References have 5-15 word descriptions
- [ ] Examples are real and tested
- [ ] Headers use sentence case

**Quality**:
- [ ] No generic statements
- [ ] No empty references
- [ ] No duplicated content
- [ ] Cross-references are accurate
