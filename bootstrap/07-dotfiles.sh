#!/bin/bash
set -e

echo "=== 07: Setting up dotfiles ==="

export PATH="$HOME/.local/bin:$PATH"

cd "$HOME/git/dotfiles"

rm -f "$HOME/.zshrc"
rm -f "$HOME/.bashrc"
rm -f "$HOME/.bash_logout"
rm -f "$HOME/.profile"
rm -f "$HOME/.gitconfig"
rm -f "$HOME/.zshenv"

stow -t "$HOME" -d . bash git zsh ghostty

mkdir -p "$HOME/.config"

if command -v ghostty &> /dev/null; then
    if [ -f /usr/bin/ghostty ]; then
        update-alternatives --set x-terminal-emulator /usr/bin/ghostty 2>/dev/null || true
    fi
fi

echo "=== 07: Dotfiles installed ==="
