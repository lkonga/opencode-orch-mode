# Subagent Delegation Patterns for PD Documentation Creation

## When to Use Subagents

**Architect-Coder Delegation Triggers**:

1. **Massive Codebase** (> 50 components)
   - Token budget exceeds single-agent context
   - Multiple subsystems need parallel analysis
   - Depth analysis requires focused attention

2. **Time-Consuming Analysis** (> 30 minutes)
   - Comprehensive component documentation
   - Cross-cutting pattern extraction
   - Multi-depth document generation

3. **Specialized Knowledge Domains**
   - Frontend patterns require deep React/Vue knowledge
   - Backend patterns require database expertise
   - Infrastructure patterns require DevOps context

## Architect Role (Lightweight Orchestration)

### Phase 1: Survey and Plan

**Step 1.1**: High-level repository survey

```bash
# Quick structure analysis
tree -L 3 -d src/
ls -la config/
ls -la tests/
```

**Step 1.2**: Identify major subsystems

```
Survey Results:
├── Frontend (src/ui/) - 15 components
├── Backend API (src/api/) - 20 endpoints
├── Data Layer (src/data/) - 10 repositories
├── Authentication (src/auth/) - 5 services
└── Infrastructure (scripts/) - 8 deployment scripts

Total: ~60 components across 5 subsystems
```

**Step 1.3**: Determine documentation needs

```
Documentation Strategy:
- D0 Hub: Single doc covering all subsystems
- D1 Guides: 5 role-based entry points + 5 subsystem guides
- D2 Implementation: 3-5 deep-dive guides for complex subsystems
- D3 Architecture: 1-2 system-wide architecture docs
- Total: ~15-20 documents to create
```

**Step 1.4**: Create subagent task breakdown

```
Subagent Tasks:
1. Frontend Component Analysis (10 min)
2. Backend API Analysis (15 min)
3. Data Layer Analysis (10 min)
4. Authentication System Analysis (8 min)
5. Infrastructure & DevOps Analysis (7 min)

Parallel execution: ~15 minutes total
Sequential execution: ~50 minutes
```

### Phase 2: Prepare Context for Subagents

**Step 2.1**: Create WIP Documentation Hub

```markdown
# [Project] Documentation Hub [D0] - WORK IN PROGRESS

## Project Overview
[Fill in high-level overview]

## Subsystems Identified
- **Frontend** → [To be analyzed by Subagent 1]
- **Backend API** → [To be analyzed by Subagent 2]
- **Data Layer** → [To be analyzed by Subagent 3]
- **Authentication** → [To be analyzed by Subagent 4]
- **Infrastructure** → [To be analyzed by Subagent 5]

## Task Delegation
- Subagent 1: Analyze Frontend (src/ui/)
- Subagent 2: Analyze Backend API (src/api/)
- Subagent 3: Analyze Data Layer (src/data/)
- Subagent 4: Analyze Authentication (src/auth/)
- Subagent 5: Analyze Infrastructure (scripts/)
```

**Step 2.2**: Define subagent task template

```markdown
Task Template for Subagent:

**Subsystem**: [Name]
**Directory**: [Path]
**Scope**: [D1/D2/D3 analysis]

**Your Task**:
1. Survey directory structure
2. Identify main components and patterns
3. Extract entry points and key files
4. Document common operations
5. Identify integration points
6. Return structured findings (see format below)

**Output Format**:
[See Subagent Output Format section below]

**Context**:
- You have access to WIP Documentation Hub at: [path]
- You can use $DocumentationPDNavigator to read existing docs
- Focus on [specific aspect] for this subsystem
```

### Phase 3: Delegate to Subagents

**Step 3.1**: Launch subagents using `run_glm_prompt`

```bash
# Subagent 1: Frontend Analysis
run_glm_prompt \
  --description "Frontend subsystem analysis" \
  --prompt "$(cat subagent-task-frontend.md)"

# Subagent 2: Backend API Analysis
run_glm_prompt \
  --description "Backend API analysis" \
  --prompt "$(cat subagent-task-backend.md)"

# [Continue for all subagents]
```

**Step 3.2**: Provide each subagent with:
- Task-specific prompt
- Access to WIP Documentation Hub
- Permission to read codebase in specified directory
- Output format requirements

### Phase 4: Integrate Findings

**Step 4.1**: Collect subagent outputs

```
Subagent 1 Output: frontend-analysis.md
Subagent 2 Output: backend-analysis.md
Subagent 3 Output: data-layer-analysis.md
Subagent 4 Output: auth-analysis.md
Subagent 5 Output: infra-analysis.md
```

