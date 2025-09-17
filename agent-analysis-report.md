# Agent Definition Analysis Report

## Context

This report analyzes the agent definitions in the ORCH (Agent Orchestration) workflow. The workflow, as defined in `orch.md`, coordinates two sub-agents:

- **@agent_1 (zai-glm-4-5)**: Implementation specialist that executes development plans exactly as specified
- **@agent_2 (github-copilot-grok-fast)**: Quality reviewer that evaluates implementation compliance and provides detailed feedback

The agents are intended to work within the OpenCode framework, which requires specific markdown formatting for agent definitions.

## Current Issues with Agent Definitions

### Non-Standard Frontmatter Structure

Both agent files (`zai-glm-4-5.md` and `github-copilot-grok-fast.md`) use a custom frontmatter structure that doesn't comply with OpenCode's agent specification. The current structure includes non-standard fields like `capabilities`, `settings`, and nested `system_prompt` under `settings`.

### Missing Required Fields

Both agents are missing critical required fields that OpenCode expects:

- `mode`: Defines whether the agent is primary, subagent, or all
- `tools`: Specifies which tools the agent can access
- `description`: Must be in the correct frontmatter format

### Incorrect System Prompt Placement

The system prompts are nested under `settings.system_prompt` instead of being the main body content of the markdown file.

## OpenCode Agent Specification

### Required Fields

| Field         | Type   | Description                                | Possible Values                 |
| ------------- | ------ | ------------------------------------------ | ------------------------------- |
| `description` | string | Brief description of when to use the agent | Any descriptive text (required) |
| `mode`        | string | Agent's operational mode                   | `primary`, `subagent`, `all`    |

### Optional Fields

| Field                 | Type          | Description               | Possible Values                                                   |
| --------------------- | ------------- | ------------------------- | ----------------------------------------------------------------- |
| `tools`               | object        | Tool access permissions   | Object with tool names as keys and boolean values                 |
| `permission.edit`     | string        | File editing permissions  | `ask`, `allow`, `deny`                                            |
| `permission.bash`     | string/object | Shell command permissions | `ask`, `allow`, `deny` or object with command patterns            |
| `permission.webfetch` | string        | Web fetching permissions  | `ask`, `allow`, `deny`                                            |
| `model`               | string        | Model identifier          | Any valid model ID (e.g., `anthropic/claude-3-5-sonnet-20241022`) |
| `temperature`         | number        | Model temperature         | 0.0 to 2.0                                                        |
| `top_p`               | number        | Model top-p sampling      | 0.0 to 1.0                                                        |
| `prompt`              | string        | Custom system prompt      | Any text (alternative to body content)                            |

### Tool Names

Common tool names include:

- `bash`: Shell command execution
- `edit`: File editing operations
- `read`: File reading operations
- `write`: File writing operations
- `list`: Directory listing
- `glob`: File pattern matching
- `grep`: Text searching
- `webfetch`: Web content fetching
- `task`: Sub-agent task delegation
- `todowrite`: Todo list creation
- `todoread`: Todo list reading

## Suggested Agent Definitions

### For zai-glm-4-5.md (Implementation Agent - @agent_1)

```markdown
---
description: Implementation specialist for ORCH workflow - executes development plans exactly as specified
mode: subagent
tools:
  bash: true
  edit: true
  read: true
  write: true
  list: true
  glob: true
  grep: true
permission:
  edit: allow
  bash:
    "*": allow
  webfetch: allow
model: glm-4.5
temperature: 0.1
---

You are an implementation specialist for the ORCH workflow. Your role is to:

1. Read and understand issue and plan files
2. Execute plans EXACTLY as written - no deviations
3. Implement all components specified in the plan
4. Work efficiently and aggressively to complete tasks
5. Stay strictly within scope - no suggestions or improvements
6. Provide clear summaries of what was implemented
7. Never commit changes - only make code changes

Important: Always follow the plan precisely. Do not add unplanned features or make improvements beyond what's specified.
```

### For github-copilot-grok-fast.md (Review Agent - @agent_2)

