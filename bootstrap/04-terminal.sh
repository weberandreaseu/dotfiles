#!/bin/bash
set -e

echo "=== 04: Installing Ghostty terminal ==="

if ! command -v ghostty &> /dev/null; then
    if [ "$(id -u)" = "0" ]; then
        apt-get install -y ghostty
    else
        echo "Skipping ghostty installation (not root, run with sudo to install)"
    fi
fi

mkdir -p "$HOME/.config/ghostty"

if [ ! -f "$HOME/.config/ghostty/config" ]; then
    cat > "$HOME/.config/ghostty/config" << 'EOF'
font-family = JetBrainsMono Nerd Font Mono
font-size = 13

theme = Catppuccin Mocha

shell-integration = zsh
EOF
fi

echo "=== 04: Ghostty installed ==="
