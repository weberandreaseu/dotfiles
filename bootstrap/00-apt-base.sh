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
    pkg-config \
    libx11-dev \
    libxft-dev \
    libxcb1-dev \
    libxcb-randr0-dev \
    libxcb-util0-dev \
    libxcb-xkb-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libglib2.0-dev \
    cmake

echo "=== 00: Base packages installed ==="
