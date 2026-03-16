#!/bin/bash
set -e

DOTFILES_DIR="/tmp/dotfiles"
HOME_DIR="${HOME:-/home/testuser}"

export HOME="$HOME_DIR"

export PATH="$HOME_DIR/.local/bin:$PATH"
mkdir -p "$HOME_DIR/.local/bin"

curl -sS https://webinstall.dev/zoxide | HOME="$HOME_DIR" bash

if ! command -v fzf &> /dev/null; then
    git clone --depth 1 https://github.com/junegunn/fzf.git /tmp/fzf
    /tmp/fzf/install --bin
    mkdir -p "$HOME_DIR/.local/bin"
    mv /tmp/fzf/bin/fzf "$HOME_DIR/.local/bin/"
    rm -rf /tmp/fzf
fi

if [ -d "$DOTFILES_DIR" ]; then
    cd "$DOTFILES_DIR"
    rm -f "$HOME_DIR/.zshrc"
    rm -f "$HOME_DIR/.bashrc"
    rm -f "$HOME_DIR/.bash_logout"
    rm -f "$HOME_DIR/.profile"
    rm -f "$HOME_DIR/.gitconfig"
    stow -t "$HOME_DIR" -d . bash git zsh jetbrains
fi

mkdir -p "$HOME_DIR/.config"

if command -v ghostty &> /dev/null; then
    update-alternatives --set x-terminal-emulator /usr/bin/ghostty
fi
