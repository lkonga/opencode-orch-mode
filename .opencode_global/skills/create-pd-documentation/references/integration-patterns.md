# Skill Integration Patterns for Documentation & Analysis Group

## Overview

The Documentation & Analysis skills work together as a cohesive workflow for codebase understanding and documentation management. This reference describes how to coordinate these skills effectively.

## Core Workflow Pattern

```
Repository Analysis → Create PD Documentation → Documentation PD Navigator
        ↓                       ↓                           ↓
  Capture State             Build Structure            Navigate Efficiently
```

### Detailed Flow

1. **Repository Analysis** captures the current state of codebase
2. **Create PD Documentation** transforms analysis into structured PD docs
3. **Documentation PD Navigator** enables efficient navigation of created docs

### When to Use Each Skill

**Use Repository Analysis when**:
- Need current codebase snapshot
- Preparing for documentation generation
- Creating handoff context
- Before major refactoring
- Validating documentation completeness

**Use Create PD Documentation when**:
- Generating documentation structure
- Building from repository analysis
- Creating hub and depth levels
- Establishing navigation framework

**Use Documentation PD Navigator when**:
- Navigating existing PD documentation
- Finding relevant docs for a task
- Understanding component relationships
- Surgical information extraction

## Integration Pattern 1: Full Documentation Generation

**Scenario**: Creating documentation from scratch for an existing codebase

**Workflow**:
```
1. Trigger: $RepositoryAnalysis
   → Generate comprehensive codebase snapshot
   → Output: project-analysis-YYYY-MM-DD-HHMM.xml

2. Trigger: $CreatePDDocs (with analysis as input)
   → Use Architect-Coder delegation for massive codebases
   → Build D0 hub from analysis
   → Create D1 entry points
   → Develop D2-D5 specialized docs

3. Validate: $DocumentationPDNavigator
   → Navigate created documentation
   → Verify depth progression works
   → Test stop conditions
```

**Example**:
```
User: "Create comprehensive PD documentation for PSP-Landing project"

Agent:
1. Activates $RepositoryAnalysis
   → Runs optimized repomix command
   → Generates: psp-landing-analysis-2025-12-18-1430.xml

2. Activates $CreatePDDocs
   → Reads analysis file
   → Uses $ArchitectCoder for large codebase
     - Architect: Plans documentation structure
     - Coder subagents: Analyze subsystems
     - Architect: Integrates into PD docs
   → Creates DOCUMENTATION-HUB.md [D0]
   → Creates component guides [D1]
   → Creates implementation guides [D2]

3. Activates $DocumentationPDNavigator
   → Tests navigation from hub
   → Verifies depth progression
   → Validates stop conditions
```

## Integration Pattern 2: Documentation Validation

**Scenario**: Verifying documentation completeness against codebase

**Workflow**:
```
1. Trigger: $DocumentationPDNavigator
   → Navigate existing documentation
   → Identify documented components

2. Trigger: $RepositoryAnalysis
   → Capture current codebase state
   → Compare with documented components

3. Gap Analysis:
   → Components in code but not documented
   → Documented components no longer in code
   → Documentation depth mismatches

4. Update: $CreatePDDocs (for gaps)
   → Generate missing documentation
   → Update outdated docs
```

**Example**:
```
User: "Verify documentation is complete and up-to-date"

Agent:
1. Activates $DocumentationPDNavigator
   → Reads DOCUMENTATION-HUB.md
   → Lists documented components:
     - Component-A [D1-D3]
     - Component-B [D1-D2]

2. Activates $RepositoryAnalysis
   → Generates current snapshot
   → Finds components in code:
     - Component-A (exists, matches docs)
     - Component-B (exists, matches docs)
     - Component-C (NEW, not documented)

3. Gap Analysis:
   → Component-C needs documentation

4. Activates $CreatePDDocs
   → Generate docs for Component-C [D1-D2]
   → Update hub to reference Component-C
```

## Integration Pattern 3: Task-Specific Documentation Navigation

**Scenario**: Using documentation to complete a specific task

**Workflow**:
```
1. Trigger: $DocumentationPDNavigator
   → Navigate to relevant component [D0→D1]
   → Read at appropriate depth based on task
   → Stop at first sufficient level

2. Optional: $RepositoryAnalysis (if docs insufficient)
   → Generate targeted analysis for component
   → Supplement documentation with current code state

3. Optional: $CreatePDDocs (if major gaps found)
   → Generate missing documentation sections
   → Update to appropriate depth level
```

