#!/bin/bash
set -e

echo "=== 01: Adding third-party repositories ==="

if [ "$(id -u)" = "0" ]; then
    if [ ! -f /etc/apt/trusted.gpg.d/ghostty.gpg ]; then
        add-apt-repository -y ppa:mkasberg/ghostty
    fi
    apt-get update
else
    echo "Skipping repo addition (not root)"
fi

echo "=== 01: Repositories added ==="
