# OpenCode Skills Integration - Quick Reference

## 🚀 Quick Start

### Check Your Setup
```bash
cd /path/to/your/project
ls .opencode_global/agent/*.md | wc -l  # Should show: 19
ls .opencode_global/skills/ | wc -l      # Should show: 27
```

### Initialize Skills in Your Project
```bash
cd /path/to/your/project
init-skills --opencode
```

## 🎯 Agent Quick Reference

### For Implementation (Write Access)
- `@grok` - Fast implementation (github-copilot/grok-code-fast-1)
- `@implementor-zai-glm-4-5` - ZAI model implementation (zai/glm-4.5)
- `@gemini-implementor` - Local Gemini (google/gemini-2.5-pro)

### For Exploration (Read-Only)
- `@explore` - Fast discovery (chutes/MiniMaxAI/MiniMax-M2.1-TEE)
- `@general` - Research (zai-coding-plan/glm-4.7)

### For Review (Read-Only)
- `@reviewer-github-copilot-grok-fast` - Compliance review (github-copilot/grok-code-fast-1)
- `@quickReviewer` - Rapid validation (chutes/MiniMaxAI/MiniMax-M2.1-TEE)
- `@expert` - Deep analysis (github-copilot/gpt-5.2)

### For Planning (Read-Only)
- `@plan` - Analysis without modifications (zai-coding-plan/glm-4.7)
- `@general` - Research and planning (zai-coding-plan/glm-4.7)

## 🎨 Skill Quick Reference

### Mention skills in prompts using `$SkillName` syntax

### Infrastructure & Deployment
- `$WorktreeOrchestration` - Git worktree management
- `$VPSSudoPassword` - VPS sudo automation
- `$VPSLaravelDeployment` - Laravel deployment
- `$VPSGenericDeployment` - Generic deployment
- `$CFLauncher` - Cloudflare tunnels

### Development Workflows
- `$ArchitectCoderWorkflow` - Architect-coder pattern
- `$LaravelTestingExcellence` - Laravel testing
- `$LaravelAPIDevelopment` - RESTful API development
- `$LaravelSecurityPatterns` - Security implementation
- `$RelentlessWebResearch` - Web research with MCP

### Code Analysis
- `$BTCACodebaseSearch` - Codebase search
- `$DocumentationPDNavigator` - Documentation navigation
- `$CreatePDDocumentation` - Documentation creation

## 💡 Usage Examples

### Example 1: Implement a Feature
```bash
opencode run --agent grok "Implement user authentication using $LaravelSecurityPatterns"
```

### Example 2: Explore Codebase
```bash
opencode run --agent explore "Find all authentication files using $BTCACodebaseSearch"
```

### Example 3: Review Changes
```bash
opencode run --agent reviewer-github-copilot-grok-fast "Review the authentication implementation"
```

### Example 4: ORCH Workflow
```bash
/orch "check the issue at ./issue/add-feature.md and the plan at ./plan/add-feature.md and start the ORCH workflow using @grok as agent_1 and @reviewer-github-copilot-grok-fast as agent_2"
```

## 🔧 Agent-Skill Mapping

| Skill Type | Use Agent | Example |
|------------|-----------|---------|
| Implementation | @grok, @implementor-zai-glm-4-5 | `$VPSLaravelDeployment` |
| Exploration | @explore | `$BTCACodebaseSearch` |
| Review | @reviewer-github-copilot-grok-fast | Compliance check |
| Planning | @plan, @general | `$CreatePDDocumentation` |
| Research | @general, @expert | `$RelentlessWebResearch` |

## 📚 Full Documentation

- **SKILLS-INTEGRATION.md** - Complete integration guide
- **REMEDIATION-REPORT.md** - Remediation details
- **.opencode_global/agent/README.md** - Agent usage
- **AGENTS.md** (in llm-rules) - Master agents doc

## 🆘 Troubleshooting

### "Agent not found"
```bash
# Check agent exists
ls .opencode_global/agent/agent-name.md

# List all agents
ls .opencode_global/agent/
```

### "Skills not loading"
```bash
# Check skills symlink
ls -la .opencode_global/skills

# Should show: -> /home/lkonga/codes/llm-rules/.opencode_global/skills
```

### ORCH workflow fails
```bash
# Verify agents exist
ls .opencode_global/agent/grok.md
ls .opencode_global/agent/reviewer-github-copilot-grok-fast.md

# Check issue and plan files
ls ./issue/
ls ./plan/
```

## ✅ Verification Checklist

- [ ] 19 agents available in `.opencode_global/agent/`
- [ ] 27 skills accessible via `.opencode_global/skills/`
- [ ] Skills symlink points to llm-rules
- [ ] Can run `opencode run --agent grok "test"`
- [ ] Can run `opencode run --agent explore "test"`
- [ ] Can run `opencode run --agent reviewer-github-copilot-grok-fast "test"`

## 🎓 Best Practices

1. **Always use existing agents** - Don't create new ones
2. **Mention skills explicitly** - Use `$SkillName` syntax
3. **Choose the right agent** - Match agent to task type
4. **Use ORCH for complex tasks** - Create issue and plan files
5. **Read documentation** - Check SKILLS-INTEGRATION.md for details

## 📞 Getting Help

1. Check agent documentation: `.opencode_global/agent/README.md`
2. Check skill documentation: `.opencode_global/skills/<skill>/SKILL.md`
3. Read integration guide: `SKILLS-INTEGRATION.md`
4. Review remediation: `REMEDIATION-REPORT.md`

---

**Last Updated**: January 5, 2026
**Status**: ✅ Production Ready
