# Safe GitHub CLI Command Patterns

## Read Operations (Always Safe)

### Repository Information
- `gh repo view owner/repo` - View repository information
- `gh repo view owner/repo --json name,description,stars` - Get specific repository fields
- `gh repo list` - List your repositories
- `gh repo list --limit 10` - List limited number of repositories
- `gh repo search "query"` - Search for repositories

### Issues
- `gh issue list --repo owner/repo --json number,title` - List issues as JSON (prevents pagination)
- `gh issue list --repo owner/repo --limit 10` - List limited number of issues
- `gh issue list --repo owner/repo --state closed --json number,title` - List closed issues as JSON
- `gh issue list --repo owner/repo --label bug --json number,title` - List issues with specific label as JSON
- `gh issue view 123 --repo owner/repo` - View a specific issue
- `gh issue view 123 --repo owner/repo --json title,body,state` - Get specific issue fields
- `gh issue status --repo owner/repo` - Show issue status summary

### Pull Requests
- `gh pr list --repo owner/repo --json number,title` - List PRs as JSON (prevents pagination)
- `gh pr list --repo owner/repo --limit 10` - List limited number of PRs
- `gh pr list --repo owner/repo --state closed --json number,title` - List closed PRs as JSON
- `gh pr view 123 --repo owner/repo` - View a specific pull request
- `gh pr view 123 --repo owner/repo --json title,body,state` - Get specific PR fields
- `gh pr checks 123 --repo owner/repo` - View PR status checks
- `gh pr diff 123 --repo owner/repo` - View PR diff
- `gh pr status --repo owner/repo` - Show PR status summary

### Releases
- `gh release list --repo owner/repo --json tagName,name` - List releases as JSON (prevents pagination)
- `gh release list --repo owner/repo --limit 10` - List limited number of releases
- `gh release view tag --repo owner/repo` - View a specific release
- `gh release view latest --repo owner/repo` - View latest release
- `gh release download tag --repo owner/repo` - Download release assets

### Workflows
- `gh workflow list --repo owner/repo --json name,id` - List workflows as JSON (prevents pagination)
- `gh workflow view workflow-id --repo owner/repo` - View a specific workflow
- `gh workflow run workflow-id --repo owner/repo` - Run a workflow (safe if no required inputs)
- `gh workflow list --repo owner/repo --limit 10` - List limited number of workflows

### Actions
- `gh run list --repo owner/repo --json databaseId,status` - List runs as JSON (prevents pagination)
- `gh run view run-id --repo owner/repo` - View a specific workflow run
- `gh run list --repo owner/repo --limit 10` - List limited number of runs
- `gh run watch run-id --repo owner/repo` - Watch a run (non-interactive)

### Extensions
- `gh extension list` - List installed extensions
- `gh extension search name` - Search for extensions
- `gh extension view owner/repo` - View extension details

### Authentication (Read-only)
- `gh auth status` - Check authentication status
- `gh auth token` - Show current auth token (safe, read-only)

### Miscellaneous
- `gh browse --no-browser` - Print repository URL without opening browser
- `gh api endpoint` - Make API requests (read-only endpoints)
- `gh gist list` - List your gists
- `gh gist view gist-id` - View a specific gist

## Write Operations (Conditional)

### Issues (Safe with complete parameters)

#### Create Issue
```bash
# Safe: Both title and body provided
gh issue create --title "Issue Title" --body "Issue description" --repo owner/repo
gh issue create --title "Issue Title" --body-file description.md --repo owner/repo
gh issue create --title "Issue Title" --body "Issue description" --label bug,high-priority --repo owner/repo
gh issue create --title "Issue Title" --body "Issue description" --assignee username --repo owner/repo
```

#### Comment on Issue
```bash
# Safe: Comment body provided
gh issue comment 123 --body "This needs investigation" --repo owner/repo
gh issue comment 123 --body-file comment.md --repo owner/repo
```

#### Close Issue
```bash
# Safe: No interaction required
gh issue close 123 --repo owner/repo
gh issue close 123 --comment "Fixed in PR #456" --repo owner/repo
```

#### Reopen Issue
```bash
# Safe: No interaction required
gh issue reopen 123 --repo owner/repo
```

