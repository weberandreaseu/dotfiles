#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/lib/root.sh"

echo "=== 06: Installing tools ==="

# SDKMAN - Software Development Kit Manager
if [ -d "$HOME/.sdkman" ]; then
    echo "SDKMAN already installed"
else
    curl -s "https://get.sdkman.io" | bash
fi

# docker - container platform
if ! command -v docker &> /dev/null; then
    run_as_root "Docker installation" apt-get install -y docker.io
    run_as_root "Docker service setup" systemctl enable docker || true
    run_as_root "Docker service setup" systemctl start docker || true
fi

# code - Visual Studio Code
if ! command -v code &> /dev/null; then
    apt_update_once "VS Code installation index refresh"
    run_as_root "VS Code installation" apt-get install -y code
fi

# JetBrains Toolbox - manage JetBrains IDEs
if [ ! -d "$HOME/.local/share/JetBrains/Toolbox" ]; then
    TOOLBOX_TMP=$(mktemp -d)
    echo "Fetching latest JetBrains Toolbox version..."
    TOOLBOX_URL=$(curl -sSL 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' \
        | grep -oP '"linux":\s*\{"link":\s*"\K[^"]+' | head -1)
    echo "Downloading JetBrains Toolbox..."
    curl -sSL "$TOOLBOX_URL" -o "$TOOLBOX_TMP/jetbrains-toolbox.tar.gz"
    mkdir -p "$HOME/.local/share/JetBrains"
    tar -xzf "$TOOLBOX_TMP/jetbrains-toolbox.tar.gz" -C "$TOOLBOX_TMP"
    TOOLBOX_EXTRACTED=$(ls -d "$TOOLBOX_TMP"/jetbrains-toolbox-*/)
    mv "$TOOLBOX_EXTRACTED" "$HOME/.local/share/JetBrains/Toolbox"
    chmod +x "$HOME/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox"
    rm -rf "$TOOLBOX_TMP"
    echo "JetBrains Toolbox installed"
fi

echo "=== 06: Tools installed ==="
