#!/bin/bash
# VS Code: https://code.visualstudio.com/docs/setup/linux

if [ "$(id -u)" != "0" ]; then
    echo "Skipping VS Code repo (not root)"
    exit 0
fi

if [ -f /usr/share/keyrings/microsoft.gpg ]; then
    echo "VS Code repo already configured"
    exit 0
fi

echo "Adding VS Code repository..."

apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg
rm -f microsoft.gpg

echo "Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg" | tee /etc/apt/sources.list.d/vscode.sources > /dev/null

echo "VS Code repo added"
