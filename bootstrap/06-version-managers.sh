#!/bin/bash
set -e

echo "=== 06: Installing version managers ==="

# NVM - Node Version Manager
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

echo "=== 06: Version managers installed ==="