**Step 4.2**: Validate consistency

```
Validation Checks:
✓ All subsystems documented
✓ Integration points identified and match
✓ Depth levels appropriate to complexity
✓ No conflicting information
✓ Output format followed
```

**Step 4.3**: Synthesize into cohesive documentation

```
Integration Process:
1. Create D0 Hub from all subagent summaries
2. Create D1 guides using subagent component details
3. Create D2 implementation docs from subagent patterns
4. Add cross-references between documents
5. Validate progressive disclosure structure
```

## Coder Role (Subagent - Deep Analysis)

### Subagent Input

**Task Description**:
```markdown
**Subsystem**: Frontend UI Components
**Directory**: src/ui/
**Scope**: D1-D2 analysis

**Your Task**:
Analyze the Frontend subsystem and produce structured documentation suitable for D1 (Component Overview) and D2 (Implementation Patterns) levels.

**Specific Requirements**:
1. Identify all major components (minimum 5)
2. Extract common UI patterns
3. Document component hierarchy
4. Identify integration points with Backend API
5. Extract typical workflows
6. Document configuration and theming

**Output Format**: See template below

**Context**:
- WIP Hub available at: ./DOCUMENTATION-HUB-WIP.md
- Existing Backend API docs: ./docs/API-GUIDE.md [D1]
- Technology: React 18, TypeScript, Vite
```

### Subagent Execution

**Step 1**: Survey directory structure

```bash
cd src/ui/
tree -L 3
ls -la components/
ls -la hooks/
ls -la utils/
```

**Step 2**: Read WIP Hub for context

```
Use $DocumentationPDNavigator to read:
- DOCUMENTATION-HUB-WIP.md
- Existing docs referenced (e.g., API-GUIDE.md)
```

**Step 3**: Analyze components

```
Component Analysis:
1. LoginComponent
   - Purpose: User authentication UI
   - Entry: src/ui/components/Login/LoginForm.tsx
   - Dependencies: AuthService, Validation
   - Patterns: Form handling, error display

2. DashboardComponent
   [Similar analysis]

[Continue for all components]
```

**Step 4**: Extract patterns

```
Pattern Extraction:
1. Form Handling Pattern
   - Used by: Login, Register, Profile components
   - Code: [Extract pattern code]
   - Integration: Connects to API via hooks

2. Data Fetching Pattern
   [Similar extraction]

[Continue for all patterns]
```

**Step 5**: Document findings

```markdown
# Frontend Subsystem Analysis

## Summary (D1 Level)
- **Purpose**: User interface layer
- **Technology**: React 18 + TypeScript + Vite
- **Components**: 12 major components identified
- **Patterns**: 5 core patterns extracted
- **Integration**: REST API via custom hooks

## Component List (D1)
1. LoginComponent → src/ui/components/Login/
2. DashboardComponent → src/ui/components/Dashboard/
[Continue list]

## Common Operations (D1)
1. User Login Flow: [Description]
2. Data Display Pattern: [Description]
[Continue list]

## Implementation Patterns (D2)
### Pattern 1: Form Handling
[Complete pattern documentation with code]

### Pattern 2: Data Fetching
[Complete pattern documentation]

[Continue for all patterns]

## Integration Points (D2)
- **Backend API**: [Description of integration]
- **State Management**: [Description]
- **Routing**: [Description]

## Entry Points for Tasks (D1)
- Fix UI bug: Start at src/ui/components/[Component]/
- Add new feature: Follow Pattern X (see D2)
- Modify styling: See docs/THEMING-GUIDE.md [D2]
```

### Subagent Output Format

**Required Structure**:

