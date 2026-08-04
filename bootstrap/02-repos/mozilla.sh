#!/bin/bash
set -e
# Mozilla Firefox: https://support.mozilla.org/kb/install-firefox-linux

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/../lib/root.sh"
ensure_root "Mozilla repository setup" "$@"

if grep -Rqs "packages.mozilla.org/apt" /etc/apt/sources.list.d 2>/dev/null; then
    echo "Mozilla repo already configured"
    exit 0
fi

echo "Adding Mozilla repository..."

extrepo enable mozilla

echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | tee /etc/apt/preferences.d/mozilla > /dev/null

echo "Mozilla repo added"
