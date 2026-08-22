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
ensure_root "Docker repository setup" "$@"

if grep -Rqs "download.docker.com" /etc/apt/sources.list.d 2>/dev/null; then
    echo "Docker repo already configured"
    exit 0
fi

echo "Setting up Docker repository..."

apt_update_once "Docker prerequisite index refresh"
apt-get install -y ca-certificates
extrepo enable docker-ce

echo "Docker repository configured"
