#!/bin/bash
set -e
# Google Chrome: https://www.google.com/linuxrepositories/

if ! grep -Rqs "dl.google.com/linux/chrome/deb" /etc/apt/sources.list.d 2>/dev/null; then
    echo "Adding Google Chrome repository..."

    sudo install -d -m 0755 /etc/apt/keyrings
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null

    sudo apt-get update
    echo "Google Chrome repo added"
else
    echo "Google Chrome repo already configured"
fi

sudo apt-get install -y google-chrome-stable
