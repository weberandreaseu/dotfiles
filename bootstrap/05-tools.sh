#!/bin/bash
set -e

echo "=== 05: Installing tools ==="

export PATH="$HOME/.local/bin:$PATH"

if ! command -v fzf &> /dev/null; then
    FZF_DIR=$(mktemp -d)
    git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_DIR"
    "$FZF_DIR/install" --bin
    mkdir -p "$HOME/.local/bin"
    mv "$FZF_DIR/bin/fzf" "$HOME/.local/bin/"
    rm -rf "$FZF_DIR"
fi

if ! command -v zoxide &> /dev/null; then
    curl -sS https://webinstall.dev/zoxide | HOME="$HOME" bash
fi

if ! command -v docker &> /dev/null; then
    if [ "$(id -u)" = "0" ]; then
        apt-get install -y docker.io
        systemctl enable docker || true
        systemctl start docker || true
    else
        echo "Skipping docker installation (not root)"
    fi
fi

if [ ! -d "$HOME/.local/share/JetBrains/Toolbox" ]; then
    TOOLBOX_TMP=$(mktemp -d)
    echo "Fetching latest JetBrains Toolbox version..."
    TOOLBOX_URL=$(curl -sSL 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' \
        | grep -oP '"linux":\s*\{"link":\s*"\K[^"]+' | head -1)
    echo "Downloading JetBrains Toolbox..."
    curl -sSL "$TOOLBOX_URL" -o "$TOOLBOX_TMP/jetbrains-toolbox.tar.gz"
    tar -xzf "$TOOLBOX_TMP/jetbrains-toolbox.tar.gz" -C "$HOME/.local/share/JetBrains"
    chmod +x "$HOME/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox"
    rm -rf "$TOOLBOX_TMP"
    echo "JetBrains Toolbox installed"
fi

echo "=== 05: Tools installed ==="
