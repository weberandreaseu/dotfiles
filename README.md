# Dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
dotfiles/
├── git/           # git config
└── zsh/           # zsh config
```

## Adding New Configs

1. **Create a new package directory:**
   ```bash
   mkdir -p ~/git/dotfiles/<package-name>
   ```

2. **Place config files** in the package directory (maintaining the directory structure as they should appear in `$HOME`):
   ```
   ~/git/dotfiles/<package-name>/
   └── .config/
       └── tool/
           └── configfile
   ```

3. **Run stow** to create symlinks:
   ```bash
   cd ~/git/dotfiles
   stow -t ~ -d . <package-name>
   ```

## Example: Add starship config

```bash
# 1. Create package dir
mkdir -p ~/git/dotfiles/starship

# 2. Move config (maintaining path)
mkdir -p ~/.config
mv ~/.config/starship.toml ~/git/dotfiles/starship/.config/

# 3. Stow it
cd ~/git/dotfiles
stow -t ~ -d . starship
```

## Removing a Package

```bash
cd ~/git/dotfiles
stow -t ~ -d . -D <package-name>
```
