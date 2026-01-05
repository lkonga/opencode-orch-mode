# Agent Cleanup Plan

**Date**: January 5, 2026  
**Location**: `/home/lkonga/codes/opencode-related/opencode-orch-mode/.opencode_global/agent/`  
**Analyst**: Agent Cleanup Specialist

---

## Executive Summary

After comprehensive analysis of **19 agent files**, I've identified **6 specialized single-purpose agents** that should be deleted, **10 general-purpose meta agents** to keep, and **3 agents requiring user decision**.

### Key Findings
- **Total Agents Analyzed**: 19
- **Recommended for Deletion**: 6 (31.6%)
- **Recommended to Keep**: 10 (52.6%)
- **Need User Decision**: 3 (15.8%)

### Primary Issues Identified
1. **Specialized single-task agents** that do one narrow thing (fetch rules, create AGENTS.md)
2. **Redundant agents** with overlapping functionality (multiple implementors/reviewers)
3. **Poorly configured agents** lacking proper tool definitions or unclear purpose
4. **Agents tied to specific workflows** that should be handled by general agents

---

## Agents Recommended for Deletion ❌

### 1. **rules-fetcher.md** ❌ DELETE
- **Current Purpose**: Ports VS Code Copilot chatmodes to OpenCode format, fetches rules/prompts from GitHub
- **Why Delete**: 
  - Extremely specialized single-purpose agent
  - Does only one thing: fetches and ports rules
  - Functionality could be handled by a general agent with proper instructions
  - Tied to specific workflow (awesome-copilot repo)
- **Registered in opencode.json**: No
- **Impact**: Low - this is a niche task that doesn't need a dedicated agent
- **Alternative**: Use `@general` or `@coder` agent with specific instructions to fetch/port rules

### 2. **agentsmd-creator.md** ❌ DELETE
- **Current Purpose**: Analyzes codebase and generates AGENTS.md with project-specific instructions
- **Why Delete**:
  - Single-purpose agent that only creates one specific file
  - Very narrow use case (only needed once per project)
  - Functionality is a one-time setup task, not ongoing work
  - Could be handled by general agent with proper instructions
- **Registered in opencode.json**: No
- **Impact**: Low - AGENTS.md creation is a one-time task per project
- **Alternative**: Use `@general` or `@explore` agent to analyze codebase and generate AGENTS.md

### 3. **PromptEnhancer.md** ❌ DELETE
- **Current Purpose**: Enhances prompts with context, clarity, and detail for subagent tasks
- **Why Delete**:
  - Single-purpose metaprompting agent
  - Very narrow use case (only enhances prompts)
  - This is a meta-task that should be handled by the main agent orchestrating
  - Doesn't do actual implementation or analysis
- **Registered in opencode.json**: Yes
- **Impact**: Low - prompt enhancement should be part of main agent's workflow, not separate agent
- **Alternative**: Main agent should handle prompt enhancement as part of delegation process

### 4. **quickReviewer.md** ❌ DELETE
- **Current Purpose**: Rapid second-opinion reviewer using MiniMax model for fast assessments
- **Why Delete**:
  - Redundant with @reviewer and @expert agents
  - Very narrow purpose (quick second opinion)
  - Adds confusion - when to use @quickReviewer vs @reviewer vs @expert?
  - "Speed" difference is not sufficient justification for separate agent
- **Registered in opencode.json**: Yes
- **Impact**: Low - existing reviewer agents can handle quick reviews
- **Alternative**: Use @reviewer with instruction to "provide quick assessment" or adjust @reviewer's temperature

### 5. **summarizer.md** ❌ DELETE
- **Current Purpose**: Condenses subagent sessions for main agent orchestration
- **Why Delete**:
  - Single-purpose agent that only summarizes text
  - This is a basic task that any LLM can do
  - Should be handled by main agent, not a subagent
  - Creates unnecessary delegation overhead
- **Registered in opencode.json**: Yes
- **Impact**: Low - summarization is a core LLM capability, doesn't need dedicated agent
- **Alternative**: Main agent should summarize subagent outputs directly