```markdown
---
description: Quality reviewer for ORCH workflow - evaluates implementation compliance and provides detailed feedback
mode: subagent
tools:
  bash: false
  edit: false
  read: true
  write: false
  list: true
  glob: true
  grep: true
permission:
  edit: deny
  bash:
    "*": deny
  webfetch: allow
model: grok-code-fast-1
temperature: 0.2
---

You are a code reviewer for the ORCH workflow. Your role is to:

1. Read original issue and plan files
2. Check git diff to see what changes were made
3. Compare implemented changes against plan requirements
4. Calculate compliance score (0-100%) based on:
   - How many plan items were fully implemented
   - How closely implementation follows the plan's approach
   - Whether any unplanned changes were made
   - Quality and correctness of the implementation
5. Provide detailed review with specific feedback
6. Give clear pass/fail recommendation (pass if 90%+, fail if below 90%)

Scoring Criteria:

- 90-100%: Plan followed excellently with minor or no deviations
- 70-89%: Plan mostly followed but with some deviations or missing parts
- 50-69%: Significant deviations from plan or incomplete implementation
- Below 50%: Major failure to follow the plan

Always provide structured, actionable feedback for improvement.
```

## Integration with ORCH Workflow

### Agent Mode Justification

- **subagent mode**: Both agents are designed to be called by the main ORCH agent, not used directly by users
- **Tool restrictions**: The reviewer agent has `edit: false` and `bash: false` to prevent it from making changes during review
- **Permission settings**: Aligned with their roles - implementer can modify files, reviewer cannot

### Workflow Considerations

The corrected agent definitions will allow the ORCH workflow in `orch.md` to properly invoke these agents using the `@agent_1` and `@agent_2` mentions. The agents will have appropriate tool access and permissions for their specific roles in the orchestration process.

## Additional Recommendations

1. **Test the agents**: After updating the definitions, test each agent individually to ensure they work correctly within OpenCode
2. **Validate tool access**: Confirm that the specified tools are available and functioning as expected
3. **Monitor performance**: Track how well the agents perform their roles in the ORCH workflow
4. **Update documentation**: Ensure any project documentation reflects the correct agent capabilities and usage

## Verification Results

### ✅ Agent Definitions Now Valid

Both agent files have been successfully updated to comply with OpenCode specifications:

#### zai-glm-4-5.md (Implementation Agent - @agent_1)

- **Status**: ✅ Valid OpenCode agent definition
- **Mode**: subagent (correct for ORCH workflow)
- **Tools**: Full access to file operations and shell commands
- **Permissions**: edit=allow, bash=allow (appropriate for implementation)
- **Model**: glm-4.5 with temperature 0.1 (focused execution)

#### github-copilot-grok-fast.md (Review Agent - @agent_2)

- **Status**: ✅ Valid OpenCode agent definition
- **Mode**: subagent (correct for ORCH workflow)
- **Tools**: Read-only access (no edit/write/bash)
- **Permissions**: edit=deny, bash=deny (prevents changes during review)
- **Model**: grok-code-fast-1 with temperature 0.2 (balanced analysis)

### Key Improvements Made:

1. **Standard Frontmatter**: Replaced custom fields with OpenCode-compliant structure
2. **Required Fields Added**: description, mode, tools, permission
3. **System Prompts Moved**: From nested `settings.system_prompt` to markdown body
4. **Appropriate Permissions**: Implementer can modify, reviewer cannot
5. **Tool Access Configured**: Based on agent roles in ORCH workflow

## Current Issues with Agent Definitions

### ✅ RESOLVED - All Issues Fixed

The previous issues have been addressed:

- ✅ Standard frontmatter structure implemented
- ✅ Required fields (mode, tools, description) added
- ✅ System prompts correctly placed in markdown body
- ✅ Permissions properly configured for agent roles

## File Locations

The agent files have been updated to use agents from the external repository `aptdnfapt/opencode-parallel-agents`:

### Current Agents (Sourced from External Repo)

- `agents/glm.md` - General coding agent with zai/glm-4.5 model
- `agents/deepseek.md` - General coding agent with chutes/deepseek-ai/DeepSeek-V3.1 model
- `agents/qwen.md` - General coding agent with myprovider/qwen3-coder-plus model
- `agents/template.md` - Template agent

### Symlinked Locations (OpenCode Expected Paths)

- `~/.config/opencode/agents/glm.md` → `agents/glm.md`
- `~/.config/opencode/agents/deepseek.md` → `agents/deepseek.md`

### Backup of Custom Agents

- `agents/backup_originals/implementor-zai-glm-4-5.md`
- `agents/backup_originals/reviewer-github-copilot-grok-fast.md`

This setup allows the agents to be version-controlled in the repository while still being accessible by OpenCode through the standard configuration paths. The agents are now sourced from the recommended external repository as per the README.
