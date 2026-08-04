#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/lib/root.sh"
ensure_root "01-mise.sh" "$@"

if [ "$(id -u)" -eq 0 ]; then
    export HOME="/root"
fi

echo "=== 01: Installing mise via extrepo ==="

export DEBIAN_FRONTEND=noninteractive

apt_update_once "01-mise prerequisite index refresh"
apt-get install -y extrepo ca-certificates

mise_repo_changed=0
if grep -Rqs "download.mise.jdx.dev" /etc/apt/sources.list.d 2>/dev/null; then
    echo "mise extrepo source already enabled"
else
    extrepo enable mise
    mise_repo_changed=1
fi

if [ "$mise_repo_changed" -eq 1 ]; then
    apt_update_once "01-mise repository index refresh" force
else
    apt_update_once "01-mise repository index refresh"
fi
apt-get install -y mise

mise --version

echo "=== 01: mise installed ==="
