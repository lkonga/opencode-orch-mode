---
name: Architect-Coder Workflow
description: "Orchestrator pattern with lightweight architect delegating token-heavy operations to specialized coder subagents for optimal context management"
opencode_tools: "read,write,bash"
triggers: ['$ArchitectCoder']
trigger_keywords: ['architect', 'orchestrator', 'delegate', 'subagent', 'token management']
references: {}
---

# Architect-Coder Workflow

## Core Principle

A strict **Orchestrator → Coder** workflow must be followed. The main agent (Orchestrator/Architect) remains lightweight, delegating token-heavy coding, file analysis, and research to a Coder subagent via `runGLMprompt` or `runGLMPromptThinking` or `runSubagent` (whichever is available first, in the order specified).

## Critical Meta-Instructions

### Workflow Mandate

- **Main agent (Orchestrator/Architect)**: Remains lightweight
- **Delegation**: Token-heavy coding, file analysis, and research go to Coder subagent
- **Tools**: Use `runGLMprompt` or `runGLMPromptThinking` or `runSubagent` (whichever is available first, in the order specified)
  - Note: 95% of the time only one will be available
- **Main agent handles**: Core decision-making and highly interactive tasks

### File Analysis Protocol

When implementing features requiring file analysis:

1. **Locate and preview files** (reading headers and key lines only)
2. **Delegate full analysis** to subagent for detailed reporting
3. **Use subagent** to create detailed suggestion implementation plans
4. **Refine and execute** - provides blueprint while saving tokens

**Parallel Operations Requirement**:
- Subagent MUST use parallel file reads when analyzing multiple files
- Subagent MUST use parallel file edits when modifying multiple files
- Subagent MUST leverage any tool that supports parallel invocation (e.g., `multi_replace_string_in_file`)
- This maximizes efficiency and minimizes token usage through batched operations

### User Frustration Point

Previous interactions deviated from this model, leading to:
- Slow, multi-turn exchanges with no output
- **Priority**: Direct, efficient execution

### Research Protocol

For complex research or troubleshooting:
- Trigger `$RelentlessWebResearch` skill for autonomous web research
- Delegate token-heavy investigation to subagent for succinct report
- Use `runGLMprompt` or `runGLMPromptThinking` or `runSubagent` (whichever is available first, in the order specified) for research delegation

### Playwright MCP Grounding Protocol

When integrating Playwright logic, NEVER guess. Always:

1. Ground implementation step-by-step using **interactive Playwright MCP calls via prompting** (NOT scripting)
2. Validate selectors and actions through real-time debugging and snapshots
3. Apply changes surgically only after successful validation
4. Repeat for each action

**Important Notes**:
- This is about prompting MCP tool interactively, NOT writing automated MCP scripts
- Use normal prompt tool calls like `browser_click`, `browser_navigate`, etc.
- Trigger `$MCPGrounding` skill for detailed interactive automation workflow

**STRICT CONDITION**: NEVER take screenshots as they crash some agents (unless you are from Anthropic's Sonnet family)

### Interactive Sessions

The main agent (Architect) **must** conduct interactive sessions (like Playwright MCP tool-calling), as subagent is not designed for such tasks.

### Blocking Issues

If a hard block occurs that cannot be resolved with research, agent may ask the user, primarily about:
- Control flow
- Debugging strategy

## Project-Specific Notes

Remember every Python dependency and run to use `poetry`, which is used in this project.

## Related Skills

- `$RelentlessWebResearch`: For research delegation and autonomous web research
- `$SurgicalImplementation`: For implementation protocols and precise code modifications
- `$MCPGrounding`: For interactive automation and browser testing
