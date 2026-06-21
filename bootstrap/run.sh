#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IS_ROOT=0

if [ "$(id -u)" = "0" ]; then
    IS_ROOT=1
fi

requires_root() {
    case "$1" in
        00-apt-base.sh|01-repos.sh|04-gnome.sh)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

echo "=========================================="
echo "Dotfiles Bootstrap"
echo "=========================================="

export HOME="${HOME:-/home/testuser}"
export PATH="$HOME/.local/bin:$PATH"

mkdir -p "$HOME/.local/bin"

for script in 00-apt-base.sh 01-repos.sh 02-fonts.sh 03-shell.sh 04-gnome.sh 05-tools.sh 06-version-managers.sh 07-dotfiles.sh; do
    if [ -f "$SCRIPT_DIR/$script" ]; then
        echo ""
        echo "----------------------------------------"
        echo "Running $script..."
        echo "----------------------------------------"
        if requires_root "$script"; then
            if [ "$IS_ROOT" = "1" ]; then
                bash "$SCRIPT_DIR/$script"
            elif command -v sudo > /dev/null 2>&1; then
                sudo bash "$SCRIPT_DIR/$script"
            else
                echo "Skipping $script (requires root and sudo is unavailable)"
            fi
        else
            bash "$SCRIPT_DIR/$script"
        fi
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
