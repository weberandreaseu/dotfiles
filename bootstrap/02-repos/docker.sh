#!/bin/bash
set -e
# Docker: https://docs.docker.com/engine/install/ubuntu/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/../lib/root.sh"
ensure_root "Docker repository setup" "$@"

if [ "${DOTFILES_CONTAINER_TEST:-0}" = "1" ] || [ -f /.dockerenv ] || grep -qaE '(docker|containerd)' /proc/1/cgroup 2>/dev/null; then
    echo "Container environment detected; skipping Docker repository setup"
    exit 0
fi

if grep -Rqs "download.docker.com" /etc/apt/sources.list.d 2>/dev/null; then
    echo "Docker repo already configured"
    exit 0
fi

echo "Setting up Docker repository..."

apt_update_once "Docker prerequisite index refresh"
apt-get install -y ca-certificates
extrepo enable docker-ce

apt_update_once "Docker repository index refresh" force

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Docker installed successfully"
