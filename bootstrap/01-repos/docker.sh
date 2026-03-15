#!/bin/bash
# Docker: https://docs.docker.com/engine/install/ubuntu/

if [ "$(id -u)" != "0" ]; then
    echo "Skipping Docker repo (not root)"
    exit 0
fi

if [ -f /etc/apt/keyrings/docker.asc ]; then
    echo "Docker repo already configured"
    exit 0
fi

echo "Adding Docker repository..."

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

echo "Docker repo added"
