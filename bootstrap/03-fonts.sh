#!/bin/bash
set -e

echo "=== 03: Installing JetBrains Mono Nerd Font ==="

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
cd "$FONT_DIR"

if [ ! -f "OFL.txt" ]; then
    curl -fLo "JetBrainsMono.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
    unzip -o JetBrainsMono.zip
    rm JetBrainsMono.zip
fi

fc-cache -f -v

echo "=== 03: JetBrains Mono Nerd Font installed ==="
