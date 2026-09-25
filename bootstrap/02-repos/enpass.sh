#!/bin/bash
set -e
# Enpass: https://support.enpass.io/app/getting_started/installing_enpass.htm
# Temporarily disabled
exit 0

ENPASS_LIST="/etc/apt/sources.list.d/enpass.list"
ENPASS_SOURCES="/etc/apt/sources.list.d/enpass.sources"

if [ -f "$ENPASS_LIST" ] && [ -f "$ENPASS_SOURCES" ]; then
    echo "Enpass repo is configured in both .list and .sources; removing legacy .list"
    sudo rm -f "$ENPASS_LIST"
fi

if [ -f "$ENPASS_LIST" ] || [ -f "$ENPASS_SOURCES" ]; then
    echo "Enpass repo already configured"
    exit 0
fi

echo "Adding Enpass repository..."

wget -qO- https://apt.enpass.io/keys/enpass-linux.key | sudo tee /etc/apt/trusted.gpg.d/enpass.asc > /dev/null
echo "deb https://apt.enpass.io/ stable main" | sudo tee "$ENPASS_LIST" > /dev/null

echo "Enpass repo added"
