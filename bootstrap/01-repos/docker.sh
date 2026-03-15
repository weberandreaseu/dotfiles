#!/bin/bash
# Docker: https://docs.docker.com/engine/install/ubuntu/

if [ "$(id -u)" != "0" ]; then
    echo "Skipping Docker repo (not root)"
    exit 0
fi

if [ -f /etc/apt/keyrings/docker.asc ] && [ -f /etc/apt/sources.list.d/docker.sources ]; then
    echo "Docker repo already configured"
    exit 0
fi

echo "Setting up Docker repository..."

apt update
apt install -y ca-certificates curl

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt update

apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Docker installed successfully"
