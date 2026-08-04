#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/lib/root.sh"

echo "=== 03: Installing fonts ==="

if command -v apt-get &> /dev/null; then
    run_as_root "Fira Code system package installation" apt-get install -y fonts-firacode
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

echo "=== 03: Fonts installed ==="
