# GLM-4.7 Configuration Restoration Summary

## Changes Applied

**Base Configuration:** Restored from commit `a270627` (January 3, 2026 at 16:07)

**Modifications Made:**

### 1. Removed `reasoning: true` from base `glm-4.7` model

**Before (commit a270627):**
```json
"glm-4.7": {
  "id": "glm-4.7",
  "name": "GLM-4.7",
  "attachment": false,
  "reasoning": true,        // ← REMOVED
  "temperature": true,
  "tool_call": true,
  ...
}
```

**After (current):**
```json
"glm-4.7": {
  "id": "glm-4.7",
  "name": "GLM-4.7",
  "attachment": false,
  "temperature": true,
  "tool_call": true,
  ...
}
```

### 2. Kept reasoning flags for specialized models

Both `glm-4.7-thinking` and `glm-4.7-fast` retain their `"reasoning": true` flags.

### 3. Build agent configuration

The `build` agent uses `zai/glm-4.7` (the base model without explicit reasoning flag).

## Provider Configuration

- **Provider Name:** `zai`
- **Base URL:** `https://api.z.ai/api/anthropic/v1`
- **NPM Package:** `@ai-sdk/anthropic`
- **API Key:** `b2442a512a7940c2bb29caba28f49c8a.KoJlYSGjsvNxUPt6`

## Available Models

1. **glm-4.7** - Base model without explicit reasoning flag (default for build agent)
2. **glm-4.7-thinking** - With reasoning enabled for expert subagent
3. **glm-4.7-fast** - With reasoning enabled for normal subagent

## Agent Assignments

- **general:** `zai/glm-4.7`
- **build:** `zai/glm-4.7` ← Uses base model without reasoning flag
- **expert:** `zai/glm-4.7-thinking` (subagent with system prompt)
- **normal:** `zai/glm-4.7-fast` (subagent with system prompt)

## Rationale

Removing the `reasoning: true` flag from the base `glm-4.7` model while keeping it for the specialized variants allows:
- The build agent to use standard GLM-4.7 behavior
- Expert and normal subagents to have explicit reasoning control
- More predictable behavior for the default build workflow

## Verification

To verify the configuration:
```bash
cat .opencode_global/opencode.json | jq '.provider.zai.models."glm-4.7"'
cat .opencode_global/opencode.json | jq '.agent.build'
```

