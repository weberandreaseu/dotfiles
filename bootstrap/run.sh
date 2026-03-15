#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Dotfiles Bootstrap"
echo "=========================================="

export HOME="${HOME:-/home/testuser}"
export PATH="$HOME/.local/bin:$PATH"

mkdir -p "$HOME/.local/bin"

for script in 00-apt-base.sh 01-repos.sh 02-fonts.sh 03-shell.sh 04-terminal.sh 05-tools.sh 06-version-managers.sh 07-dotfiles.sh; do
    if [ -f "$SCRIPT_DIR/$script" ]; then
        echo ""
        echo "----------------------------------------"
        echo "Running $script..."
        echo "----------------------------------------"
        bash "$SCRIPT_DIR/$script"
    fi
done

echo ""
echo "=========================================="
echo "Bootstrap complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Restart your shell"
echo "  2. Run 'exec zsh' to switch to zsh"
echo "  3. Customize as needed"
echo ""
