---
name: BTCA Codebase Search
description: "AI-powered codebase search CLI - ask questions about any library/framework by cloning repos locally and searching source code directly. Works with OpenCode and VSCode for optimal developer experience."
opencode_tools: "read,write,bash"
triggers: ['$BTCA', '$BetterContext', 'btca', 'codebase search', 'search library code', 'framework documentation']
references: {}
---

# BTCA Codebase Search (Better Context)

## Core Principle

**Direct source code answers** - `btca` clones library/framework repositories locally and searches the actual source code to answer questions, providing up-to-date information that never goes stale.

## What is BTCA?

`btca` (Better Context) is a CLI tool that:
- Clones git repositories of libraries/frameworks locally
- Searches source code directly to answer questions
- Provides accurate, up-to-date information from actual code
- Works with AI models to synthesize answers from codebase context
- Supports both OpenCode and VSCode integrations

## Installation

### Prerequisites
- Bun package manager (install via `curl -fsSL https://bun.sh/install | bash`)
- Node.js/Bun runtime environment

### Install Globally
```bash
bun add -g btca opencode-ai
btca --help
```

### Verify Installation
```bash
btca --version
btca --help
```

### PATH Configuration

**CRITICAL**: After installation, ensure binaries are in your PATH. The installation adds to `~/.bashrc` and `~/.zshrc` automatically, but you may need to:

```bash
# For current session only
export PATH="$HOME/.bun/bin:$PATH"

# For new terminal sessions (already done by installer)
# Restart terminal or run:
source ~/.bashrc    # For bash users
source ~/.zshrc     # For zsh users
```

### Binary Availability Check

**FOR AGENTS**: Before using btca, ALWAYS verify binary availability:

```bash
# Check if bun is available
if ! command -v bun &> /dev/null; then
    echo "ERROR: bun not found in PATH"
    echo "Please fix by running:"
    echo "  export PATH=\"\$HOME/.bun/bin:\$PATH\""
    echo "  # OR restart your terminal"
    echo "  # OR source ~/.bashrc or ~/.zshrc"
    exit 1
fi

# Check if btca is available
if ! command -v btca &> /dev/null; then
    echo "ERROR: btca not found in PATH"
    echo "Please fix by running:"
    echo "  export PATH=\"\$HOME/.bun/bin:\$PATH\""
    echo "  # OR restart your terminal"
    echo "  # OR source ~/.bashrc or ~/.zshrc"
    echo ""
    echo "If still not working, reinstall:"
    echo "  bun add -g btca opencode-ai"
    exit 1
fi

# Verify versions
bun --version    # Should be 1.3.5 or higher
btca --version   # Should be 0.6.42 or higher
```

**If binaries are not available, return to user with instructions**:
1. Add to PATH: `export PATH="$HOME/.bun/bin:$PATH"`
2. Restart terminal or source shell config: `source ~/.bashrc` or `source ~/.zshrc`
3. If still failing, reinstall: `bun add -g btca opencode-ai --force`

## Quick Start

### 1. Add a Resource (Git Repository)
```bash
# Add a framework/library
btca config resources add -n svelte -t git -u https://github.com/sveltejs/svelte -b main

# Add Laravel
btca config resources add -n laravel -t git -u https://github.com/laravel/framework -b master

# Add a specific branch
btca config resources add -n tailwindcss -t git -u https://github.com/tailwindlabs/tailwindcss -b next
```

### 2. Ask Questions
```bash
# Single question
btca ask -r svelte -q "How does the $state rune work?"

# Interactive chat
btca chat -r laravel
```

## OpenCode Integration

### Binary Usage
`btca` includes OpenCode integration via the `opencode` binary installed with `opencode-ai`:

```bash
# Keep an OpenCode instance running
btca open

# Run as a server for OpenCode
btca serve -p 8080
# Then POST /question with:
# {"tech": "svelte", "question": "how does query remote function work in sveltekit?"}
```

### AGENTS.md Integration
Add this to your project's `AGENTS.md` so agents know when to use btca:

```markdown
## btca
When the user says "use btca" for codebase/docs questions about libraries/frameworks.

Run:
- `btca ask -r <resource> -q "<question>"` for single questions
- `btca chat -r <resource>` for interactive sessions

Available resources: svelte, laravel, tailwindcss, react (add your own)
```

## VSCode Integration

### Cursor Rule Setup
Run this command in your project root:
```bash
mkdir -p .cursor/rules
curl -fsSL "https://btca.dev/rule" -o .cursor/rules/better_context.md
echo "Rule file created."
```

