# Complete ORCH Workflow Example

This guide demonstrates how to use the ORCH workflow with the configured agents, providing detailed step-by-step examples for different types of development tasks.

## Prerequisites

1. **Install ORCH command** (already done):
   ```bash
   ./install.sh
   ```

2. **Agents configured** (just created):
   - `@implementor-zai-glm-4-5` - Implementation specialist
   - `@reviewer-github-copilot-grok-fast` - Quality reviewer

3. **Main agent**: Your default OpenCode agent (github-copilot with GPT-5)

## Quick Start Overview

The ORCH workflow follows these key phases:
1. **Issue Creation** → Define what needs to be done
2. **Planning** → Collaborate with main agent to create a detailed plan
3. **Execution** → Agents implement and review the plan
4. **Quality Loop** → Iterate until 90%+ compliance is achieved
5. **Completion** → Review and commit changes manually

## Example 1: Simple Feature Addition

Let's start with a basic example - adding a "Hello World" feature to a project.

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

**Key Points:**
- Problem statement is clear and concise
- Requirements are specific and actionable
- Expected outcomes define success criteria
- File is placed in the correct `./issue/` directory

### Step 2: Planning Phase

Start a new OpenCode session with your main agent and say:
```
I created an issue file at ./issue/add-hello-feature.md, please look at it and help me come up with a plan. Tell me what you understood. Don't present code. Tell me what's wrong and what can be the plan to fix this. Explain in plain English.
```

**Collaborative Planning Process:**
1. **Main agent analyzes** your issue and codebase
2. **Agent proposes** initial plan based on understanding
3. **You provide feedback** and refine requirements
4. **Continue iteration** until you're satisfied with the plan

**Example Planning Dialogue:**
```
You: I created an issue file at ./issue/add-hello-feature.md, please look at it and help me come up with a plan. Tell me what you understood.

Agent: I understand you want to add a "Hello World" feature to your application. The problem is that users currently don't have a way to get a simple greeting. The plan would be to create a function that returns "Hello, World!", add a CLI command to execute it, include basic error handling, and follow your existing code style.

You: That's correct. Can you also make sure it's properly documented and includes some basic tests?

Agent: Understood. I'll update the plan to include proper documentation for the feature and add basic unit tests to ensure the functionality works correctly. The plan will cover creating the function, CLI command, error handling, documentation, and tests.
```

**Key Planning Tips:**
- Always ask "did you get my idea? Tell me what you understood"
- Be specific about additional requirements
- Ensure the agent understands your vision completely
- Take time to refine the plan before proceeding

### Step 3: Create Plan File

When satisfied with the plan, tell the main agent:
```
Please create a plan file in ./plan/ directory based on our discussion. This should contain 2 sections. 1st section (no fluff, just pure English explanation, no code): what's wrong and how you plan to fix it (use arrows to explain better in this section). 2nd section is more detailed with which file would be edited and why, what will be the new project structure, and so on. 2nd section is detailed plan.
```

This creates `./plan/add-hello-feature.md` with:

**Section 1: Problem Analysis and Solution Approach**
```markdown
## What's wrong:
- No greeting functionality → Users can't get simple hello message
- Missing CLI interface → No command-line way to run the feature
- No error handling → Feature might fail silently
- No documentation → Users don't know how to use the feature

## How to fix:
- Create hello_world() function → Returns "Hello, World!" string
- Add CLI command → Users can run from command line
- Implement error handling → Graceful failure if issues occur
- Add documentation → Clear usage instructions
- Include tests → Ensure functionality works correctly
```

**Section 2: Detailed Implementation Plan**
```markdown
### Files to be created/modified:

#### 1. src/hello.py (create)
- **Why**: Main module for hello functionality
- **Content**: hello_world() function, error handling, docstrings

#### 2. cli.py (create)
- **Why**: Command-line interface for the feature
- **Content**: CLI command setup, argument parsing, main function

#### 3. tests/test_hello.py (create)
- **Why**: Unit tests for the hello functionality
- **Content**: Test cases for hello_world function, error scenarios

#### 4. README.md (update)
- **Why**: Document the new feature for users
- **Content**: Usage instructions, examples, installation notes

#### 5. setup.py (update)
- **Why**: Register CLI command for installation
- **Content**: Entry points for CLI command

### New project structure:
```
project/
├── src/
│   └── hello.py          # Hello functionality
├── cli.py               # CLI interface
├── tests/
│   └── test_hello.py    # Unit tests
├── README.md           # Updated documentation
└── setup.py            # Updated setup configuration
```

### Implementation steps:
1. Create src/hello.py with hello_world() function
2. Create cli.py with command-line interface
3. Create tests/test_hello.py with unit tests
4. Update README.md with usage instructions
5. Update setup.py with CLI entry point
6. Test the complete functionality
```

