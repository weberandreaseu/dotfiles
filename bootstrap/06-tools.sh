#!/bin/bash
set -e

echo "=== 06: Installing tools ==="

# JetBrains Toolbox - manage JetBrains IDEs
if [ ! -d "$HOME/.local/share/JetBrains/Toolbox" ]; then
    TOOLBOX_TMP=$(mktemp -d)
    cleanup_toolbox_tmp() {
        rm -rf "$TOOLBOX_TMP"
    }
    trap cleanup_toolbox_tmp EXIT

    echo "Fetching latest JetBrains Toolbox version..."
    TOOLBOX_URL=$(curl --fail --silent --show-error --location 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' \
        | grep -oP '"linux":\s*\{"link":\s*"\K[^"]+' | head -1)
    if [ -z "$TOOLBOX_URL" ]; then
        echo "ERROR: Unable to find a JetBrains Toolbox Linux download URL." >&2
        exit 1
    fi

    echo "Downloading JetBrains Toolbox..."
    curl --fail --silent --show-error --location "$TOOLBOX_URL" -o "$TOOLBOX_TMP/jetbrains-toolbox.tar.gz"
    tar -xzf "$TOOLBOX_TMP/jetbrains-toolbox.tar.gz" -C "$TOOLBOX_TMP"
    TOOLBOX_EXTRACTED=$(find "$TOOLBOX_TMP" -mindepth 1 -maxdepth 1 -type d -name 'jetbrains-toolbox-*' -print -quit)
    if [ -z "$TOOLBOX_EXTRACTED" ] || [ ! -f "$TOOLBOX_EXTRACTED/bin/jetbrains-toolbox" ]; then
        echo "ERROR: JetBrains Toolbox archive did not contain the expected executable." >&2
        exit 1
    fi

    mkdir -p "$HOME/.local/share/JetBrains"
    mv "$TOOLBOX_EXTRACTED" "$HOME/.local/share/JetBrains/Toolbox"
    chmod +x "$HOME/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox"
    trap - EXIT
    cleanup_toolbox_tmp
    echo "JetBrains Toolbox installed"
fi

echo "=== 06: Tools installed ==="