This creates a Cursor rule file that enables btca integration for AI-assisted codebase searches.

### Usage in VSCode
- Use `btca ask` for quick questions about libraries
- Use `btca chat` for interactive exploration
- Combine with VSCode's AI features for enhanced context

## Configuration

### Config Location
On first run, `btca` creates a config at:
```
~/.config/btca/btca.json
```

This file stores:
- Resource list (repositories)
- Model/provider settings
- Search paths and preferences

### Common Config Commands
```bash
# List configured resources
btca config resources list

# Add new resource interactively
btca config resources add

# Set AI model
btca config model -p <provider> -m <model>

# List collections
btca config collections list

# Clear collections
btca config collections clear -k <key>
```

## Command Reference

### Ask
Answer a single question about a resource:
```bash
btca ask -r <resource> -q "<question>"
```

### Chat
Open interactive TUI session:
```bash
btca chat -r <resource>
```

### Config
Manage configuration:
```bash
btca config resources list
btca config resources add -n <name> -t git -u <url> -b <branch>
btca config resources remove -n <name>
btca config model -p <provider> -m <model>
```

### Clear
Clear cached data:
```bash
btca clear resources
btca clear collections
```

## Optimal Usage Patterns

### For OpenCode Users
1. **Pre-configure common resources**: Add frequently used frameworks to config
2. **Use `btca serve`**: Run as server for programmatic access
3. **Integrate with AGENTS.md**: Let agents know when to use btca
4. **Combine with OpenCode workflows**: Use btca for codebase context during development

### For VSCode Users
1. **Install Cursor rules**: Enable AI integration in Cursor
2. **Quick questions**: Use `btca ask` for rapid answers
3. **Deep exploration**: Use `btca chat` for complex investigations
4. **Keep resources updated**: Regularly update cloned repositories

### For AI Agents
1. **Trigger conditions**: Use when user asks about library/framework internals
2. **Resource selection**: Choose appropriate pre-configured resource
3. **Question formulation**: Craft specific, technical questions for best results
4. **Answer synthesis**: Combine btca output with reasoning for comprehensive responses

## Best Practices

### Resource Management
- **Keep resources focused**: One resource per library/framework
- **Use specific branches**: Pin to stable branches (main, master, vX.X)
- **Regular updates**: Periodically update cloned repositories
- **Add notes**: Document resource purpose in config

### Question Formulation
- **Be specific**: "How does X work?" > "Tell me about X"
- **Use technical terms**: "How does $state rune work?" > "How does state work?"
- **Reference code**: "How is validate() implemented in User model?"
- **Ask about internals**: btca excels at implementation details

### Performance Tips
- **Use collections**: Group related resources for faster access
- **Clear cache periodically**: Remove old cached data
- **Monitor disk space**: Cloned repos can consume significant space
- **Use specific branches**: Avoid cloning entire histories

## Common Use Cases

### Framework Documentation
```bash
# Laravel routing
btca ask -r laravel -q "How does Route::middleware() work internally?"

# React hooks
btca ask -r react -q "How is useEffect cleanup implemented?"
```

### Library Internals
```bash
# State management
btca chat -r svelte
# Ask: "How does Svelte 5 runes reactivity work?"

# CSS framework
btca ask -r tailwindcss -q "How are utility classes generated?"
```

### Version-Specific Questions
```bash
# Add specific version
btca config resources add -n laravel-10 -t git -u https://github.com/laravel/framework -b 10.x

# Ask version-specific question
btca ask -r laravel-10 -q "What's new in Laravel 10's routing?"
```

## Troubleshooting

### Binary Not Found Errors

**Symptoms**: `command not found: btca` or `command not found: bun`

**Solution**:
```bash
# 1. Add to PATH for current session
export PATH="$HOME/.bun/bin:$PATH"

# 2. Verify binaries are now available
command -v bun && echo "✓ bun found" || echo "✗ bun still not found"
command -v btca && echo "✓ btca found" || echo "✗ btca still not found"

# 3. If found, make persistent by restarting terminal or sourcing:
source ~/.bashrc    # For bash users
source ~/.zshrc     # For zsh users

# 4. If still not found, check if binaries exist:
ls -la ~/.bun/bin/btca
ls -la ~/.bun/bin/bun

# 5. If binaries exist but not in PATH, reinstall:
bun add -g btca opencode-ai --force
```

### Installation Issues
```bash
# Verify Bun is installed
bun --version

# If bun not found, reinstall Bun:
curl -fsSL https://bun.sh/install | bash

# Then reinstall btca
export PATH="$HOME/.bun/bin:$PATH"
bun add -g btca opencode-ai --force

# Verify installation
btca --version
```

