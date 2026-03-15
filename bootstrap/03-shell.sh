#!/bin/bash
set -e

echo "=== 03: Installing zsh and plugins ==="

export PATH="$HOME/.local/bin:$PATH"

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

if command -v zsh &> /dev/null; then
    if [ -z "$SHELL" ] || [ "$SHELL" != "/bin/zsh" ]; then
        chsh -s /bin/zsh
    fi
fi

echo "=== 03: zsh installed ==="
