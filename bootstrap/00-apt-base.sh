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
    flatpak \
    curl \
    wget \
    extrepo \
    zsh \
    unzip \
    fontconfig \
    ca-certificates \
    fonts-powerline \
    build-essential \
    cmake \
    bsdutils \
    diffutils \
    findutils \
    grep \
    gzip \
    hostname \
    rename

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "=== 00: Base packages installed ==="
