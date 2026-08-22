#!/bin/bash
set -e

echo "=== 06: Installing tools ==="

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
