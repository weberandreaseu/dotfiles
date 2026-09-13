#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/root.sh
source "$SCRIPT_DIR/lib/root.sh"
ensure_root "05-gnome.sh" "$@"

CUSTOM_SHORTCUTS_DCONF_FILE="$SCRIPT_DIR/assets/gnome-custom-shortcuts.dconf"
WM_KEYBINDINGS_DCONF_FILE="$SCRIPT_DIR/assets/gnome-wm-keybindings.dconf"
MUTTER_KEYBINDINGS_DCONF_FILE="$SCRIPT_DIR/assets/gnome-mutter-keybindings.dconf"

CLIPBOARD_INDICATOR_UUID="clipboard-indicator@tudmotu.com"
CLIPBOARD_INDICATOR_EXTENSION_PK="779"

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
            if cat "$dconf_file" | runuser -u "$target_user" -- env \
                XDG_RUNTIME_DIR="$user_runtime_dir" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=$user_dbus_bus" \
                dconf load "$dconf_prefix"; then
                echo "Applied GNOME dconf import: $dconf_prefix from $(basename "$dconf_file")"
            else
                warn "Failed GNOME dconf import: $dconf_prefix from $(basename "$dconf_file")"
            fi
            return 0
        fi

        if command -v sudo >/dev/null 2>&1; then
            if cat "$dconf_file" | sudo -u "$target_user" env \
                XDG_RUNTIME_DIR="$user_runtime_dir" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=$user_dbus_bus" \
                dconf load "$dconf_prefix"; then
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

install_clipboard_indicator() {
    local target_user="${SUDO_USER:-}"
    local target_uid=""
    local user_home=""
    local user_runtime_dir=""
    local user_dbus_bus=""
    local shell_version=""
    local extension_info=""
    local download_path=""
    local tmp_zip=""

    if [ -z "$target_user" ]; then
        warn "Skipping Clipboard Indicator install because SUDO_USER is not set."
        return 0
    fi

    if ! command -v gnome-extensions >/dev/null 2>&1 || ! command -v gnome-shell >/dev/null 2>&1; then
        warn "Skipping Clipboard Indicator install because gnome-shell is not installed."
        return 0
    fi

    user_home="$(getent passwd "$target_user" | cut -d: -f6)"
    if [ -n "$user_home" ] && [ -d "$user_home/.local/share/gnome-shell/extensions/$CLIPBOARD_INDICATOR_UUID" ]; then
        echo "Clipboard Indicator extension already installed for $target_user, skipping."
        return 0
    fi

    target_uid="$(id -u "$target_user" 2>/dev/null || true)"
    if [ -z "$target_uid" ]; then
        warn "Skipping Clipboard Indicator install because user lookup failed for: $target_user"
        return 0
    fi

    user_runtime_dir="/run/user/$target_uid"
    user_dbus_bus="$user_runtime_dir/bus"

    if [ ! -S "$user_dbus_bus" ]; then
        warn "Skipping Clipboard Indicator install because no user DBus session bus was found at $user_dbus_bus"
        return 0
    fi

    shell_version="$(gnome-shell --version | grep -oP '\d+' | head -1)"
    if [ -z "$shell_version" ]; then
        warn "Skipping Clipboard Indicator install because the GNOME Shell version could not be determined."
        return 0
    fi

    extension_info="$(curl --fail --silent --location \
        "https://extensions.gnome.org/extension-info/?pk=$CLIPBOARD_INDICATOR_EXTENSION_PK&shell_version=$shell_version")" || {
        warn "Skipping Clipboard Indicator install because extension metadata could not be fetched."
        return 0
    }

    download_path="$(echo "$extension_info" | grep -oP '"download_url":\s*"[^"]+"' | grep -oP '(?<=: ")[^"]+')"
    if [ -z "$download_path" ]; then
        warn "Skipping Clipboard Indicator install because no compatible version was found for GNOME Shell $shell_version."
        return 0
    fi

    tmp_zip="$(mktemp --suffix=.shell-extension.zip)"
    if ! curl --fail --silent --location --output "$tmp_zip" "https://extensions.gnome.org${download_path}"; then
        warn "Skipping Clipboard Indicator install because the extension archive could not be downloaded."
        rm -f "$tmp_zip"
        return 0
    fi
    chmod 644 "$tmp_zip"

    run_as_target_user() {
        if command -v runuser >/dev/null 2>&1; then
            runuser -u "$target_user" -- env \
                XDG_RUNTIME_DIR="$user_runtime_dir" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=$user_dbus_bus" \
                "$@"
            return $?
        fi

        if command -v sudo >/dev/null 2>&1; then
            sudo -u "$target_user" env \
                XDG_RUNTIME_DIR="$user_runtime_dir" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=$user_dbus_bus" \
                "$@"
            return $?
        fi

        warn "Skipping Clipboard Indicator install because neither runuser nor sudo is available."
        return 1
    }

    if run_as_target_user gnome-extensions install "$tmp_zip" \
        && run_as_target_user gnome-extensions enable "$CLIPBOARD_INDICATOR_UUID"; then
        echo "Installed and enabled Clipboard Indicator extension for $target_user."
    else
        warn "Failed to install/enable Clipboard Indicator extension."
    fi

    rm -f "$tmp_zip"
}

echo "=== 05: Applying GNOME configuration ==="

apply_custom_shortcuts
install_clipboard_indicator

echo "=== 05: GNOME configuration applied ==="
