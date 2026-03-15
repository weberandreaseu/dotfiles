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

echo "=== 05: Tools installed ==="
