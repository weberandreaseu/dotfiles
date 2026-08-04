#!/bin/bash
set -e
# VS Code: https://code.visualstudio.com/docs/setup/linux

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/../lib/root.sh"
ensure_root "VS Code repository setup" "$@"

echo "Configuring VS Code repository..."

if grep -Rqs "packages.microsoft.com/repos/code" /etc/apt/sources.list.d 2>/dev/null; then
    echo "VS Code repo already configured"
    exit 0
fi

ensure_extrepo_non_free_policy
extrepo enable vscode

echo "VS Code repo configured"