### 6. **plan.md** ❌ DELETE
- **Current Purpose**: Restricted agent for planning and analysis with approval-required changes
- **Why Delete**:
  - Built-in reserved agent name (should never be created manually)
  - Conflicts with OpenCode's built-in `plan` mode
  - Poorly configured (all tools disabled)
  - Unclear purpose - why use this instead of @general?
- **Registered in opencode.json**: No
- **Impact**: Low - this is a misconfiguration, not a functional agent
- **Alternative**: Use @general agent with instructions to focus on planning/analysis

---

## Agents Recommended to Keep ✅

### 1. **general.md** ✅ KEEP
- **Purpose**: General-purpose agent for research, searching, and multi-step tasks
- **Why Keep**: 
  - True general-purpose meta agent
  - Can be used across any project or task
  - Handles research, exploration, and complex queries
  - Core capability that's always useful

### 2. **build.md** ✅ KEEP
- **Purpose**: Default primary agent with all tools enabled for development work
- **Why Keep**:
  - Standard development agent
  - Full tool access for implementation
  - Core capability needed in all projects
  - Default agent for most work

### 3. **explore.md** ✅ KEEP
- **Purpose**: Fast codebase exploration - file discovery, pattern matching, code search
- **Why Keep**:
  - Core capability - finding code and understanding structure
  - General-purpose - useful in any codebase
  - Distinct from implementation/review
  - Optimized for speed and discovery

### 4. **coder.md** ✅ KEEP
- **Purpose**: Implementation specialist - executes development plans and code modifications
- **Why Keep**:
  - Core implementation capability
  - General-purpose - can implement anything in any project
  - Delegates to @explore for context (good pattern)
  - Essential for ORCH-style workflows

### 5. **expert.md** ✅ KEEP
- **Purpose**: Expert reviewer with ultrathink - deep analysis, second opinions, comprehensive reviews
- **Why Keep**:
  - Core capability - deep analysis and review
  - General-purpose - can review anything
  - Uses ultrathink for thorough reasoning
  - Distinct from quick review (comprehensive vs rapid)

### 6. **reviewer.md** ✅ KEEP
- **Purpose**: Quick code reviewer - fast, focused reviews with clear pass/fail assessment
- **Why Keep**:
  - Core review capability
  - General-purpose - can review any code
  - Balanced between quick and comprehensive
  - Standard code review agent

### 7. **repositoryAnalyst.md** ✅ KEEP
- **Purpose**: Deep codebase analyst with ultrathink - comprehensive analysis, architectural reviews
- **Why Keep**:
  - Core capability - deep architectural analysis
  - General-purpose - can analyze any codebase
  - Uses ultrathink for long-form reasoning
  - Distinct from @expert (architectural vs code-level)

### 8. **implementor-zai-glm-4-5.md** ✅ KEEP
- **Purpose**: ORCH workflow implementor - executes plans exactly using ZAI GLM-4.5
- **Why Keep**:
  - Essential for ORCH workflow
  - General-purpose implementation capability
  - Low temperature (0.1) for precise execution
  - Alternative model option to @coder

### 9. **reviewer-github-copilot-grok-fast.md** ✅ KEEP
- **Purpose**: ORCH workflow reviewer - evaluates compliance using Grok Code Fast
- **Why Keep**:
  - Essential for ORCH workflow
  - General-purpose review capability
  - Alternative model to @reviewer
  - Specific compliance scoring for ORCH

### 10. **gemini-implementor.md** ✅ KEEP
- **Purpose**: ORCH workflow implementor using local Gemini 2.5 Pro model
- **Why Keep**:
  - Alternative model option for ORCH workflow
  - General-purpose implementation capability
  - Useful when local Gemini is preferred
  - Provides model diversity

---

## Agents Requiring User Decision ⚠️

### 1. **grok.md** ⚠️ USER DECISION
- **Current Purpose**: Implementation specialist for ORCH workflow using Grok Code Fast model
- **Why Borderline**:
  - Redundant with @implementor-zai-glm-4-5 and @gemini-implementor
  - Three different ORCH implementors seems excessive
  - However, provides model diversity which may be valuable