**Key Plan Elements:**
- Clear problem analysis with arrows showing cause/effect
- Detailed file-by-file implementation plan
- New project structure visualization
- Step-by-step implementation sequence
- Specific reasons for each file change

### Step 4: Clear Context

Use the `/new` command to clear the context window:
```
/new
```

### Step 5: Execute ORCH Workflow

In the new chat context, run:
```
/orch "check the issue at ./issue/add-hello-feature.md and the plan at ./plan/add-hello-feature.md and start the ORCH workflow using @implementor-zai-glm-4-5 as agent_1 and @reviewer-github-copilot-grok-fast as agent_2"
```

**Command Breakdown:**
- `/orch` → The ORCH workflow command
- `"check the issue at ./issue/add-hello-feature.md"` → Path to your issue file
- `"and the plan at ./plan/add-hello-feature.md"` → Path to your plan file
- `"start the ORCH workflow"` → Action to perform
- `"using @implementor-zai-glm-4-5 as agent_1"` → Implementation agent
- `"and @reviewer-github-copilot-grok-fast as agent_2"` → Review agent

**Alternative Agent Combinations:**
- For speed: `using @grok as agent_1 and @glm as agent_2`
- For quality: `using @glm as agent_1 and @grok as agent_2`
- For complex tasks: `using @deepseek as agent_1 and @glm as agent_2`

### What Happens During Execution

**Phase 1 - Implementation:**
- ORCH spawns `@implementor-zai-glm-4-5`
- Agent reads issue and plan files
- Implements the Hello World feature exactly as specified
- Provides implementation summary with details of what was created

**Example Implementation Summary:**
```
I have successfully implemented the Hello World feature according to the plan:

Files Created:
- src/hello.py: Contains hello_world() function with proper error handling
- cli.py: Command-line interface with argument parsing
- tests/test_hello.py: Unit tests covering normal and error cases

Files Modified:
- README.md: Added usage instructions and examples
- setup.py: Added CLI entry point configuration

Implementation Details:
- Created hello_world() function that returns "Hello, World!"
- Added proper error handling for edge cases
- Implemented CLI command that can be run with 'python cli.py'
- Added comprehensive unit tests with 95% coverage
- Updated documentation with clear usage examples
```

**Phase 2 - Review:**
- ORCH spawns `@reviewer-github-copilot-grok-fast`
- Agent reads issue, plan, and checks git diff
- Evaluates implementation against plan requirements
- Calculates compliance score (should be 90%+ for simple feature)

**Example Review Output:**
```
Compliance Score: 95%

Review Summary:
✅ All required files created (src/hello.py, cli.py, tests/test_hello.py)
✅ All existing files properly updated (README.md, setup.py)
✅ Functionality matches requirements exactly
✅ Error handling implemented as specified
✅ Documentation added and comprehensive
✅ Tests cover all scenarios

Minor Deviations:
- CLI command uses slightly different argument name than specified in plan
- Test file has one additional test case not mentioned in plan

Overall: Excellent implementation with minor deviations that improve quality.
```

**Phase 3 - Quality Loop (if needed):**
- If score < 90%, ORCH spawns new agent_1 to fix issues
- Agent_1 receives specific feedback from agent_2
- Agent_2 reviews the fixes again
- Loop continues until 90%+ compliance is achieved

**Phase 4 - Completion:**
- ORCH provides final summary
- Shows iterations, final score, and implementation details
- Workflow completes without committing changes

**Example Final Summary:**
```
ORCH Workflow Completed Successfully!

Iterations: 1
Final Compliance Score: 95%
Implementation Status: Complete

Summary of Changes:
- Created 3 new files (src/hello.py, cli.py, tests/test_hello.py)
- Modified 2 existing files (README.md, setup.py)
- Added complete Hello World functionality with CLI interface
- Implemented comprehensive error handling
- Added full test coverage
- Updated documentation

Minor Deviations:
- CLI argument name improved for better user experience
- Additional test case added for edge case coverage

Ready for manual testing and commit.
```

### Step 6: Post-Execution

1. **Review the final summary** provided by ORCH
   - Check compliance score (should be 90%+)
   - Review any deviations from the plan
   - Understand what was implemented

