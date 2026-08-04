#!/bin/bash
set -e
# Enpass: https://support.enpass.io/app/getting_started/installing_enpass.htm

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/../lib/root.sh"
ensure_root "Enpass repository setup" "$@"

ENPASS_LIST="/etc/apt/sources.list.d/enpass.list"
ENPASS_SOURCES="/etc/apt/sources.list.d/enpass.sources"

if [ -f "$ENPASS_LIST" ] && [ -f "$ENPASS_SOURCES" ]; then
    echo "Enpass repo is configured in both .list and .sources; removing legacy .list"
    rm -f "$ENPASS_LIST"
fi

if [ -f "$ENPASS_LIST" ] || [ -f "$ENPASS_SOURCES" ]; then
    echo "Enpass repo already configured"
    exit 0
fi

echo "Adding Enpass repository..."

wget -qO- https://apt.enpass.io/keys/enpass-linux.key | tee /etc/apt/trusted.gpg.d/enpass.asc > /dev/null
echo "deb https://apt.enpass.io/ stable main" > "$ENPASS_LIST"

echo "Enpass repo added"
