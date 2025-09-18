---
description: "Copilot instructions for ORCH workflow in this repo"
applyTo: ".github/copilot-instructions.md"
---

## Purpose

Guidance for AI coding agents working in this repo. This project defines an ORCH (Agent Orchestration) workflow for OpenCode that delegates implementation and review to sub-agents, driven by an issue file and a plan file.

## Big picture architecture

- Main pieces
  - Command: `command/orch.md` installs as `/orch` via `./install.sh` and coordinates the workflow (you never code as main agent).
  - Agents: `agent/*.md` define sub-agent roles:
    - Implementor: `agent/implementor-zai-glm-4-5.md` (writes code, low temp, full edit/bash perms)
    - Reviewer: `agent/reviewer-github-copilot-grok-fast.md` (read-only, computes compliance score)
  - Docs: `docs/orch-workflow.md`, `docs/usage-examples.md`, `docs/agent-configuration.md` explain phases and agent configs.
- Data flow (why it’s structured this way)
  - Inputs: `./issue/<name>.md` (problem) and `./plan/<name>.md` (approved plan)
  - Phase 1: Implementor executes plan exactly, makes edits but does not commit
  - Phase 2: Reviewer compares git diff vs plan and scores compliance (0–100%)
  - Loop until ≥90% compliance, then main agent summarizes; user decides when to commit

## Critical workflows (commands and paths)

- Install slash command
  - Run from repo root: `./install.sh` (copies `command/orch.md` to `~/.config/opencode/command/`)
- Required agent placement (singular directory name)
  - Agents must be in `~/.config/opencode/agent/` (not `agents/`). See `agent/README.md`.
- Run ORCH
  - Example: `/orch "check the issue at ./issue/add-feature-x.md and the plan at ./plan/add-feature-x.md and start the ORCH workflow using @implementor-zai-glm-4-5 as agent_1 and @reviewer-github-copilot-grok-fast as agent_2"`
- Clear context between planning and execution
  - Use `/new` before invoking `/orch` to free context window (see docs).

## Project conventions and patterns

- Issue/Plan files
  - Place user-authored issue files under `./issue/` and approved plans under `./plan/` with matching names.
  - Plans are the source of truth. Implementor MUST follow them exactly—no unplanned changes.
- No automatic commits
  - Implementor edits files but never commits; reviewer evaluates changes using git diff; user controls commits.
- Compliance threshold
  - Reviewer computes compliance; main agent loops implementor/reviewer until ≥90%.
- Agent configs
  - Implementor: low temperature (e.g., 0.1), full `bash/edit/read/write` tools, explicit “follow plan exactly” scope.
  - Reviewer: read-only tools, `bash: false`, provides structured review + score. See agent MD files for exact YAML.
- External agent templates
  - Additional templates live in `workspace/external_agents/` and may be symlinked/ported to global config.

## Integration points

- OpenCode runtime and CLI
  - This repo assumes OpenCode is installed and reads commands/agents from `~/.config/opencode/...`.
- Git
  - Reviews rely on `git diff` to assess implementation vs plan.
- Optional external resources
  - Some docs refer to external agent packs (e.g., opencode-parallel-agents) for more agent definitions.

## Concrete examples (use and modify in-context)

- Create issue and plan
  - `./issue/fix-auth-bug.md`, `./plan/fix-auth-bug.md` with clear requirements; see `docs/usage-examples.md` for templates.
- Run a session
  - `/orch "check the issue at ./issue/fix-auth-bug.md and the plan at ./plan/fix-auth-bug.md and start the ORCH workflow using @grok as agent_1 and @glm as agent_2"`
- Troubleshooting
  - If agents are “not found”, verify `~/.config/opencode/agent/` contains your agent files (singular folder name).
  - If loops never converge, simplify the plan or break into smaller issue/plan pairs.

## Pointers to key files

- Command orchestrator: `command/orch.md`
- Agents and roles: `agent/implementor-zai-glm-4-5.md`, `agent/reviewer-github-copilot-grok-fast.md`, `agent/README.md`
- Workflow docs: `docs/orch-workflow.md`, `docs/usage-examples.md`, `docs/agent-configuration.md`
- Installer: `install.sh`