**Example**:
```
User: "Fix JWT validation bug in authentication system"

Agent:
1. Activates $DocumentationPDNavigator
   → Reads DOCUMENTATION-HUB.md [D0] (30s)
   → Locates: Component-A (Auth) → AUTH-GUIDE.md [D1-D3]
   → Reads AUTH-GUIDE.md [D1] (3 min)
   → Finds: JWT validation entry point: src/auth/JWTService.ts
   → STOPS at D1 (sufficient for bug fix)

Result: Ready to fix bug (Total: 3.5 min, 2,300 tokens)

Alternative (if docs insufficient):
2. Activates $RepositoryAnalysis
   → Targets authentication component only
   → Generates: auth-component-analysis.xml

3. Uses analysis to supplement documentation
```

## Integration Pattern 4: Architect-Coder Delegation

**Scenario**: Massive codebase requiring documentation (50+ components)

**Workflow**:
```
1. Trigger: $CreatePDDocs
   → Recognizes massive codebase scale

2. Activates $ArchitectCoder workflow:

   Architect Phase (lightweight):
   → Surveys project structure
   → Identifies major subsystems
   → Creates analysis task breakdown
   → Plans documentation structure

   Coder Phase (via run_glm_prompt_thinking):
   → Subagent 1: Analyzes Component Group A
   → Subagent 2: Analyzes Component Group B
   → Subagent 3: Analyzes Component Group C
   → Each returns structured findings

   Integration Phase:
   → Architect integrates findings
   → Builds cohesive PD documentation
   → Maintains consistency across depths

3. Optional: $RepositoryAnalysis (for baseline)
   → Provides initial snapshot for subagents
   → Serves as reference for completeness
```

**Example**:
```
User: "Create PD documentation for PSP-P2P (large Laravel project)"

Agent:
1. Activates $CreatePDDocs
   → Detects large codebase (50+ major components)
   → Triggers $ArchitectCoder workflow

2. Architect Phase:
   → Surveys project: Payment, Auth, Merchant, API layers
   → Plans delegation:
     - Subagent 1: Payment subsystem
     - Subagent 2: Authentication subsystem
     - Subagent 3: Merchant subsystem
     - Subagent 4: API layer

3. Optionally runs $RepositoryAnalysis first:
   → Generates: psp-p2p-baseline-analysis.xml
   → Provides to subagents as reference

4. Coder Phase:
   Each subagent (via run_glm_prompt_thinking):
   → Input: Component path + baseline analysis
   → Analyzes subsystem at specified depth
   → Returns: Structured findings (D1-D3)

5. Integration Phase:
   → Architect creates DOCUMENTATION-HUB.md [D0]
   → Integrates subagent findings into:
     - PAYMENT-GUIDE.md [D1], PAYMENT-IMPL.md [D2]
     - AUTH-GUIDE.md [D1], AUTH-IMPL.md [D2]
     - MERCHANT-GUIDE.md [D1], MERCHANT-IMPL.md [D2]
     - API-GUIDE.md [D1], API-IMPL.md [D2]
```

## Integration Pattern 5: Incremental Documentation Updates

**Scenario**: Updating documentation after code changes

**Workflow**:
```
1. Code change completed

2. Trigger: $RepositoryAnalysis (targeted)
   → Analyze only changed component
   → Generate component-specific snapshot

3. Trigger: $DocumentationPDNavigator
   → Locate existing documentation for component
   → Identify depth levels that need updates

4. Trigger: $CreatePDDocs (update mode)
   → Update affected documentation sections
   → Maintain PD structure and depth levels
   → Update cross-references if needed

5. Validate:
   → Verify stop conditions still work
   → Check cross-references are current
```

**Example**:
```
User: "Added OAuth2 support to authentication, update docs"

Agent:
1. Activates $RepositoryAnalysis (targeted)
   → Runs: repomix --include "app/Auth/**,config/auth.php"
   → Generates: auth-oauth2-update-2025-12-18.xml

2. Activates $DocumentationPDNavigator
   → Locates: AUTH-GUIDE.md [D1], AUTH-IMPL.md [D2]
   → Identifies sections to update:
     - D1: Add OAuth2 to authentication methods
     - D2: Add OAuth2 implementation patterns

3. Activates $CreatePDDocs (update mode)
   → Updates AUTH-GUIDE.md [D1]:
     - Add OAuth2 to "What" section
     - Add OAuth2 entry point to Quick Reference
   → Updates AUTH-IMPL.md [D2]:
     - Add OAuth2 implementation pattern
     - Add OAuth2 integration example

4. Validates:
   → Tests navigation from hub to updated docs
   → Verifies stop conditions still appropriate
```

