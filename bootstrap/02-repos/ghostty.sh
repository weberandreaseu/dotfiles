#!/bin/bash
set -e
# Ghostty: https://ghostty.org/docs/install/binary#linux

sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:mkasberg/ghostty-ubuntu
sudo apt-get update
sudo apt-get install -y ghostty
sudo update-alternatives --set x-terminal-emulator /usr/bin/ghostty