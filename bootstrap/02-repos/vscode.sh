#!/bin/bash
set -e
# VS Code: https://code.visualstudio.com/docs/setup/linux

if grep -Rqs "packages.microsoft.com/repos/code" /etc/apt/sources.list.d 2>/dev/null; then
    echo "VS Code repo already configured"
    exit 0
fi

echo "Configuring VS Code repository..."

sudo apt-get install -y --no-install-recommends ca-certificates
sudo apt-get install -y --no-install-recommends curl
sudo apt-get install -y --no-install-recommends gnupg

tmp_key="$(mktemp)"
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor --yes -o "$tmp_key"
sudo install -D -o root -g root -m 644 "$tmp_key" /usr/share/keyrings/microsoft.gpg
rm -f "$tmp_key"

sudo tee /etc/apt/sources.list.d/vscode.sources > /dev/null <<EOF
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF

echo "VS Code repo configured"
