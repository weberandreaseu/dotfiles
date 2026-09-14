#!/bin/bash
set -e
# Ghostty: https://ghostty.org/docs/install/binary#linux

if command -v ghostty &> /dev/null; then
    echo "Ghostty already installed"
    exit 0
fi

echo "Installing Ghostty..."

GHOSTTY_TMP_DIR="$(mktemp -d)"
cleanup() {
    rm -rf "$GHOSTTY_TMP_DIR"
}
trap cleanup EXIT

(
    cd "$GHOSTTY_TMP_DIR"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
)

echo "Ghostty installed"
