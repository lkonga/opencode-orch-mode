# Protected Repository Configuration

## Overview

The GitHub CLI skill protects certain repositories from write operations to prevent accidental modifications to critical upstream repositories. This protection is especially important for LLM agents that might inadvertently attempt to modify code in repositories they shouldn't have write access to.

## Protected Repository Types

### Microsoft Repositories

The following Microsoft repositories are protected by default:

- `microsoft/vscode` - Visual Studio Code
- `microsoft/vscode-copilot` - VS Code Copilot
- `microsoft/vscode-copilot-release` - VS Code Copilot Releases
- `microsoft/TypeScript` - TypeScript
- `microsoft/vscode-extensions` - VS Code Extensions

### User and Organization Restrictions

Write operations are only allowed on repositories owned by:
- Users: `lkonga`, `yzgyzinc`
- Organizations: `lkonga`, `yzgyzinc`

These can be customized via environment variables:
- `ALLOWED_USERS` - Comma-separated list of allowed GitHub usernames
- `ALLOWED_ORGS` - Comma-separated list of allowed GitHub organizations
- `MICROSOFT_REPOS` - Comma-separated list of protected Microsoft repositories

## Protection Rules

### Write Operations Blocked

The following operations are blocked on protected repositories:

- Creating issues (`gh issue create`)
- Editing issues (`gh issue edit`)
- Closing/reopening issues (`gh issue close`, `gh issue reopen`)
- Creating pull requests (`gh pr create`)
- Editing pull requests (`gh pr edit`)
- Merging pull requests (`gh pr merge`)
- Creating releases (`gh release create`)
- Editing releases (`gh release edit`)
- Deleting releases (`gh release delete`)
- Creating/editing gists (`gh gist create`, `gist edit`)
- Repository operations (`gh repo create`, `gh repo edit`, `gh repo delete`, `gh repo archive`, `gh repo transfer`)

### Read Operations Allowed

The following operations are always allowed on any repository:

- Viewing issues (`gh issue list`, `gh issue view`)
- Viewing pull requests (`gh pr list`, `gh pr view`)
- Viewing repository information (`gh repo view`)
- Listing releases (`gh release list`, `gh release view`)
- Viewing gists (`gh gist list`, `gh gist view`)
- Viewing workflow runs (`gh run list`, `gh run view`)
- Cloning repositories (`gh repo clone`)

## Override Mechanisms

### Human Override

Human operators can bypass protection using environment variables:

```bash
# Allow upstream operations (human only)
ALLOW_UPSTREAM=true gh issue create --repo microsoft/vscode

# Allow interactive commands (human only)
ALLOW_INTERACTIVE=true gh pr create
```

### System-wide Override

The protection can be completely disabled by setting the `ORIGINAL_GH` environment variable to point directly to the original GitHub CLI binary:

```bash
# Bypass all protection
ORIGINAL_GH=/usr/bin/gh-original gh <command>
```

## Integration with Skills

The protection integrates with other skills for seamless workflows:

- **$LocalSudoRunner**: Can be used for operations requiring elevated privileges
- **$WorktreeOrchestration**: Safely creates worktrees from protected repositories
- **$ArchitectCoder**: Analyzes code before creating issues/PRs

## Error Messages

When a write operation is blocked, the wrapper provides:

1. Clear indication of what was blocked
2. Explanation of why it was blocked
3. Guidance on alternative actions
4. Progressive disclosure hints to relevant skill documentation

Example:
```
❌ ERROR: 🚫 UPSTREAM OPERATION BLOCKED: gh issue create --repo microsoft/vscode

❌ MICROSOFT REPOSITORY PROTECTION:
  Repository 'microsoft/vscode' is a Microsoft repository
  Write operations on Microsoft repos are blocked for LLM agents

📖 LLM AGENT GUIDANCE:
  • Read operations (view, list, status) are allowed on Microsoft repos
  • Use 'gh issue list --repo microsoft/vscode' to read issues
  • Create issues/PRs in your own fork instead

💡 SKILL HINT (D4): See examples/basic-operations.md for reading from protected repos
```