### Pull Requests (Safe with complete parameters)

#### Create PR
```bash
# Safe: Both title and body provided
gh pr create --title "PR Title" --body "PR description" --base main --head feature-branch
gh pr create --title "PR Title" --body-file description.md --base main --head feature-branch
gh pr create --title "PR Title" --fill --base main --head feature-branch  # Auto-generate body
gh pr create --title "PR Title" --fill-first --base main --head feature-branch  # Auto-generate body from first commit
```

#### Comment on PR
```bash
# Safe: Comment body provided
gh pr comment 123 --body "This looks good" --repo owner/repo
gh pr comment 123 --body-file comment.md --repo owner/repo
```

#### Merge PR
```bash
# Safe: No interaction required
gh pr merge 123 --merge --repo owner/repo
gh pr merge 123 --squash --repo owner/repo
gh pr merge 123 --rebase --repo owner/repo
gh pr merge 123 --delete-branch --repo owner/repo
```

#### Close PR
```bash
# Safe: No interaction required
gh pr close 123 --repo owner/repo
gh pr close 123 --comment "Superseded by PR #456" --repo owner/repo
```

#### Reopen PR
```bash
# Safe: No interaction required
gh pr reopen 123 --repo owner/repo
```

### Repositories (Safe with complete parameters)

#### Create Repository
```bash
# Safe: All options provided
gh repo create new-repo --public --description "New repository" --clone=false
gh repo create new-repo --private --description "Private repository" --clone=false
gh repo create new-repo --public --clone=false  # Minimal safe options
```

#### Fork Repository
```bash
# Safe: No interaction required
gh repo fork owner/repo
gh repo fork owner/repo --clone=false
```

### Releases (Safe with complete parameters)

#### Create Release
```bash
# Safe: Title and notes provided
gh release create v1.0.0 --title "Version 1.0.0" --notes "Release notes"
gh release create v1.0.0 --title "Version 1.0.0" --notes-file release-notes.md
gh release create v1.0.0 --title "Version 1.0.0" --notes "Release notes" --latest
```

## Blocked Operations (Never Safe for LLM)

### Authentication
- `gh auth login` - Requires interactive authentication
- `gh auth refresh` - Requires interactive token refresh
- `gh auth setup-git` - Requires interactive configuration

### Browsing
- `gh browse` (without `--no-browser`) - Opens browser
- `gh extension browse` - Opens browser

### Repository Creation (Interactive)
- `gh repo create` (without `--clone=false`) - Prompts for cloning
- `gh repo create` (without `--public` or `--private`) - Prompts for visibility

### Issues (Interactive)
- `gh issue create` (without both `--title` AND `--body`) - Opens editor
- `gh issue create` (without `--title`) - Prompts for title
- `gh issue create` (without `--body`) - Prompts for body
- `gh issue edit` - Always opens editor
- `gh issue lock` (without `--reason`) - Prompts for reason

### Pull Requests (Interactive)
- `gh pr create` (without both `--title` AND `--body`/`--fill`) - Opens editor
- `gh pr create` (without `--title`) - Prompts for title
- `gh pr create` (without `--body` AND without `--fill`) - Opens editor
- `gh pr edit` - Always opens editor
- `gh pr ready` - May prompt for confirmation
- `gh pr draft` - May prompt for confirmation

### Protected Repository Operations
- Any write operation on Microsoft repositories
- Any write operation on repositories not owned by allowed users/orgs

## Error Recovery Patterns

When a command is blocked, use these patterns:

1. **Interactive Commands**: Add required parameters or flags
   ```bash
   # Instead of: gh issue create
   # Use: gh issue create --title "Title" --body "Description"
   ```

2. **Browse Commands**: Add `--no-browser` flag
   ```bash
   # Instead of: gh browse
   # Use: gh browse --no-browser
   ```

3. **Protected Repositories**: Use your own repository or fork
   ```bash
   # Instead of: gh issue create --repo microsoft/vscode
   # Use: gh issue create --repo yourusername/yourrepo
   ```

4. **Repository Creation**: Provide all required options
   ```bash
   # Instead of: gh repo create new-repo
   # Use: gh repo create new-repo --public --clone=false
   ```
