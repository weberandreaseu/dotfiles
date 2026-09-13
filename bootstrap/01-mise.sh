#!/bin/bash
set -e

echo "=== 01: Installing mise ==="

if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: 01-mise.sh must be run as your normal user, not root."
    echo "mise installs into that user's \$HOME; re-run without sudo."
    exit 1
fi

if command -v mise > /dev/null 2>&1; then
    echo "mise already installed: $(mise --version)"
else
    curl -fsSL https://mise.run | sh
fi

export PATH="$HOME/.local/bin:$PATH"
mise --version

echo "=== 01: mise installed ==="
