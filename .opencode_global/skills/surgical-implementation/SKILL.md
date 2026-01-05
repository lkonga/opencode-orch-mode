---
name: Surgical Implementation
description: "Precise, verifiable code modifications with read-only analysis, targeted edits, and mandatory verification following strict token budgets"
opencode_tools: "read,write,bash"
triggers: ['$SurgicalImplementation']
trigger_keywords: ['implement', 'code changes', 'modify code', 'surgical edits', 'precise changes']
references: {'Surgical commands': 'references/surgical-commands.md', 'Implementation patterns': 'references/implementation-patterns.md', 'Web research integration': 'references/web-research-integration.md'}
---

# Surgical Implementation Protocol

## Core Principle

You are an **Orchestrator Agent** overseeing implementation of pre-defined coding phases. This workflow keeps your primary context light while delegating all token-heavy coding operations to a specialized **Coder Agent** via `runGLMprompt`.

## Implementation Workflow

### Phase 1: Review Implementation Plan

- Analyze provided `index.md` and linked phase-specific plans
- Understand full scope and sequence
- **Do not begin implementation yet**

### Phase 2: Process Phases Sequentially

For each phase in order:

1. **Dispatch to Coder Agent** via `runGLMprompt` or `runGLMPromptThinking`
2. **Include full phase plan** verbatim (e.g., `phase1_prompt_routing_implementation.md`)
3. **Provide index.md path** for cross-phase context reference
4. **Coder returns** formatted Markdown summary of changes only

## Coder Agent: Surgical Protocol

### Five-Step Process

#### 1. Plan of Attack
- Read phase plan completely
- Use `think` tool to outline approach
- Estimate context budget needed

#### 2. Contextual Analysis (Read-Only)
- Locate targets with `git grep -n`, `rg -n`, or `sg`
- Perform dry-run: `wc -l <file>` before reading
- Read only specific sections with `sed -n 'X,Yp' <file>`

**See**: <reference title="Surgical commands" path="references/surgical-commands.md" description="Git grep, ripgrep, ast-grep command patterns for code discovery" /> for detailed command patterns

#### 3. Surgical Changes
- Use `edit` tool with precise operations (insert/replace/delete)
- Apply only specified changes at identified line numbers
- **Never overwrite entire files**

**See**: <reference title="Implementation patterns" path="references/implementation-patterns.md" description="Step-by-step modification protocols with examples" /> for modification patterns

#### 4. Verification
- Run compile/build task minimum
- Execute tests if specified in plan
- Fix issues before concluding

#### 5. Report Summary
- List files edited and functions modified
- Note tests run and verification results
- Return concise Markdown summary

## Token Constraints

### Context Budget
- **Hard limit**: 21,000 lines
- **Target**: Minimum necessary for task
- **Per-command**: Maximum 200 lines output

### Mandatory Dry-Runs
```bash
# Before reading any file
cat file.ts | wc -l
```

### Command Output Control
```bash
# Limit with head
rg -n "pattern" src/ | head -n 200

# Scope to specific areas
sg -p 'pattern' src/specific-module/
```

## Conditional Web Research

**Only if required** for implementation:
- Use `brave_search`, `context7`, `perplexity_search`
- For API usage, library patterns, error resolution
- Limit research time and token usage

**See**: <reference title="Web research integration" path="references/web-research-integration.md" /> for research workflow

## Related Skills

- **$ArchitectCoder**: Orchestration patterns and subagent delegation
- **$RelentlessWebResearch**: Comprehensive external research needs

## Progressive Disclosure

**References** (load only when needed):
<references>
  <reference title="Surgical commands" path="references/surgical-commands.md" description="Git grep, ripgrep, ast-grep command patterns for code discovery" />
  <reference title="Implementation patterns" path="references/implementation-patterns.md" description="Step-by-step modification protocols with examples" />
  <reference title="Web research integration" path="references/web-research-integration.md" description="Research workflow and integration with surgical edits" />
</references>
