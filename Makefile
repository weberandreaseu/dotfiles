.DEFAULT_GOAL := help

STOW_EXCLUDE_DIRS := .git bootstrap test bin shell
STOW_PACKAGES := $(filter-out $(STOW_EXCLUDE_DIRS),$(patsubst %/,%,$(wildcard */))) $(if $(wildcard .config),.config)

.PHONY: help install test lint stow unstow

help: ## Show available targets
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make <target>\n\nTargets:\n"} /^[a-zA-Z0-9_.-]+:.*##/ {printf "  %-8s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Run bootstrap installation
	./bootstrap/run.sh

test: ## Run Docker-based test suite
	./test/test-docker.sh

lint: ## Run ShellCheck on project shell scripts
	shellcheck bootstrap/*.sh test/*.sh

stow: ## Stow dotfiles packages
	./bootstrap/07-dotfiles.sh

unstow: ## Unstow all dotfiles packages from home directory
	@for pkg in $(STOW_PACKAGES); do \
		echo "Unstowing $$pkg..."; \
		stow -t "$(HOME)" -d . -D "$$pkg"; \
	done
