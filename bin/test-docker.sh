#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
IMAGE_NAME="dotfiles-test"

echo "Building Docker image..."
docker build -t "$IMAGE_NAME" "$DOTFILES_DIR"

echo
echo "Running tests in container..."
docker run --rm "$IMAGE_NAME"
