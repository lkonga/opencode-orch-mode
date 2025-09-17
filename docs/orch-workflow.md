# ORCH Workflow Documentation

## Overview

The ORCH (Orchestration) workflow is a structured approach to issue resolution through collaborative planning and execution. It combines manual issue creation, interactive planning with the main agent, and automated execution using specialized sub-agents.

## Workflow Phases

### Phase 1: Manual Issue Creation

#### Step 1: Create Issue File
1. Create a new file in the `./issue/` directory
2. Name your file descriptively (e.g., `fix-auth-bug.md`, `add-user-profile.md`)
3. Include in your issue file:
   - Problem description
   - Error logs (if applicable)
   - Your suggestions or ideas
   - Any specific requirements
   - Expected outcomes

### Phase 2: Interactive Planning with Main Agent

#### Step 2: Start Planning Discussion
1. Open an opencode session with your main agent
2. Tell the agent about your issue file:
   ```
   I created an issue file at ./issue/fix-auth-bug.md, please look at it and help me come up with a plan
   ```

#### Step 3: Back-and-Forth Planning
1. **Main agent analyzes** your issue file and codebase
2. **Main agent proposes** an initial plan
3. **You review and provide feedback**:
   - Explain your thought process
   - Clarify requirements
   - Suggest alternative approaches
   - User asks "did you get my idea? Tell me what you understood"
4. **Main agent refines** the plan based on your input
5. **Continue this loop** until you're satisfied with the plan

#### Step 4: Create Plan File
When satisfied with the plan:
1. Tell the main agent:
   ```
   Please create a plan file in ./plan/ directory based on our discussion. This should contain 2 sections. 1st section (no fluff, just pure English explanation, no code): what's wrong and how you plan to fix it (use arrows to explain better in this section). 2nd section is more detailed with which file would be edited and why, what will be the new project structure, and so on. 2nd section is detailed plan.
   ```
2. Main agent creates a plan file (e.g., `./plan/fix-auth-bug.md`)

### Phase 3: Clear Context

#### Step 5: Start New Chat
1. Use the `/new` command to clear the context window
2. This frees up memory/context window and starts fresh for the execution phase.

### Phase 4: Automated Execution

#### Step 6: Run ORCH Workflow Command
In the new chat context, run:
```
/orch "check the issue at ./issue/fix-auth-bug.md and the plan at ./plan/fix-auth-bug.md and start the ORCH workflow using @grok as agent_1 and @glm as agent_2"
```

## Execution Process

### What Happens During Execution

**The main agent will:**

#### Phase 1 - Execute Plan with @agent_1
- Spawn @agent_1 (your first specified agent)
- @agent_1 reads the issue and plan files
- @agent_1 implements the plan exactly as written
- @agent_1 provides a summary of completed work
- @agent_1 does NOT commit changes

#### Phase 2 - Review Implementation with @agent_2
- Spawn @agent_2 (your second specified agent)
- @agent_2 reads the issue file, plan file, and checks git diff
- @agent_2 compares implementation against plan requirements
- @agent_2 calculates a compliance score (0-100%)
- @agent_2 provides detailed review with specific feedback

#### Phase 3 - Loop Until 90%+ Compliance (if needed)
- If score < 90%: Main agent spawns new @agent_1 to fix issues
- @agent_1 receives specific issues to fix from @agent_2's review
- @agent_2 reviews the fixes again
- Loop continues until 90%+ compliance is achieved

#### Phase 4 - Final Completion
- Main agent provides final summary:
  - Number of iterations required
  - Final compliance score
  - Summary of what was implemented
  - Any remaining minor deviations
- Workflow completes without committing changes

## Key Features

### Quality Assurance
- **90% Compliance Threshold**: Ensures high-quality implementation
- **Independent Review**: Separate agent for unbiased evaluation
- **Iterative Improvement**: Loop until quality standards are met

### Agent Roles
- **Main Agent**: Coordinates workflow, never codes
- **@agent_1**: Implementation specialist, executes plans
- **@agent_2**: Quality reviewer, evaluates compliance

### Safety Features
- **No Automatic Commits**: You decide when to commit
- **Plan-Bound Execution**: Agents follow plans exactly
- **Clear Documentation**: All steps tracked and reviewed

## Best Practices

### For Issue Files
- Be specific about problems and requirements
- Include relevant error logs and context
- Structure your thoughts clearly

### For Planning Phase
- Take time to explain your thought process
- Ensure the main agent understands your vision
- Review the plan carefully before approval

### For Execution Phase
- Choose appropriate agents for your specific needs
- Be patient with the quality loop process
- Review the final summary before committing changes

## Example Commands

**Start planning:**
```
I created an issue file at ./issue/add-feature-x.md, please look at it and help me come up with a plan. Tell me what you understood. Don't present code. Tell me what's wrong and what can be the plan to fix this. Explain in plain English.
```

**Create plan file:**
```
Please create a plan file in ./plan/ directory based on our discussion. This should contain 2 sections. 1st section (no fluff, just pure English explanation, no code): what's wrong and how you plan to fix it (use arrows to explain better in this section). 2nd section is more detailed with which file would be edited and why, what will be the new project structure, and so on. 2nd section is detailed plan.
```

**Execute workflow:**
```
/orch "check the issue at ./issue/add-feature-x.md and the plan at ./plan/add-feature-x.md and start the ORCH workflow using @grok as agent_1 and @glm as agent_2"
```

## Troubleshooting

**If agents get stuck:**
- Git hard reset
- Use `/new` to clear context and restart
- Ensure your issue and plan files are clear and specific

**If quality loop takes too long:**
- Make sure to use fast model like grok or qwen3 coder plus
- Consider if your requirements are too complex for one iteration
- Break down large issues into smaller, manageable parts

This ORCH workflow ensures systematic issue resolution with quality assurance while maintaining human oversight throughout the process.