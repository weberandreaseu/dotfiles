#!/bin/bash
set -e

echo "=== 06: Installing version managers ==="

export PATH="$HOME/.local/bin:$PATH"

if ! command -v bun &> /dev/null; then
    curl -fsSL https://bun.sh/install | bash
fi

echo "=== 06: Version managers installed ==="
