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

apt-get update
apt-get install -y extrepo ca-certificates

if grep -Rqs "download.mise.jdx.dev" /etc/apt/sources.list.d 2>/dev/null; then
    echo "mise extrepo source already enabled"
else
    extrepo enable mise
fi

apt-get update
apt-get install -y mise

mise --version

echo "=== 01: mise installed ==="
