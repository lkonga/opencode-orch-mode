# Agent Recovery Report

## Date
January 6, 2026

## Issue
The `.opencode/agent/` directory was empty, and `.opencode_global/agent/` contained broken symlinks pointing to themselves.

## Root Cause
During a previous cleanup/refactor (commit `c415ff5`), agent files were removed from `.opencode_global/agent/`, but broken symlinks were left behind. The `.opencode/agent/` directory (the correct location for OpenCode agents) was never populated with the actual agent files.

## Recovery Process

### 1. Identified Missing Agents
From commit `12a65f0`, the following agents were recovered:

| Agent | Purpose | Model |
|-------|---------|-------|
| **general.md** | General-purpose research and multi-step tasks | zai-coding-plan/glm-4.7 |
| **explore.md** | Fast codebase exploration and pattern matching | chutes/MiniMaxAI/MiniMax-M2.1-TEE |
| **coder.md** | Implementation specialist, delegates to @explore | github-copilot/gpt-5.2 |
| **expert.md** | Expert reviewer with ultrathink for deep analysis | github-copilot/gpt-5.2 |
| **build.md** | Default primary agent with all tools enabled | zai-coding-plan/glm-4.7 |
| **plan.md** | Planning specialist for structured development | - |
| **reviewer.md** | Code review specialist | - |
| **summarizer.md** | Summarization and documentation | - |

### 2. Recovery Commands
```bash
# Recover agents from commit 12a65f0
git show 12a65f0:.opencode_global/agent/general.md > .opencode/agent/general.md
git show 12a65f0:.opencode_global/agent/explore.md > .opencode/agent/explore.md
git show 12a65f0:.opencode_global/agent/coder.md > .opencode/agent/coder.md
git show 12a65f0:.opencode_global/agent/expert.md > .opencode/agent/expert.md
git show 12a65f0:.opencode_global/agent/build.md > .opencode/agent/build.md
git show 12a65f0:.opencode_global/agent/plan.md > .opencode/agent/plan.md
git show 12a65f0:.opencode_global/agent/reviewer.md > .opencode/agent/reviewer.md
git show 12a65f0:.opencode_global/agent/summarizer.md > .opencode/agent/summarizer.md

# Remove broken symlinks
rm -rf .opencode_global/agent/*.md
```

### 3. Agent Details

#### @general
**Purpose**: Research complex questions, search for code, execute multi-step tasks
**When to use**:
- Searching for keywords or files
- Not confident you'll find the right match immediately
- Multi-step research tasks
- Complex queries requiring investigation

#### @explore
**Purpose**: Fast codebase exploration and pattern matching
**When to use**:
- Quickly find files by patterns
- Search code for keywords
- Answer questions about codebase structure
- Fast exploration and discovery

**Constraints**:
- 10 tool iterations maximum
- Read-only operations
- Fast, focused searches

#### @coder
**Purpose**: Implementation specialist for executing development plans
**Workflow**:
- Delegates to @explore for context discovery
- Performs surgical code edits
- Runs tests and verification scripts
- Follows plans strictly without unplanned changes

#### @expert
**Purpose**: Expert reviewer with ultrathink for comprehensive analysis
**Analysis dimensions**:
- Correctness (bug-free, works as intended)
- Security (vulnerabilities, edge cases)
- Performance (efficiency, bottlenecks)
- Maintainability (clean, well-structured)
- Best practices (conventions, patterns)

#### @build
**Purpose**: Default primary agent with all tools enabled
**When to use**:
- Default agent for most development tasks
- Full access to all tools needed
- Implementation and coding work

## Current State

### Before Recovery
```
.opencode/
└── agent/          (empty)

.opencode_global/
└── agent/
    ├── general.md -> .opencode_global/agent/general.md (broken)
    ├── explore.md -> .opencode_global/agent/explore.md (broken)
    └── ... (all broken symlinks)
```

### After Recovery
```
.opencode/
├── agent/
│   ├── build.md
│   ├── coder.md
│   ├── expert.md
│   ├── explore.md
│   ├── general.md
│   ├── plan.md
│   ├── reviewer.md
│   └── summarizer.md
└── opencode.json   (built-in agent configurations)

.opencode_global/
└── agent/          (cleaned up - broken symlinks removed)
```

## Integration with opencode.json

The recovered agents work alongside the built-in agents configured in `opencode.json`:

**Built-in agents (in opencode.json)**:
- `@general` - General-purpose agent
- `@expert` - Expert subagent with deep reasoning
- `@normal` - Normal subagent for routine tasks
- `@build` - Build agent with reasoning enabled
- `@explore` - Explore agent (read-only)
- `@coder` - Coder agent

**Custom agents (in .opencode/agent/)**:
- More detailed configurations with specific prompts
- Can be used as alternatives to built-in agents
- Provide additional capabilities like planning, reviewing, summarizing

## Verification

All agents have been verified:
- ✅ 8 agents recovered from git history
- ✅ All agents have valid YAML frontmatter
- ✅ All agents have clear descriptions and usage guidelines
- ✅ Broken symlinks removed from `.opencode_global/agent/`
- ✅ Agents added to git tracking

## Next Steps

1. **Test agents**: Verify each agent works correctly with OpenCode
2. **Update documentation**: Ensure agent usage is documented in project README
3. **Consider cleanup**: Evaluate if `.opencode_global/agent/` directory is still needed
4. **Update init-skills**: The init-skills script now has agents to symlink to other projects

## Notes

- The ORCH workflow agents (`implementor-zai-glm-4-5.md`, `reviewer-github-copilot-grok-fast.md`) remain in `backup_orch_agents/agents/` and are separate from these general-purpose agents
- These recovered agents are the standard OpenCode agents that can be used across different projects
- The init-skills script can now symlink these agents to other projects when using `--opencode` flag
