#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/lib/root.sh"
ensure_root "00-apt-base.sh" "$@"

echo "=== 00: Installing base packages ==="

export DEBIAN_FRONTEND=noninteractive

apt_update_once "00-apt-base package index refresh"

apt-get install -y \
    git \
    curl \
    wget \
    extrepo \
    stow \
    zsh \
    unzip \
    fontconfig \
    ca-certificates \
    fonts-powerline \
    build-essential \
    cmake \
    nmap \
    traceroute \
    wireguard \
    htop \
    tree \
    fd-find \
    wl-clipboard \
    yq \
    bsdutils \
    diffutils \
    findutils \
    grep \
    gzip \
    hostname \
    rename

echo "=== 00: Base packages installed ==="