2. **Test the implemented changes**:
   ```bash
   # Test the new feature
   python cli.py --help
   python cli.py greet
   
   # Run the tests
   python -m pytest tests/test_hello.py -v
   
   # Test error cases
   python cli.py greet --invalid-arg
   ```

3. **Verify implementation quality**:
   ```bash
   # Check code quality
   flake8 src/ cli.py
   pylint src/hello.py
   
   # Check test coverage
   python -m pytest --cov=src tests/
   ```

4. **Commit changes manually** when satisfied:
   ```bash
   git add .
   git commit -m "Add Hello World feature
   
   - Create hello_world() function in src/hello.py
   - Add CLI interface in cli.py
   - Implement comprehensive error handling
   - Add unit tests with 95% coverage
   - Update documentation and setup configuration"
   ```

5. **Clean up workspace**:
   ```bash
   # Archive issue and plan files
   mkdir -p archive/hello-feature
   mv ./issue/add-hello-feature.md archive/hello-feature/
   mv ./plan/add-hello-feature.md archive/hello-feature/
   
   # Or remove if not needed
   # rm ./issue/add-hello-feature.md
   # rm ./plan/add-hello-feature.md
   ```

6. **Update project documentation** (if needed):
   ```bash
   # Update CHANGELOG.md
   echo "## [Unreleased]### Added
   - Hello World feature with CLI interface
   - Comprehensive unit tests
   - Improved documentation" >> CHANGELOG.md
   ```

## Directory Structure

```
your-project/
├── issue/
│   └── add-hello-feature.md
├── plan/
│   └── add-hello-feature.md
├── src/
│   └── hello.py              # New hello functionality
├── cli.py                   # New CLI interface
├── tests/
│   └── test_hello.py        # New unit tests
├── archive/                  # Optional archive directory
│   └── hello-feature/
│       ├── add-hello-feature.md
│       └── add-hello-feature.md
├── README.md                # Updated with new feature
├── setup.py                 # Updated with CLI entry point
└── (your existing project files)
```

## Agent Configuration Summary

- **Main Agent**: Your default OpenCode agent (Planning & orchestration)
- **@implementor-zai-glm-4-5**: Implementation specialist (ZAI GLM 4.5 model)
- **@reviewer-github-copilot-grok-fast**: Quality reviewer (GitHub Copilot Grok Fast)

### Agent Selection Guide

| Task Type | Recommended Agent_1 | Recommended Agent_2 | Reason |
|-----------|-------------------|-------------------|---------|
| Simple Features | @implementor-zai-glm-4-5 | @reviewer-github-copilot-grok-fast | Balanced implementation with fast review |
| Complex Logic | @implementor-zai-glm-4-5 | @reviewer-github-copilot-grok-fast | Strong implementation with thorough review |
| Quick Prototyping | @grok | @glm | Fast implementation with good review |
| High-Quality Production | @glm | @grok | High-quality implementation with fast review |
| Refactoring | @implementor-zai-glm-4-5 | @reviewer-github-copilot-grok-fast | Precise changes with detailed review |

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

## Example 2: Bug Fix Workflow

Let's walk through a more complex example - fixing a bug in user authentication.

### Step 1: Create Issue File
Create `./issue/fix-auth-bug.md`:
```markdown
# Fix Authentication Bug

## Problem
Users are unable to log in when their passwords contain special characters. The system throws a validation error even for valid special characters.

## Error Logs
```
ERROR: Invalid character in password at position 8
Expected: [a-zA-Z0-9]
Found: '@'
```

## Requirements
- Update password validation regex to allow common special characters
- Add comprehensive test cases for password validation
- Update error messages to be more user-friendly
- Ensure backward compatibility

## Expected Outcome
- Users can log in with passwords containing special characters
- All existing functionality continues to work
- Clear error messages for invalid passwords
```

### Step 2: Planning Phase
```
I created an issue file at ./issue/fix-auth-bug.md, please look at it and help me come up with a plan. The authentication system is rejecting valid special characters in passwords. I need to understand what's wrong and how to fix it.
```

### Step 3: Create Plan File
After planning discussion, the plan file would include:
- Analysis of current validation regex
- Updated regex pattern to allow common special characters
- Files to modify (auth service, validation logic, tests)
- Backward compatibility considerations
- Error message improvements

### Step 4: Execute ORCH Workflow
```
/orch "check the issue at ./issue/fix-auth-bug.md and the plan at ./plan/fix-auth-bug.md and start the ORCH workflow using @implementor-zai-glm-4-5 as agent_1 and @reviewer-github-copilot-grok-fast as agent_2"
```

