#!/bin/bash
set -e

echo "=== 08: Setting up dotfiles ==="

export PATH="$HOME/.local/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
cd "$DOTFILES_DIR"

rename_home_dir_to_xdg() {
    local source_dir="$1"
    local target_dir="$2"

    [ -d "$source_dir" ] || return 0

    if [ ! -e "$target_dir" ]; then
        mv "$source_dir" "$target_dir"
        echo "Renamed $source_dir -> $target_dir"
        return 0
    fi

    if [ -d "$target_dir" ]; then
        find "$source_dir" -mindepth 1 -maxdepth 1 -exec mv -n -t "$target_dir" -- {} +
        if rmdir "$source_dir" 2>/dev/null; then
            echo "Merged and removed $source_dir -> $target_dir"
        else
            echo "Skipped removing $source_dir because conflicting files exist in $target_dir"
        fi
    else
        echo "Skipped $source_dir because target exists and is not a directory: $target_dir"
    fi
}

rename_home_dir_to_xdg "$HOME/Desktop" "$HOME/desktop"
rename_home_dir_to_xdg "$HOME/Downloads" "$HOME/downloads"
rename_home_dir_to_xdg "$HOME/Templates" "$HOME/templates"
rename_home_dir_to_xdg "$HOME/Public" "$HOME/public"
rename_home_dir_to_xdg "$HOME/Documents" "$HOME/documents"
rename_home_dir_to_xdg "$HOME/Music" "$HOME/music"
rename_home_dir_to_xdg "$HOME/Pictures" "$HOME/pictures"
rename_home_dir_to_xdg "$HOME/Videos" "$HOME/videos"

if [ ! -f "$DOTFILES_DIR/mise.toml" ]; then
    echo "Error: mise.toml not found at $DOTFILES_DIR/mise.toml"
    exit 1
fi

backup_managed_file_conflict() {
    local source_path="$1"
    local target_path="$2"
    local backup_path="$3"

    [ -e "$target_path" ] || [ -L "$target_path" ] || return 0

    if [ -L "$target_path" ]; then
        local source_real target_real
        source_real="$(readlink -f "$source_path" 2>/dev/null || true)"
        target_real="$(readlink -f "$target_path" 2>/dev/null || true)"
        if [ "$source_real" = "$target_real" ]; then
            return 0
        fi
    fi

    mkdir -p "$(dirname "$backup_path")"
    mv "$target_path" "$backup_path"
    echo "Backed up conflicting managed file: $target_path -> $backup_path"
}

backup_managed_file_conflict "$DOTFILES_DIR/dotfiles/.zshrc" "$HOME/.zshrc" "$BACKUP_DIR/.zshrc"
backup_managed_file_conflict "$DOTFILES_DIR/dotfiles/.zshenv" "$HOME/.zshenv" "$BACKUP_DIR/.zshenv"
backup_managed_file_conflict "$DOTFILES_DIR/dotfiles/.config/mise/config.toml" "$HOME/.config/mise/config.toml" "$BACKUP_DIR/.config/mise/config.toml"
backup_managed_file_conflict "$DOTFILES_DIR/dotfiles/.claude/settings.json" "$HOME/.claude/settings.json" "$BACKUP_DIR/.claude/settings.json"
backup_managed_file_conflict "$DOTFILES_DIR/dotfiles/.config/user-dirs.dirs" "$HOME/.config/user-dirs.dirs" "$BACKUP_DIR/.config/user-dirs.dirs"
backup_managed_file_conflict "$DOTFILES_DIR/dotfiles/.config/user-dirs.locale" "$HOME/.config/user-dirs.locale" "$BACKUP_DIR/.config/user-dirs.locale"

MISE_BOOTSTRAP_PARTS="user,dotfiles,packages,services"
if [ "${DOTFILES_CONTAINER_TEST:-0}" = "1" ]; then
    MISE_BOOTSTRAP_PARTS="user,dotfiles,packages"
fi

echo "Applying managed user shell, dotfiles, system packages, and services with mise..."
mise bootstrap --yes --only "$MISE_BOOTSTRAP_PARTS"

echo "Installing tools from the managed global mise config..."
mise install

if command -v flatpak >/dev/null 2>&1; then
    echo "Ensuring Gradia is installed (user-scope Flatpak, no polkit required)..."
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    if ! flatpak info --user be.alexandervanhee.gradia >/dev/null 2>&1; then
        flatpak install --user -y flathub be.alexandervanhee.gradia
    fi
else
    echo "Skipping Gradia install: flatpak is not installed (expected in minimal container test environments)."
fi

mkdir -p "$HOME/.config"

WALLPAPER_PATH="$HOME/.local/share/backgrounds/wallpaper.jpg"
if [ -f "$WALLPAPER_PATH" ] && command -v gsettings &>/dev/null; then
    if gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_PATH" 2>/dev/null \
        && gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER_PATH" 2>/dev/null; then
        echo "Set GNOME desktop background to $WALLPAPER_PATH"
    else
        echo "WARNING: Skipping GNOME wallpaper configuration (no active desktop session found)."
    fi
fi

if command -v ghostty &> /dev/null; then
    if [ -f /usr/bin/ghostty ]; then
        update-alternatives --set x-terminal-emulator /usr/bin/ghostty 2>/dev/null || true
    fi
fi

echo "=== 08: Dotfiles installed ==="
