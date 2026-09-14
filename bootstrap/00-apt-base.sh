#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/lib/root.sh"

echo "=== 00: Installing base packages ==="

apt_update_once "00-apt-base package index refresh"

sudo apt-get install -y git
sudo apt-get install -y flatpak
sudo apt-get install -y curl
sudo apt-get install -y wget
sudo apt-get install -y gnupg
sudo apt-get install -y zsh
sudo apt-get install -y unzip
sudo apt-get install -y fontconfig
sudo apt-get install -y ca-certificates
sudo apt-get install -y fonts-powerline
sudo apt-get install -y build-essential
sudo apt-get install -y cmake
sudo apt-get install -y bsdutils
sudo apt-get install -y diffutils
sudo apt-get install -y findutils
sudo apt-get install -y grep
sudo apt-get install -y gzip
sudo apt-get install -y hostname
sudo apt-get install -y rename

sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "=== 00: Base packages installed ==="
