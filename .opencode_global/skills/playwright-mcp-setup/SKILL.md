---
name: 'Playwright MCP Setup'
description: 'Install and troubleshoot Playwright MCP browser tools across different operating systems, with special handling for unsupported distributions'
trigger: ['$PlaywrightMCPSetup', 'playwright mcp install', 'playwright browser tools', 'playwright troubleshooting', 'mcp browser setup']
related_skills: ['$MCPGrounding', '$SurgicalImplementation', '$RelentlessWebResearch']
references: {'Troubleshooting': 'references/troubleshooting.md', 'OS-specific installation': 'references/os-specific-installation.md', 'Installation script': 'scripts/install-playwright-mcp.sh'}
---

# Playwright MCP Setup

## Purpose

Install and configure Playwright MCP browser tools for automated browser interaction. This skill provides quick-start instructions for common platforms (Ubuntu/Debian) with references to comprehensive OS-specific guides.

**Core Principle**: Cross-platform compatibility with progressive disclosure—start fast, dig deeper when needed.

## When to Use This Skill

- Setting up Playwright MCP browser tools for the first time
- Browser tools failing to launch or navigate
- Missing browser installation or system dependency errors
- Use this skill first → then **$MCPGrounding** for interactive testing

## Prerequisites

**Required**: Node.js (v14+) + npm/yarn, sudo access, terminal, internet

## Quick Installation (Ubuntu/Debian)

<reference title="Installation script" path="scripts/install-playwright-mcp.sh" />

### Step 1: Install Project Dependencies

```bash
# Navigate to your project
cd /path/to/your/project

# Install base dependencies
npm install
npm install --save-dev @playwright/test
```

### Step 2: Install Playwright MCP Globally

```bash
# Install MCP Playwright server
npm install -g @playwright/mcp
```

### Step 3: Install System Dependencies

```bash
# Install required system libraries
sudo apt-get update
sudo apt-get install -y libnss3 libatk-bridge2.0-0 libdrm2 libxcomposite1 \
  libxdamage1 libxrandr2 libgbm1 libxss1 libasound2
```

### Step 4: Install Browsers

```bash
# Install Playwright browsers
npx playwright install
```

### Verification

```bash
# Check installed browsers
npx playwright install --dry-run

# Test browser launch
npx playwright codegen --device="Desktop Chrome" https://example.com
```

**Success**: Browser opens and navigates to example.com → You're ready for **$MCPGrounding**!

## Common Troubleshooting

### Issue 1: "Browser not found" or "Chrome not installed"

**Symptom**: Missing Chrome/Chromium errors, browser tools fail to launch
**Fix**: See <reference title="Troubleshooting" path="references/troubleshooting.md" /> → Issue 1 (Browser Installation)

### Issue 2: "Missing system dependencies"

**Symptom**: Library loading errors, display/GUI failures
**Fix**: See <reference title="Troubleshooting" path="references/troubleshooting.md" /> → Issue 2 (System Dependencies)

### Issue 3: "Permission denied" errors

**Symptom**: Unable to install browsers, permission failures
**Fix**: See <reference title="Troubleshooting" path="references/troubleshooting.md" /> → Issue 3 (Permissions)

**Still failing?** → See <reference title="Troubleshooting" path="references/troubleshooting.md" /> for MCP server issues, navigation problems, advanced debugging

## OS-Specific Installation

**Quick Reference**:

| OS | Installation Guide |
|----|-------------------|
| **Ubuntu/Debian** | ↑ Above (standard workflow, officially supported) |
| **Pop! OS** | <reference title="OS-specific installation" path="references/os-specific-installation.md" /> (manual Chrome required, warnings safe to ignore) |
| **Fedora/CentOS** | <reference title="OS-specific installation" path="references/os-specific-installation.md" /> (use dnf package manager) |
| **macOS/Windows** | <reference title="OS-specific installation" path="references/os-specific-installation.md" /> (officially supported) |
| **Arch/Alpine** | <reference title="OS-specific installation" path="references/os-specific-installation.md" /> (manual setup needed) |

## Next Steps

**After Setup**: (1) Run verification commands, (2) Use **$MCPGrounding** for interactive testing, (3) Build automation scripts
**If Issues Persist**: Check <reference title="Troubleshooting" path="references/troubleshooting.md" /> (advanced solutions) → <reference title="OS-specific installation" path="references/os-specific-installation.md" /> (OS fixes) → **$RelentlessWebResearch** (bleeding-edge compatibility)

## Reference Files

- **`references/os-specific-installation.md`** (180 lines)
  - Detailed setup for Pop! OS, Fedora, macOS, Windows, Arch, Alpine
  - Custom browser paths, network configuration, offline installation
  - OS-specific troubleshooting

- **`references/troubleshooting.md`** (190 lines)
  - Navigation issues (Issue 4)
  - MCP server problems (Issue 5)
  - Custom browser paths
  - Maintenance and updates
  - Production considerations
  - Emergency recovery procedures

## Related Skills

- **$MCPGrounding**: Interactive testing and validation (use AFTER setup completes)
- **$SurgicalImplementation**: Precise configuration changes
- **$RelentlessWebResearch**: Find OS-specific solutions and latest updates

## Success Criteria

✓ Playwright MCP server installed globally
✓ Browsers installed and accessible
✓ System dependencies satisfied
✓ Browser tools can navigate and interact with pages
✓ Verification steps completed successfully

**Next**: Proceed to **$MCPGrounding** for interactive Playwright MCP testing workflow

---

## Progressive Disclosure

**References** (load only when needed):
<references>
  <reference title="Troubleshooting" path="references/troubleshooting.md" description="Advanced browser setup issues, MCP server problems, custom paths, maintenance" />
  <reference title="OS-specific installation" path="references/os-specific-installation.md" description="Detailed setup for Pop! OS, Fedora, macOS, Windows, Arch, Alpine" />
  <reference title="Installation script" path="scripts/install-playwright-mcp.sh" description="Automated installation script for common platforms" />
</references>

**Remember**: This skill focuses on infrastructure setup. Once browsers work, use **$MCPGrounding** to develop and test automation interactively before scripting.
