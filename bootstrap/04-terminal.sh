#!/bin/bash
set -e

echo "=== 04: Configuring Ghostty terminal ==="

mkdir -p "$HOME/.config/ghostty"

if [ ! -f "$HOME/.config/ghostty/config" ]; then
    cat > "$HOME/.config/ghostty/config" << 'EOF'
font-family = JetBrainsMono Nerd Font Mono
font-size = 13

theme = Catppuccin Mocha

shell-integration = zsh
EOF
fi

echo "=== 04: Ghostty configured ==="
