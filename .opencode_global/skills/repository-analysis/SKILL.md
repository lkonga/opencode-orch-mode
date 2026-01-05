---
name: 'Repository Analysis'
description: 'Generate comprehensive codebase analysis using repomix with selective inclusion and targeted exclusions for Laravel projects'
trigger: ['$RepositoryAnalysis', '$Repomix', 'analyze codebase', 'generate project analysis', 'repomix analysis', 'codebase snapshot']
references: {'Command variations': 'references/command-variations.md', 'Troubleshooting': 'references/troubleshooting.md', 'Output formats': 'references/output-formats.md'}
related_skills: ['$DocumentationPDNavigator', '$CreatePDDocs']
---

# Repository Analysis

## Quickstart (15 seconds)

**Purpose**: Generate token-efficient codebase snapshots using `repomix` with selective inclusion—focus on core code, exclude noise.

**Core Command** (Laravel):
```bash
repomix --compress \
  --include "app/**,config/**,database/**,resources/**,routes/**,tests/" \
  -i "docs/**,public/**,storage/**,*.log,*.cache,*.lock,*.env*" \
  --style xml \
  -o project-analysis-$(date +"%Y-%m-%d-%H%M").xml
```

**When to Use**:
- Capture current state for documentation
- Prepare handoff context
- Pre-refactoring snapshot
- User mentions `$Repomix` or `$RepositoryAnalysis`

## Core Principle

**Selective precision over bulk capture**: Include only application code, exclude dependencies, generated files, and runtime artifacts.

**Balance**:
- Comprehensiveness: All core application logic
- Token efficiency: No vendor/, node_modules/, logs

## Phase 1: Preparation (30 seconds)

**Step 1**: Navigate to project root
```bash
cd /path/to/project
```

**Step 2**: Verify repomix available
```bash
which repomix || npm install -g repomix
```

**Step 3**: Identify project type
```bash
ls -la | grep -E "artisan|composer.json"  # Laravel check
```

## Phase 2: Command Customization (1 minute)

**Selective Inclusion** (`--include`):
Include essential directories: `app/`, `resources/`, `config/`, `routes/`, `database/migrations/`.
Skip `tests/`, `public/build/`, `node_modules/`.

**Targeted Exclusions** (`-i`):
Common patterns: `vendor/`, `*.log`, `storage/logs/`, `.git/`, `.env*`, `public/build/`.
Laravel: `bootstrap/cache/`, `node_modules/`, `.phpunit.result.cache`.

**Output Options**:
- Compression: `-c` (5-20x reduction, slower)
- Style: `-s xml` (better parsing) or `plain` (human-readable)
- Output: `-o output-laravel.xml` (descriptive naming)

**See** <reference title="Command variations" path="references/command-variations.md" description="Laravel, Node.js, Python project commands, recipes, integration patterns" /> for project-specific patterns.

## Phase 3: Execution (10-60 seconds)

Run customized command from Phase 2. Monitor token estimates in output.

**Verify**: Check output file exists, reasonable size (500KB-10MB typical).

## Phase 4: Validation (1 minute)

```bash
wc -l output-laravel.xml && du -h output-laravel.xml
```

**Expected**: 1K-50K lines, 500KB-10MB. If >50MB, add exclusions.
See <reference title="Troubleshooting" path="references/troubleshooting.md" description="Size issues, path errors, format problems, optimization strategies" /> for size optimization.

## Command Variations

See <reference title="Command variations" path="references/command-variations.md" /> for:
- All project-type specific commands
- Advanced patterns and recipes
- Output format variations

## Integration with Other Skills

**Before Creating PD Docs**: `$RepositoryAnalysis` → analyze → `$CreatePDDocs` with snapshot
**Large Codebases**: `$RepositoryAnalysis` → snapshot → `$ArchitectCoder` reads output
**Documentation Discovery**: `$DocumentationPDNavigator` uses repomix output for structure

See <reference title="Command variations" path="references/command-variations.md" /> for integration patterns.

## Output Format

Default: XML with nested structure. See <reference title="Output formats" path="references/output-formats.md" /> for format specs.

**Quick validation**: `head -50 output-laravel.xml` shows header and first files.

## Best Practices

**Do's**: Run from root, timestamp files, verify size, include only relevant dirs
**Don'ts**: Include vendor/node_modules/logs, skip compression, use generic names

See <reference title="Command variations" path="references/command-variations.md" /> for detailed patterns.

## Troubleshooting

For all error scenarios and solutions, see <reference title="Troubleshooting" path="references/troubleshooting.md" />:
- Size issues, path problems, format errors
- Missing dependencies, permission errors
- Performance optimization

## Success Criteria

✓ Analysis file generated successfully
✓ Size reasonable (< 50MB)
✓ Includes core directories
✓ Excludes noise (logs, caches, deps)
✓ Timestamped filename
✓ Valid XML format
✓ Suitable for AI context/documentation

---

**Remember**: Repository analysis = **selective precision**. Include only what's needed, exclude everything else.

## Progressive Disclosure

**References** (load only when needed):
<references>
  <reference title="Command variations" path="references/command-variations.md" description="Laravel, Node.js, Python project commands, recipes, integration patterns" />
  <reference title="Troubleshooting" path="references/troubleshooting.md" description="Size issues, path errors, format problems, optimization strategies" />
  <reference title="Output formats" path="references/output-formats.md" description="XML format specs, parsing examples, structure documentation" />
</references>
