#!/bin/bash
set -e
# Docker: https://docs.docker.com/engine/install/ubuntu/

if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
    echo "GitHub Actions environment detected; skipping Docker repository setup"
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/../lib/root.sh"

if grep -Rqs "download.docker.com" /etc/apt/sources.list.d 2>/dev/null; then
    echo "Docker repo already configured"
    exit 0
fi

echo "Setting up Docker repository..."

apt_update_once "Docker prerequisite index refresh"
sudo apt-get install -y ca-certificates

sudo install -d -m 0755 /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo "Docker repository configured"
