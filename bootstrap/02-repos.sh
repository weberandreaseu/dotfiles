#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/lib/root.sh"
ensure_root "02-repos.sh" "$@"

echo "=== 02: Adding third-party repositories ==="

for script in "$SCRIPT_DIR"/02-repos/*.sh; do
    if [ -f "$script" ] && [ "$(basename "$script")" != "$(basename "$0")" ]; then
        echo "Running $(basename "$script")..."
        bash "$script"
    fi
done

apt-get update

echo "=== 02: Repositories added ==="
