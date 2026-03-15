#!/bin/bash
# Enpass: https://support.enpass.io/app/getting_started/installing_enpass.htm

if [ "$(id -u)" != "0" ]; then
    echo "Skipping Enpass repo (not root)"
    exit 0
fi

if [ -f /etc/apt/trusted.gpg.d/enpass.asc ] && [ -f /etc/apt/sources.list.d/enpass.list ]; then
    echo "Enpass repo already configured"
    exit 0
fi

echo "Adding Enpass repository..."

wget -qO- https://apt.enpass.io/keys/enpass-linux.key | tee /etc/apt/trusted.gpg.d/enpass.asc > /dev/null
echo "deb https://apt.enpass.io/ stable main" > /etc/apt/sources.list.d/enpass.list

echo "Enpass repo added"
