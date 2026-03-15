#!/bin/bash
set -e

echo "=== 00: Installing base packages ==="

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get install -y \
    git \
    curl \
    wget \
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
    fdfind \
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
