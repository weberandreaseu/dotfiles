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
    sudo -E bash "$0" "$@" || {
        echo "ERROR: Failed to run $step with sudo."
        return 1
    }
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
