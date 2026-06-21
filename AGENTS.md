# Dotfiles

## Overview

This projects bootstraps and serves two purposes:
1. Bootstrap Ubuntu by installing essentials tools
2. Configure dotfiles and development environment


## Files

File structure:

- `bootstrap/` - numbered installation scripts (00-apt-base, 01-repos, 02-fonts, 03-shell, 04-gnome, 05-tools, 06-version-managers, 07-dotfiles)
- `test/` test scripts for validation in Docker
- `bin/` personal scripts (currently empty)
- `components/` stow packages mirroring `$HOME` structure

Stow package convention: only directories under `components/` are stow packages.

## Usage

### Run tests manually

```bash
./test/test-docker.sh
```

### Run with Docker directly

```bash
docker build -t dotfiles-test .
docker run --rm dotfiles-test
```

Tests run inside Docker using the project `Dockerfile` and `test/test-docker.sh`.

## Test Scenarios

The Docker test runs these validations from `test/test-dotfiles.sh` (around 15 individual checks):

1. **Syntax Tests** - Bash and Zsh config files
2. **Load Tests** - Zsh loads without error
3. **Alias Tests** - common aliases exist
4. **Function Tests** - required shell functions are loaded
5. **Git Config Tests** - required Git identity/config values are set
6. **Tools Tests** - expected CLI tools are available

### Tools Managed

- `fzf`
- `zoxide`
- `opencode`
- `Docker`
- `VS Code`
- `JetBrains Toolbox`
- `SDKMAN`
- `NVM`

## Adding New Tests

Edit `test/test-dotfiles.sh` and add new test cases following the pattern:

```bash
if <test-condition>; then
    pass "Description"
else
    fail "Description"
fi
```
