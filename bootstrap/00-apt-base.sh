#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/lib/root.sh"

echo "=== 00: Installing base packages ==="

apt_update_once "00-apt-base package index refresh"

sudo apt install -y git
sudo apt install -y flatpak
sudo apt install -y curl
sudo apt install -y wget
sudo apt install -y gnupg
sudo apt install -y zsh
sudo apt install -y unzip
sudo apt install -y ca-certificates
sudo apt install -y gzip
sudo apt install -y htop
sudo apt install -y traceroute
sudo apt install -y tree
sudo apt install -y wl-clipboard
sudo apt install -y fonts-firacode

sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "=== 00: Base packages installed ==="
