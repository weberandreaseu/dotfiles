#!/bin/bash
set -e

FONT_NAME="JetBrainsMono"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
FONT_DIR="$HOME/.local/share/fonts"

mkdir -p "$FONT_DIR"
cd "$FONT_DIR"

curl -fLo "JetBrainsMono.zip" "$FONT_URL"
unzip -o JetBrainsMono.zip
rm JetBrainsMono.zip

fc-cache -f -v
