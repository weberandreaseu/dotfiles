# Dotfiles
<!-- TODO: Add CI badge once GitHub Actions is configured -->

Personal dotfiles and system bootstrap for Ubuntu, managed with GNU Stow.

## Prerequisites

- Ubuntu 24.04 or newer
- `git`
- `curl`
- `stow`

`bootstrap/00-apt-base.sh` installs these base dependencies (plus additional system packages) on a fresh machine.

## Quick Start

For a fresh Ubuntu machine:

```bash
mkdir -p ~/git
cd ~/git
git clone <your-repo-url> dotfiles
cd dotfiles
sudo bash bootstrap/run.sh
```

After bootstrap completes:

```bash
exec zsh
```

## What's Included

### Tools

- `fzf`
- `zoxide`
- `SDKMAN`
- JetBrains Toolbox
- `opencode`
- Docker
- VS Code

### Shell

- Zsh as default shell
- Zinit plugin manager
- Powerlevel10k prompt
- Zsh syntax highlighting
- Zsh autosuggestions
- `fzf-tab`

### Configs

- Git
- Ghostty
- JetBrains
- OpenCode

### Fonts

- JetBrains Mono Nerd Font
- Fira Code

## Repository Structure

```text
dotfiles/
├── bootstrap/       # Numbered install scripts (00-07)
│   └── 01-repos/    # Per-app APT repository setup scripts
├── test/            # Docker-based test suite
├── bin/             # Personal scripts (PATH-accessible)
├── shell/           # Shared shell utilities
├── git/             # Git config (stow package)
├── zsh/             # Zsh config (stow package)
├── ghostty/         # Ghostty terminal config (stow package)
├── jetbrains/       # JetBrains config (stow package)
├── .config/         # XDG config files (stow package)
├── Dockerfile       # Test container definition
├── Makefile         # Task runner (if created)
└── setup.sh         # (deprecated, see bootstrap/)
```

## Adding New Configs

1. **Create a new package directory:**
   ```bash
   mkdir -p ~/git/dotfiles/<package-name>
   ```
2. **Place config files** in the package directory (maintaining the directory structure as they should appear in `$HOME`):
   ```text
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

Example (`starship`):

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

## Testing

Run the Docker-based test suite:

```bash
./test/test-docker.sh
```

What it validates:

- Docker image builds from `Dockerfile`
- Bootstrap scripts run inside the container
- Zsh config syntax and load behavior
- Key aliases/functions are present
- Core tools (for example `fzf`, `zoxide`, `opencode`) are installed

To add a new test:

1. Add assertions to `test/test-dotfiles.sh`.
2. Keep each test as pass/fail with clear output.
3. Re-run `./test/test-docker.sh` locally to verify.

## Development

Enable local Git hooks (one-time, opt-in):

```bash
git config core.hooksPath .githooks
```

## Bootstrap Scripts

| Script | Purpose |
|---|---|
| `00-apt-base.sh` | Installs base APT dependencies (including `git`, `curl`, `stow`, `zsh`). |
| `01-repos.sh` | Adds third-party APT repositories from `bootstrap/01-repos/*.sh`. |
| `02-fonts.sh` | Installs Fira Code and JetBrains Mono Nerd Font. |
| `03-shell.sh` | Sets Zsh as default shell. |
| `04-gnome.sh` | Installs selected GNOME applications. |
| `05-tools.sh` | Installs user tools (`fzf`, `zoxide`, `opencode`, Docker, VS Code, JetBrains Toolbox, SDKMAN). |
| `06-version-managers.sh` | Reserved in `run.sh`; currently not present in this repository. |
| `07-dotfiles.sh` | Stows dotfile packages into `$HOME` and applies final setup. |
