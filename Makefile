.DEFAULT_GOAL := help

.PHONY: help
help:  ## Show this help.
	@grep -E '^\S+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "%-30s %s\n", $$1, $$2}'

pre-requirements:
	@scripts/pre-requirements.sh

# =============================================================================
# LOCAL DEVELOPMENT
# =============================================================================

.PHONY: local-setup
local-setup: pre-requirements  ## Install hooks and packages
	scripts/local-setup.sh
	make install

.PHONY: install
install: pre-requirements  ## Install the app packages
	uv sync

.PHONY: update
update: pre-requirements  ## Updates the app packages
	uv lock --upgrade
	uv sync

.PHONY: add-package
add-package: pre-requirements  ## Installs a new package in the app. ex: make add-package package=XXX
	uv add $(package)
	uv sync

.PHONY: add-dev-package
add-dev-package: pre-requirements  ## Installs a new dev package in the app. ex: make add-dev-package package=XXX
	uv add --dev $(package)
	uv sync

.PHONY: run
run: pre-requirements  ## Run the Django development server locally
	uv run python manage.py runserver

# =============================================================================
# CODE QUALITY
# =============================================================================

.PHONY: check-typing
check-typing: pre-requirements  ## Run a static analyzer over the code to find issues
	uv run ty check

.PHONY: check-lint
check-lint: pre-requirements  ## Checks the code style
	uv run ruff check

.PHONY: lint
lint: pre-requirements  ## Lints and fixes the code format
	uv run ruff check --fix

.PHONY: check-format
check-format: pre-requirements  ## Check format python code
	uv run ruff format --check

.PHONY: format
format: pre-requirements  ## Format python code
	uv run ruff format

.PHONY: test-local
test-local: pre-requirements  ## Run tests locally with uv
	uv run pytest -vv -n auto -ra --durations=5

# =============================================================================
# DOCKER COMMANDS
# =============================================================================

.PHONY: build
build:  ## Build Docker images
	docker-compose build

.PHONY: up
up:  ## Build and start all Docker services
	docker-compose up --build --remove-orphans

.PHONY: up-d
up-d:  ## Build and start all Docker services in background
	docker-compose up --build --remove-orphans -d

.PHONY: stop
stop:  ## Stop Docker services
	docker-compose stop

.PHONY: down
down:  ## Stop and remove all Docker containers
	docker-compose down

.PHONY: down-v
down-v:  ## Stop and remove all Docker containers with volumes
	docker-compose down -v

.PHONY: restart
restart:  ## Restart all Docker services
	docker-compose restart

.PHONY: logs
logs:  ## Show logs for all services
	docker-compose logs -f

.PHONY: ps
ps:  ## Show running Docker containers
	docker-compose ps

# =============================================================================
# DJANGO COMMANDS
# =============================================================================

.PHONY: migrate
migrate:  ## Run Django migrations in Docker
	docker-compose run --rm app python manage.py migrate

.PHONY: makemigrations
makemigrations:  ## Create Django migrations in Docker
	docker-compose run --rm app python manage.py makemigrations

.PHONY: createsuperuser
createsuperuser:  ## Create Django superuser in Docker
	docker-compose run --rm app python manage.py createsuperuser

.PHONY: collectstatic
collectstatic:  ## Collect static files in Docker
	docker-compose run --rm app python manage.py collectstatic --noinput

.PHONY: test
test:  ## Run tests in Docker
	docker-compose run --rm app sh -c "uv sync --dev && uv run pytest -vv -n auto -ra --durations=5"

# =============================================================================
# UTILITY COMMANDS
# =============================================================================

.PHONY: pyclean
pyclean:  ## Clean up temporary files and caches
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} +
	find . -type d -name ".pytest_cache" -exec rm -rf {} +
	find . -type d -name ".ruff_cache" -exec rm -rf {} +

.PHONY: env-example
env-example:  ## Copy .env.example to .env if .env doesn't exist
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo ".env file created from .env.example"; \
	else \
		echo ".env file already exists"; \
	fi

.PHONY: pre-commit
pre-commit: pre-requirements check-lint check-format check-typing test-local

.PHONY: pre-push
pre-push: test
