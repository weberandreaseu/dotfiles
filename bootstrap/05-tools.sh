#!/bin/bash
set -e

echo "=== 05: Installing tools ==="

export PATH="$HOME/.local/bin:$PATH"

# fzf - command-line fuzzy finder
if ! command -v fzf &> /dev/null; then
    FZF_DIR=$(mktemp -d)
    git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_DIR"
    "$FZF_DIR/install" --bin
    mkdir -p "$HOME/.local/bin"
    mv "$FZF_DIR/bin/fzf" "$HOME/.local/bin/"
    rm -rf "$FZF_DIR"
fi

# zoxide - smarter cd command that learns your habits
if ! command -v zoxide &> /dev/null; then
    curl -sS https://webinstall.dev/zoxide | HOME="$HOME" bash
fi

# opencode - AI coding assistant
if ! command -v opencode &> /dev/null; then
    curl -fsSL https://opencode.ai/install | bash
fi

# Some opencode installers place the binary under ~/.opencode/bin only.
# Link it into ~/.local/bin so it's consistently available on PATH.
if ! command -v opencode &> /dev/null && [ -x "$HOME/.opencode/bin/opencode" ]; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$HOME/.opencode/bin/opencode" "$HOME/.local/bin/opencode"
fi

# SDKMAN - Software Development Kit Manager
if [ -d "$HOME/.sdkman" ]; then
    echo "SDKMAN already installed"
else
    curl -s "https://get.sdkman.io" | bash
fi

# docker - container platform
if ! command -v docker &> /dev/null; then
    if [ "$(id -u)" = "0" ]; then
        apt-get install -y docker.io
        systemctl enable docker || true
        systemctl start docker || true
    else
        echo "Skipping docker installation (not root)"
    fi
fi

# code - Visual Studio Code
if ! command -v code &> /dev/null; then
    if [ "$(id -u)" = "0" ]; then
        apt-get update
        apt-get install -y code
    else
        echo "Skipping VS Code installation (not root)"
    fi
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

echo "=== 05: Tools installed ==="
