#!/bin/bash
set -e

echo "=== 02: Installing fonts ==="

FONT_NAME="JetBrainsMono"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
FONT_DIR="$HOME/.local/share/fonts"

mkdir -p "$FONT_DIR"
cd "$FONT_DIR"

if [ ! -f "OFL.txt" ]; then
    curl -fLo "JetBrainsMono.zip" "$FONT_URL"
    unzip -o JetBrainsMono.zip
    rm JetBrainsMono.zip
fi

fc-cache -f -v

echo "=== 02: Fonts installed ==="
