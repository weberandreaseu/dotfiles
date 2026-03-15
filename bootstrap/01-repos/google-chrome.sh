#!/bin/bash
# Google Chrome: https://www.google.com/linuxrepositories/

if [ "$(id -u)" != "0" ]; then
    echo "Skipping Google Chrome repo (not root)"
    exit 0
fi

if [ -f /etc/apt/sources.list.d/google-chrome.list ]; then
    echo "Google Chrome repo already configured"
    exit 0
fi

echo "Adding Google Chrome repository..."

wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | tee /etc/apt/trusted.gpg.d/google.asc >/dev/null
# NOTE: On systems with older versions of apt (i.e. versions prior to 1.4), the ASCII-armored
# format public key must be converted to binary format before it can be used by apt.
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | su tee /etc/apt/trusted.gpg.d/google.gpg >/dev/null

echo "Google Chrome repo added"
