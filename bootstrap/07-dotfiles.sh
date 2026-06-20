#!/bin/bash
set -e

echo "=== 07: Setting up dotfiles ==="

export PATH="$HOME/.local/bin:$PATH"

DOTFILES_DIR="$HOME/git/dotfiles"
cd "$DOTFILES_DIR"

rm -f "$HOME/.zshrc"
rm -f "$HOME/.zshenv"

EXCLUDE_DIRS=".git .opencode bootstrap test bin shell"

for dir in */; do
    dir="${dir%/}"
    skip=false
    for exc in $EXCLUDE_DIRS; do
        [ "$dir" = "$exc" ] && skip=true && break
    done
    if [ "$skip" = false ]; then
        echo "Stowing $dir..."
        stow -t "$HOME" -d . "$dir"
    fi
done

if [ -d ".config" ]; then
    echo "Stowing .config..."
    stow -t "$HOME" -d . .config
fi

mkdir -p "$HOME/.config"

if command -v ghostty &> /dev/null; then
    if [ -f /usr/bin/ghostty ]; then
        update-alternatives --set x-terminal-emulator /usr/bin/ghostty 2>/dev/null || true
    fi
fi

echo "=== 07: Dotfiles installed ==="
