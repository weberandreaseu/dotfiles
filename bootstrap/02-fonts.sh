#!/bin/bash
set -e

echo "=== 02: Installing fonts ==="

if [ "$(id -u)" -ne 0 ]; then
    echo "Skipping Fira Code (system package - requires sudo)"
elif command -v apt-get &> /dev/null; then
    sudo apt-get install -y fonts-firacode
fi

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
cd "$FONT_DIR"

if [ ! -f "OFL.txt" ]; then
    curl -fLo "JetBrainsMono.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
    unzip -o JetBrainsMono.zip
    rm JetBrainsMono.zip
fi

fc-cache -f -v

echo "=== 02: Fonts installed ==="
