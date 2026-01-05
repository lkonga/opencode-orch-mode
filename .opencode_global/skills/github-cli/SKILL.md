
---
name: GitHub CLI
description: Safe GitHub CLI operations with LLM agent protection, blocking interactive commands and preventing accidental modifications to protected repositories
opencode_tools: "read,write,bash"
triggers: [$GitHubCLI, $GitHub, 'gh cli', 'github cli']
related_skills: [$LocalSudoRunner, $WorktreeOrchestration, $ArchitectCoder]
references: {'Safe commands': 'references/safe-commands.md', 'Protected repos': 'references/protected-repos.md', 'Error handling': 'references/error-handling.md', 'Configuration': 'references/configuration.md', 'Safe wrapper script': 'scripts/gh-safe.sh'}
---

# GitHub CLI

## Purpose (D0)

Execute GitHub CLI commands safely with LLM agent protection, preventing accidental modifications to protected repositories while blocking interactive commands that can hang automation.

## Quick Start (D0)

<reference title="Safe wrapper script" path="scripts/gh-safe.sh" />

```bash
# List issues from Microsoft repository (read-only, always safe)
$GitHubCLI gh issue list --repo microsoft/vscode --limit 5 --json number,title

# Create an issue in your repository (non-interactive)
$GitHubCLI gh issue create --title "Bug Report" --body "Detailed description" --repo yourusername/yourrepo
```

## Core Concepts (D1)

### Protection Overview

The GitHub CLI skill provides three layers of protection:

1. **Repository Protection**: Blocks write operations on protected repositories (Microsoft repos, etc.)
2. **Interactive Command Blocking**: Prevents commands that require user interaction and can hang automation
3. **Safe Operation Allowance**: Allows read operations on any repository and writes to user-owned repos

### Basic Usage Patterns

- **Read operations**: Always safe on any repository
- **Write operations**: Safe only on user-owned repositories
- **Interactive commands**: Blocked with clear error messages and alternatives
- **Non-interactive operations**: Allowed with proper parameters

### Key Safety Guarantees

- No accidental modifications to protected repositories
- No hanging automation from interactive prompts
- Clear error messages with actionable alternatives
- Human override mechanisms available when needed

## Common Patterns (D2)

### Reading from Protected Repositories

```bash
# List issues from Microsoft VS Code repository (non-interactive)
$GitHubCLI gh issue list --repo microsoft/vscode --limit 10 --json number,title

# List pull requests from Microsoft VS Code repository (non-interactive)
$GitHubCLI gh pr list --repo microsoft/vscode --limit 10 --json number,title

# View a specific pull request (non-JSON output is safe for viewing)
$GitHubCLI gh pr view 123456 --repo microsoft/vscode

# Get repository information (JSON output prevents pagination)
$GitHubCLI gh repo view microsoft/vscode --json name,description,stars

# List releases (non-interactive)
$GitHubCLI gh release list --repo microsoft/vscode --limit 10 --json tagName,name
```

### Creating Issues and Pull Requests

```bash
# Create an issue with title and body (non-interactive)
$GitHubCLI gh issue create \
  --title "Bug Found" \
  --body "Steps to reproduce..." \
  --repo yourusername/yourrepo

# Create a PR with auto-generated body
$GitHubCLI gh pr create \
  --title "Fix authentication bug" \
  --fill \
  --base main \
  --head feature-branch
```

### Error Handling and Recovery

When operations are blocked, you'll receive clear error messages with alternatives:

```bash
# This will be blocked (missing title/body)
$GitHubCLI gh issue create --repo microsoft/vscode

# Error message provides the solution:
# ✓ Use: gh issue create --title 'Your Title' --body 'Your description'
```

## Progressive Disclosure

### D3: Reference Materials
- **Command patterns**: <reference title="Safe commands" path="references/safe-commands.md" />
- **Repository protection**: <reference title="Protected repos" path="references/protected-repos.md" />
- **Error handling**: <reference title="Error handling" path="references/error-handling.md" />
- **Configuration**: <reference title="Configuration" path="references/configuration.md" />

### D4: Examples
- **Basic operations**: <reference title="Safe commands" path="references/safe-commands.md" />
- **Error handling**: <reference title="Error handling" path="references/error-handling.md" />
- **Configuration**: <reference title="Configuration" path="references/configuration.md" />
- **Protected repos**: <reference title="Protected repos" path="references/protected-repos.md" />

### D5: Advanced Topics
- **Complex workflows**: Integration with other skills
- **Customization**: Configuration options
- **Edge cases**: Handling special scenarios

## Progressive Disclosure

**References** (load only when needed):
<references>
  <reference title="Safe commands" path="references/safe-commands.md" description="Complete command patterns, read operations, write operations, examples" />
  <reference title="Protected repos" path="references/protected-repos.md" description="Repository protection rules, allowed operations, override mechanisms" />
  <reference title="Error handling" path="references/error-handling.md" description="Error messages, recovery procedures, debugging strategies" />
  <reference title="Configuration" path="references/configuration.md" description="Setup options, customization, environment configuration" />
  <reference title="Safe wrapper script" path="scripts/gh-safe.sh" description="Protection implementation, safety guarantees, usage" />
</references>

All references are already integrated inline in the usage sections above.
