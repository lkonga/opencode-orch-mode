# Skill Creation Workflow

Complete step-by-step process for creating high-quality skills.

## Decision Tree: Choose Your Path

```
Start
  │
  ├─ Fresh PD documentation exists? ────YES──→ Documentation-Driven Approach
  │                                               │
  │                                               ├─ Load documentation via PD Navigator
  │                                               ├─ Extract patterns and workflows
  │                                               └─ Create skill directly
  │
  └─ No documentation? ────────────────NO───→ Auto-Discovery Approach
                                                  │
                                                  ├─ Repository Analysis Skill
                                                  ├─ Pattern extraction
                                                  └─ Create skill with findings
```

## Documentation-Driven Approach

**When to use**: Fresh PD documentation exists for the target domain.

### Step 1: Load Documentation

```bash
# Use Documentation PD Navigator skill
# Load relevant documentation sections progressively
# Example: Loading git workflow docs
cat /docs/git/workflows/*.md
```

### Step 2: Extract Core Patterns

Identify from documentation:
- **Primary workflow**: Main sequence of operations
- **Decision points**: When to branch/choose alternatives
- **Success criteria**: How to verify completion
- **Common pitfalls**: Known failure modes

### Step 3: Create from Template

```bash
# Copy templates
cp templates/skill-template.md SKILL.md
cp templates/reference-template.md references/workflow.md

# Fill placeholders with documentation insights
```

## Auto-Discovery Approach

**When to use**: No documentation exists; learn from codebase/tools.

### Step 1: Repository Analysis

Use Repository Analysis skill to discover:

```bash
# Analyze command patterns
grep -r "function.*(" scripts/ | head -20

# Find configuration files
find . -name "*.config.js" -o -name "*.json"

# Discover workflow scripts
ls -la scripts/*.sh
```

**Extract**:
- Available commands/functions
- Configuration patterns
- Typical usage sequences
- Error handling approaches

### Step 2: Pattern Synthesis

From analysis results, identify:

1. **Core operations**: Most frequently used commands
2. **Dependencies**: What must run before what
3. **Validation steps**: How success is checked
4. **Recovery procedures**: Error handling patterns

### Step 3: Document Findings

Create skill content from discovered patterns:

```markdown
## Quickstart

[Most common usage pattern from analysis]

## Core Principle

[Underlying philosophy extracted from code patterns]

## When to Use

[Situations where discovered patterns apply]
```

## Template Usage Guide

### SKILL.md Template Placeholders

```markdown
---
version: [INCREMENT_VERSION]
last_updated: [YYYY-MM-DD]
applies_to: [DOMAIN_SPECIFICATION]
tokens: [ESTIMATED_TOKENS]
---

# [SKILL_NAME]

[ONE_LINE_DESCRIPTION]

## Quickstart

[COMMON_USAGE_PATTERN]

## Core Principle

[FUNDAMENTAL_CONCEPT]

## When to Use

[APPLICABLE_SCENARIOS]

## Workflow

[STEP_BY_STEP_PROCESS]

## Success Criteria

[VALIDATION_CHECKLIST]

## Progressive Disclosure

**References** (load only when needed):
<references>
  <reference title="[REF_TITLE]" path="references/[REF_FILE].md" description="[5-15 WORD DESCRIPTION]" />
</references>
```

### Reference Template Placeholders

```markdown
# [REFERENCE_TITLE]

[DETAILED_TOPIC_DESCRIPTION]

## [SECTION_1]

[CONTENT_WITH_EXAMPLES]

## [SECTION_2]

[CONTENT_WITH_EXAMPLES]

## Real-World Example

[COMPLETE_SCENARIO_WALKTHROUGH]
```

### Placeholder Replacement Strategy

1. **Version**: Start at `1.0.0`, increment on major changes
2. **Date**: Use ISO format `YYYY-MM-DD`
3. **Applies to**: `"repository-analysis"`, `"git-workflows"`, etc.
4. **Tokens**: Count with `wc -w SKILL.md | awk '{print int($1 * 1.3)}'`
5. **Descriptions**: 5-15 words, action-oriented, specific

**Example**:
```markdown
# Before
<reference title="[REF_TITLE]" path="references/[REF_FILE].md" description="[5-15 WORD DESCRIPTION]" />

# After
<reference title="Validation checklist" path="references/validation.md" description="Comprehensive validation steps and automated checks for skill quality assurance" />
```

## File Organization Patterns

### Standard Skill Structure

```
skill-name/
├── SKILL.md                          # Main skill file (<150 lines)
├── templates/                        # Optional: if skill creates files
│   ├── skill-template.md
│   └── reference-template.md
├── references/                       # Progressive disclosure content
│   ├── workflow.md                   # Step-by-step procedures
│   ├── patterns.md                   # Common patterns and examples
│   └── validation.md                 # Validation and quality checks
└── scripts/                          # Optional: automation scripts
    └── validate-skill.sh
```

### Content Distribution Guidelines

**SKILL.md** (token-efficient, <150 lines):
- Frontmatter metadata
- One-paragraph introduction
- Quickstart example
- Core principle (1-2 paragraphs)
- When to Use (bullet list)
- High-level workflow (numbered steps)
- Success criteria (checklist)
- Progressive Disclosure references

**references/workflow.md** (comprehensive):
- Detailed step-by-step instructions
- Multiple approaches/branches
- Command examples with output
- Troubleshooting steps

