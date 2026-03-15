#!/bin/bash
set -e

echo "=== 04: Installing GNOME apps ==="

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get install -y \
    geary \
    gnome-calendar \
    gnome-contacts

echo "=== 04: GNOME apps installed ==="
