# Contributing to OpenCode ORCH Mode

## Overview

Thank you for your interest in contributing to the OpenCode ORCH Mode project! This document provides guidelines and instructions for contributors.

## Getting Started

### Prerequisites

1. **OpenCode Setup**: Ensure you have OpenCode properly installed and configured
2. **Agent Access**: Have access to the required AI models and agents
3. **Git Knowledge**: Basic understanding of Git workflows
4. **ORCH Workflow**: Familiarity with the ORCH workflow process

### Initial Setup

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/opencode-orch-mode.git
   cd opencode-orch-mode
   ```

2. **Install ORCH Command**:
   ```bash
   ./install.sh
   ```

3. **Configure Agents**: Ensure your agents are properly configured in `~/.config/opencode/agents/`

## Contribution Workflow

### Step 1: Find or Create an Issue

#### Finding Existing Issues
- Check the project's issue tracker for open issues
- Look for issues labeled "good first issue" or "help wanted"
- Comment on the issue to indicate your interest

#### Creating New Issues
If you want to contribute a new feature or fix:

1. **Create Issue File**:
   ```bash
   # Create a new issue file
   touch ./issue/your-feature-name.md
   ```

2. **Write Issue Content**:
   ```markdown
   # Your Feature Title

   ## Problem
   Describe the problem you're trying to solve

   ## Requirements
   - List specific requirements
   - Include acceptance criteria
   - Mention any constraints

   ## Expected Outcome
   Describe what success looks like
   ```

### Step 2: Planning Phase

1. **Start Planning Discussion**:
   ```
   I created an issue file at ./issue/your-feature-name.md, please look at it and help me come up with a plan. Tell me what you understood. Don't present code. Tell me what's wrong and what can be the plan to fix this. Explain in plain English.
   ```

2. **Refine the Plan**:
   - Provide feedback on the initial plan
   - Clarify requirements and expectations
   - Ensure the plan covers all aspects of the issue

3. **Create Plan File**:
   ```
   Please create a plan file in ./plan/ directory based on our discussion. This should contain 2 sections. 1st section (no fluff, just pure English explanation, no code): what's wrong and how you plan to fix it (use arrows to explain better in this section). 2nd section is more detailed with which file would be edited and why, what will be the new project structure, and so on. 2nd section is detailed plan.
   ```

### Step 3: Implementation Phase

1. **Clear Context**:
   ```
   /new
   ```

2. **Execute ORCH Workflow**:
   ```
   /orch "check the issue at ./issue/your-feature-name.md and the plan at ./plan/your-feature-name.md and start the ORCH workflow using @implementor-zai-glm-4-5 as agent_1 and @reviewer-github-copilot-grok-fast as agent_2"
   ```

3. **Review Implementation**:
   - Wait for the workflow to complete
   - Review the final summary and compliance score
   - Test the changes manually

### Step 4: Submit Contribution

1. **Test Your Changes**:
   ```bash
   # Run any existing tests
   npm test  # or appropriate test command
   
   # Test your specific changes
   # Add manual testing steps here
   ```

2. **Commit Changes**:
   ```bash
   git add .
   git commit -m "Add your feature: descriptive commit message"
   ```

3. **Push to Fork**:
   ```bash
   git push origin your-branch-name
   ```

4. **Create Pull Request**:
   - Go to the repository on GitHub
   - Click "New Pull Request"
   - Select your branch
   - Fill in the PR template
   - Link to the original issue

## Code Standards

### General Guidelines

- **Follow Existing Style**: Match the coding style of existing files
- **Keep It Simple**: Write clear, straightforward code
- **Add Comments**: Comment complex logic or non-obvious implementations
- **Error Handling**: Include proper error handling and validation

### Documentation

- **Update README**: If your change affects user-facing functionality
- **Add Docstrings**: Include documentation for functions and classes
- **Update Examples**: Add or update usage examples if applicable
- **Document Changes**: Update relevant documentation files

### Testing

- **Write Tests**: Include unit tests for new functionality
- **Update Tests**: Modify existing tests if needed
- **Test Coverage**: Aim for high test coverage
- **Integration Tests**: Consider adding integration tests for complex features

## Agent Configuration Contributions

### Adding New Agent Templates

1. **Create Agent File**:
   ```bash
   # Create new agent configuration
   touch agents/backup/your-agent-template.md
   ```

2. **Configure Agent**:
   ```yaml
   ---
   description: Your agent description
   mode: subagent
   tools:
     bash: true/false
     edit: true/false
     read: true
     write: true/false
     list: true
     glob: true
     grep: true
   permission:
     edit: allow/deny
     bash:
       "*": allow/deny
     webfetch: allow/deny
   model: your/model-name
   temperature: 0.x
   ---
   ```

3. **Add Documentation**: Update `docs/agent-configuration.md` with new agent details

### Modifying Existing Agents

1. **Test Changes**: Ensure modifications don't break existing functionality
2. **Update Documentation**: Document any changes to agent behavior
3. **Backward Compatibility**: Maintain compatibility with existing workflows

## Documentation Contributions

### Improving Documentation

1. **Identify Gaps**: Look for unclear or missing documentation
2. **Create Issue**: Document the documentation improvement needed
3. **Follow ORCH Workflow**: Use the standard contribution process
4. **Be Specific**: Provide clear, actionable documentation

### Adding Examples

1. **Create Realistic Examples**: Examples should reflect real-world usage
2. **Test Examples**: Ensure all examples work as described
3. **Update Index**: Add new examples to relevant documentation indexes

## Review Process

### Pull Request Review

1. **Automated Checks**: All automated checks must pass
2. **Code Review**: At least one maintainer must review the code
3. **Documentation Review**: Documentation changes are reviewed
4. **Testing Review**: Tests are reviewed for adequacy

### Review Criteria

- **Functionality**: Does the code work as intended?
- **Quality**: Is the code well-written and maintainable?
- **Documentation**: Is the documentation clear and complete?
- **Testing**: Are tests adequate and well-written?
- **Performance**: Does the code perform well?
- **Security**: Are there any security concerns?

## Community Guidelines

### Communication

- **Be Respectful**: Treat all contributors with respect
- **Be Constructive**: Provide helpful, constructive feedback
- **Be Patient**: Allow time for reviews and responses
- **Be Collaborative**: Work together to find the best solutions

### Issue Etiquette

- **Search First**: Check if your issue already exists
- **Be Specific**: Provide clear, detailed information
- **Use Templates**: Follow the provided issue templates
- **Stay On Topic**: Keep discussions focused on the issue

### Pull Request Etiquette

- **Small Changes**: Keep PRs focused and manageable
- **Clear Descriptions**: Explain what and why you're changing
- **Respond to Reviews**: Address review comments promptly
- **Keep Updated**: Rebase your branch if needed

## Getting Help

### Resources

- **Documentation**: Read the project documentation
- **Examples**: Review existing usage examples
- **Issues**: Check existing issues and discussions
- **Discussions**: Join community discussions

### Asking Questions

1. **Check Documentation**: Look for answers in existing documentation
2. **Search Issues**: Check if your question has been asked before
3. **Create Discussion**: Start a new discussion for your question
4. **Be Specific**: Provide context and details about your question

### Reporting Issues

1. **Use Template**: Follow the issue template
2. **Provide Details**: Include steps to reproduce, expected behavior, actual behavior
3. **Include Environment**: Mention your environment and setup
4. **Be Reproducible**: Ensure issues can be reproduced by others

## Recognition

### Contributor Recognition

- **Contributors List**: All contributors are acknowledged in the contributors list
- **Release Notes**: Significant contributions are mentioned in release notes
- **Special Thanks**: Exceptional contributions receive special recognition

### Becoming a Maintainer

- **Active Contribution**: Regular, high-quality contributions
- **Community Engagement**: Helpful participation in discussions and reviews
- **Technical Expertise**: Deep understanding of the project
- **Reliability**: Consistent and dependable contribution history

## License

By contributing to this project, you agree that your contributions will be licensed under the project's license. Please ensure you have the right to contribute any code or documentation you submit.

---

Thank you for contributing to the OpenCode ORCH Mode project! Your contributions help make this project better for everyone.