#!/bin/bash
set -e
# Mozilla Firefox: https://support.mozilla.org/kb/install-firefox-linux

if grep -Rqs "packages.mozilla.org/apt" /etc/apt/sources.list.d 2>/dev/null; then
    echo "Mozilla repo already configured"
    exit 0
fi

echo "Adding Mozilla repository..."

sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/packages.mozilla.org.asc

if command -v gpg > /dev/null 2>&1; then
    EXPECTED_FINGERPRINT="35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3"
    FINGERPRINT="$(gpg --show-keys --with-colons /etc/apt/keyrings/packages.mozilla.org.asc 2>/dev/null | awk -F: '$1=="fpr"{print $10; exit}')"
    if [ "$FINGERPRINT" != "$EXPECTED_FINGERPRINT" ]; then
        echo "ERROR: Mozilla key fingerprint mismatch. Expected: $EXPECTED_FINGERPRINT, Got: $FINGERPRINT"
        exit 1
    fi
fi

echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null

echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla > /dev/null

echo "Mozilla repo added"