- **Registered in opencode.json**: No
- **Options**:
  - **DELETE**: Keep only @implementor-zai-glm-4-5 as default ORCH implementor
  - **KEEP**: Maintain model diversity for users who prefer Grok
  - **MERGE**: Create one configurable ORCH implementor that can use any model
- **Recommendation**: **DELETE** - Three ORCH implementors is excessive. Keep @implementor-zai-glm-4-5 as primary, users can specify model in plan if needed.

### 2. **glm.md** ⚠️ USER DECISION
- **Current Purpose**: General coding and planning agent using ZAI GLM-4.5
- **Why Borderline**:
  - Very similar to @general agent (both use GLM-4.7)
  - Unclear what differentiates it from @general
  - Poorly configured (minimal tools, minimal instructions)
  - However, may serve as lightweight alternative to @general
- **Registered in opencode.json**: No
- **Options**:
  - **DELETE**: Use @general for all GLM-based tasks
  - **KEEP**: Maintain as lightweight GLM agent
  - **IMPROVE**: Add proper tool definitions and clarify differentiation from @general
- **Recommendation**: **DELETE** - Redundant with @general. If users want GLM, they can use @general which is already configured with GLM-4.7.

### 3. **README.md** ⚠️ NOT AN AGENT
- **Current Purpose**: Documentation file explaining agent usage and ORCH workflow
- **Why Borderline**:
  - This is documentation, not an agent file
  - Should not be in the agent directory
  - However, contains valuable information
