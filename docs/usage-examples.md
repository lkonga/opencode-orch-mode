# Usage Examples for ORCH Workflow

## Overview

This document provides practical examples of using the ORCH workflow for different types of development tasks. Each example demonstrates the complete process from issue creation to execution.

## Example 1: Simple Feature Addition

### Scenario
Adding a "Hello World" feature to a project.

#### Step 1: Create Issue File
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

#### Step 2: Planning Phase
Start a new OpenCode session with your main agent:
```
I created an issue file at ./issue/add-hello-feature.md, please look at it and help me come up with a plan. Tell me what you understood. Don't present code. Tell me what's wrong and what can be the plan to fix this. Explain in plain English.
```

#### Step 3: Create Plan File
When satisfied with the plan:
```
Please create a plan file in ./plan/ directory based on our discussion. This should contain 2 sections. 1st section (no fluff, just pure English explanation, no code): what's wrong and how you plan to fix it (use arrows to explain better in this section). 2nd section is more detailed with which file would be edited and why, what will be the new project structure, and so on. 2nd section is detailed plan.
```

#### Step 4: Execute ORCH Workflow
Clear context with `/new`, then run:
```
/orch "check the issue at ./issue/add-hello-feature.md and the plan at ./plan/add-hello-feature.md and start the ORCH workflow using @implementor-zai-glm-4-5 as agent_1 and @reviewer-github-copilot-grok-fast as agent_2"
```

## Example 2: Bug Fix

### Scenario
Fixing a bug in user authentication.

#### Step 1: Create Issue File
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

#### Step 2: Planning Phase
```
I created an issue file at ./issue/fix-auth-bug.md, please look at it and help me come up with a plan. The authentication system is rejecting valid special characters in passwords. I need to understand what's wrong and how to fix it.
```

#### Step 3: Create Plan File
After planning discussion:
```
Please create a plan file in ./plan/ directory based on our discussion. This should contain 2 sections. 1st section (no fluff, just pure English explanation, no code): what's wrong and how you plan to fix it (use arrows to explain better in this section). 2nd section is more detailed with which file would be edited and why, what will be the new project structure, and so on. 2nd section is detailed plan.
```

#### Step 4: Execute ORCH Workflow
```
/orch "check the issue at ./issue/fix-auth-bug.md and the plan at ./plan/fix-auth-bug.md and start the ORCH workflow using @implementor-zai-glm-4-5 as agent_1 and @reviewer-github-copilot-grok-fast as agent_2"
```

## Example 3: API Endpoint Addition

### Scenario
Adding a new REST API endpoint for user profile management.

#### Step 1: Create Issue File
Create `./issue/add-user-profile-api.md`:
```markdown
# Add User Profile API Endpoint

## Problem
Our application needs a REST API endpoint for managing user profiles. Currently, users can only update basic information through the web interface.

## Requirements
- Create GET /api/users/{id}/profile endpoint
- Create PUT /api/users/{id}/profile endpoint
- Add proper authentication and authorization
- Implement input validation
- Add comprehensive error handling
- Include API documentation
- Add unit tests for new endpoints

## Expected Outcome
- Users can retrieve their profile data via API
- Users can update their profile data via API
- Proper security measures in place
- Well-documented API with examples
- Full test coverage for new functionality
```

#### Step 2: Planning Phase
```
I created an issue file at ./issue/add-user-profile-api.md, please look at it and help me come up with a plan. We need to add REST API endpoints for user profile management with proper security and testing.
```

#### Step 3: Create Plan File
```
Please create a plan file in ./plan/ directory based on our discussion. This should contain 2 sections. 1st section (no fluff, just pure English explanation, no code): what's wrong and how you plan to fix it (use arrows to explain better in this section). 2nd section is more detailed with which file would be edited and why, what will be the new project structure, and so on. 2nd section is detailed plan.
```

#### Step 4: Execute ORCH Workflow
```
/orch "check the issue at ./issue/add-user-profile-api.md and the plan at ./plan/add-user-profile-api.md and start the ORCH workflow using @implementor-zai-glm-4-5 as agent_1 and @reviewer-github-copilot-grok-fast as agent_2"
```

## Example 4: Database Schema Migration

### Scenario
Adding new fields to an existing database table.

#### Step 1: Create Issue File
Create `./issue/add-user-preferences.md`:
```markdown
# Add User Preferences to Database

## Problem
Users want to customize their experience, but we don't have a way to store user preferences in the database.

## Requirements
- Add preferences table to database
- Create migration script for existing data
- Add model classes for preferences
- Update user service to handle preferences
- Add API endpoints for preference management
- Include default preferences for new users
- Add database rollback script

## Expected Outcome
- Users can set and retrieve their preferences
- Existing users get default preferences
- Database schema is properly versioned
- All functionality is tested and documented
```

