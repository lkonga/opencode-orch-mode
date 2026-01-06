# OpenCode Structure Explanation

## Date
January 6, 2026

## 📁 Directory Structure

The OpenCode ecosystem has **two separate locations** with different purposes:

### 1. **llm-rules** (Central Source)
```
llm-rules/
├── .vscode/
│   └── skills/              # VS Code skills (source)
│       ├── architect-coder-workflow/
│       ├── btca-codebase-search/
│       ├── cf-launcher/
│       ├── laravel-*/
│       └── [other skills]/
│
└── skills-opencode/         # OpenCode skills (source)
    ├── README.md
    ├── CLAUDE.md
    ├── architect-coder-workflow/
    ├── btca-codebase-search/
    ├── laravel-*/
    └── [other skills]/
```

**Purpose**: Contains the **skill definitions** (reusable workflows and capabilities)
- **Skills** are like "tools" or "capabilities" that agents can use
- Examples: `$RelentlessWebResearch`, `$LaravelTestingExcellence`, `$WorktreeOrchestration`
- Each skill is a directory with `SKILL.md` and reference documentation

### 2. **opencode-orch-mode** (Agent Definitions)
```
opencode-orch-mode/
├── .opencode/
│   ├── agent/              # OpenCode agents (source)
│   │   ├── general.md
│   │   ├── explore.md
│   │   ├── coder.md
│   │   ├── expert.md
│   │   ├── build.md
│   │   ├── plan.md
│   │   ├── reviewer.md
│   │   ├── summarizer.md
│   │   ├── repositoryAnalyst.md
│   │   ├── quickReviewer.md
│   │   └── PromptEnhancer.md
│   │
│   ├── skill → llm-rules/skills-opencode/  (symlink)
│   ├── CLAUDE.md → llm-rules/skills-opencode/CLAUDE.md  (symlink)
│   └── opencode.json      # Built-in agent configurations
│
└── .vscode/
    └── skills → llm-rules/.vscode/skills/  (symlink)
```

**Purpose**: Contains the **agent definitions** (AI personalities with specific roles)
- **Agents** are like "people" with specific capabilities and behaviors
- Examples: `@general`, `@expert`, `@coder`, `@explore`
- Each agent is a `.md` file with YAML frontmatter and system prompt

## 🔑 Key Differences

| Aspect | Skills | Agents |
|--------|--------|--------|
| **Location** | `llm-rules/skills-opencode/` | `opencode-orch-mode/.opencode/agent/` |
| **Purpose** | Capabilities and workflows | AI personalities and roles |
| **Trigger** | `$SkillName` (e.g., `$RelentlessWebResearch`) | `@agent` (e.g., `@general`) |
| **Structure** | Directory with `SKILL.md` + references | Single `.md` file with YAML + prompt |
| **Distribution** | Symlinked to all projects | Symlinked to OpenCode projects |
| **Example** | `$LaravelTestingExcellence` skill | `@general` agent |

## 🚀 How init-skills Works

The `init-skills` script sets up the correct symlinks based on the mode:

### VS Code Mode (default)
```bash
init-skills
```
Creates:
- `.vscode/skills` → `llm-rules/.vscode/skills/`
- `AGENTS.md` → `llm-rules/AGENTS.md`

### OpenCode Mode
```bash
init-skills --opencode
```
Creates:
- `.opencode/skill` → `llm-rules/skills-opencode/`
- `.opencode/agent` → `opencode-orch-mode/.opencode/agent/`
- `CLAUDE.md` → `llm-rules/skills-opencode/CLAUDE.md`

## 📦 Complete Agent List

### Core Agents (11 total)

| Agent | Description | Model | Special |
|-------|-------------|-------|---------|
| **@general** | General-purpose research and multi-step tasks | glm-4.7 | - |
| **@explore** | Fast codebase exploration (10 iterations max) | MiniMax-M2.1-TEE | Read-only |
| **@coder** | Implementation specialist (delegates to @explore) | gpt-5.2 | Full tools |
| **@expert** | Expert reviewer with ultrathink | gpt-5.2 | Ultrathink |
| **@build** | Default primary agent with all tools | glm-4.7 | Primary mode |
| **@plan** | Planning specialist for structured development | - | - |
| **@reviewer** | Code review specialist | - | - |
| **@summarizer** | Summarization and documentation | - | - |
| **@repositoryAnalyst** | Deep codebase analyst with ultrathink | gpt-5.2 | Ultrathink |
| **@quickReviewer** | Quick code review | - | - |
| **@PromptEnhancer** | Prompt enhancement specialist | - | - |

### Built-in Agents (in opencode.json)

These are configured in `.opencode/opencode.json` and don't need `.md` files:
- `@general` - General-purpose agent
- `@expert` - Expert subagent with deep reasoning
- `@normal` - Normal subagent for routine tasks
- `@build` - Build agent with reasoning enabled
- `@explore` - Explore agent (read-only)
- `@coder` - Coder agent

**Note**: The `.md` files in `.opencode/agent/` provide more detailed configurations and can be used as alternatives to the built-in agents.

## 🔄 Workflow Example

### Using Skills with Agents

```bash
# In OpenCode, you can combine agents and skills:

@general "Use $RelentlessWebResearch to find information about X"
@coder "Use $SurgicalImplementation to make these changes"
@expert "Use $DocumentationPDNavigator to analyze the docs"
```

### Agent Delegation

Agents can delegate to other agents:
```bash
@coder "Implement this feature (will delegate to @explore for context discovery)"
@expert "Review this code (uses ultrathink for deep analysis)"
```

## 📂 File Locations Summary

| What | Where | Source |
|------|-------|--------|
| VS Code Skills | `.vscode/skills/` | `llm-rules/.vscode/skills/` |
| OpenCode Skills | `.opencode/skill/` | `llm-rules/skills-opencode/` |
| OpenCode Agents | `.opencode/agent/` | `opencode-orch-mode/.opencode/agent/` |
| VS Code Docs | `AGENTS.md` | `llm-rules/AGENTS.md` |
| OpenCode Docs | `CLAUDE.md` | `llm-rules/skills-opencode/CLAUDE.md` |

## 🎯 Best Practices

1. **Skills** go in `llm-rules/skills-opencode/` (centralized, shared across projects)
2. **Agents** go in `opencode-orch-mode/.opencode/agent/` (project-specific, but can be symlinked)
3. Use `init-skills` to set up symlinks automatically
4. Don't modify skills in project directories (changes will be lost)
5. Agent `.md` files provide detailed configs beyond `opencode.json`

## 🐛 Common Issues

### Issue: "Where are the agents?"
**Solution**: Agents are in `opencode-orch-mode/.opencode/agent/`, not in `llm-rules`

### Issue: "Why is .opencode/agent/ empty?"
**Solution**: Run `init-skills --opencode` to symlink agents from `opencode-orch-mode`

### Issue: "What's the difference between skill and agent?"
**Solution**:
- **Skill** = Capability/workflow (e.g., "How to do Laravel testing")
- **Agent** = Personality/role (e.g., "Expert reviewer who thinks deeply")

## 📚 Related Documentation

- `AGENT-RECOVERY-REPORT.md` - How agents were recovered from git history
- `INIT-SKILLS-FIXES.md` - Bug fixes for the init-skills script
- `skills-opencode/README.md` - OpenCode skills documentation
- `docs/agent-configuration.md` - Detailed agent configuration guide
