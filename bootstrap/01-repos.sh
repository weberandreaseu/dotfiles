#!/bin/bash
set -e

echo "=== 01: Adding third-party repositories ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for script in "$SCRIPT_DIR"/01-repos/*.sh; do
    if [ -f "$script" ] && [ "$(basename "$script")" != "$(basename "$0")" ]; then
        echo "Running $(basename "$script")..."
        bash "$script"
    fi
done

if [ "$(id -u)" = "0" ]; then
    apt-get update
fi

echo "=== 01: Repositories added ==="
