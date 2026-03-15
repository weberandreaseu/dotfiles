#!/bin/bash
set -e

if [ "$(id -u)" != "0" ]; then
    echo "Skipping Google Chrome repo (not root)"
    exit 0
fi

if [ -f /etc/apt/trusted.gpg.d/google-chrome.gpg ]; then
    echo "Google Chrome repo already configured"
    exit 0
fi

echo "Adding Google Chrome repository..."

curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/trusted.gpg.d/google-chrome.gpg
echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

echo "Google Chrome repo added"
