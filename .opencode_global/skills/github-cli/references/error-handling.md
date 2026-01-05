# GitHub CLI Error Handling and Recovery

## Error Message Structure

The GitHub CLI wrapper provides structured error messages with the following components:

1. **Error Header**: Clear indication of what went wrong
2. **Explanation**: Why the operation was blocked
3. **Guidance**: What the LLM agent should do instead
4. **Skill Hints**: Progressive disclosure pointers to additional resources
5. **Override Options**: Human-only bypass mechanisms (when applicable)

## Interactive Command Errors

### Issue Creation Without Title/Body

**Error Message**:
```
❌ ERROR: 🚫 INTERACTIVE COMMAND BLOCKED: gh issue create

This command requires user interaction and will hang LLM agents.

🔧 HOW TO FIX (LLM AGENTS READ THIS):
  ✓ Use: gh issue create --title 'Your Title' --body 'Your description'
  ✓ Or:  gh issue create --title 'Your Title' --body-file description.md

  IMPORTANT: Both --title AND --body (or --body-file) are REQUIRED
  Without both, the command opens an editor which blocks automation
```

**Recovery Pattern**:
```bash
# Instead of: gh issue create --repo owner/repo
# Use: gh issue create --title "Descriptive Title" --body "Detailed description" --repo owner/repo
```

### PR Creation Without Title/Body

**Error Message**:
```
❌ ERROR: 🚫 INTERACTIVE COMMAND BLOCKED: gh pr create

This command requires user interaction and will hang LLM agents.

🔧 HOW TO FIX (LLM AGENTS READ THIS):
  ✓ Use: gh pr create --title 'Your Title' --body 'Your description'
  ✓ Or:  gh pr create --title 'Your Title' --body-file description.md
  ✓ Or:  gh pr create --fill (auto-generates from commits)

  IMPORTANT: Both --title AND --body/--fill are REQUIRED
  Without both, the command opens an editor which blocks automation
```

**Recovery Pattern**:
```bash
# Instead of: gh pr create --base main --head feature-branch
# Use: gh pr create --title "Feature: Add new functionality" --fill --base main --head feature-branch
```

### Browser Opening

**Error Message**:
```
❌ ERROR: 🚫 INTERACTIVE COMMAND BLOCKED: gh browse

This command requires user interaction and will hang LLM agents.

🔧 HOW TO FIX (LLM AGENTS READ THIS):
  ✓ Use: gh browse --no-browser
    (This prints the URL without opening a browser)
```

**Recovery Pattern**:
```bash
# Instead of: gh browse
# Use: gh browse --no-browser
```

### Authentication Commands

**Error Message**:
```
❌ ERROR: 🚫 INTERACTIVE COMMAND BLOCKED: gh auth login

This command requires user interaction and will hang LLM agents.

🔧 HOW TO FIX (LLM AGENTS READ THIS):
  ✗ Authentication MUST be done by a human operator
  ✗ Cannot be automated - security requirement

  💡 Human operator bypass: ALLOW_INTERACTIVE=true gh auth login
```

**Recovery Pattern**:
```bash
# No automated recovery for authentication
# Human operator must run: ALLOW_INTERACTIVE=true gh auth login
```

## Repository Protection Errors

### Microsoft Repository Write Operations

**Error Message**:
```
❌ ERROR: 🚫 UPSTREAM OPERATION BLOCKED: gh issue create --repo microsoft/vscode

❌ MICROSOFT REPOSITORY PROTECTION:
  Repository 'microsoft/vscode' is a Microsoft repository
  Write operations on Microsoft repos are blocked for LLM agents

📖 LLM AGENT GUIDANCE:
  • Read operations (view, list, status) are allowed on Microsoft repos
  • Use 'gh issue list --repo microsoft/vscode' to read issues
  • Use 'gh pr list --repo microsoft/vscode' to read pull requests
  • Create issues/PRs in your own fork instead

💡 To override (human only): ALLOW_UPSTREAM=true gh issue create --repo microsoft/vscode
```

**Recovery Pattern**:
```bash
# Instead of: gh issue create --repo microsoft/vscode --title "Bug" --body "Description"
# Use: gh issue create --repo yourusername/yourfork --title "Bug" --body "Description"

# Or read from Microsoft repo:
gh issue list --repo microsoft/vscode --limit 10
```

### Unknown Repository Write Operations

**Error Message**:
```
❌ ERROR: 🚫 UPSTREAM OPERATION BLOCKED: gh issue create --repo unknown/repo

Repository 'unknown/repo' is not in allowed users/orgs: lkonga, yzgyzinc

📖 LLM AGENT GUIDANCE:
  • Only write to repositories you own or are explicitly allowed
  • Use 'gh repo create' to create your own repository
  • Fork the repository first if you need to make changes
```

