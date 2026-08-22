# Dotfiles
<!-- TODO: Add CI badge once GitHub Actions is configured -->

Personal dotfiles and system bootstrap for Ubuntu, managed with `mise bootstrap dotfiles`.

This repo uses **explicit `[dotfiles]` source mappings** in `mise.toml` and defaults to `symlink` mode.

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
- OpenCode
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
├── bin/             # Personal scripts (PATH-accessible)
├── shell/           # Shared shell utilities
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
mise bootstrap dotfiles apply --yes
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
- Bootstrap scripts run inside the container
- Zsh config syntax and load behavior
- Key aliases/functions are present
- Core tools are installed
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
| `04-shell.sh` | Sets Zsh as default shell. |
| `05-gnome.sh` | Installs selected GNOME applications. |
| `06-tools.sh` | Installs user tools (`fzf`, `zoxide`, `opencode`, Docker, VS Code, JetBrains Toolbox, SDKMAN). |
| `07-version-managers.sh` | Verifies `mise` is available for runtime version management. |
| `08-dotfiles.sh` | Applies configured dotfiles from `mise.toml`, then runs final setup steps. |
| `09-firefox.sh` | Enforces apt-only Firefox and cleans duplicate launchers. |
