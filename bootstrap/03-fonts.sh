#!/bin/bash
set -e

echo "=== 03: Installing JetBrains Mono Nerd Font ==="

FONT_DIR="$HOME/.local/share/fonts"
FONT_VERSION="3.4.0"
FONT_ARCHIVE="JetBrainsMono.zip"
FONT_SHA256="76f05ff3ace48a464a6ca57977998784ff7bdbb65a6d915d7e401cd3927c493c"
mkdir -p "$FONT_DIR"
cd "$FONT_DIR"

if [ ! -f "OFL.txt" ]; then
    curl --fail --location --retry 3 --output "$FONT_ARCHIVE" \
        "https://github.com/ryanoasis/nerd-fonts/releases/download/v${FONT_VERSION}/${FONT_ARCHIVE}"
    printf '%s  %s\n' "$FONT_SHA256" "$FONT_ARCHIVE" | sha256sum --check --status
    unzip -o "$FONT_ARCHIVE"
    rm -f "$FONT_ARCHIVE"
fi

fc-cache -f -v

echo "=== 03: JetBrains Mono Nerd Font installed ==="
