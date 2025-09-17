# Architecture

This project implements the ORCH (Agent Orchestration) workflow for OpenCode, a structured approach to issue resolution through collaborative planning and execution. The system consists of three main components:

- **Command Orchestrator**: `command/orch.md` coordinates the entire workflow and installs as `/orch` slash command
- **Sub-agents**: Specialized agents in `agent/` directory with distinct roles (implementation vs review)
- **Documentation**: Comprehensive guides in `docs/` explaining workflow phases and configurations

The architecture follows a clear separation of concerns: main agent coordinates, implementation agent executes, review agent evaluates quality. This ensures consistent, high-quality code implementation while maintaining human oversight.

# Workflows

## ORCH Workflow Execution
1. **Install**: Run `./install.sh` to copy `command/orch.md` to `~/.config/opencode/command/`
2. **Issue Creation**: Create issue files in `./issue/` directory with problem descriptions and requirements
3. **Planning**: Interactive planning session with main agent to create plan files in `./plan/` directory
4. **Execution**: Run `/orch "check the issue at ./issue/name.md and the plan at ./plan/name.md and start the ORCH workflow using @agent_1 as agent_1 and @agent_2 as agent_2"`
5. **Quality Loop**: Implementation agent executes plan → Review agent evaluates compliance → Loop until 90%+ score achieved

## Agent Setup
Agents must be placed in `~/.config/opencode/agent/` (singular folder name). Use `agent/README.md` for verification and troubleshooting.

# Conventions

## File Structure
- Issue files: `./issue/<name>.md` - Problem descriptions with requirements and expected outcomes
- Plan files: `./plan/<name>.md` - Two-section format: plain English explanation + detailed implementation steps
- Agent configs: `agent/*.md` - YAML frontmatter with model, tools, permissions, and role instructions

## Agent Roles
- **Implementation Agent** (`@implementor-zai-glm-4-5`): Low temperature (0.1), full write permissions, executes plans exactly
- **Review Agent** (`@reviewer-github-copilot-grok-fast`): Moderate temperature (0.3), read-only, calculates compliance scores
- **Main Agent**: Coordinates workflow, never codes directly

## Quality Standards
- 90%+ compliance threshold required for workflow completion
- Review agents use git diff to compare implementation vs plan
- No automatic commits - user controls all commit decisions
- Plans are source of truth - implementors follow exactly without deviations

# Integration Points

## OpenCode Runtime
- Commands installed to `~/.config/opencode/command/`
- Agents configured in `~/.config/opencode/agent/`
- Supports custom instruction files via `opencode.json`

## External Dependencies
- Git integration for diff-based review process
- Model providers: ZAI (glm-4.5), GitHub Copilot (grok-code-fast-1)
- External agent templates in `workspace/external_agents/` for additional model support

## Key Files
- Workflow orchestrator: `command/orch.md`
- Agent configurations: `agent/implementor-zai-glm-4-5.md`, `agent/reviewer-github-copilot-grok-fast.md`
- Documentation: `docs/orch-workflow.md`, `docs/usage-examples.md`, `docs/agent-configuration.md`
- Installation: `install.sh`