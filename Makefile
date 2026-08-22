.DEFAULT_GOAL := help

.PHONY: help install test lint dotfiles-apply dotfiles-status dotfiles-unapply dotfiles-edit

help: ## Show available targets
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make <target>\n\nTargets:\n"} /^[a-zA-Z0-9_.-]+:.*##/ {printf "  %-8s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Run bootstrap installation
	./bootstrap/run.sh

test: ## Run Docker-based test suite
	./test/test-docker.sh

lint: ## Run ShellCheck on project shell scripts
	shellcheck -x bootstrap/*.sh bootstrap/02-repos/*.sh bootstrap/lib/*.sh test/*.sh

dotfiles-apply: ## Apply managed dotfiles via mise
	mise bootstrap --yes --only dotfiles,tools

dotfiles-status: ## Show managed dotfiles status
	mise bootstrap dotfiles status

dotfiles-unapply: ## Remove managed dotfiles from home
	mise bootstrap dotfiles unapply --yes

dotfiles-edit: ## Edit managed source for a target (TARGET=~/.zshrc)
	@if [ -z "$(TARGET)" ]; then echo "Usage: make dotfiles-edit TARGET=~/.zshrc"; exit 1; fi
	mise bootstrap dotfiles edit "$(TARGET)"
