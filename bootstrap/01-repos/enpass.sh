#!/bin/bash
set -e

if [ "$(id -u)" != "0" ]; then
    echo "Skipping Enpass repo (not root)"
    exit 0
fi

if [ -f /etc/apt/trusted.gpg.d/enpass.asc ]; then
    echo "Enpass repo already configured"
    exit 0
fi

echo "Adding Enpass repository..."

wget -qO- https://apt.enpass.io/keys/enpass.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/enpass.asc
echo "deb https://apt.enpass.io/ stable main" > /etc/apt/sources.list.d/enpass.list

echo "Enpass repo added"
