#!/bin/bash
# VS Code: https://code.visualstudio.com/docs/setup/linux

if [ "$(id -u)" != "0" ]; then
    echo "Skipping VS Code repo (not root)"
    exit 0
fi

echo "Configuring VS Code repository..."

apt-get install -y --no-install-recommends ca-certificates curl gnupg

tmp_key="$(mktemp)"
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor --yes -o "$tmp_key"
install -D -o root -g root -m 644 "$tmp_key" /usr/share/keyrings/microsoft.gpg
rm -f "$tmp_key"

rm -f /etc/apt/sources.list.d/vscode.list

echo "Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg" | tee /etc/apt/sources.list.d/vscode.sources > /dev/null

echo "VS Code repo configured"
