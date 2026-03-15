#!/bin/bash
set -e

echo "=== 03: Set zsh as default shell ==="

if command -v zsh &> /dev/null; then
    if [ -z "$SHELL" ] || [ "$SHELL" != "/bin/zsh" ]; then
        chsh -s /bin/zsh
    fi
fi

echo "=== 03: zsh set as default shell ==="
