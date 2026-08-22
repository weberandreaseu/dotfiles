# Dotfiles

Personal dotfiles and system bootstrap for Ubuntu, managed with `mise bootstrap`.

This repo uses **explicit `[dotfiles]` source mappings** in `mise.toml` and defaults to `symlink` mode. Global mise tools have one source of truth in `dotfiles/.config/mise/config.toml`.

## Prerequisites

- Ubuntu 24.04 or newer
- `git`
- `curl`

`bootstrap/00-apt-base.sh` installs the base dependencies on a fresh machine.

## Quick Start

For a fresh Ubuntu machine:

```bash
mkdir -p ~/git
cd ~/git
git clone <your-repo-url> dotfiles
cd dotfiles
make install
```

`make install` runs as your normal user and prompts for `sudo` only when needed.

After bootstrap completes:

```bash
exec zsh
```

## What's Included

### Tools

- `mise`
- Node.js + `npm` (latest via `mise`)
- Java (latest Temurin GA release via `mise`)
- `kubectl`, `fzf`, and `zoxide` (latest via `mise`)
- JetBrains Toolbox
- Claude Code and `opencode` (latest via `mise`)
- Gradia (latest from Flathub via `mise bootstrap`)
- Docker
- VS Code
- Google Chrome
- Enpass

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
- OpenCode
- `mise` global config
- XDG user-dirs

### Fonts

- JetBrains Mono Nerd Font
- Fira Code

## Repository Structure

```text
dotfiles/
├── bootstrap/       # Numbered install scripts (00-09)
│   └── 02-repos/    # Per-app APT repository setup scripts
├── test/            # Docker-based test suite
├── bin/             # Personal scripts (currently empty)
├── dotfiles/        # Managed source files for mise dotfiles
├── mise.toml        # Dotfiles declarations ([dotfiles])
├── Dockerfile       # Test container definition
└── Makefile         # Task runner
```

## Dotfiles Operations

Apply managed configs:

```bash
make dotfiles-apply
# or
mise bootstrap --yes --only user,dotfiles,packages
mise install
```

Check status:

```bash
make dotfiles-status
# or
mise bootstrap dotfiles status
```

Unapply managed files:

```bash
make dotfiles-unapply
# or
mise bootstrap dotfiles unapply --yes
```

## Runtime Management with mise

- Global runtime config is managed at `~/.config/mise/config.toml`.
- `dotfiles/.config/mise/config.toml` is the sole source of truth for tool versions; root `mise.toml` only configures bootstrap and dotfile mappings.
- Bootstrap links that global config, then uses `mise install` to install any missing configured Node.js (including `npm`), Temurin Java, Codex, Claude Code, `kubectl`, `fzf`, `zoxide`, and `opencode` versions.
- Re-running bootstrap converges missing tools; use a separate mise upgrade workflow when you want to refresh already installed `latest` versions.

## Adding and Checking In New Config Files

This repo uses a **capture-first workflow**.

1. Edit or create the live target file in `$HOME`.
2. Capture/update it in the repo with `mise`.
3. Review, test, and commit.

Example (`~/.config/starship.toml`):

```bash
# 1) Edit live file
$EDITOR ~/.config/starship.toml

# 2) Capture into repo + update mise mapping
cd ~/git/dotfiles
mise bootstrap dotfiles add ~/.config/starship.toml

# 3) Verify state
mise bootstrap dotfiles status

# 4) Check in
git add mise.toml dotfiles/.config/starship.toml
git commit -m "Add starship config"
```

Notes:

- `mise bootstrap dotfiles add` creates a new `[dotfiles]` entry when unmanaged.
- If the target is already managed, `add` updates the existing source file.
- If you need to edit the managed source directly, use:

```bash
mise bootstrap dotfiles edit ~/.zshrc
```

## Removing Managed Configs

1. Unapply while the entry still exists:

```bash
mise bootstrap dotfiles unapply --yes
```

2. Remove the corresponding entry from `mise.toml` and source file from `dotfiles/`.
3. Commit the removal.

## Testing

Run the Docker-based test suite:

```bash
./test/test-docker.sh
```

What it validates:

- Docker image builds from `Dockerfile`
- Selected bootstrap scripts run inside the container (`01`, `02`, `03`, `04`, `06`, and `08`)
- Zsh config syntax and load behavior
- Key aliases are present
- Git identity and core tools are configured
- `node`, `npm`, Temurin Java, Claude Code, `kubectl`, `fzf`, `zoxide`, and `opencode` are installed via `mise`
- `mise bootstrap dotfiles status --missing` is clean
- Zsh interactive startup median stays under regression threshold

Performance threshold knobs for CI/local Docker tests:

- `ZSH_STARTUP_MAX_SECONDS` (default `0.20`)
- `ZSH_STARTUP_RUNS` (default `5`)

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
| `00-apt-base.sh` | Installs base APT dependencies (including `git`, `curl`, `zsh`). |
| `01-mise.sh` | Installs `mise` via `extrepo` and APT. |
| `02-repos.sh` | Adds third-party APT repositories from `bootstrap/02-repos/*.sh`. |
| `03-fonts.sh` | Installs Fira Code and JetBrains Mono Nerd Font. |
| `04-shell.sh` | Informational step; login shell setup occurs in step `08`. |
| `05-gnome.sh` | Installs selected GNOME applications. |
| `06-tools.sh` | Installs user tools not managed by `mise` (Docker, VS Code, JetBrains Toolbox). |
| `08-dotfiles.sh` | Applies user/dotfiles bootstrap settings, installs tools from the managed global mise config, and performs final setup. |
| `09-firefox.sh` | Enforces apt-only Firefox and cleans duplicate launchers. |
