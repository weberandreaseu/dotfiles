#!/bin/bash
# Mozilla Firefox: https://support.mozilla.org/en-US/kb/install-firefox-linux

if [ "$(id -u)" != "0" ]; then
    echo "Skipping Mozilla repo (not root)"
    exit 0
fi

if [ -f /etc/apt/keyrings/packages.mozilla.org.asc ]; then
    echo "Mozilla repo already configured"
    exit 0
fi

echo "Adding Mozilla repository..."

mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg | gpg --dearmor -o /etc/apt/keyrings/packages.mozilla.org.asc
chmod a+r /etc/apt/keyrings/packages.mozilla.org.asc
echo "Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc" > /etc/apt/sources.list.d/mozilla.sources

echo "Mozilla repo added"
