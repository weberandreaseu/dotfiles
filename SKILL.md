# Dotfiles

## Overview

This projects bootstraps and serves two purposes:
1. Bootstrap Ubuntu by installing essentials tools
2. Configure dotfiles and development environment


## Files

File structure:

- `bootstrap/` installation scripts (fonts.sh)
- `test/` test scripts for validation in Docker
- `bin/` personal scripts (currently empty)
- `<other>` dotfiles for the corresponding tool

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

## Test Scenarios

The Docker test runs these validations:

1. **Syntax validation** - Bash and Zsh config files
2. **Load tests** - Zsh loads without error
3. **Alias tests** - `gst`, `ll`, `la` aliases exist
4. **Function tests** - `__zoxide_z`, `__zoxide_zi` functions loaded
5. **Git config** - `user.name` and `user.email` configured

## Adding New Tests

Edit `test/run.sh` and add new test cases following the pattern:

```bash
if <test-condition>; then
    pass "Description"
else
    fail "Description"
fi
```
