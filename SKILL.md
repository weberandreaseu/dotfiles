# Dotfiles Testing

## Overview

This directory contains Docker-based testing for the dotfiles. It validates that shell configurations load without errors and that aliases/functions are properly configured.

## Files

| File | Description |
|------|-------------|
| `Dockerfile` | Ubuntu 22.04 with zsh, bash, git, stow, kubectl |
| `setup.sh` | Installs Oh My Zsh, zoxide, stows dotfiles |
| `test/run.sh` | Test scenarios |
| `bin/test-docker.sh` | Wrapper to build and run tests |

## Test Scenarios

1. **Bash syntax validation** - `bash -n ~/.bashrc`
2. **Zsh syntax validation** - `zsh -n ~/.zshrc`
3. **Zsh loads without error** - `source ~/.zshrc`
4. **Alias `gst`** - Expands to `git status`
5. **Alias `ll`** - Exists
6. **Alias `la`** - Exists
7. **Function `__zoxide_z`** - Loaded
8. **Function `__zoxide_zi`** - Loaded
9. **Git `user.name`** - Configured
10. **Git `user.email`** - Configured

## Usage

### Run tests manually

```bash
./bin/test-docker.sh
```

### Run with Docker directly

```bash
docker build -t dotfiles-test .
docker run --rm dotfiles-test
```

## Adding New Tests

Edit `test/run.sh` and add new test cases following the pattern:

```bash
if <test-condition>; then
    pass "Description"
else
    fail "Description"
fi
```
