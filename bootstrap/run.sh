#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS=(00-apt-base.sh 01-repos.sh 02-fonts.sh 03-shell.sh 04-gnome.sh 05-tools.sh 06-version-managers.sh 07-dotfiles.sh 08-firefox.sh)
COMPLETED_SCRIPTS=()
SKIPPED_SCRIPTS=()
FAILED_SCRIPT=""

echo "=========================================="
echo "Dotfiles Bootstrap"
echo "=========================================="

export HOME="${HOME:-/home/testuser}"
export PATH="$HOME/.local/bin:$PATH"

mkdir -p "$HOME/.local/bin"

print_summary() {
    echo ""
    echo "=========================================="
    echo "Bootstrap summary"
    echo "=========================================="
    echo "Completed: ${#COMPLETED_SCRIPTS[@]}"
    for script in "${COMPLETED_SCRIPTS[@]}"; do
        echo "  - $script"
    done
    echo "Skipped: ${#SKIPPED_SCRIPTS[@]}"
    for script in "${SKIPPED_SCRIPTS[@]}"; do
        echo "  - $script"
    done
    if [ -n "$FAILED_SCRIPT" ]; then
        echo "Failed: $FAILED_SCRIPT"
    else
        echo "Failed: none"
    fi
}

trap print_summary EXIT

for script in "${SCRIPTS[@]}"; do
    if [ ! -f "$SCRIPT_DIR/$script" ]; then
        SKIPPED_SCRIPTS+=("$script (missing)")
        continue
    fi

    echo ""
    echo "----------------------------------------"
    echo "Running $script..."
    echo "----------------------------------------"

    if bash "$SCRIPT_DIR/$script"; then
        COMPLETED_SCRIPTS+=("$script")
    else
        FAILED_SCRIPT="$script"
        echo "ERROR: $script failed. Aborting bootstrap."
        break
    fi
done

if [ -n "$FAILED_SCRIPT" ]; then
    exit 1
fi

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
