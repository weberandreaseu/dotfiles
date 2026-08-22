# Dotfiles

## Overview

This projects bootstraps and serves two purposes:
1. Bootstrap Ubuntu by installing essentials tools
2. Configure dotfiles and development environment


## Files

File structure:

- `bootstrap/` - numbered installation scripts (00-apt-base, 01-mise, 02-repos, 03-fonts, 04-shell, 05-gnome, 06-tools, 08-dotfiles, 09-firefox)
- `test/` test scripts for validation in Docker
- `bin/` personal scripts (currently empty)
- `dotfiles/` managed dotfiles sources mirrored into `$HOME` via `mise`
- `mise.toml` `[dotfiles]` declarations and settings

Dotfiles convention: files under `dotfiles/` are managed via explicit `[dotfiles]` mappings in `mise.toml`.

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
- Java (Temurin)
- `Docker`
- `VS Code`
- `JetBrains Toolbox`
- `mise`

## Adding New Tests

Edit `test/test-dotfiles.sh` and add new test cases following the pattern:

```bash
if <test-condition>; then
    pass "Description"
else
    fail "Description"
fi
```
