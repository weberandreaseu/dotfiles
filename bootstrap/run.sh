#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS=(00-apt-base.sh 01-mise.sh 02-repos.sh 03-fonts.sh 04-shell.sh 05-gnome.sh 06-tools.sh 08-dotfiles.sh 09-firefox.sh)
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
