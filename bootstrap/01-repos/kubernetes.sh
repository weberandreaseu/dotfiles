#!/bin/bash
set -e

if [ "$(id -u)" != "0" ]; then
    echo "Skipping Kubernetes repo (not root)"
    exit 0
fi

if [ -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]; then
    echo "Kubernetes repo already configured"
    exit 0
fi

echo "Adding Kubernetes repository..."

mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" > /etc/apt/sources.list.d/kubernetes.list

echo "Kubernetes repo added"
