#!/bin/bash
# Mozilla Firefox: https://support.mozilla.org/kb/install-firefox-linux

if [ "$(id -u)" != "0" ]; then
    echo "Skipping Mozilla repo (not root)"
    exit 0
fi

if [ -f /etc/apt/sources.list.d/mozilla.list ] || [ -f /etc/apt/sources.list.d/mozilla.sources ]; then
    echo "Mozilla repo already configured"
    exit 0
fi

echo "Adding Mozilla repository..."

sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/packages.mozilla.org.asc

if command -v gpg > /dev/null 2>&1; then
    FINGERPRINT=$(gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc 2>/dev/null | awk '/pub/{getline; gsub(/^ +| +$/,""); print}')
    if [ "$FINGERPRINT" != "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3" ]; then
        echo "ERROR: Mozilla key fingerprint mismatch. Expected: 35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3, Got: $FINGERPRINT"
        exit 1
    fi
fi

if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$VERSION_ID" in
        13|14)
            cat <<EOF | sudo tee /etc/apt/sources.list.d/mozilla.sources > /dev/null
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF
            ;;
        *)
            echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
            ;;
    esac
else
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
fi

echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla > /dev/null

echo "Mozilla repo added"
