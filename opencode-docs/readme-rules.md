---
post_title: "Opencode Rules & Instructions: Project and Global Setup"
author1: "voidBeast"
post_slug: "opencode-rules-instructions"
microsoft_alias: "voidbeast"
featured_image: "https://opencode.ai/assets/rules-banner.png"
categories:
  - opencode
  - configuration
  - agents
tags:
  - rules
  - instructions
  - global
  - project
  - prompt
ai_note: true
summary: "How to set up and use global and per-project instructions/rules in opencode."
post_date: "2025-09-17"
---

## Setting Instructions & Rules in Opencode

### Automatic Porting Summary

When you use the `rules-fetcher` agent to port Copilot chatmodes, prompts, or instructions, it will automatically generate a concise `rules-fetcher-summary.md` after each run:

- For project scope (`--scope project`): Summarizes rationale and lists all files ported for the current `AGENTS.md`.
- For global scope (`--scope global`): Summarizes rationale and lists all meta/global files ported.

**Example (project scope):**

```md
# rules-fetcher-summary.md

## Rationale

Ported agents and instructions based on current AGENTS.md and project config to enable advanced code review and workflow automation.

## Files Ported

- agent/code-reviewer.md: Code review agent for Python
- prompts/project-coding-standards.md: Project-specific coding standards
- instructions/ci-workflow.md: CI workflow instructions

## Scope

Project: /path/to/project
Config: opencode.json
```

**Example (global scope):**

```md
# rules-fetcher-summary.md

## Rationale

Ported meta/global agents and instructions to enable consistent standards and workflows across all projects.

## Files Ported

- agent/meta-reviewer.md: Meta code review agent
- prompts/global-coding-standards.md: Global coding standards
- instructions/meta-workflows.md: Meta workflow instructions

## Scope

Global: ~/.config/opencode
Config: opencode.json
```

You can customize agent behavior by providing instructions/rules globally or per project. These are injected into every LLM message.

### 1. Project-Specific Instructions

- Create an `AGENTS.md` file in your project root.
- Add your rules/instructions in markdown.
- Example:

  ```md
  # Project Rules

  - Always write tests for new code
  - Use Python 3.10+
  ```

- Opencode will automatically include these for sessions in this project.

### 2. Global Instructions

- Create `AGENTS.md` in `~/.config/opencode/AGENTS.md`.
- Add personal/global rules here (not shared via git).
- Example:

  ```md
  # Global Rules

  - Prefer readable code
  - Ask before deleting files
  ```

- These apply to all projects unless overridden by project rules.

### 3. Custom Instruction Files

- List additional instruction files in your config (`opencode.json` or `~/.config/opencode/opencode.json`):
  ```json
  {
    "instructions": [
      "CONTRIBUTING.md",
      "docs/guidelines.md",
      ".cursor/rules/*.md"
    ]
  }
  ```
- All listed files are merged and injected for every message.

### 4. Agent & Mode Prompts

- Set custom prompts per agent or mode in config:
  ```json
  {
    "agent": {
      "review": {
        "prompt": "{file:./prompts/code-review.txt}"
      }
    },
    "mode": {
      "build": {
        "prompt": "{file:./prompts/build.txt}"
      }
    }
  }
  ```
- Paths are relative to the config file location.

## Precedence & Usage

- Project rules override global, but both are included.
- All instructions are merged and injected for every LLM message.
- To use: just add/edit the files as above—no extra commands needed.

## Mounting This Docs Folder

- Place this `opencode-docs` folder inside your opencode config directory as `docs` (e.g., `~/.config/opencode/docs`).
- Reference these docs for quick setup and troubleshooting.
