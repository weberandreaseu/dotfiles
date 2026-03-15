---
name: dotfiles-test
description: Run Docker-based tests to validate dotfiles (syntax, aliases, functions, git config)
---

## What I do

Run the Docker test suite to validate dotfiles changes:
- Build Docker image with Ubuntu LTS + dependencies
- Execute test scenarios in container
- Report pass/fail results

## When to use me

Use this when you've made changes to the dotfiles and want to verify they work correctly without breaking your local setup.

## How to run

Execute the test script:
```
./bin/test-docker.sh
```

Or manually:
```
docker build -t dotfiles-test .
docker run --rm dotfiles-test
```

## Test scenarios

1. Bash syntax validation
2. Zsh syntax validation
3. Zsh loads without error
4. Alias `gst` expands to `git status`
5. Alias `ll` exists
6. Alias `la` exists
7. Function `__zoxide_z` loaded
8. Function `__zoxide_zi` loaded
9. Git `user.name` configured
10. Git `user.email` configured