```markdown
# [Subsystem] Analysis Output

## Executive Summary
- **Subsystem**: [Name]
- **Directory**: [Path]
- **Complexity**: [Low/Medium/High]
- **Recommended Depth**: [D1/D1-D2/D1-D3]

## D1 Content (Component Overview)
### What
[One-paragraph description]

### Why
[Problem solved, approach]

### How
[High-level implementation approach]

### Entry Points
- [File 1]: [Purpose]
- [File 2]: [Purpose]
- [File 3]: [Purpose]

### Component List
1. [Component 1]: [One-line description]
2. [Component 2]: [One-line description]
[Continue]

### Common Operations
1. [Operation 1]: [Brief how-to]
2. [Operation 2]: [Brief how-to]
[Continue]

### Integration Points
- [Integration 1]: [Description]
- [Integration 2]: [Description]

## D2 Content (Implementation Patterns) - IF NEEDED
### Pattern 1: [Name]
**Code**:
```[language]
[Complete pattern code]
```

**When to use**: [Scenarios]
**Integration**: [How it connects]

### Pattern 2: [Name]
[Same structure]

[Continue for all patterns]

## D3 Considerations - IF COMPLEX
### Architecture Notes
[Only if subsystem requires architectural documentation]

### Design Decisions
[Only if important decisions to document]

## Cross-References
- References [Other Subsystem]: [Description of relationship]
- Integrates with [System]: [Description]

## Suggestions
- [Suggestion 1 for documentation structure]
- [Suggestion 2 for cross-referencing]
```

## Task Delegation Patterns

### Pattern 1: Parallel Subsystem Analysis

**When to use**: 5+ independent subsystems

**Delegation**:
```
Architect:
├── Survey project structure (5 min)
├── Create WIP Hub (5 min)
└── Delegate to 5 subagents in parallel
    ├── Subagent 1: Frontend (10 min)
    ├── Subagent 2: Backend (15 min)
    ├── Subagent 3: Data (10 min)
    ├── Subagent 4: Auth (8 min)
    └── Subagent 5: Infra (7 min)

Total time: ~25 min (vs ~60 min sequential)
```

### Pattern 2: Depth-Level Focused Delegation

**When to use**: Single complex subsystem needs D1-D3

**Delegation**:
```
Architect:
├── Analyze subsystem structure (5 min)
├── Create D0 entry in Hub (5 min)
└── Delegate depth-focused tasks
    ├── Subagent 1: D1 Component Overview (10 min)
    ├── Subagent 2: D2 Implementation Patterns (20 min)
    └── Subagent 3: D3 Architecture Design (15 min)

Total time: ~55 min (vs ~75 min sequential)
```

### Pattern 3: Pattern Extraction Delegation

**When to use**: Multiple components use similar patterns

**Delegation**:
```
Architect:
├── Identify pattern categories (10 min)
└── Delegate pattern extraction
    ├── Subagent 1: Extract Form Patterns (15 min)
    ├── Subagent 2: Extract Data Patterns (15 min)
    ├── Subagent 3: Extract Auth Patterns (10 min)
    └── Subagent 4: Extract API Patterns (20 min)

Architect: Synthesize into pattern catalog (20 min)
Total time: ~50 min (vs ~90 min sequential)
```

### Pattern 4: Role-Based Documentation Delegation

**When to use**: Multiple role-specific guides needed

**Delegation**:
```
Architect:
├── Define role requirements (5 min)
└── Delegate role-specific doc creation
    ├── Subagent 1: Agent Quick Start [D1] (15 min)
    ├── Subagent 2: Developer Workflow [D1] (20 min)
    ├── Subagent 3: Configuration Guide [D1] (10 min)
    └── Subagent 4: Architecture Overview [D3] (25 min)

Total time: ~35 min (vs ~70 min sequential)
```

## Context Handoff Strategies

### Strategy 1: WIP Hub as Living Document

**Process**:
1. Architect creates WIP Hub with initial structure
2. Subagents read WIP Hub for context
3. Subagents add findings to WIP Hub sections
4. Architect reviews and refines
5. Final Hub published

**Benefits**:
- Single source of truth during creation
- Subagents see each other's work
- Reduces integration effort

### Strategy 2: Subagent Reading Privilege

**Setup**:
```
Allow subagents to use $DocumentationPDNavigator:
- Read existing D1 guides for related components
- Check integration points in other docs
- Verify consistency with system-wide patterns
```

**Example Subagent Usage**:
```
Subagent analyzing Frontend:
1. Read Backend API docs to understand integration
2. Read Authentication docs for auth patterns
3. Verify frontend hooks align with API contracts
4. Document integration points with evidence
```

### Strategy 3: Structured Output Templates

**Provide subagents with**:
- Exact output format requirements
- Markdown structure templates
- Example outputs from similar tasks
- Validation checklist

**Result**: Consistent outputs that integrate cleanly

## Integration and Validation

### Integration Workflow

**Step 1**: Collect all subagent outputs

```bash
outputs/
├── frontend-analysis.md
├── backend-analysis.md
├── data-analysis.md
├── auth-analysis.md
└── infra-analysis.md
```

**Step 2**: Validate consistency

