# BTCA Quick Start Guide

## Installation Complete ✅

Bun and btca are installed globally and ready to use!

## Immediate Usage

### Basic Commands
```bash
# Ask a question (single query)
btca ask -r svelte -q "How does the $state rune work?"

# Interactive chat session
btca chat -r tailwindcss

# List available resources
btca config resources list

# Add a new library/framework
btca config resources add -n laravel -t git -u https://github.com/laravel/framework -b master
```

## Default Resources

btca comes pre-configured with:
- **svelte** - Svelte documentation
- **tailwindcss** - Tailwind CSS documentation
- **nextjs** - Next.js framework docs

## OpenCode Integration

```bash
# Keep OpenCode instance running
btca open

# Run as server for programmatic access
btca serve -p 8080
```

## VSCode Integration

### For Cursor Users
```bash
mkdir -p .cursor/rules
curl -fsSL "https://btca.dev/rule" -o .cursor/rules/better_context.md
```

### For AGENTS.md Integration
Add to your project's `AGENTS.md`:

```markdown
## btca
When the user says "use btca" for codebase/docs questions.

Run:
- `btca ask -r <resource> -q "<question>"`
- `btca chat -r <resource>`

Available resources: svelte, tailwindcss, nextjs
```

## Skill Triggers

Use this skill when:
- User says `$BTCA` or `$BetterContext`
- User mentions "btca", "codebase search", "search library code"
- User asks about library/framework internals
- Need up-to-date API documentation

## Common Use Cases

### Framework Documentation
```bash
btca ask -r svelte -q "How does the $state rune work?"
btca ask -r tailwindcss -q "How are utility classes generated?"
btca ask -r nextjs -q "How does server actions work?"
```

### Implementation Details
```bash
btca chat -r svelte
# Ask: "How does Svelte 5 runes reactivity work?"
```

### Version-Specific Questions
```bash
# Add specific version
btca config resources add -n laravel-10 -t git -u https://github.com/laravel/framework -b 10.x

# Ask version-specific
btca ask -r laravel-10 -q "What's new in Laravel 10?"
```

## Configuration

Config file location: `~/.config/btca/btca.json`

### Common Commands
```bash
# List resources
btca config resources list

# Add resource
btca config resources add -n <name> -t git -u <url> -b <branch>

# Remove resource
btca config resources remove -n <name>

# Set model
btca config model -p <provider> -m <model>

# Clear caches
btca clear resources
btca clear collections
```

## Tips for Best Results

1. **Be specific**: "How does X work?" > "Tell me about X"
2. **Use technical terms**: "How does $state rune work?" > "How does state work?"
3. **Reference code**: "How is validate() implemented?"
4. **Regular updates**: Resources auto-update on first use

## Troubleshooting

### Command Not Found

If you get `command not found: btca` or `command not found: bun`:

```bash
# Quick fix for current session
export PATH="$HOME/.bun/bin:$PATH"

# Verify it works
command -v btca && echo "✓ btca found" || echo "✗ Still not found"

# Make permanent - restart terminal OR source your shell config:
source ~/.bashrc    # For bash users
source ~/.zshrc     # For zsh users
```

### If Still Not Working

```bash
# Check if binaries exist
ls -la ~/.bun/bin/btca
ls -la ~/.bun/bin/bun

# Reinstall if needed
curl -fsSL https://bun.sh/install | bash
export PATH="$HOME/.bun/bin:$PATH"
bun add -g btca opencode-ai --force
```

### Check Installation
```bash
bun --version    # Should be 1.3.5 or higher
btca --version   # Should be 0.6.42 or higher
```

### For AI Agents

**Always check binary availability before using btca**:

```bash
# Pre-flight check
if ! command -v btca &> /dev/null; then
    echo "ERROR: btca not found. Please run:"
    echo "  export PATH=\"\$HOME/.bun/bin:\$PATH\""
    echo "  source ~/.bashrc (or ~/.zshrc)"
    exit 1
fi
```

## Learn More

- Full documentation: See `SKILL.md`
- Installation details: See `INSTALLATION_SUMMARY.md`
- Official site: https://btca.dev/
- GitHub: https://github.com/bmdavis419/better-context

## Summary

✅ Bun installed (v1.3.5)
✅ btca installed (v0.6.42)
✅ Skill created and integrated
✅ AGENTS.md updated
✅ Ready to use!

Start asking questions about any library/framework by cloning their repos and searching the source code directly!
