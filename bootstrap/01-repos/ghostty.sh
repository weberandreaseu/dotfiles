#!/bin/bash
set -e
# Ghostty: https://ghostty.org/docs/install/binary#linux

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/../lib/root.sh"
ensure_root "Ghostty installation" "$@"

if command -v ghostty &> /dev/null; then
    echo "Ghostty already installed"
    exit 0
fi

echo "Installing Ghostty..."

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"

echo "Ghostty installed"
