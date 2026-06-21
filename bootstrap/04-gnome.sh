#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/lib/root.sh"
ensure_root "04-gnome.sh" "$@"

echo "=== 04: Installing GNOME apps ==="

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get install -y \
    geary \
    gnome-calendar \
    gnome-contacts

echo "=== 04: GNOME apps installed ==="
