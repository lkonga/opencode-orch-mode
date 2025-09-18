# ORCH Workflow – AI Agent Guide

## Architecture (what exists here)
- Main orchestrator: .opencode_global/command/orch.md (installs as /orch)
- Sub-agents (singular folder name required): .opencode_global/agent/
  - @implementor-zai-glm-4-5 → implementation (write + bash)
  - @reviewer-github-copilot-grok-fast → review (read-only)
- Inputs/flow: ./issue/<name>.md (problem) → ./plan/<name>.md (approved plan) → implement → review → loop until ≥90% compliance

## Setup & Installation
- Preferred: symlink this repo’s global config mirror
  - ln -sfn "$(pwd)/.opencode_global" ~/.config/opencode
- Alternative (command only): ./install.sh (copies command/orch.md to ~/.config/opencode/command/). In this repo the canonical file is .opencode_global/command/orch.md.
- Agents must live in ~/.config/opencode/agent/ (singular "agent"). See .opencode_global/agent/*.md for ready configs.

## How to run the ORCH workflow
1) Create an issue: ./issue/<name>.md (problem, requirements, expected outcome)
2) Plan with main agent, then create ./plan/<name>.md with 2 sections:
   - Plain-English approach (no code, use arrows for clarity)
   - Detailed, file-by-file implementation steps
3) Clear context: /new
4) Execute: /orch "check the issue at ./issue/<name>.md and the plan at ./plan/<name>.md and start the ORCH workflow using @implementor-zai-glm-4-5 as agent_1 and @reviewer-github-copilot-grok-fast as agent_2"
5) Loop: Implementor executes exactly; Reviewer scores via git diff; iterate until score ≥90%; no commits are made automatically

## Conventions & Roles (enforced in this repo)
- Plans are the source of truth; implementor must follow exactly (no unplanned changes)
- No automatic commits; you decide when to commit
- Reviewer computes a compliance score (0–100%) by comparing plan vs git diff
- Folder naming: use agent/ (not agents/)

## Integration points
- OpenCode merges project AGENTS.md with global ~/.config/opencode/AGENTS.md
- Models/providers configured in .opencode_global/opencode.json (override secrets in your own environment)
- External agent templates available under workspace/external_agents/

## Key files to open first
- Orchestrator: .opencode_global/command/orch.md
- Agents: .opencode_global/agent/implementor-zai-glm-4-5.md, .opencode_global/agent/reviewer-github-copilot-grok-fast.md
- How-tos: docs/orch-workflow.md, docs/usage-examples.md, docs/agent-configuration.md, README.md

## Troubleshooting
- “Agent not found”: ensure ~/.config/opencode/agent/ exists (singular) or recreate the symlink above
- Low compliance/loops: simplify plan or split into multiple issue/plan pairs
- Install issues: prefer the symlink method; verify .opencode_global/command/orch.md is visible under ~/.config/opencode/command/
