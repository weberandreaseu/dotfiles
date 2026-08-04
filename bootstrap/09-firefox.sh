#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/lib/root.sh"

echo "=== 09: Enforcing apt-only Firefox ==="

MOZILLA_REPO_SCRIPT="$SCRIPT_DIR/02-repos/mozilla.sh"
FIREFOX_PIN_FILE="/etc/apt/preferences.d/no-ubuntu-firefox"

if [ -f /etc/apt/sources.list.d/mozilla.list ] || [ -f /etc/apt/sources.list.d/mozilla.sources ]; then
    echo "Mozilla Firefox repository already configured"
else
    echo "Mozilla Firefox repository missing; configuring it now"
    bash "$MOZILLA_REPO_SCRIPT"
fi

apt_update_once "Firefox APT install index refresh" force

if dpkg -s firefox > /dev/null 2>&1; then
    echo "Firefox package already installed via APT"
else
    run_as_root "Firefox APT install" apt-get install -y firefox
fi

if command -v snap > /dev/null 2>&1 && snap list firefox > /dev/null 2>&1; then
    echo "Removing Firefox Snap package"
    if ! run_as_root "Firefox Snap removal" snap remove --purge firefox; then
        run_as_root "Firefox Snap removal" snap remove firefox
    fi
else
    echo "Firefox Snap package not installed"
fi

TMP_PIN_FILE="$(mktemp)"
cat > "$TMP_PIN_FILE" <<'EOF'
Package: firefox firefox-locale-*
Pin: release o=Ubuntu
Pin-Priority: -1
EOF

run_as_root "Firefox APT pinning" install -m 0644 "$TMP_PIN_FILE" "$FIREFOX_PIN_FILE"
rm -f "$TMP_PIN_FILE"

if command -v xdg-settings > /dev/null 2>&1; then
    xdg-settings set default-web-browser firefox.desktop || true
fi

rm -f "$HOME/.local/share/applications/firefox_firefox.desktop"
rm -f "$HOME/.local/share/applications/userapp-Firefox-"*.desktop 2>/dev/null || true

if command -v update-desktop-database > /dev/null 2>&1; then
    update-desktop-database "$HOME/.local/share/applications" > /dev/null 2>&1 || true
fi

echo "=== 09: apt-only Firefox is configured ==="