#### Step 2: Planning Phase
```
I created an issue file at ./issue/add-user-preferences.md, please look at it and help me come up with a plan. We need to add user preferences functionality with database changes and API endpoints.
```

#### Step 3: Create Plan File
```
Please create a plan file in ./plan/ directory based on our discussion. This should contain 2 sections. 1st section (no fluff, just pure English explanation, no code): what's wrong and how you plan to fix it (use arrows to explain better in this section). 2nd section is more detailed with which file would be edited and why, what will be the new project structure, and so on. 2nd section is detailed plan.
```

#### Step 4: Execute ORCH Workflow
```
/orch "check the issue at ./issue/add-user-preferences.md and the plan at ./plan/add-user-preferences.md and start the ORCH workflow using @implementor-zai-glm-4-5 as agent_1 and @reviewer-github-copilot-grok-fast as agent_2"
```

## Example 5: Frontend Component Addition

### Scenario
Adding a new React component for a dashboard widget.

#### Step 1: Create Issue File
Create `./issue/add-dashboard-widget.md`:
```markdown
# Add Dashboard Widget Component

## Problem
The dashboard needs a new widget to display user statistics. Currently, users have to navigate to multiple pages to see their data.

## Requirements
- Create reusable DashboardWidget component
- Implement UserStatsWidget as specific implementation
- Add responsive design for mobile and desktop
- Include loading states and error handling
- Add unit tests for the component
- Update dashboard to include new widget
- Add TypeScript types and interfaces

## Expected Outcome
- Users can see their statistics on the dashboard
- Component is reusable for other data types
- Proper responsive design across devices
- Full test coverage and documentation
```

#### Step 2: Planning Phase
```
I created an issue file at ./issue/add-dashboard-widget.md, please look at it and help me come up with a plan. We need to add a new React component for dashboard widgets with user statistics.
```

#### Step 3: Create Plan File
```
Please create a plan file in ./plan/ directory based on our discussion. This should contain 2 sections. 1st section (no fluff, just pure English explanation, no code): what's wrong and how you plan to fix it (use arrows to explain better in this section). 2nd section is more detailed with which file would be edited and why, what will be the new project structure, and so on. 2nd section is detailed plan.
```

#### Step 4: Execute ORCH Workflow
```
/orch "check the issue at ./issue/add-dashboard-widget.md and the plan at ./plan/add-dashboard-widget.md and start the ORCH workflow using @implementor-zai-glm-4-5 as agent_1 and @reviewer-github-copilot-grok-fast as agent_2"
```

## Advanced Usage: Multi-Step Projects

### Scenario
Building a complete feature with multiple components.

#### Step 1: Break Down into Issues
Create separate issue files for each major component:
- `./issue/setup-database-schema.md`
- `./issue/implement-api-endpoints.md`
- `./issue/create-frontend-components.md`
- `./issue/add-testing.md`

#### Step 2: Sequential Execution
Run ORCH workflows one at a time, ensuring each builds on the previous:
```
/orch "check the issue at ./issue/setup-database-schema.md and the plan at ./plan/setup-database-schema.md and start the ORCH workflow using @implementor-zai-glm-4-5 as agent_1 and @reviewer-github-copilot-grok-fast as agent_2"
```

Wait for completion, then proceed to the next issue.

#### Step 3: Integration Testing
After all workflows complete, perform manual integration testing before committing.

## Tips for Success

### Issue File Best Practices
- **Be Specific**: Clearly define what needs to be done
- **Include Context**: Add error logs, screenshots, or relevant code snippets
- **Set Clear Requirements**: List exactly what should be implemented
- **Define Success Criteria**: Explain how to verify the implementation works

### Planning Phase Best Practices
- **Explain Your Thinking**: Help the agent understand your vision
- **Ask for Clarification**: Ensure the agent understands your requirements
- **Iterate**: Refine the plan until you're satisfied
- **Think About Edge Cases**: Consider error handling and edge cases

### Execution Phase Best Practices
- **Choose Appropriate Agents**: Match agent capabilities to task complexity
- **Be Patient**: Allow the quality loop to work
- **Review Results**: Check the final summary before committing
- **Test Manually**: Always test the implementation before committing

## Common Patterns

### File Creation Pattern
Most implementations follow this pattern:
1. Create new files (components, services, tests)
2. Modify existing files (routes, configurations, imports)
3. Update documentation
4. Add tests

### API Endpoint Pattern
For API additions:
1. Define route/endpoints
2. Implement controller/service logic
3. Add input validation
4. Implement error handling
5. Add authentication/authorization
6. Write tests
7. Update API documentation

### Frontend Component Pattern
For UI components:
1. Create component file
2. Add TypeScript types/interfaces
3. Implement component logic
4. Add styling
5. Create tests
6. Update parent components
7. Add to documentation

These examples provide a foundation for using the ORCH workflow effectively across different types of development tasks.