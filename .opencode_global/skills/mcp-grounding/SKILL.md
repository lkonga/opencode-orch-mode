---
name: MCP Grounding
description: "Interactive Playwright MCP exploration and validation before scripting automation, enabling rapid iteration and debugging"
opencode_tools: "read,write,bash"
triggers: ['$MCPGrounding']
trigger_keywords: ['playwright', 'browser automation', 'mcp grounding', 'interactive testing', 'browser testing']
references: {}
---

# MCP Grounding - Rapid Iteration & Debugging

## Core Principle

Before scripting any automation, use VS Code's Playwright MCP tools directly via chat to explore, test, and validate actions interactively. This "grounding" approach allows you to iterate faster without writing/running Python scripts.

## Why This Works

### Multi-Client Support

- Both VS Code MCP (stdio) and standalone MCP (HTTP/SSE) can bind to the same Chrome instance
- Multiple MCP clients can connect simultaneously without conflict
- VS Code tools provide immediate feedback via chat interface
- See snapshots and confirm actions in real-time

## Grounding Workflow

### Step 1: Keep MCP Server Running

Keep the standalone MCP server running (Terminal 1)

### Step 2: Interactive Exploration

Use VS Code Playwright MCP tools in chat for exploration:

#### Available Tools

- **`browser_snapshot`**: Get current page structure with element ref IDs
- **`browser_click`**: Test clicking elements by their ref
- **`browser_type`**: Test typing into input fields
- **`browser_navigate`**: Test page navigation
- **`browser_scroll`**: Test scrolling actions
- **`browser_evaluate`**: Execute JavaScript in browser context

### Step 3: Validation Loop

For each action you want to automate:

1. **Test interactively** using MCP tools in chat
2. **Verify behavior** through snapshots and visual feedback
3. **Refine selectors** based on actual page structure
4. **Confirm success** before moving to next action

### Step 4: Translation to Code

Once an action is validated interactively:

1. **Translate** the working tool call into its Python client method equivalent
2. **Add validated code** to the automation script
3. **Preserve exact selectors** and parameters that worked

## Benefits

### Eliminates Trial-and-Error

- No more blind coding within Python scripts
- Test each action before committing to code
- Immediate visual feedback from live browser

### Faster Development

- Experiment with different element selectors instantly
- See results without running full scripts
- Dramatically speeds up debugging

### Higher Confidence

- Only script actions that have been validated
- Reduce runtime errors and failures
- Build automation incrementally with verified steps

## Key Insight

**Use VS Code MCP tools for interactive exploration (grounding), then script the validated actions in Python for robust automation.**

## Workflow Pattern

```
1. Start MCP Server (Terminal 1)
   ↓
2. Use VS Code MCP Tools (Chat)
   - browser_snapshot → Identify elements
   - browser_click → Test interaction
   - Verify result
   ↓
3. Action Validated?
   Yes → Add to Python script
   No  → Refine and retry
   ↓
4. Repeat for next action
```

## Integration with Other Skills

### With $ArchitectCoder

- **Main agent (Architect)** conducts interactive MCP sessions
- This is highly interactive work - not suitable for delegation
- Keep context light by focusing on one action at a time

### With $SurgicalImplementation

- Once actions are validated, trigger `$SurgicalImplementation` for precise code modifications
- Use exact selectors discovered during grounding
- Apply minimal changes to automation scripts

## Best Practices

### Do's

✓ Test each action individually before combining
✓ Use `browser_snapshot` frequently to understand page state
✓ Validate selectors against actual page structure
✓ Keep grounding sessions focused on specific workflows
✓ Document working selectors and element refs

### Don'ts

✗ Don't script automation without grounding first
✗ Don't assume selectors without verification
✗ Don't skip validation steps to save time
✗ Don't bulk-test multiple actions at once
✗ Don't forget to update scripts with validated code

## Related Skills

- `$ArchitectCoder`: For understanding delegation patterns and orchestrator workflow
- `$SurgicalImplementation`: For precise code modifications after validation
