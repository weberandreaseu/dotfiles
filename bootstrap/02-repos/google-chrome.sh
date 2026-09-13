#!/bin/bash
set -e
# Google Chrome: https://www.google.com/linuxrepositories/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/../lib/root.sh"
ensure_root "Google Chrome repository setup" "$@"

if grep -Rqs "dl.google.com/linux/chrome/deb" /etc/apt/sources.list.d 2>/dev/null; then
    echo "Google Chrome repo already configured"
    exit 0
fi

echo "Adding Google Chrome repository..."

install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list > /dev/null

echo "Google Chrome repo added"
