#!/bin/bash
set -e

echo "=== 07: Setting up dotfiles ==="

export PATH="$HOME/.local/bin:$PATH"

DOTFILES_DIR="$HOME/git/dotfiles"
COMPONENTS_DIR="$DOTFILES_DIR/components"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
cd "$DOTFILES_DIR"

rm -f "$HOME/.zshrc"
rm -f "$HOME/.zshenv"

backup_conflicts_for_package() {
    local pkg_root="$1"
    local pkg="$2"
    local created_backup_dir=0

    backup_target_path() {
        local rel="$1"
        local target_path="$2"
        if [ "$created_backup_dir" = "0" ]; then
            mkdir -p "$BACKUP_DIR"
            created_backup_dir=1
        fi
        mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
        mv "$target_path" "$BACKUP_DIR/$rel"
        echo "Backed up existing file: $target_path -> $BACKUP_DIR/$rel"
    }

    while IFS= read -r rel; do
        rel="${rel#./}"
        [ -z "$rel" ] && continue

        local src_path="$pkg_root/$pkg/$rel"
        local target_path="$HOME/$rel"

        if [ -d "$src_path" ]; then
            if [ -L "$target_path" ]; then
                local src_real target_real
                src_real="$(readlink -f "$src_path" 2>/dev/null || true)"
                target_real="$(readlink -f "$target_path" 2>/dev/null || true)"
                if [ "$src_real" != "$target_real" ]; then
                    backup_target_path "$rel" "$target_path"
                fi
            elif [ -e "$target_path" ] && [ ! -d "$target_path" ]; then
                backup_target_path "$rel" "$target_path"
            fi
        else
            if [ -L "$target_path" ]; then
                local src_real target_real
                src_real="$(readlink -f "$src_path" 2>/dev/null || true)"
                target_real="$(readlink -f "$target_path" 2>/dev/null || true)"
                if [ "$src_real" != "$target_real" ]; then
                    backup_target_path "$rel" "$target_path"
                fi
            elif [ -e "$target_path" ]; then
                backup_target_path "$rel" "$target_path"
            fi
        fi
    done < <(cd "$pkg_root/$pkg" && find . -mindepth 1)
}

stow_package() {
    local base_dir="$1"
    local pkg="$2"
    local base_label
    if [ "$base_dir" = "$DOTFILES_DIR" ]; then
        base_label="."
    else
        base_label="${base_dir#"$DOTFILES_DIR"/}"
    fi
    backup_conflicts_for_package "$base_dir" "$pkg"
    echo "Stowing $pkg from $base_label..."
    stow --no-folding -t "$HOME" -d "$base_dir" "$pkg"
}

if [ ! -d "$COMPONENTS_DIR" ]; then
    echo "Error: components/ directory not found at $COMPONENTS_DIR"
    exit 1
fi

COMPONENT_PACKAGES="$(find "$COMPONENTS_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)"
if [ -z "$COMPONENT_PACKAGES" ]; then
    echo "Error: no stow packages found in $COMPONENTS_DIR"
    exit 1
fi

while IFS= read -r pkg; do
    [ -z "$pkg" ] && continue
    stow_package "$COMPONENTS_DIR" "$pkg"
done <<< "$COMPONENT_PACKAGES"

mkdir -p "$HOME/.config"

if command -v ghostty &> /dev/null; then
    if [ -f /usr/bin/ghostty ]; then
        update-alternatives --set x-terminal-emulator /usr/bin/ghostty 2>/dev/null || true
    fi
fi

echo "=== 07: Dotfiles installed ==="
