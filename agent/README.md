# OpenCode ORCH Agents

## ⚠️ IMPORTANT: Correct Agent Folder Location

**Agents MUST be in `~/.config/opencode/agent/` (singular "agent", not "agents")**

OpenCode expects agents in the singular `agent` folder. The workspace `agents/` folder contains templates that get symlinked to the correct location.

## Using ORCH Workflow

### Quick Start

```bash
# 1. Install ORCH command
./install.sh

# 2. Run ORCH workflow
/orch "check the issue at ./issue/your-issue.md and the plan at ./plan/your-plan.md and start the ORCH workflow using @grok as agent_1 and @glm as agent_2"
```

### What ORCH Does

1. **@grok** (agent_1) → Implements plan exactly
2. **@glm** (agent_2) → Reviews compliance (90%+ required)
3. **Loop** → Fixes if score < 90%
4. **Complete** → Final summary

## Agent Setup Verification

### Check Agent Location

```bash
ls -la ~/.config/opencode/agent/
# Should show: grok.md, glm.md, implementor-zai-glm-4-5.md, reviewer-github-copilot-grok-fast.md
```

### Test Agents

```bash
# Test implementor
opencode run --agent grok "Confirm your role and temperature"

# Test reviewer
opencode run --agent glm "Confirm your role and temperature"
```

## Agent Roles

| Agent                                | Model                           | Temp | Permissions | Role               |
| ------------------------------------ | ------------------------------- | ---- | ----------- | ------------------ |
| `@grok`                              | github-copilot/grok-code-fast-1 | 0.1  | Full write  | Implementation     |
| `@glm`                               | zai/glm-4.5                     | 0.3  | Read-only   | Review             |
| `@implementor-zai-glm-4-5`           | zai/glm-4.5                     | 0.1  | Full write  | Alt Implementation |
| `@reviewer-github-copilot-grok-fast` | github-copilot/grok-code-fast-1 | 0.3  | Read-only   | Alt Review         |
| `@agentsmd-creator`                  | zai/glm-4.5                     | 0.3  | Full write  | AGENTS.md Creator  |
| `@rules-fetcher`                     | github-copilot/grok-code-fast-1 | 0.3  | Full write  | Rules Fetcher      |

## Troubleshooting

### "Agent not found" error

- Agents must be in `~/.config/opencode/agent/` (not `agents/`)
- Check symlinks: `ls -la ~/.config/opencode/agent/`

### Permission errors

- Implementor agents need `edit: allow`, `bash: allow`
- Reviewer agents need `edit: deny`, `bash: deny`

### ORCH command fails

- Ensure agents are properly configured
- Check model access and API keys
- Verify issue and plan files exist

## Agent Configuration

Each agent requires:

```yaml
---
description: "Role description"
mode: subagent
model: "provider/model"
temperature: 0.1-0.5
tools: { read: true, ... }
permission: { edit: allow|deny, ... }
---
Role instructions...
```

## Advanced Usage

### Custom Agents

1. Create `.md` file in this directory
2. Follow configuration format
3. Test: `opencode run --agent your-agent "test"`
4. Use: `/orch "... using @your-agent as agent_1 ..."`

### Alternative Workflows

```bash
# Use alternative agents
/orch "... using @implementor-zai-glm-4-5 as agent_1 and @reviewer-github-copilot-grok-fast as agent_2"
```

## Additional Agents

### @agentsmd-creator

- **Purpose**: Analyzes codebase and generates/updates `agents.md` with project-specific instructions for AI agents.
- **Usage**: `opencode run --agent agentsmd-creator "analyze this project and create agents.md"`
- **Output**: Creates `agents.md` in project root with architecture, workflows, and conventions.

### @rules-fetcher

- **Purpose**: Fetches relevant prompts, instructions, and chatmodes from https://github.com/github/awesome-copilot, using `agents.md` for context.
- **Usage**: `opencode run --agent rules-fetcher "fetch relevant rules for app development"`
- **Prerequisites**: Ensures `agents.md` exists (runs `agentsmd-creator` if needed).
- **Output**: Downloads files to appropriate folders, provides workflow summary.

## OpenCode Rules & Instructions Support

OpenCode supports setting rules, prompts, and instructions both globally and per project, injected into every LLM message.

### Global and Project-Specific Rules

- **Project**: Place `AGENTS.md` in project root.
- **Global**: Place `AGENTS.md` in `~/.config/opencode/AGENTS.md`.
- Both are merged and injected automatically.

### Custom Instruction Files

- Specify in `opencode.json` (project) or `~/.config/opencode/opencode.json` (global):
  ```json
  {
    "instructions": [
      "CONTRIBUTING.md",
      "docs/guidelines.md",
      ".cursor/rules/*.md"
    ]
  }
  ```
- Files are merged with `AGENTS.md`.

### Agent and Mode Prompts

- Set custom prompts in config:
  ```json
  {
    "agent": {
      "review": {
        "prompt": "{file:./prompts/code-review.txt}"
      }
    }
  }
  ```
- Works for agents and modes.

### Precedence

- Project overrides global, but both included.
- Customize behavior for all agents, specific agents, or modes.