### Step 5: Post-Execution
- Test with various password combinations
- Verify existing functionality still works
- Check that error messages are improved
- Run comprehensive test suite

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
/orch "check the issue at ./issue/setup-database-schema.md and the plan at ./plan/setup-database-schema.md and start the ORCH workflow using @implementor-zai-glm-4-5 as agent_1 and @reviewer-github-copilot-grok-fast as agent_2"
```
Wait for completion, then proceed to the next issue.

### Step 3: Integration Testing
After all workflows complete, perform manual integration testing before committing.

### Multi-Project Management
For complex projects, consider using a project tracking system:
```markdown
# Project: User Management System

## Phase 1: Database (Complete)
- [x] setup-database-schema.md
- [x] create-migration-scripts.md

## Phase 2: Backend (In Progress)
- [x] implement-api-endpoints.md
- [ ] add-authentication.md
- [ ] create-user-service.md

## Phase 3: Frontend (Pending)
- [ ] create-frontend-components.md
- [ ] implement-user-interface.md
- [ ] add-form-validation.md

## Phase 4: Testing (Pending)
- [ ] add-unit-tests.md
- [ ] create-integration-tests.md
- [ ] setup-e2e-testing.md
```

## Tips for Success

### Issue Creation Best Practices
- **Start Small**: Use simple features to learn the workflow
- **Clear Requirements**: Be specific in issue files
- **Include Context**: Add error logs, screenshots, or relevant code snippets
- **Define Success**: Clearly state what "done" looks like

### Planning Phase Best Practices
- **Iterative Planning**: Refine plans with the main agent
- **Ask Questions**: Ensure the agent understands your vision
- **Think About Edge Cases**: Consider error handling and edge cases
- **Be Realistic**: Set achievable goals for each iteration

### Execution Phase Best Practices
- **Quality First**: Let the review loop ensure high standards
- **Choose Right Agents**: Match agent capabilities to task complexity
- **Be Patient**: Allow the quality loop to work properly
- **Manual Testing**: Always test before committing

### Common Pitfalls to Avoid
- **Vague Requirements**: Leads to implementation that doesn't match expectations
- **Skipping Planning**: Results in poor implementation quality
- **Ignoring Review Feedback**: Causes repeated quality loops
- **Complex Single Issues**: Break down large tasks into smaller pieces

### Performance Optimization
- **Use Fast Models**: For simple tasks, use faster models like Grok
- **Batch Similar Tasks**: Group related changes in single issues
- **Parallel Work**: Create multiple independent issues for parallel processing
- **Cache Context**: Use `/new` strategically to clear context when needed

### Troubleshooting Common Issues

**Low Compliance Scores:**
- Check if requirements were clear in the issue file
- Verify the plan was detailed enough
- Consider if the task was too complex for one iteration
- Break down complex issues into smaller pieces

**Agents Getting Stuck:**
- Use `/new` to clear context and restart
- Check if issue/plan files are properly formatted
- Verify agent configurations are correct
- Try with different agent combinations

**Slow Execution:**
- Use faster models for implementation
- Reduce task complexity
- Check for unnecessary file operations
- Optimize agent selection for the task type

### Advanced Techniques

**Conditional Implementation:**
```markdown
## Requirements
- If database exists, add new column to users table
- If database doesn't exist, create it with the new column
- Ensure backward compatibility with existing installations
```

**Multi-Environment Support:**
```markdown
## Requirements
- Feature must work in development, staging, and production
- Include environment-specific configuration
- Add environment detection logic
- Provide different logging levels per environment
```

**Progressive Enhancement:**
```markdown
## Requirements
- Implement basic functionality first
- Add advanced features as optional enhancements
- Ensure basic functionality works without advanced features
- Provide clear upgrade path for users
```

## Real-World Examples

### Example 3: API Endpoint Addition
- Issue: `./issue/add-user-profile-api.md`
- Plan: Detailed API design with authentication
- Implementation: RESTful endpoints with proper validation
- Review: Security and compliance checks

### Example 4: Database Migration
- Issue: `./issue/add-user-preferences.md`
- Plan: Database schema changes with migration scripts
- Implementation: Schema changes, data migration, rollback scripts
- Review: Data integrity and backward compatibility

### Example 5: Frontend Component
- Issue: `./issue/add-dashboard-widget.md`
- Plan: React component with TypeScript and responsive design
- Implementation: Component, tests, documentation, integration
- Review: Code quality, accessibility, performance

By following these examples and best practices, you'll be able to effectively use the ORCH workflow for a wide variety of development tasks, from simple bug fixes to complex feature implementations.