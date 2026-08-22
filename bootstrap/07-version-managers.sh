#!/bin/bash
set -e

echo "=== 07: Installing version managers ==="

if command -v mise &> /dev/null; then
    echo "mise is installed and handles runtime version management"
else
    echo "Error: mise not found in PATH"
    exit 1
fi

echo "Node/npm and login shell setup are handled in 08-dotfiles.sh via: mise bootstrap --only user,dotfiles,tools"

echo "=== 07: Version managers installed ==="
