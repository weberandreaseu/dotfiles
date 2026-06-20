#!/bin/bash
set -e

echo "=== 06: Installing version managers ==="

# SDKMAN - Software Development Kit Manager
if [ -d "$HOME/.sdkman" ]; then
    echo "SDKMAN already installed"
else
    curl -s "https://get.sdkman.io" | bash
fi

# NVM - Node Version Manager
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

echo "=== 06: Version managers installed ==="
