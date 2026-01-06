# GLM-4.7 Quick Restore Guide

## TL;DR

**The working configuration is from commit `8bd13fc` (Jan 3, 2026 18:26).**

## One-Line Restore Command

```bash
cd /home/lkonga/codes/opencode-related/opencode-orch-mode && git checkout 8bd13fc -- .opencode_global/opencode.json
```

## Verify It Worked

```bash
cat .opencode_global/opencode.json | grep -A 30 '"zai"'
```

You should see:
- Provider name: `"zai"` (NOT `zai-coding-plan`)
- Base URL: `"https://api.z.ai/api/coding/paas/v4"`
- NPM package: `"@ai-sdk/openai-compatible"`
- Three models: `glm-4.7`, `glm-4.7-thinking`, `glm-4.7-fast`

## What Was Wrong

The current configuration uses:
- ❌ Provider name: `zai-coding-plan` (breaks agent references)
- ❌ Only one model: `glm-4.7` (missing thinking/fast variants)

## What It Should Be

The working configuration uses:
- ✅ Provider name: `zai`
- ✅ Base URL: `https://api.z.ai/api/coding/paas/v4`
- ✅ Three models: glm-4.7, glm-4.7-thinking, glm-4.7-fast
- ✅ Agents configured: general, build, expert, normal

## Key Configuration

```json
{
  "provider": {
    "zai": {
      "name": "Z.AI",
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "https://api.z.ai/api/coding/paas/v4",
        "apiKey": "b2442a512a7940c2bb29caba28f49c8a.KoJlYSGjsvNxUPt6"
      },
      "models": {
        "glm-4.7": {
          "id": "glm-4.7",
          "name": "GLM-4.7",
          "reasoning": true,
          "tool_call": true
        },
        "glm-4.7-thinking": {
          "id": "glm-4.7",
          "name": "GLM-4.7 Thinking",
          "reasoning": true,
          "tool_call": true
        },
        "glm-4.7-fast": {
          "id": "glm-4.7",
          "name": "GLM-4.7 Fast",
          "reasoning": true,
          "tool_call": true
        }
      }
    }
  },
  "agent": {
    "general": {
      "model": "zai/glm-4.7",
      "description": "General-purpose agent for researching and multi-step tasks"
    },
    "build": {
      "model": "zai/glm-4.7",
      "description": "Build agent with reasoning enabled for complex development tasks"
    },
    "expert": {
      "description": "Expert subagent for complex tasks requiring deep reasoning and analysis.",
      "mode": "subagent",
      "model": "zai/glm-4.7-thinking"
    },
    "normal": {
      "description": "Normal subagent for routine tasks and quick operations.",
      "mode": "subagent",
      "model": "zai/glm-4.7-fast"
    }
  }
}
```

## Why This Works

1. **Correct Endpoint:** Coding Plan API is designed for GLM subscriptions
2. **Stable SDK:** OpenAI-compatible SDK is well-tested
3. **Simple Config:** No complex options that cause errors
4. **Three Modes:** Clear separation between thinking, fast, and default
5. **Agent Integration:** All agents properly configured

## Test It

After restoring, test with:

```bash
# Use the general agent
opencode --agent general

# Use the expert agent (with thinking)
opencode --agent expert

# Use the normal agent (fast, no thinking)
opencode --agent normal
```

## If You Need More Details

See the full report: `GLM-4.7-WORKING-CONFIGURATIONS-REPORT.md`

---

**Last Updated:** January 6, 2026  
**Tested Commit:** 8bd13fc  
**Status:** ✅ Working
