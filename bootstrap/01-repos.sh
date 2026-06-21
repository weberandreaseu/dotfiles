#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/lib/root.sh"
ensure_root "01-repos.sh" "$@"

echo "=== 01: Adding third-party repositories ==="

for script in "$SCRIPT_DIR"/01-repos/*.sh; do
    if [ -f "$script" ] && [ "$(basename "$script")" != "$(basename "$0")" ]; then
        echo "Running $(basename "$script")..."
        bash "$script"
    fi
done

apt-get update

echo "=== 01: Repositories added ==="