### Resource Issues
```bash
# List resources to verify
btca config resources list

# Remove and re-add problematic resource
btca config resources remove -n <name>
btca config resources add -n <name> -t git -u <url> -b <branch>
```

### Performance Issues
```bash
# Clear all caches
btca clear resources
btca clear collections

# Check disk usage
du -sh ~/.config/btca/
```

### Agent-Specific Troubleshooting

**For AI Agents Using This Skill**:

1. **Always check binary availability first**:
```bash
# Pre-flight check before any btca operation
if ! command -v btca &> /dev/null; then
    echo "ERROR: btca binary not found in PATH"
    echo ""
    echo "USER ACTION REQUIRED:"
    echo "1. Run: export PATH=\"\$HOME/.bun/bin:\$PATH\""
    echo "2. OR restart your terminal"
    echo "3. OR run: source ~/.bashrc (or ~/.zshrc for zsh users)"
    echo ""
    echo "If the issue persists after trying the above:"
    echo "  bun add -g btca opencode-ai --force"
    exit 1
fi
```

2. **If binaries are missing, STOP and inform user** - do not attempt to proceed with btca commands

3. **Provide clear, actionable error messages** with exact commands to run

4. **After user fixes the issue**, verify with:
```bash
command -v btca && btca --version
```

## Advanced Features

### Multiple Resources
Query multiple repositories in one session:
```bash
btca chat -r laravel -r svelte -r react
```

### Custom Search Paths
Specify which parts of repo to search:
```bash
btca config resources add -n mylib -t git -u <url> -b main --search-path "src/"
```

### Notes and Documentation
Add notes to resources for context:
```bash
btca config resources add -n mylib -t git -u <url> -b main --notes "Custom library for X"
```

## Integration Examples

### With AI Agents
Add to AGENTS.md:
```markdown
## btca Integration
Use $BTCA when:
- User asks about library/framework internals
- Need up-to-date API documentation
- Exploring implementation details
- Understanding version-specific changes

Example triggers:
- "How does [feature] work in [library]?"
- "Show me the implementation of [method]"
- "What's the architecture of [component]?"
```

### With Development Workflows
```bash
# Before implementing a feature
btca ask -r laravel -q "How do middleware work in Laravel?"

# During debugging
btca chat -r react
# Ask: "How does React handle state updates?"

# For code review
btca ask -r svelte -q "What's the best practice for component composition?"
```

## Token Efficiency

For token-heavy research tasks:
1. **Use specific questions**: Narrow scope to reduce context
2. **Leverage collections**: Pre-group related resources
3. **Clear unused data**: Regularly clean up caches
4. **Use ask over chat**: Single questions are more token-efficient

## Agent Usage Checklist

**FOR AI AGENTS**: Follow this checklist before using btca:

### 1. Pre-Flight Checks
```bash
# Check bun availability
if ! command -v bun &> /dev/null; then
    echo "ERROR: bun binary not found in PATH"
    echo "Fix: export PATH=\"\$HOME/.bun/bin:\$PATH\" && source ~/.bashrc (or ~/.zshrc)"
    exit 1
fi

# Check btca availability
if ! command -v btca &> /dev/null; then
    echo "ERROR: btca binary not found in PATH"
    echo "Fix: export PATH=\"\$HOME/.bun/bin:\$PATH\" && source ~/.bashrc (or ~/.zshrc)"
    echo "If persistent: bun add -g btca opencode-ai --force"
    exit 1
fi

# Verify versions
bun --version && btca --version
```

### 2. If Binaries Missing
**STOP and inform user with clear instructions**:
1. Add to PATH: `export PATH="$HOME/.bun/bin:$PATH"`
2. Source config: `source ~/.bashrc` or `source ~/.zshrc`
3. Restart terminal if needed
4. Reinstall if still failing: `bun add -g btca opencode-ai --force`

### 3. After User Fixes Issue
```bash
# Verify the fix worked
command -v btca && btca --version
```

### 4. Proceed with btca Commands
Only after all checks pass, execute btca commands.

## Summary

`btca` provides direct access to library/framework source code, ensuring accurate, up-to-date information. Perfect for:
- Understanding implementation details
- Exploring unfamiliar codebases
- Getting version-specific answers
- AI-assisted code research

Key commands:
- `btca ask -r <resource> -q "<question>"` - Quick answers
- `btca chat -r <resource>` - Interactive exploration
- `btca config resources add` - Add new libraries
- `btca open` - OpenCode integration