- **Registered in opencode.json**: N/A (it's documentation)
- **Options**:
  - **MOVE**: Relocate to `/docs/` directory with other documentation
  - **KEEP**: Leave in agent directory for easy reference
  - **DELETE**: Move content to main repo README
- **Recommendation**: **MOVE** - This is documentation and belongs in `/docs/` or repo root, not in agent directory.

---

## opencode.json Changes Required

### Agents to Unregister (Delete from config)

The following agents are currently registered in `opencode.json` and must be removed:

```json
{
  "agent": {
    // DELETE these entries:
    "PromptEnhancer": {
      "description": "Expert metaprompter - enhances prompts with context, clarity, and detail for high-quality subagent tasks",
      "mode": "subagent",
      "model": "chutes/MiniMaxAI/MiniMax-M2.1-TEE"
    },
    "quickReviewer": {
      "description": "Rapid second-opinion reviewer - fast assessments using GPT-5.2 for validation and alternative perspectives",
      "mode": "subagent",
      "model": "chutes/MiniMaxAI/MiniMax-M2.1-TEE"
    },
    "summarizer": {
      "description": "Session summarizer - condenses subagent sessions for main agent orchestration",
      "mode": "subagent",
      "model": "chutes/MiniMaxAI/MiniMax-M2.1-TEE"
    }
  }
}
```

### Agents to Keep (No Changes)

These agents are properly registered and should remain:
- `general` - General-purpose agent
- `build` - Default primary agent
- `expert` - Expert reviewer with ultrathink
- `normal` - Normal subagent for routine tasks
- `explore` - Codebase discovery agent
- `coder` - Implementation specialist
- `repositoryAnalyst` - Deep codebase analyst
- `reviewer` - Comprehensive code reviewer

---

## Impact Assessment

### Low Impact Deletions ✅
- **rules-fetcher.md**: Niche task, can use general agent
- **agentsmd-creator.md**: One-time task, can use general agent
- **PromptEnhancer.md**: Meta-task, should be handled by main agent
- **quickReviewer.md**: Redundant with existing reviewers
- **summarizer.md**: Basic LLM capability, no need for dedicated agent
- **plan.md**: Misconfiguration, conflicts with built-in

### Medium Impact Deletions ⚠️
- **grok.md**: If deleted, users preferring Grok model for ORCH will need to use alternative
- **glm.md**: If deleted, users lose lightweight GLM option (but can use @general)

### No Impact to Core Functionality
- All core capabilities remain: implementation, review, exploration, analysis
- ORCH workflow remains functional with @implementor-zai-glm-4-5 and @reviewer-github-copilot-grok-fast
- General-purpose agents handle all use cases

---

## Recommendations Summary

### Immediate Actions (Delete)

1. **Delete these 6 agent files**:
   ```
   rm .opencode_global/agent/rules-fetcher.md
   rm .opencode_global/agent/agentsmd-creator.md
   rm .opencode_global/agent/PromptEnhancer.md
   rm .opencode_global/agent/quickReviewer.md
   rm .opencode_global/agent/summarizer.md
   rm .opencode_global/agent/plan.md
   ```

2. **Update opencode.json** - Remove agent registrations:
   - Remove `PromptEnhancer` entry
   - Remove `quickReviewer` entry
   - Remove `summarizer` entry

### User Decision Required

3. **Decide on redundant agents**:
   - **grok.md**: DELETE (recommended) - Redundant ORCH implementor
   - **glm.md**: DELETE (recommended) - Redundant with @general
   - **README.md**: MOVE to /docs/ (recommended) - It's documentation, not an agent

### Alternative Approaches

**Option A: Minimal Cleanup (Conservative)**
- Delete only the 6 clearly single-purpose agents
- Keep all borderline agents
- Update opencode.json accordingly

**Option B: Moderate Cleanup (Recommended)**
- Delete 6 single-purpose agents
- Delete @grok and @glm (redundant)
- Move README.md to /docs/
- Results in 10 general-purpose agents

**Option C: Aggressive Cleanup**
- Delete all 6 single-purpose agents
- Delete all ORCH-specific agents except one implementor/reviewer pair
- Keep only 5-6 core general-purpose agents
- Maximum simplification

---

## Decision Matrix

| Agent | Specialized? | Redundant? | Poorly Configured? | Recommendation |
|-------|-------------|------------|-------------------|----------------|
| rules-fetcher.md | ✅ Yes | ❌ No | ❌ No | ❌ DELETE |
| agentsmd-creator.md | ✅ Yes | ❌ No | ❌ No | ❌ DELETE |
| PromptEnhancer.md | ✅ Yes | ❌ No | ❌ No | ❌ DELETE |
| quickReviewer.md | ✅ Yes | ✅ Yes | ❌ No | ❌ DELETE |
| summarizer.md | ✅ Yes | ❌ No | ❌ No | ❌ DELETE |
| plan.md | ❌ No | ❌ No | ✅ Yes | ❌ DELETE |
| grok.md | ❌ No | ✅ Yes | ❌ No | ⚠️ USER DECISION |
| glm.md | ❌ No | ✅ Yes | ⚠️ Yes | ⚠️ USER DECISION |
| README.md | N/A | N/A | N/A | ⚠️ MOVE |

---

## Next Steps

### For User Review

1. **Review this plan** and confirm which deletions to proceed with
2. **Decide on borderline agents** (@grok, @glm, README.md)
3. **Choose cleanup approach** (Minimal/Moderate/Aggressive)

### After Confirmation

1. **Delete approved agent files**
2. **Update opencode.json** to remove deleted agent registrations
3. **Test remaining agents** to ensure functionality
4. **Update documentation** to reflect final agent list

### Testing Checklist

After cleanup, verify:
- [ ] All remaining agents load correctly
- [ ] ORCH workflow still functions
- [ ] No broken references in documentation
- [ ] opencode.json is valid
- [ ] Agent calls work as expected

---

## Conclusion

This cleanup plan reduces agent count from **19 to 10-13 agents** (depending on user decisions), eliminating specialized single-purpose agents while preserving all general-purpose meta agents. The result is a cleaner, more maintainable agent ecosystem focused on core capabilities rather than narrow tasks.

**Key Principle**: Agents should be GENERAL PURPOSE meta agents, not specialized single-task agents. This cleanup aligns the agent collection with that principle.

---

**End of Cleanup Plan**

**Please review and confirm which deletions to proceed with.**
