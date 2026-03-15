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

curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
echo "Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/microsoft.gpg" > /etc/apt/sources.list.d/vscode.sources

echo "VS Code repo added"
