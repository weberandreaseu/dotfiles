#!/bin/bash
set -e

echo "=== 01: Adding third-party repositories ==="

if [ "$(id -u)" = "0" ]; then
    # Docker
    if [ ! -f /etc/apt/keyrings/docker.asc ]; then
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        chmod a+r /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
    fi

    # Google Chrome
    if [ ! -f /etc/apt/trusted.gpg.d/google-chrome.gpg ]; then
        curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/trusted.gpg.d/google-chrome.gpg
        echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
    fi

    # Kubernetes
    if [ ! -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]; then
        mkdir -p /etc/apt/keyrings
        curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
        echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" > /etc/apt/sources.list.d/kubernetes.list
    fi

    # Mozilla Firefox
    if [ ! -f /etc/apt/keyrings/packages.mozilla.org.asc ]; then
        mkdir -p /etc/apt/keyrings
        curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg | gpg --dearmor -o /etc/apt/keyrings/packages.mozilla.org.asc
        chmod a+r /etc/apt/keyrings/packages.mozilla.org.asc
        echo "Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc" > /etc/apt/sources.list.d/mozilla.sources
    fi

    # VS Code
    if [ ! -f /usr/share/keyrings/microsoft.gpg ]; then
        curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
        echo "Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/microsoft.gpg" > /etc/apt/sources.list.d/vscode.sources
    fi

    # Enpass
    if [ ! -f /etc/apt/trusted.gpg.d/enpass.asc ]; then
        wget -qO- https://apt.enpass.io/keys/enpass.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/enpass.asc
        echo "deb https://apt.enpass.io/ stable main" > /etc/apt/sources.list.d/enpass.list
    fi

    # Ghostty
    if ! command -v ghostty &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
    fi

    apt-get update
else
    echo "Skipping repo addition (not root, run with sudo)"
fi

echo "=== 01: Repositories added ==="
