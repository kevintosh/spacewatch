#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="${0:A:h}"
cd "$SCRIPT_DIR"

echo "SpaceWatch installer"
echo "===================="

# Check Swift
if ! command -v swift >/dev/null 2>&1; then
    echo "Error: Swift is not installed."
    echo ""
    echo "Install Apple's Command Line Tools with:"
    echo ""
    echo "    xcode-select --install"
    echo ""
    exit 1
fi

# Check package
if [[ ! -f "Package.swift" ]]; then
    echo "Error: Package.swift was not found in:"
    echo "    $SCRIPT_DIR"
    exit 1
fi

if [[ ! -f "Sources/SpaceWatch/main.swift" ]]; then
    echo "Error: Sources/SpaceWatch/main.swift was not found."
    exit 1
fi

echo ""
echo "Building release version..."
swift build -c release

INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

echo ""
echo "Installing..."
cp ".build/release/spacewatch" \
   "$INSTALL_DIR/spacewatch"

chmod +x "$INSTALL_DIR/spacewatch"

echo ""
echo "Installed successfully:"
echo "    $INSTALL_DIR/spacewatch"
echo ""

# Check PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "Adding ~/.local/bin to your PATH..."

    if ! grep -q 'HOME/.local/bin' "$HOME/.zshrc" 2>/dev/null; then
        echo '' >> "$HOME/.zshrc"
        echo '# SpaceWatch' >> "$HOME/.zshrc"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    fi

    export PATH="$INSTALL_DIR:$PATH"

    echo "Added to ~/.zshrc."
fi

echo ""
echo "Installation complete."
echo ""
echo "Next steps:"
echo ""
echo "1. Give your terminal Accessibility permission:"
echo ""
echo "   System Settings"
echo "     -> Privacy & Security"
echo "     -> Accessibility"
echo ""
echo "2. Arrange all windows and Spaces exactly as you want them."
echo ""
echo "3. Save your HOME configuration:"
echo ""
echo "   spacewatch snapshot home"
echo ""
echo "4. Test restoration with:"
echo ""
echo "   spacewatch restore home"
echo ""
echo "5. Start automatic profile management with:"
echo ""
echo "   spacewatch watch-auto"
echo ""
echo "   To install it as a LaunchAgent, run ./install-watcher.sh"
echo ""