#!/bin/bash
set -e
# Kubernetes: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/../lib/root.sh"
ensure_root "Kubernetes repository setup" "$@"

KUBE_LIST="/etc/apt/sources.list.d/kubernetes.list"
KUBE_SOURCES="/etc/apt/sources.list.d/kubernetes.sources"
KUBE_KEYRING="/etc/apt/keyrings/kubernetes-apt-keyring.gpg"
kube_repo_changed=0

if [ -f "$KUBE_LIST" ] && [ -f "$KUBE_SOURCES" ]; then
    echo "Kubernetes repo is configured in both .list and .sources; removing legacy .list"
    rm -f "$KUBE_LIST"
fi

if [ ! -f "$KUBE_LIST" ] && [ ! -f "$KUBE_SOURCES" ]; then
    echo "Adding Kubernetes repository..."

    apt_update_once "Kubernetes prerequisite index refresh"
    apt-get install -y apt-transport-https ca-certificates curl gnupg

    mkdir -p /etc/apt/keyrings
    chmod 755 /etc/apt/keyrings

    tmp_keyring="$(mktemp)"
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | gpg --dearmor --yes -o "$tmp_keyring"
    install -o root -g root -m 644 "$tmp_keyring" "$KUBE_KEYRING"
    rm -f "$tmp_keyring"

    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' > "$KUBE_LIST"
    chmod 644 "$KUBE_LIST"
    kube_repo_changed=1
else
    echo "Kubernetes repo already configured"
fi

if [ "$kube_repo_changed" -eq 1 ]; then
    apt_update_once "Kubernetes repository index refresh" force
else
    apt_update_once "Kubernetes repository index refresh"
fi
apt-get install -y kubectl

echo "Kubernetes kubectl installed"
