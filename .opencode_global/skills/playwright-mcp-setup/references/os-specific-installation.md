# OS-Specific Installation Guide

## Quick Reference Table

| Operating System | Package Manager | Browser Install Method | Notes |
|------------------|----------------|------------------------|-------|
| Ubuntu/Debian | apt | `npx playwright install` | Officially supported |
| Pop! OS | apt | Manual Chrome installation | Not officially supported |
| Fedora/CentOS/RHEL | dnf/yum | `sudo dnf install chromium` | Extra deps needed |
| macOS | brew | `npx playwright install` | Officially supported |
| Windows | npm | `npx playwright install` | Officially supported |
| Arch Linux | pacman | `yay -S google-chrome` | Manual setup |
| Alpine Linux | apk | `apk add chromium` | Lightweight setup |

## Pop! OS (Not Officially Supported)

### Why Special Handling Needed
Pop! OS is based on Ubuntu but not officially recognized by Playwright's OS detection. You'll see warnings during installation, but browsers will work if properly configured.

### Complete Setup Steps

```bash
# Step 1: Install system dependencies (same as Ubuntu)
sudo apt-get update
sudo apt-get install -y libnss3 libatk-bridge2.0-0 libdrm2 libxcomposite1 \
  libxdamage1 libxrandr2 libgbm1 libxss1 libasound2

# Step 2: Add Google Chrome repository manually
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | \
  sudo tee /etc/apt/sources.list.d/google-chrome.list

# Step 3: Update package list and install Chrome
sudo apt-get update
sudo apt-get install -y google-chrome-stable

# Step 4: Install Playwright browsers (expect warnings about unsupported OS)
npx playwright install
```

### Expected Warnings
```
Warning: Unsupported operating system detected
Installing browsers anyway...
```
**These warnings can be safely ignored** - the browsers will work correctly.

## Fedora/CentOS/RHEL

### System Dependencies

```bash
# Install system dependencies with DNF
sudo dnf install -y nss atk-bridge libdrm libXcomposite libXrandr \
  mesa-libgbm libXScrnSaver alsa-lib

# Install Chrome/Chromium browser
sudo dnf install -y chromium

# Install Playwright browsers
npx playwright install
```

### Alternative: YUM (Older Versions)
```bash
# For older CentOS/RHEL versions
sudo yum install -y nss atk-bridge libdrm libXcomposite libXrandr \
  mesa-libgbm libXScrnSaver alsa-lib

sudo yum install -y chromium
npx playwright install
```

## macOS

### Standard Installation

```bash
# Install Playwright browsers
npx playwright install

# Install additional dependencies if needed
npx playwright install-deps
```

### Homebrew Alternative
```bash
# Install via Homebrew
brew install playwright

# Install system dependencies
npx playwright install-deps
```

### macOS-Specific Considerations
- **Xcode Command Line Tools** may be required: `xcode-select --install`
- **Rosetta 2** needed on Apple Silicon: Automatically prompted if required
- **System permissions**: Grant terminal access in System Preferences > Privacy & Security

## Windows

### Standard Installation

```bash
# Install Playwright browsers
npx playwright install

# Install additional dependencies if needed
npx playwright install-deps
```

### Windows-Specific Setup
```powershell
# Run in PowerShell as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Install Node.js via Chocolatey (if needed)
choco install nodejs

# Install Playwright MCP
npm install -g @playwright/mcp
npx playwright install
```

### WSL (Windows Subsystem for Linux)
Follow the Ubuntu/Debian instructions when using WSL:
```bash
# Inside WSL terminal
sudo apt-get update
sudo apt-get install -y libnss3 libatk-bridge2.0-0 libdrm2 libxcomposite1 \
  libxdamage1 libxrandr2 libgbm1 libxss1 libasound2

npx playwright install
```

## Arch Linux

### Package Installation

```bash
# Step 1: Install dependencies via pacman
sudo pacman -S nss atk libdrm libxcomposite libxdamage libxrandr \
  libgbm libxss alsa-lib

# Step 2: Install Chrome via AUR helper (yay)
yay -S google-chrome

# Alternative: Use Chromium from official repos
sudo pacman -S chromium

# Step 3: Install Playwright browsers
npx playwright install
```

### AUR Setup (If Needed)
```bash
# Install yay AUR helper
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

## Alpine Linux

### Lightweight Setup

```bash
# Step 1: Install dependencies
apk add nss atk-bridge libdrm libxcomposite libxdamage libxrandr \
  mesa-gbm libxss alsa-lib

# Step 2: Install Chromium
apk add chromium

# Step 3: Install Playwright browsers
npx playwright install
```

### Alpine-Specific Considerations
- **musl libc** instead of glibc may cause compatibility issues
- **Limited browser support**: Chromium recommended, Firefox may have issues
- **Docker Alpine**: Consider using Node.js Alpine image with Playwright

## Advanced Configuration

### Custom Browser Paths

For non-standard browser installations:

```bash
# Set custom browser path environment variable
export PLAYWRIGHT_BROWSERS_PATH=/path/to/custom/browsers

# Install browsers to custom path
npx playwright install --browser-path=/path/to/custom/browsers
```

### Network Configuration

For restricted network environments:

```bash
# Use proxy for browser downloads
export HTTPS_PROXY=http://proxy.company.com:8080
export HTTP_PROXY=http://proxy.company.com:8080

# Install browsers with proxy
npx playwright install
```

### Offline Installation

```bash
# Download browsers on a connected machine
npx playwright install
tar -czf playwright-browsers.tar.gz ~/.cache/ms-playwright

# Transfer to offline machine and extract
scp playwright-browsers.tar.gz user@offline-machine:~
ssh user@offline-machine
tar -xzf playwright-browsers.tar.gz -C ~/.cache/
```

## Troubleshooting OS-Specific Issues

### Pop! OS: Chrome Not Found After Installation
```bash
# Verify Chrome is installed
which google-chrome

# Create symlink if needed
sudo ln -s /usr/bin/google-chrome-stable /usr/bin/google-chrome

# Reinstall Playwright browsers
npx playwright install --force
```

### Fedora: SELinux Blocking Browser
```bash
# Check SELinux status
getenforce

# Temporarily disable for testing
sudo setenforce 0

# Permanent fix: Create custom SELinux policy (consult documentation)
```

### macOS: Gatekeeper Blocking Browser
```bash
# Remove quarantine attribute
xattr -d com.apple.quarantine /path/to/browser

# Or allow in System Preferences
# System Preferences > Privacy & Security > Allow anyway
```

### Windows: Antivirus Blocking Installation
```powershell
# Add exclusion in Windows Defender
Add-MpPreference -ExclusionPath "$env:USERPROFILE\.cache\ms-playwright"

# Or temporarily disable real-time protection during installation
```
