# BTCA Codebase Search Skill

## Overview

This skill provides integration with **btca** (Better Context), a CLI tool for searching library/framework codebases by cloning repositories locally and querying the source code directly with AI assistance.

## What Makes BTCA Different

Unlike traditional documentation search:
- **Direct source access**: Searches actual code, not just docs
- **Always up-to-date**: Clones latest repos, no stale documentation
- **Implementation details**: Answers "how it works" not just "how to use it"
- **AI-powered**: Uses LLMs to synthesize answers from codebase context

## Installation Status

✅ **Bun**: Installed globally at `~/.bun/bin/bun` (v1.3.5)
✅ **btca**: Installed globally via `bun add -g btca opencode-ai`
✅ **Skill**: Created at `.vscode/skills/btca-codebase-search/SKILL.md`
✅ **AGENTS.md**: Updated with skill reference

## Quick Start

```bash
# Ask a question about a library
btca ask -r svelte -q "How does the $state rune work?"

# Interactive chat session
btca chat -r tailwindcss

# Add a new resource
btca config resources add -n laravel -t git -u https://github.com/laravel/framework -b master

# List available resources
btca config resources list
```

## Default Resources

btca comes pre-configured with:
- **svelte**: Svelte documentation website
- **tailwindcss**: Tailwind CSS documentation
- **nextjs**: Next.js framework docs

## OpenCode Integration

btca includes OpenCode integration via the `opencode` binary:

```bash
# Keep OpenCode instance running
btca open

# Run as server
btca serve -p 8080
```

## VSCode Integration

### Cursor Rules
```bash
mkdir -p .cursor/rules
curl -fsSL "https://btca.dev/rule" -o .cursor/rules/better_context.md
```

### AGENTS.md Integration
Add to your project's `AGENTS.md`:
```markdown
## btca
When the user says "use btca" for codebase/docs questions.

Run:
- `btca ask -r <resource> -q "<question>"`
- `btca chat -r <resource>`

Available resources: svelte, tailwindcss, nextjs
```

## Usage Examples

### Framework Internals
```bash
# Laravel routing
btca ask -r laravel -q "How does Route::middleware() work internally?"

# React hooks
btca ask -r react -q "How is useEffect cleanup implemented?"
```

### Version-Specific Questions
```bash
# Add specific version
btca config resources add -n laravel-10 -t git -u https://github.com/laravel/framework -b 10.x

# Ask version-specific
btca ask -r laravel-10 -q "What's new in Laravel 10's routing?"
```

### Interactive Exploration
```bash
btca chat -r svelte
# Then ask: "How does Svelte 5 runes reactivity work?"
```

## Configuration

Config location: `~/.config/btca/btca.json`

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

## Best Practices

1. **Be specific**: "How does X work?" > "Tell me about X"
2. **Use technical terms**: "How does $state rune work?" > "How does state work?"
3. **Reference code**: "How is validate() implemented in User model?"
4. **Regular updates**: Periodically update cloned repositories

## Token Efficiency

For AI agents:
- Use specific questions to reduce context
- Leverage collections for grouped resources
- Clear unused data regularly
- Prefer `ask` over `chat` for token efficiency

## Troubleshooting

```bash
# Verify installation
bun --version
btca --version

# Reinstall
bun add -g btca opencode-ai --force

# Check config
cat ~/.config/btca/btca.json

# Clear all caches
btca clear resources
btca clear collections
```

## Skill Triggers

Use this skill when:
- User says `$BTCA` or `$BetterContext`
- User mentions "btca", "codebase search", "search library code"
- User asks about library/framework internals
- Need up-to-date API documentation
- Exploring implementation details

## Progressive Disclosure Structure

The SKILL.md follows Progressive Disclosure principles:
- **D0**: Quick start and basic usage
- **D1**: Command reference and configuration
- **D2**: OpenCode/VSCode integration
- **D3**: Best practices and optimization
- **D4**: Advanced features and troubleshooting
- **D5**: Token efficiency and agent integration

## Related Skills

- **Documentation PD Navigator**: For traditional doc search
- **Relentless Web Research**: For web-based research
- **Architect-Coder Workflow**: For token-heavy operations

## Resources

- Official website: https://btca.dev/
- GitHub repo: https://github.com/bmdavis419/better-context
- Installation guide: https://btca.dev/getting-started

## Contributing

To improve this skill:
1. Test btca with different libraries
2. Document common use cases
3. Add troubleshooting tips
4. Update AGENTS.md with new patterns

## License

This skill follows the same license as the llm-rules repository.
