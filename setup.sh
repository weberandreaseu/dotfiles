#!/bin/bash
set -e

DOTFILES_DIR="/tmp/dotfiles"
HOME_DIR="${HOME:-/home/testuser}"

export HOME="$HOME_DIR"
export ZSH="$HOME_DIR/.oh-my-zsh"

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

export PATH="$HOME_DIR/.local/bin:$PATH"
mkdir -p "$HOME_DIR/.local/bin"

curl -sS https://webinstall.dev/zoxide | HOME="$HOME_DIR" bash

if [ -d "$DOTFILES_DIR/oh-my-zsh/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    mkdir -p "$ZSH/custom/plugins"
    cp -r "$DOTFILES_DIR/oh-my-zsh/.oh-my-zsh/custom/plugins/zsh-autosuggestions" "$ZSH/custom/plugins/"
fi

if [ -d "$DOTFILES_DIR/oh-my-zsh/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    mkdir -p "$ZSH/custom/plugins"
    cp -r "$DOTFILES_DIR/oh-my-zsh/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" "$ZSH/custom/plugins/"
fi

if [ -d "$DOTFILES_DIR" ]; then
    cd "$DOTFILES_DIR"
    rm -f "$HOME_DIR/.zshrc"
    rm -f "$HOME_DIR/.bashrc"
    rm -f "$HOME_DIR/.bash_logout"
    rm -f "$HOME_DIR/.profile"
    rm -f "$HOME_DIR/.gitconfig"
    stow -t "$HOME_DIR" -d . bash git zsh
fi

mkdir -p "$HOME_DIR/.config"

if command -v ghostty &> /dev/null; then
    update-alternatives --set x-terminal-emulator /usr/bin/ghostty
fi
