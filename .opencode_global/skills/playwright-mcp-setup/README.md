# Playwright MCP Setup Skill

This skill provides comprehensive guidance for installing and troubleshooting Playwright MCP browser tools across different operating systems, with special handling for distributions not officially supported by Playwright.

## Quick Start

To use this skill, trigger it with any of the following:
- `$PlaywrightMCPSetup`
- "playwright mcp install"
- "playwright browser tools"
- "playwright troubleshooting"
- "mcp browser setup"

## What's Included

### Main Skill File
- **SKILL.md**: Complete installation and troubleshooting guide

### References
- **quick-install-guide.md**: OS-specific installation commands
- **troubleshooting-checklist.md**: Step-by-step troubleshooting checklist

### Scripts
- **install-playwright-mcp.sh**: Automated installation script that detects OS and installs appropriate dependencies

## Key Features

1. **Cross-Platform Support**: Covers Ubuntu, Debian, Pop! OS, Fedora, CentOS, RHEL, macOS, and Windows
2. **Pop! OS Special Handling**: Includes manual Chrome installation steps for this unsupported distribution
3. **Comprehensive Troubleshooting**: Addresses common issues and their solutions
4. **Automated Installation**: Provides script for hands-off installation
5. **Verification Steps**: Ensures installation is working correctly

## Common Use Cases

1. **First-Time Setup**: Installing Playwright MCP on a new system
2. **OS Migration**: Setting up Playwright MCP on a different operating system
3. **Troubleshooting**: Resolving browser installation and dependency issues
4. **CI/CD Configuration**: Setting up Playwright MCP in automated environments

## Related Skills

- **$MCPGrounding**: For interactive testing and validation after setup
- **$SurgicalImplementation**: For making precise configuration changes
- **$RelentlessWebResearch**: For finding OS-specific solutions and updates

## Success Criteria

After using this skill, you should have:
- Playwright MCP server installed globally
- Browsers installed and accessible
- System dependencies satisfied
- Browser tools capable of navigating and interacting with pages
- No permission or access errors
- MCP server running and accessible

## Getting Help

If you encounter issues not covered in this skill:
1. Check the [Playwright troubleshooting guide](https://github.com/microsoft/playwright/blob/main/docs/troubleshooting.md)
2. Use the `$RelentlessWebResearch` skill to find OS-specific solutions
3. Check the Playwright MCP repository for known issues
