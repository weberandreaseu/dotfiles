#!/bin/bash
set -e

echo "=== 03: Set zsh as default shell ==="

if command -v zsh &> /dev/null; then
    target_shell="$(command -v zsh)"
    current_shell=""
    current_user="$(id -un)"

    if command -v getent &> /dev/null; then
        current_shell="$(getent passwd "$current_user" 2>/dev/null | cut -d: -f7)"
    elif command -v dscl &> /dev/null; then
        current_shell="$(dscl . -read "/Users/$current_user" UserShell 2>/dev/null | awk '{print $2}')"
    fi

    # Fallback when user DB lookup is unavailable.
    if [ -z "$current_shell" ]; then
        current_shell="${SHELL:-}"
    fi

    current_shell_name="$(basename "$current_shell")"
    target_shell_name="$(basename "$target_shell")"

    if [ "$current_shell" = "$target_shell" ] || [ "$current_shell_name" = "$target_shell_name" ]; then
        echo "zsh is already the default shell. Skipping."
    else
        chsh -s "$target_shell"
    fi
fi

echo "=== 03: zsh set as default shell ==="
