#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/lib/root.sh"
ensure_root "04-gnome.sh" "$@"

CUSTOM_SHORTCUTS_DCONF_FILE="$SCRIPT_DIR/assets/gnome-custom-shortcuts.dconf"
WM_KEYBINDINGS_DCONF_FILE="$SCRIPT_DIR/assets/gnome-wm-keybindings.dconf"
MUTTER_KEYBINDINGS_DCONF_FILE="$SCRIPT_DIR/assets/gnome-mutter-keybindings.dconf"

warn() {
    echo "WARNING: $1"
}

apply_custom_shortcuts() {
    local target_user="${SUDO_USER:-}"
    local target_uid=""
    local user_runtime_dir=""
    local user_dbus_bus=""

    if [ -z "$target_user" ]; then
        warn "Skipping GNOME custom shortcut import because SUDO_USER is not set."
        return 0
    fi

    if ! command -v dconf >/dev/null 2>&1; then
        warn "Skipping GNOME custom shortcut import because dconf is not installed."
        return 0
    fi

    target_uid="$(id -u "$target_user" 2>/dev/null || true)"
    if [ -z "$target_uid" ]; then
        warn "Skipping GNOME custom shortcut import because user lookup failed for: $target_user"
        return 0
    fi

    user_runtime_dir="/run/user/$target_uid"
    user_dbus_bus="$user_runtime_dir/bus"

    if [ ! -S "$user_dbus_bus" ]; then
        warn "Skipping GNOME custom shortcut import because no user DBus session bus was found at $user_dbus_bus"
        return 0
    fi

    apply_dconf_file() {
        local dconf_prefix="$1"
        local dconf_file="$2"

        if [ ! -f "$dconf_file" ]; then
            warn "Skipping GNOME dconf import because dump file is missing: $dconf_file"
            return 0
        fi

        if command -v runuser >/dev/null 2>&1; then
            if runuser -u "$target_user" -- env \
                XDG_RUNTIME_DIR="$user_runtime_dir" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=$user_dbus_bus" \
                dconf load "$dconf_prefix" < "$dconf_file"; then
                echo "Applied GNOME dconf import: $dconf_prefix from $(basename "$dconf_file")"
            else
                warn "Failed GNOME dconf import: $dconf_prefix from $(basename "$dconf_file")"
            fi
            return 0
        fi

        if command -v sudo >/dev/null 2>&1; then
            if sudo -u "$target_user" env \
                XDG_RUNTIME_DIR="$user_runtime_dir" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=$user_dbus_bus" \
                dconf load "$dconf_prefix" < "$dconf_file"; then
                echo "Applied GNOME dconf import: $dconf_prefix from $(basename "$dconf_file")"
            else
                warn "Failed GNOME dconf import: $dconf_prefix from $(basename "$dconf_file")"
            fi
            return 0
        fi

        warn "Skipping GNOME dconf import because neither runuser nor sudo is available."
    }

    apply_dconf_file "/org/gnome/settings-daemon/plugins/media-keys/" "$CUSTOM_SHORTCUTS_DCONF_FILE"
    apply_dconf_file "/org/gnome/desktop/wm/keybindings/" "$WM_KEYBINDINGS_DCONF_FILE"
    apply_dconf_file "/org/gnome/mutter/keybindings/" "$MUTTER_KEYBINDINGS_DCONF_FILE"

    echo "GNOME keybindings import completed for user: $target_user"
}

echo "=== 04: Installing GNOME apps ==="

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get install -y \
    geary \
    gnome-calendar \
    gnome-contacts

apply_custom_shortcuts

echo "=== 04: GNOME apps installed ==="
