# GitHub CLI Skill Configuration

## Environment Variables

The GitHub CLI skill can be configured through environment variables to customize its behavior:

### Protection Configuration

```bash
# Comma-separated list of allowed GitHub usernames
export ALLOWED_USERS="lkonga,yzgyzinc,myusername"

# Comma-separated list of allowed GitHub organizations
export ALLOWED_ORGS="lkonga,yzgyzinc,myorg"

# Comma-separated list of protected Microsoft repositories
export MICROSOFT_REPOS="microsoft/vscode,microsoft/vscode-copilot,microsoft/TypeScript"
```

### Override Configuration

```bash
# Allow operations on protected repositories (human only)
export ALLOW_UPSTREAM=true

# Allow interactive commands (human only)
export ALLOW_INTERACTIVE=true

# Use alternative GitHub CLI binary
export ORIGINAL_GH="/usr/local/bin/gh"
```

### GitHub CLI Environment

The skill sets the following environment variables to ensure non-interactive operation:

```bash
# Disable interactive prompts
export GH_PROMPT_DISABLED=true

# Prevent pager from hanging
export GH_PAGER="cat"

# Disable TTY detection
export GH_FORCE_TTY=false

# Disable color codes for cleaner output
export NO_COLOR=true
```

## Default Configuration

If not specified, the skill uses these default values:

- **ALLOWED_USERS**: `lkonga,yzgyzinc`
- **ALLOWED_ORGS**: `lkonga,yzgyzinc`
- **MICROSOFT_REPOS**: `microsoft/vscode,microsoft/vscode-copilot,microsoft/vscode-copilot-release,microsoft/TypeScript,microsoft/vscode-extensions`
- **ORIGINAL_GH**: `gh` (uses system GitHub CLI)

## Configuration Examples

### Adding New Users

To allow write operations for additional users:

```bash
export ALLOWED_USERS="lkonga,yzgyzinc,newuser"
```

### Adding New Organizations

To allow write operations for additional organizations:

```bash
export ALLOWED_ORGS="lkonga,yzgyzinc,neworg"
```

### Customizing Protected Repositories

To protect additional repositories:

```bash
export MICROSOFT_REPOS="microsoft/vscode,microsoft/vscode-copilot,facebook/react"
```

## Skill-Specific Configuration

### Progressive Disclosure Levels

The skill documentation is organized by progressive disclosure levels:

- **D0**: Quick start and core concepts
- **D1**: Basic usage patterns and safety guarantees
- **D2**: Common patterns and error handling
- **D3**: Reference documentation with detailed command patterns
- **D4**: Examples for basic operations and common workflows
- **D5**: Advanced integration patterns with other skills

### Error Message Customization

Error messages include progressive disclosure hints that reference specific documentation levels, helping agents find the most relevant information for their current task.

## Integration Patterns

### With Other Skills

The GitHub CLI skill is designed to work seamlessly with other skills:

1. **$LocalSudoRunner**: For operations requiring elevated privileges
2. **$WorktreeOrchestration**: For creating and managing git worktrees
3. **$ArchitectCoder**: For code analysis before creating issues/PRs

### Example Workflow

```bash
# List issues from a protected repository (read-only)
$GitHubCLI gh issue list --repo microsoft/vscode --limit 10 --json number,title

# Create a worktree for a protected repository (via $WorktreeOrchestration)
$WorktreeOrchestration create-worktree microsoft/vscode my-feature-branch

# Deploy from a GitHub release (via $LocalSudoRunner)
$LocalSudoRunner wget $(gh release view latest --repo owner/repo --json --jq '.assets[0].browser_download_url')
```

## Troubleshooting

### Common Issues

1. **Command blocked unexpectedly**
   - Check if the repository is in the protected list
   - Verify the operation type (read operations are always allowed)
   - Consider using the override mechanisms for human operators

2. **Pagination issues**
   - Add `--limit` or `--json` flags to list commands
   - The skill provides specific guidance for each command type

3. **Authentication required**
   - Authentication must be performed by a human operator
   - Use `ALLOW_INTERACTIVE=true` override for manual testing

### Debug Mode

For troubleshooting, you can check how the skill is processing commands:

```bash
# View error messages without executing
# The skill will show why a command is blocked and provide guidance
```

## File Locations

The skill files are located at:

- Main skill documentation: `.vscode/skills/github-cli/SKILL.md`
- Wrapper script: `.vscode/skills/github-cli/scripts/gh-safe.sh`
- Reference documentation: `.vscode/skills/github-cli/references/`
