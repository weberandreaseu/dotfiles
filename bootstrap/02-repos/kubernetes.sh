#!/bin/bash
set -e
# Kubernetes: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/../lib/root.sh"
ensure_root "Kubernetes repository setup" "$@"

if [ -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ] && [ -f /etc/apt/sources.list.d/kubernetes.list ]; then
    echo "Kubernetes repo already configured"
    exit 0
fi

echo "Adding Kubernetes repository..."

apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg

mkdir -p /etc/apt/keyrings
chmod 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' > /etc/apt/sources.list.d/kubernetes.list
chmod 644 /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubectl

echo "Kubernetes kubectl installed"
