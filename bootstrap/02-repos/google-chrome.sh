#!/bin/bash
set -e
# Google Chrome: https://www.google.com/linuxrepositories/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/../lib/root.sh"
ensure_root "Google Chrome repository setup" "$@"

if [ -f /etc/apt/sources.list.d/google-chrome.list ]; then
    echo "Google Chrome repo already configured"
    exit 0
fi

echo "Adding Google Chrome repository..."

wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | tee /etc/apt/trusted.gpg.d/google.asc >/dev/null
# NOTE: On systems with older versions of apt (i.e. versions prior to 1.4), the ASCII-armored
# format public key must be converted to binary format before it can be used by apt.
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/google.gpg

echo "Google Chrome repo added"