**references/patterns.md** (examples):
- Pattern catalog with examples
- Real-world scenarios
- Anti-patterns to avoid

**references/validation.md** (quality assurance):
- Validation checklist
- Automated tests
- Common issues

## Complete Example: Creating "Database Migration" Skill

### Phase 1: Discovery

```bash
# Repository Analysis approach
cd project-repo
find . -name "*migration*" -type f
grep -r "migrate" config/

# Findings:
# - migrations/ folder with timestamped files
# - artisan migrate command
# - database/seeds/ for data
```

### Phase 2: Create SKILL.md

```markdown
---
version: 1.0.0
last_updated: 2025-12-19
applies_to: "laravel-database-workflows"
tokens: 780
---

# Database Migration Management

Safe, reversible database schema changes with Laravel migrations.

## Quickstart

\`\`\`bash
# Create migration
php artisan make:migration create_users_table

# Edit migration file in database/migrations/
# Run migration
php artisan migrate

# Rollback if needed
php artisan migrate:rollback
\`\`\`

## Core Principle

**Version-controlled schema evolution**: Every database change is timestamped, reversible, and tracked in version control. Never modify production databases directly.

## When to Use

- Adding/modifying database tables or columns
- Creating indexes or foreign keys
- Seeding initial/test data
- Rolling back failed deployments

## Workflow

1. **Create migration**: `php artisan make:migration [name]`
2. **Define schema changes**: Edit `up()` and `down()` methods
3. **Review SQL**: `php artisan migrate --pretend`
4. **Test locally**: `php artisan migrate` on dev database
5. **Commit migration file**: Add to version control
6. **Deploy**: Run `php artisan migrate` on production

## Success Criteria

- [ ] Migration file follows naming convention: `YYYY_MM_DD_HHMMSS_description`
- [ ] `up()` and `down()` methods are inverses
- [ ] Migration runs without errors locally
- [ ] `--pretend` shows expected SQL
- [ ] Rollback works: `php artisan migrate:rollback`

## Progressive Disclosure

**References** (load only when needed):
<references>
  <reference title="Migration patterns" path="references/patterns.md" description="Common migration patterns for tables indexes foreign keys with examples" />
  <reference title="Rollback strategies" path="references/rollback.md" description="Safe rollback procedures for failed migrations and data recovery" />
  <reference title="Production safety" path="references/production.md" description="Zero-downtime migration strategies and production deployment checklist" />
</references>
```

### Phase 3: Create References

**references/patterns.md**:
```markdown
# Migration Patterns

## Creating Tables

\`\`\`php
public function up()
{
    Schema::create('users', function (Blueprint $table) {
        $table->id();
        $table->string('email')->unique();
        $table->timestamps();
    });
}

public function down()
{
    Schema::dropIfExists('users');
}
\`\`\`

## Adding Columns

\`\`\`php
public function up()
{
    Schema::table('users', function (Blueprint $table) {
        $table->string('phone')->nullable()->after('email');
    });
}

public function down()
{
    Schema::table('users', function (Blueprint $table) {
        $table->dropColumn('phone');
    });
}
\`\`\`

[Continue with more patterns...]
```

### Phase 4: Validation

```bash
# Line count check
wc -l SKILL.md
# Output: 68 SKILL.md ✓ (under 150)

# Frontmatter validation
head -8 SKILL.md | grep "version:"
# Output: version: 1.0.0 ✓

# Reference files exist
ls references/
# Output: patterns.md rollback.md production.md ✓

# Token count
wc -w SKILL.md | awk '{print int($1 * 1.3)}'
# Output: 780 ✓
```

### Phase 5: Integration

```bash
# Update AGENTS.md
# Add skill to skill registry
# Document in SKILLS.instruction.md
# Create PR with skill
```

## Common Workflow Patterns

### Pattern 1: Command Wrapper Skills

**Use for**: git, docker, kubectl wrappers

```
1. Analyze existing wrapper scripts
2. Extract common command patterns
3. Document safety mechanisms
4. Create workflow with decision tree
5. Add validation for dangerous operations
```

### Pattern 2: Process Management Skills

**Use for**: tmux, screen, background processes

```
1. Define process lifecycle
2. Document state management
3. Create monitoring procedures
4. Add recovery workflows
5. Include cleanup steps
```

### Pattern 3: Analysis Skills

**Use for**: code analysis, documentation generation

```
1. Define analysis scope
2. Document extraction methods
3. Create synthesis procedures
4. Add output formatting
5. Include validation steps
```

## Troubleshooting

### Issue: Skill exceeds 150 lines

**Solution**: Move detailed content to references
```markdown
# Instead of inline detail:
## Workflow
1. Run command X with options --foo --bar --baz
2. Verify output contains "success" message
3. Check logs at /var/log/app.log

# Use reference:
## Workflow
1. Run command <reference title="Commands" path="references/commands.md" description="Complete command reference with options" />
2. Verify output
3. Check logs
```

### Issue: Unclear when to use skill

**Solution**: Add concrete scenarios
```markdown
# Vague
## When to Use
- When working with databases

# Specific
## When to Use
- Adding a new column to users table
- Creating an index for slow queries
- Rolling back a failed deployment
- Seeding test data for local development
```

### Issue: References not loading progressively

**Solution**: Check path and format
```markdown
# Wrong
<reference title="workflow" path="workflow.md" />

# Correct
<reference title="Workflow details" path="references/workflow.md" description="Step-by-step migration workflow with examples and troubleshooting" />
```
