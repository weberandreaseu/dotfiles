#!/bin/bash

require_sudo() {
    if command -v sudo > /dev/null 2>&1; then
        return 0
    fi

    echo "ERROR: $1 requires root privileges, but sudo is not available."
    echo "Install sudo or run this script as root."
    return 1
}

ensure_root() {
    local step="$1"
    shift || true

    if [ "$(id -u)" -eq 0 ]; then
        return 0
    fi

    require_sudo "$step" || return 1
    echo "$step requires root privileges. Re-running with sudo..."
    sudo bash "$0" "$@"
    local sudo_status=$?
    if [ "$sudo_status" -ne 0 ]; then
        return "$sudo_status"
    fi
    exit 0
}

run_as_root() {
    local step="$1"
    shift || true

    if [ "$(id -u)" -eq 0 ]; then
        "$@"
        return $?
    fi

    require_sudo "$step" || return 1
    sudo "$@" || {
        echo "ERROR: Failed to run privileged command for $step."
        return 1
    }
}

apt_update_once() {
    local step="$1"
    local mode="${2:-normal}"
    local stamp_file="/tmp/dotfiles-bootstrap-apt-update.stamp"
    local max_age_seconds="${DOTFILES_APT_UPDATE_MAX_AGE_SECONDS:-1800}"
    local now_epoch
    local stamp_epoch

    now_epoch="$(date +%s)"

    if [ "$mode" = "force" ] || [ ! -f "$stamp_file" ]; then
        run_as_root "$step" apt-get update
        run_as_root "$step" touch "$stamp_file"
        return 0
    fi

    stamp_epoch="$(stat -c %Y "$stamp_file" 2>/dev/null || echo 0)"

    if [ $((now_epoch - stamp_epoch)) -ge "$max_age_seconds" ]; then
        run_as_root "$step" apt-get update
        run_as_root "$step" touch "$stamp_file"
    else
        echo "APT package lists are recent. Skipping apt-get update."
    fi
}

ensure_extrepo_non_free_policy() {
    local config_file="/etc/extrepo/config.yaml"

    if [ ! -f "$config_file" ]; then
        echo "ERROR: extrepo config file missing at $config_file"
        return 1
    fi

    if grep -Eq '^[[:space:]]*-[[:space:]]*non-free[[:space:]]*$' "$config_file"; then
        return 0
    fi

    echo "Enabling extrepo non-free policy..."

    if grep -Eq '^[[:space:]]*#[[:space:]]*-[[:space:]]*non-free[[:space:]]*$' "$config_file"; then
        sed -i -E 's|^[[:space:]]*#[[:space:]]*-[[:space:]]*non-free[[:space:]]*$|- non-free|' "$config_file"
        return 0
    fi

    if grep -Eq '^[[:space:]]*enabled_policies:[[:space:]]*$' "$config_file"; then
        sed -i '/^[[:space:]]*enabled_policies:[[:space:]]*$/a - non-free' "$config_file"
        return 0
    fi

    cat >> "$config_file" <<'EOF'

enabled_policies:
- main
- non-free
EOF
}
