# Complete ORCH Workflow Example

This guide demonstrates how to use the ORCH workflow with the configured agents.

## Prerequisites

1. **Install ORCH command** (already done):
   ```bash
   ./install.sh
   ```

2. **Agents configured** (just created):
   - `@zai-glm-4-5` - Implementation specialist
   - `@github-copilot-grok-fast` - Quality reviewer

3. **Main agent**: Your default OpenCode agent (github-copilot with GPT-5)

## Example Scenario

Let's say we want to add a simple "Hello World" feature to a project.

### Step 1: Create Issue File

Create `./issue/add-hello-feature.md`:
```markdown
# Add Hello World Feature

## Problem
Our application needs a simple "Hello World" feature to greet users.

## Requirements
- Create a function that returns "Hello, World!"
- Add a simple CLI command to run it
- Include basic error handling
- Follow existing code style

## Expected Outcome
- Users can run a command that outputs "Hello, World!"
- Code is clean and follows project conventions
- Feature is properly documented
```

### Step 2: Planning Phase

Start a new OpenCode session with your main agent and say:
```
I created an issue file at ./issue/add-hello-feature.md, please look at it and help me come up with a plan. Tell me what you understood. Don't present code. Tell me what's wrong and what can be the plan to fix this. Explain in plain English.
```

**Collaborative Planning Process:**
1. Main agent analyzes your issue
2. Agent proposes initial plan
3. You provide feedback and refine requirements
4. Continue until satisfied

### Step 3: Create Plan File

When satisfied with the plan, tell the main agent:
```
Please create a plan file in ./plan/ directory based on our discussion. This should contain 2 sections. 1st section (no fluff, just pure English explanation, no code): what's wrong and how you plan to fix it (use arrows to explain better in this section). 2nd section is more detailed with which file would be edited and why, what will be the new project structure, and so on. 2nd section is detailed plan.
```

This creates `./plan/add-hello-feature.md` with:
- **Section 1**: Plain English explanation of the problem and solution approach
- **Section 2**: Detailed technical implementation plan

### Step 4: Clear Context

Use the `/new` command to clear the context window:
```
/new
```

### Step 5: Execute ORCH Workflow

In the new chat context, run:
```
/orch "check the issue at ./issue/add-hello-feature.md and the plan at ./plan/add-hello-feature.md and start the ORCH workflow using @zai-glm-4-5 as agent_1 and @github-copilot-grok-fast as agent_2"
```

### What Happens During Execution

**Phase 1 - Implementation:**
- ORCH spawns `@zai-glm-4-5`
- Agent reads issue and plan files
- Implements the Hello World feature exactly as specified
- Provides implementation summary

**Phase 2 - Review:**
- ORCH spawns `@github-copilot-grok-fast`
- Agent reads issue, plan, and checks git diff
- Evaluates implementation against plan
- Calculates compliance score (should be 90%+ for simple feature)

**Phase 3 - Quality Loop (if needed):**
- If score < 90%, ORCH spawns new agent_1 to fix issues
- Agent_2 reviews again
- Loop continues until 90%+ compliance

**Phase 4 - Completion:**
- ORCH provides final summary
- Shows iterations, final score, and implementation details
- Workflow completes without committing changes

### Step 6: Post-Execution

1. **Review the final summary** provided by ORCH
2. **Test the implemented changes**:
   ```bash
   # Test the new feature (if it was added)
   python hello.py  # or whatever the implementation requires
   ```
3. **Commit changes manually** when satisfied:
   ```bash
   git add .
   git commit -m "Add Hello World feature"
   ```
4. **Archive or remove** issue and plan files if desired

## Directory Structure

```
your-project/
├── issue/
│   └── add-hello-feature.md
├── plan/
│   └── add-hello-feature.md
└── (your existing project files + new hello world implementation)
```

## Agent Configuration Summary

- **Main Agent**: Your default OpenCode agent (Planning & orchestration)
- **@zai-glm-4-5**: Implementation specialist (ZAI GLM 4.5 model)
- **@github-copilot-grok-fast**: Quality reviewer (GitHub Copilot Grok Fast)

## Troubleshooting

**If agents don't spawn:**
- Check agent definitions in `~/.config/opencode/agents/`
- Verify API keys and model access
- Test individual agents with basic commands

**If workflow fails:**
- Use `/new` to clear context and restart
- Ensure issue and plan files are properly formatted
- Check that agents have required capabilities

**If quality score is low:**
- Review the detailed feedback from agent_2
- Consider if the plan was too complex for one iteration
- Break down complex features into smaller issues

## Advanced Usage: Complex Multi-Step Projects

For larger projects requiring multiple ORCH workflows:

### Step 1: Break Down into Issues
Create separate issue files for each major component:
- `./issue/setup-database-schema.md`
- `./issue/implement-api-endpoints.md`
- `./issue/create-frontend-components.md`
- `./issue/add-testing.md`

### Step 2: Sequential Execution
Run ORCH workflows one at a time, ensuring each builds on the previous:
```
/orch "check the issue at ./issue/setup-database-schema.md and the plan at ./plan/setup-database-schema.md and start the ORCH workflow using @zai-glm-4-5 as agent_1 and @github-copilot-grok-fast as agent_2"
```
Wait for completion, then proceed to the next issue.

### Step 3: Integration Testing
After all workflows complete, perform manual integration testing before committing.

## Tips for Success

- **Start Small**: Use simple features to learn the workflow
- **Clear Requirements**: Be specific in issue files
- **Iterative Planning**: Refine plans with the main agent
- **Quality First**: Let the review loop ensure high standards
- **Manual Testing**: Always test before committing