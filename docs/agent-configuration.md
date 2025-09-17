# Agent Configuration Documentation

## Overview

The ORCH workflow uses three types of agents, each with specific roles and configurations. Understanding these configurations is essential for effective workflow execution.

## Agent Types

### 1. Main Agent
The main agent coordinates the entire ORCH workflow but never directly implements code.

**Role:**
- Analyzes issue files and codebase
- Facilitates planning discussions
- Creates plan files based on discussions
- Orchestrates sub-agent execution
- Provides final workflow summaries

**Configuration:**
- Typically your default OpenCode agent (github-copilot with GPT-5)
- Full access to all tools and permissions
- Temperature settings optimized for planning and coordination

### 2. Implementation Agent (@agent_1)
The implementation agent executes development plans exactly as specified.

**Current Configuration: `@implementor-zai-glm-4-5`**

**Role:**
- Reads and understands issue and plan files
- Executes plans EXACTLY as written - no deviations
- Implements all components specified in the plan
- Works efficiently and aggressively to complete tasks
- Stays strictly within scope - no suggestions or improvements
- Provides clear summaries of what was implemented
- Never commits changes - only makes code changes

**Technical Configuration:**
```yaml
description: Implementation specialist for ORCH workflow - executes development plans exactly as specified
mode: subagent
tools:
  bash: true
  edit: true
  read: true
  write: true
  list: true
  glob: true
  grep: true
permission:
  edit: allow
  bash:
    "*": allow
  webfetch: allow
model: zai/glm-4.5
temperature: 0.1
```

**Configuration Details:**
- **Model**: ZAI GLM-4.5 - Balanced model with good coding capabilities and reasonable speed
- **Temperature**: 0.1 - Low temperature ensures consistent, precise implementation without creativity
- **Tools**: Full access to coding tools (bash, edit, read, write, search tools)
- **Permissions**:
  - Edit: Allowed to modify files
  - Bash: Full shell access for running commands
  - WebFetch: Allowed for fetching external resources if needed

### 3. Review Agent (@agent_2)
The review agent evaluates implementation compliance and provides detailed feedback.

**Current Configuration: `@reviewer-github-copilot-grok-fast`**

**Role:**
- Reads original issue and plan files
- Checks git diff to see what changes were made
- Compares implemented changes against plan requirements
- Calculates compliance score (0-100%) based on:
  - How many plan items were fully implemented
  - How closely implementation follows the plan's approach
  - Whether any unplanned changes were made
  - Quality and correctness of implementation
- Provides detailed review with specific feedback
- Gives clear pass/fail recommendation (pass if 90%+, fail if below 90%)

**Scoring Criteria:**
- 90-100%: Plan followed excellently with minor or no deviations
- 70-89%: Plan mostly followed but with some deviations or missing parts
- 50-69%: Significant deviations from plan or incomplete implementation
- Below 50%: Major failure to follow the plan

**Technical Configuration:**
```yaml
description: Quality reviewer for ORCH workflow - evaluates implementation compliance and provides detailed feedback
mode: subagent
tools:
  bash: false
  edit: false
  read: true
  write: false
  list: true
  glob: true
  grep: true
permission:
  edit: deny
  bash:
    "*": deny
  webfetch: allow
model: github-copilot/grok-code-fast-1
temperature: 0.3
```

**Configuration Details:**
- **Model**: GitHub Copilot Grok Code Fast 1 - Fast model optimized for code analysis and review
- **Temperature**: 0.3 - Moderate temperature for balanced analytical evaluation
- **Tools**: Read-only access (read, list, glob, grep) to analyze code without modification
- **Permissions**:
  - Edit: Denied to prevent accidental changes during review
  - Bash: Denied to maintain review integrity
  - WebFetch: Allowed for fetching additional context if needed

## Agent Selection Guidelines

### Choosing Implementation Agents
- **Speed vs. Quality**: Faster models (like Grok) for simple tasks, more capable models for complex implementations
- **Task Complexity**: Match model capabilities to implementation complexity
- **Cost Considerations**: Balance performance with resource usage

### Choosing Review Agents
- **Analysis Speed**: Fast models preferred for quick feedback loops
- **Code Understanding**: Models with strong code analysis capabilities
- **Consistency**: Lower temperature settings for consistent evaluation

## Custom Agent Configuration

### Creating New Implementation Agents
1. Copy the template from `agents/backup/template.md`
2. Configure appropriate tools and permissions:
   - Enable `bash`, `edit`, `read`, `write` for implementation
   - Set appropriate model and temperature
   - Ensure implementation-specific instructions

### Creating New Review Agents
1. Copy the template from `agents/backup/template.md`
2. Configure read-only permissions:
   - Disable `bash`, `edit`, `write` to prevent modifications
   - Enable `read`, `list`, `glob`, `grep` for analysis
   - Set appropriate model and temperature for evaluation
   - Include review-specific scoring criteria

## Agent File Structure

```
agents/
├── backup/
│   ├── template.md          # Agent configuration template
│   ├── glm.md              # GLM model configuration
│   ├── grok.md             # Grok model configuration
│   └── qwen.md             # Qwen model configuration
├── implementor-zai-glm-4-5.md    # Current implementation agent
├── reviewer-github-copilot-grok-fast.md  # Current review agent
└── grok.md                 # Alternative agent configuration
```

## Best Practices

### For Implementation Agents
- Use low temperature (0.1-0.2) for consistent, precise execution
- Enable all necessary coding tools
- Include clear instructions to follow plans exactly
- Emphasize scope limitations to prevent feature creep

### For Review Agents
- Use moderate temperature (0.3-0.4) for balanced evaluation
- Restrict to read-only tools to maintain review integrity
- Define clear scoring criteria and thresholds
- Provide structured feedback templates

### For Main Agent
- Use your preferred model for planning and coordination
- Ensure full tool access for comprehensive analysis
- Focus on clear communication and plan refinement

## Troubleshooting Agent Issues

### Agent Not Found
- Verify agent files exist in correct location
- Check agent configuration syntax
- Ensure model is available and accessible

### Permission Errors
- Review tool permissions in agent configuration
- Verify API keys and model access
- Check for conflicting permission settings

### Performance Issues
- Adjust temperature settings for task type
- Consider model capabilities vs. task complexity
- Monitor resource usage and response times

## Agent Workflow Integration

The agents work together in a specific sequence:

1. **Main Agent** → Planning and orchestration
2. **Implementation Agent** → Code execution
3. **Review Agent** → Quality evaluation
4. **Loop** → Back to implementation if score < 90%
5. **Main Agent** → Final summary and completion

This structured approach ensures consistent, high-quality implementation while maintaining human oversight throughout the process.