**Recovery Pattern**:
```bash
# Instead of: gh issue create --repo unknown/repo --title "Bug" --body "Description"
# Use: gh repo fork unknown/repo --clone=false
# Then: gh issue create --repo yourusername/unknown --title "Bug" --body "Description"
```

## System-Level Errors

### GitHub CLI Not Found

**Error Message**:
```
❌ ERROR: GitHub CLI not found at: gh
💡 SKILL (D3): Install GitHub CLI from https://cli.github.com/
```

**Recovery Pattern**:
```bash
# Install GitHub CLI using package manager
# On Ubuntu/Debian:
sudo apt install gh

# On macOS:
brew install gh

# Or download from https://cli.github.com/
```

### Command Not Found

**Error Message**:
```
❌ ERROR: Command not found: gh-nonexistent
💡 SKILL (D3): Check command spelling and refer to safe-commands.md
```

**Recovery Pattern**:
```bash
# Check available commands
gh --help

# Refer to safe command reference
# See: references/safe-commands.md
```

## Error Recovery Strategies

### 1. Parameter Completion

For commands blocked due to missing parameters:

1. **Identify Missing Parameters**: Check error message for required parameters
2. **Add Required Parameters**: Provide all required parameters explicitly
3. **Use File Inputs**: For long content, use `--body-file` instead of `--body`
4. **Use Auto-generation**: For PRs, use `--fill` to auto-generate from commits

### 2. Repository Substitution

For commands blocked due to repository protection:

1. **Fork First**: Fork the protected repository
2. **Use Your Fork**: Work with your fork instead of the original
3. **Read Operations**: Use read operations on the original repository
4. **Reference Original**: Mention the original repository in issue/PR descriptions

### 3. Command Alternatives

For commands blocked due to interactive nature:

1. **Use Non-interactive Flags**: Add flags like `--no-browser`
2. **Use Alternative Commands**: Use different commands that achieve the same goal
3. **Use API Directly**: For complex operations, use the GitHub API
4. **Use Web Interface**: For one-time operations, use the GitHub web interface

### 4. Environment Configuration

For commands blocked due to environment issues:

1. **Check Installation**: Verify GitHub CLI is properly installed
2. **Check Authentication**: Verify you're authenticated with GitHub
3. **Check Permissions**: Verify you have necessary permissions
4. **Check Configuration**: Verify environment variables are set correctly

## Skill Progressive Disclosure in Errors

### D3 Hints

Basic command patterns and configuration:
```
💡 SKILL (D3): Install GitHub CLI from https://cli.github.com/
💡 SKILL (D3): See references/safe-commands.md for complete command reference
💡 SKILL (D3): See references/protected-repos.md for complete protection rules
```

### D4 Hints

Examples and workflows:
```
💡 SKILL (D4): See examples/basic-operations.md for reading from protected repos
💡 SKILL (D4): See examples/common-workflows.md for creating issues in your repos
💡 SKILL (D4): See examples/basic-operations.md for more examples
```

### D5 Hints

Advanced integration and customization:
```
💡 SKILL (D5): See examples/integration-patterns.md for advanced workflows
💡 SKILL (D5): See examples/integration-patterns.md for integration with other skills
```

## Testing Error Handling

To test error handling:

1. **Test Interactive Commands**:
   ```bash
   ./scripts/gh-safe.sh gh issue create --repo microsoft/vscode
   ```

2. **Test Repository Protection**:
   ```bash
   ./scripts/gh-safe.sh gh issue create --repo unknown/repo --title "Test" --body "Test"
   ```

3. **Run Verification Script**:
   ```bash
   ./scripts/verify-gh-safety.sh
   ```

## Best Practices

### For LLM Agents

1. **Read Error Messages**: Carefully read and understand error messages
2. **Follow Guidance**: Use the specific alternatives provided in error messages
3. **Check Skill Hints**: Use progressive disclosure hints for additional resources
4. **Provide Complete Parameters**: Always provide all required parameters

### For Human Operators

1. **Understand Protection**: Know why operations are blocked
2. **Use Bypasses Judiciously**: Only override protection when necessary
3. **Check Alternatives**: Use the suggested alternatives before using overrides
4. **Provide Feedback**: Report confusing error messages or missing alternatives

### For Skill Developers

1. **Clear Error Messages**: Provide clear, actionable error messages
2. **Include Alternatives**: Always suggest valid alternatives
3. **Add Skill Hints**: Include progressive disclosure hints in error messages
4. **Test Error Paths**: Thoroughly test all error scenarios
