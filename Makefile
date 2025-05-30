.DEFAULT_GOAL := help

.PHONY: help
help:  ## Show this help.
	@grep -E '^\S+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "%-30s %s\n", $$1, $$2}'

pre-requirements:
	@scripts/pre-requirements.sh

.PHONY: local-setup
local-setup: pre-requirements  ## Install hooks and packages
	scripts/local-setup.sh
	make install

.PHONY: install
install: pre-requirements  ## Install the app packages
	rm -rf poetry.lock
	poetry install

.PHONY: update
update: pre-requirements  ## Updates the app packages
	poetry update

.PHONY: add-package
add-package: pre-requirements  ## Installs a new package in the app. ex: make install package=XXX
	poetry add $(package)
	poetry install

.PHONY: check-typing
check-typing: pre-requirements  ## Run a static analyzer over the code to find issues
	poetry run ty check

.PHONY: check-lint
check-lint: pre-requirements  ## Checks the code style
	poetry run ruff check

.PHONY: pre-requirements  lint
lint: ## Lints the code format
	poetry run ruff check --fix

.PHONY: pre-requirements  check-format
check-format:  ## Check format python code
	poetry run ruff format --check

.PHONY: pre-requirements  format
format:  ## Format python code
	poetry run ruff format

.PHONY: pre-requirements  test
test: ## Run tests
	poetry run pytest -vv -n auto -ra --durations=5

.PHONY: pre-commit
pre-commit: pre-requirements check-lint check-format check-typing test

.PHONY: pre-push
pre-push: test
