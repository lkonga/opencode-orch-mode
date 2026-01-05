#!/bin/bash
# Playwright MCP Installation Script
# Detects OS and installs Playwright MCP with appropriate dependencies

set -e

echo "🎭 Playwright MCP Installation Script"
echo "====================================="

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    OS="Windows"
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi

echo "📍 Detected OS: $OS"

# Install Playwright MCP globally
echo "📦 Installing Playwright MCP globally..."
npm install -g @playwright/mcp

# Install system dependencies based on OS
case $OS in
    "Ubuntu"* | "Debian"*)
        echo "🔧 Installing Ubuntu/Debian dependencies..."
        sudo apt-get update
        sudo apt-get install -y libnss3 libatk-bridge2.0-0 libdrm2 libxcomposite1 libxdamage1 libxrandr2 libgbm1 libxss1 libasound2
        ;;
    "Pop!_OS"*)
        echo "🔧 Installing Pop!_OS dependencies..."
        sudo apt-get update
        sudo apt-get install -y libnss3 libatk-bridge2.0-0 libdrm2 libxcomposite1 libxdamage1 libxrandr2 libgbm1 libxss1 libasound2

        echo "🌐 Installing Google Chrome for Pop!_OS..."
        wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
        echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
        sudo apt-get update
        sudo apt-get install -y google-chrome-stable
        ;;
    "Fedora"* | "CentOS"* | "Red Hat"*)
        echo "🔧 Installing Fedora/CentOS/RHEL dependencies..."
        sudo dnf install -y nss atk-bridge libdrm libXcomposite libXrandr mesa-libgbm libXScrnSaver alsa-lib
        sudo dnf install -y chromium
        ;;
    "macOS")
        echo "🍎 macOS detected. Installing Playwright dependencies..."
        ;;
    "Windows")
        echo "🪟 Windows detected. Installing Playwright dependencies..."
        ;;
    *)
        echo "⚠️  Unknown Linux distribution. Installing generic dependencies..."
        sudo apt-get update || sudo yum update || sudo dnf update || true
        sudo apt-get install -y libnss3 libatk-bridge2.0-0 libdrm2 libxcomposite1 libxdamage1 libxrandr2 libgbm1 libxss1 libasound2 || \
        sudo yum install -y nss atk-bridge libdrm libXcomposite libXrandr mesa-libgbm libXScrnSaver alsa-lib || \
        sudo dnf install -y nss atk-bridge libdrm libXcomposite libXrandr mesa-libgbm libXScrnSaver alsa-lib || true
        ;;
esac

# Install Playwright browsers
echo "🌐 Installing Playwright browsers..."
npx playwright install

# Install additional dependencies if available
echo "🔍 Installing additional dependencies..."
npx playwright install-deps || echo "⚠️  Additional dependencies installation failed (this is normal on some systems)"

# Verify installation
echo "✅ Verifying installation..."
npx playwright install --dry-run

# Test browser launch
echo "🧪 Testing browser launch..."
if command -v google-chrome >/dev/null 2>&1 || command -v chromium-browser >/dev/null 2>&1 || command -v chromium >/dev/null 2>&1; then
    echo "✅ Browser installation verified"
else
    echo "⚠️  Browser not found in PATH. Manual installation may be required."
fi

echo ""
echo "🎉 Playwright MCP installation completed!"
echo ""
echo "Next steps:"
echo "1. Verify installation with: npx playwright install --dry-run"
echo "2. Test browser tools with your MCP client"
echo "3. Navigate to https://example.com to verify functionality"
echo ""
echo "If you encounter issues, check the troubleshooting guide:"
echo "https://github.com/microsoft/playwright/blob/main/docs/troubleshooting.md"