```
Consistency Checks:
✓ Integration points match across outputs
✓ Terminology consistent
✓ Depth levels appropriate
✓ Cross-references valid
✓ No contradictions
```

**Step 3**: Synthesize D0 Hub

```
Hub Sections:
- Quick Orientation: Synthesize from all summaries
- Project Map: Combine all component lists
- Task Navigation: Map from common operations
- Depth Levels: Aggregate from all outputs
```

**Step 4**: Create D1 Guides

```
For each subsystem:
1. Extract D1 content from subagent output
2. Add cross-references to related D1 guides
3. Link to D2 documents if needed
4. Add stop conditions
```

**Step 5**: Create D2 Implementation Guides

```
For complex subsystems:
1. Extract D2 patterns from subagent output
2. Organize by pattern category
3. Add code examples
4. Link to D1 overviews and D3 architecture
```

**Step 6**: Add progressive disclosure markers

```
All documents:
- Add [D0-D5] depth markers
- Add "Stop here if" conditions
- Add token estimates
- Add read time estimates
```

### Validation Checklist

**Structure Validation**:
- [ ] D0 Hub is 200-400 lines
- [ ] All D1 guides are 300-600 lines
- [ ] All D2 guides are 600-1500 lines
- [ ] Depth markers present on all docs
- [ ] Stop conditions at all levels

**Content Validation**:
- [ ] All components documented
- [ ] Integration points identified
- [ ] Common operations described
- [ ] Entry points listed
- [ ] Code examples complete

**Consistency Validation**:
- [ ] Terminology consistent
- [ ] Cross-references valid
- [ ] Integration points match
- [ ] No contradictions
- [ ] Depth progression logical

**Progressive Disclosure Validation**:
- [ ] D0 provides navigation to all D1s
- [ ] D1 provides navigation to D2s
- [ ] D2 provides navigation to D3s
- [ ] Stop conditions align with task types
- [ ] Token budgets reasonable

## Example: Complete Delegation Workflow

**Scenario**: Document a Laravel application with Frontend (Vue), Backend (Laravel API), Database (MySQL), Authentication (JWT), Deployment (Docker)

### Architect Phase

```
Step 1: Survey (10 min)
- Repository has: ~80 files across 5 subsystems
- Estimated documentation: 1 D0 Hub + 10 D1 guides + 5 D2 guides + 2 D3 guides

Step 2: Create WIP Hub (15 min)
- Create DOCUMENTATION-HUB-WIP.md
- List all 5 subsystems
- Define delegation tasks

Step 3: Delegate Tasks (5 min)
- Launch 5 subagents via run_glm_prompt
- Each subagent assigned one subsystem
- Provide context and output format

Wait for subagents: ~20 minutes
```

### Subagent Execution (Parallel)

```
Subagent 1: Frontend (Vue) - 18 min
- Survey src/ui/
- Extract 8 components
- Document 3 patterns
- Identify API integration
- Return structured output

Subagent 2: Backend (Laravel) - 22 min
- Survey app/Http/
- Extract 15 controllers
- Document routing patterns
- Identify middleware
- Return structured output

Subagent 3: Database (MySQL) - 15 min
- Survey database/migrations/
- Document schema
- Extract repository patterns
- Return structured output

Subagent 4: Authentication (JWT) - 12 min
- Survey app/Auth/
- Document auth flow
- Extract JWT patterns
- Return structured output

Subagent 5: Deployment (Docker) - 10 min
- Survey docker/, scripts/
- Document deployment process
- Extract deployment patterns
- Return structured output

Total parallel time: ~22 minutes
```

### Architect Integration (30 min)

```
Step 1: Validate outputs (5 min)
- Check all outputs complete
- Verify format consistency
- Identify integration points

Step 2: Create D0 Hub (10 min)
- Synthesize subsystem summaries
- Add task-based navigation
- Add depth level guide
- Finalize DOCUMENTATION-HUB.md

Step 3: Create D1 Guides (10 min)
- Extract D1 content from each subagent
- Add cross-references
- Add stop conditions
- Create 5 D1 guides

Step 4: Create D2 Guides (5 min)
- Aggregate patterns from subagents
- Create 2-3 D2 implementation guides
- Add code examples
- Link to D1 guides

Step 5: Final validation (5 min)
- Verify progressive disclosure
- Check token budgets
- Validate cross-references
- Mark as complete
```

**Total Time**: ~70 minutes (vs ~150 minutes without delegation)
**Token Savings**: 60% (parallel analysis + focused output)
