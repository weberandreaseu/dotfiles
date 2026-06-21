#!/bin/bash
set -e

echo "=== 07: Setting up dotfiles ==="

export PATH="$HOME/.local/bin:$PATH"

DOTFILES_DIR="$HOME/git/dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
cd "$DOTFILES_DIR"

rm -f "$HOME/.zshrc"
rm -f "$HOME/.zshenv"

EXCLUDE_DIRS=".git .opencode bootstrap test bin shell"

backup_conflicts_for_package() {
    local pkg="$1"
    local created_backup_dir=0

    while IFS= read -r rel; do
        rel="${rel#./}"
        [ -z "$rel" ] && continue

        local src_path="$DOTFILES_DIR/$pkg/$rel"
        local target_path="$HOME/$rel"

        if [ -d "$src_path" ]; then
            if [ -e "$target_path" ] && [ ! -d "$target_path" ] && [ ! -L "$target_path" ]; then
                if [ "$created_backup_dir" = "0" ]; then
                    mkdir -p "$BACKUP_DIR"
                    created_backup_dir=1
                fi
                mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
                mv "$target_path" "$BACKUP_DIR/$rel"
                echo "Backed up existing file: $target_path -> $BACKUP_DIR/$rel"
            fi
        else
            if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
                if [ "$created_backup_dir" = "0" ]; then
                    mkdir -p "$BACKUP_DIR"
                    created_backup_dir=1
                fi
                mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
                mv "$target_path" "$BACKUP_DIR/$rel"
                echo "Backed up existing file: $target_path -> $BACKUP_DIR/$rel"
            fi
        fi
    done < <(cd "$DOTFILES_DIR/$pkg" && find . -mindepth 1)
}

for dir in */; do
    dir="${dir%/}"
    skip=false
    for exc in $EXCLUDE_DIRS; do
        [ "$dir" = "$exc" ] && skip=true && break
    done
    if [ "$skip" = false ]; then
        backup_conflicts_for_package "$dir"
        echo "Stowing $dir..."
        stow --no-folding -t "$HOME" -d . "$dir"
    fi
done

if [ -d ".config" ]; then
    backup_conflicts_for_package ".config"
    echo "Stowing .config..."
    stow --no-folding -t "$HOME" -d . .config
fi

mkdir -p "$HOME/.config"

if command -v ghostty &> /dev/null; then
    if [ -f /usr/bin/ghostty ]; then
        update-alternatives --set x-terminal-emulator /usr/bin/ghostty 2>/dev/null || true
    fi
fi

echo "=== 07: Dotfiles installed ==="
