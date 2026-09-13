#!/bin/bash
set -e

echo "=== 06: Installing tools ==="

# JetBrains Toolbox - manage JetBrains IDEs
TOOLBOX_DIR="$HOME/.local/share/JetBrains/Toolbox"
TOOLBOX_BIN="$TOOLBOX_DIR/bin/jetbrains-toolbox"
TOOLBOX_ICON="$TOOLBOX_DIR/bin/toolbox.svg"
TOOLBOX_DESKTOP_FILE="$HOME/.local/share/applications/jetbrains-toolbox.desktop"

if [ ! -d "$TOOLBOX_DIR" ]; then
    TOOLBOX_TMP=$(mktemp -d)
    cleanup_toolbox_tmp() {
        rm -rf "$TOOLBOX_TMP"
    }
    trap cleanup_toolbox_tmp EXIT

    echo "Fetching latest JetBrains Toolbox version..."
    TOOLBOX_URL=$(curl --fail --silent --show-error --location 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' \
        | grep -oP '"linux":\s*\{"link":\s*"\K[^"]+' | head -1)
    if [ -z "$TOOLBOX_URL" ]; then
        echo "ERROR: Unable to find a JetBrains Toolbox Linux download URL." >&2
        exit 1
    fi

    echo "Downloading JetBrains Toolbox..."
    curl --fail --silent --show-error --location "$TOOLBOX_URL" -o "$TOOLBOX_TMP/jetbrains-toolbox.tar.gz"
    tar -xzf "$TOOLBOX_TMP/jetbrains-toolbox.tar.gz" -C "$TOOLBOX_TMP"
    TOOLBOX_EXTRACTED=$(find "$TOOLBOX_TMP" -mindepth 1 -maxdepth 1 -type d -name 'jetbrains-toolbox-*' -print -quit)
    if [ -z "$TOOLBOX_EXTRACTED" ] || [ ! -f "$TOOLBOX_EXTRACTED/bin/jetbrains-toolbox" ]; then
        echo "ERROR: JetBrains Toolbox archive did not contain the expected executable." >&2
        exit 1
    fi

    mkdir -p "$HOME/.local/share/JetBrains"
    mv "$TOOLBOX_EXTRACTED" "$TOOLBOX_DIR"
    chmod +x "$TOOLBOX_BIN"
    trap - EXIT
    cleanup_toolbox_tmp
    echo "JetBrains Toolbox installed"
fi

# Toolbox only writes its own ~/.local/share/applications entry on first
# interactive launch, so bootstrap (which never runs the GUI) leaves it
# invisible in the app grid. Install a launcher ourselves from the icon/exec
# the tarball already ships, using absolute paths since Toolbox isn't on PATH.
if [ -f "$TOOLBOX_BIN" ] && [ ! -f "$TOOLBOX_DESKTOP_FILE" ]; then
    echo "Adding JetBrains Toolbox launcher to application menu..."
    mkdir -p "$HOME/.local/share/applications"
    cat > "$TOOLBOX_DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=JetBrains Toolbox
Exec=$TOOLBOX_BIN
Icon=$TOOLBOX_ICON
StartupNotify=false
Terminal=false
Categories=Development;
EOF
    if command -v update-desktop-database > /dev/null 2>&1; then
        update-desktop-database "$HOME/.local/share/applications" > /dev/null 2>&1 || true
    fi
    echo "JetBrains Toolbox launcher added"
fi

echo "=== 06: Tools installed ==="
