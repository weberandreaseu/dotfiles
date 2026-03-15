#!/bin/bash
set -e

echo "=== 01: Adding third-party repositories ==="

if ! command -v ghostty &> /dev/null; then
    if [ "$(id -u)" = "0" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
    else
        echo "Skipping Ghostty installation (not root, run with sudo)"
    fi
fi

echo "=== 01: Repositories added ==="
