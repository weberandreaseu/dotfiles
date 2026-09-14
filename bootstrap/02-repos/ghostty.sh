#!/bin/bash
set -e
# Ghostty: https://ghostty.org/docs/install/binary#linux

sudo add-apt-repository ppa:mkasberg/ghostty-ubuntu
sudo apt update
sudo apt install ghostty