## Input/Output Relationships

### Repository Analysis Outputs

**Primary Output**: XML analysis file
- Timestamped filename
- Compressed format
- Selective inclusion/exclusion
- Structured for AI consumption

**Consumers**:
- Create PD Documentation (as baseline input)
- Documentation PD Navigator (for validation)
- Other agents (for context)

### Create PD Documentation Outputs

**Primary Outputs**:
- DOCUMENTATION-HUB.md [D0] (hub entry)
- Component guides [D1] (quick start)
- Implementation guides [D2] (patterns)
- Architecture docs [D3] (design)
- Reference docs [D4] (complete specs)
- Historical docs [D5] (evolution)

**Consumers**:
- Documentation PD Navigator (for navigation)
- All agents working with codebase
- Human developers

### Documentation PD Navigator Outputs

**Primary Output**: Navigational guidance
- Component location
- Relevant documentation paths
- Optimal depth for task
- Extracted key information

**Consumers**:
- Task execution agents
- Implementation skills
- Human developers

## Context Handoff Patterns

### Pattern 1: Analysis → Documentation Generation

**Context Passed**:
```
From Repository Analysis:
- Analysis file path
- Scope of analysis (included paths)
- Exclusions applied
- File count and size

To Create PD Documentation:
- Use analysis as baseline
- Extract component structure
- Map to D0-D5 depth levels
- Generate progressive docs
```

### Pattern 2: Documentation Generation → Navigation

**Context Passed**:
```
From Create PD Documentation:
- Hub location (DOCUMENTATION-HUB.md path)
- Depth structure (D0-D5 paths)
- Component organization
- Cross-reference map

To Documentation PD Navigator:
- Navigate from hub
- Follow depth progression
- Use stop conditions
- Extract task-specific info
```

### Pattern 3: Navigation → Analysis (Validation)

**Context Passed**:
```
From Documentation PD Navigator:
- Documented components list
- Coverage gaps identified
- Depth level completeness

To Repository Analysis:
- Target specific components for analysis
- Validate against current code
- Identify documentation needs
```

## When to Combine Skills

### Always Combine

**Repository Analysis + Create PD Documentation**:
- Fresh documentation generation
- Complete documentation system
- Baseline establishment

### Frequently Combine

**Documentation PD Navigator + Repository Analysis**:
- Documentation validation
- Gap identification
- Completeness verification

### Occasionally Combine

**All Three Skills**:
- Complete documentation lifecycle
- Full validation workflow
- Major documentation overhaul

### Rarely Combine

**Documentation PD Navigator alone**:
- Documentation already exists and is current
- Task requires only navigation
- Simple information lookup

## Success Metrics

### Efficient Skill Coordination

✓ Minimal context passed between skills
✓ Clear input/output boundaries
✓ No redundant work across skills
✓ Appropriate skill triggered for task

### Effective Documentation Workflow

✓ Analysis captures relevant state
✓ Documentation generation uses analysis effectively
✓ Navigation finds information efficiently
✓ Stop conditions work correctly

### Token Efficiency

✓ Combined workflow uses ≤ sum of individual skills
✓ Context shared efficiently
✓ No bulk loading across skill boundaries
✓ Surgical extraction maintained throughout

## Anti-Patterns to Avoid

### Don't: Use Repository Analysis Instead of Documentation Navigation

**Wrong**:
```
User: "Find authentication component entry point"
Agent: Generates full repository analysis (10,000+ tokens)
```

**Right**:
```
User: "Find authentication component entry point"
Agent: Uses Documentation PD Navigator (2,000 tokens)
```

### Don't: Generate Documentation Without Analysis

**Wrong**:
```
User: "Create documentation"
Agent: Creates docs from scratch without analyzing code
```

**Right**:
```
User: "Create documentation"
Agent: First runs Repository Analysis, then Create PD Documentation
```

### Don't: Validate Documentation Without Current State

**Wrong**:
```
User: "Verify docs are current"
Agent: Only reads existing documentation
```

**Right**:
```
User: "Verify docs are current"
Agent: Reads docs (Navigator), generates current analysis (Analysis), compares
```

### Don't: Bulk-Load Everything

**Wrong**:
```
Agent: Loads all docs [D0-D5] + full repository analysis
```

**Right**:
```
Agent: Navigates to D1 → stops when sufficient → loads analysis only if needed
```
