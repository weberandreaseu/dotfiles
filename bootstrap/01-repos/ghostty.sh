#!/bin/bash
set -e

if [ "$(id -u)" != "0" ]; then
    echo "Skipping Ghostty (not root)"
    exit 0
fi

if command -v ghostty &> /dev/null; then
    echo "Ghostty already installed"
    exit 0
fi

echo "Installing Ghostty..."

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"

echo "Ghostty installed"
