#!/bin/bash
set -e

echo "=== 07: Installing version managers ==="

if command -v mise &> /dev/null; then
    echo "mise is installed and handles runtime version management"
else
    echo "Error: mise not found in PATH"
    exit 1
fi

echo "=== 07: Version managers installed ==="
