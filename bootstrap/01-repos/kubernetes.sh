#!/bin/bash
# Kubernetes: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

if [ "$(id -u)" != "0" ]; then
    echo "Skipping Kubernetes repo (not root)"
    exit 0
fi

if [ -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ] && [ -f /etc/apt/sources.list.d/kubernetes.list ]; then
    echo "Kubernetes repo already configured"
    exit 0
fi

echo "Adding Kubernetes repository..."

apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg

mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' > /etc/apt/sources.list.d/kubernetes.list
chmod 644 /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubectl

echo "Kubernetes kubectl installed"
