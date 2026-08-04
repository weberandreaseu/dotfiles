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

ensure_extrepo_non_free_policy
extrepo enable google_chrome

echo "Google Chrome repo added"
