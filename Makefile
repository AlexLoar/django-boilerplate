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
	rm -rf poetry.lock
	poetry install

.PHONY: update
update: pre-requirements  ## Updates the app packages
	poetry update

.PHONY: add-package
add-package: pre-requirements  ## Installs a new package in the app. ex: make add-package package=XXX
	poetry add $(package)
	poetry install

.PHONY: run
run: pre-requirements  ## Run the Django development server locally
	poetry run python manage.py runserver

# =============================================================================
# CODE QUALITY
# =============================================================================

.PHONY: check-typing
check-typing: pre-requirements  ## Run a static analyzer over the code to find issues
	poetry run ty check

.PHONY: check-lint
check-lint: pre-requirements  ## Checks the code style
	poetry run ruff check

.PHONY: lint
lint: pre-requirements  ## Lints and fixes the code format
	poetry run ruff check --fix

.PHONY: check-format
check-format: pre-requirements  ## Check format python code
	poetry run ruff format --check

.PHONY: format
format: pre-requirements  ## Format python code
	poetry run ruff format

.PHONY: test-local
test-local: pre-requirements  ## Run tests locally with Poetry
	poetry run pytest -vv -n auto -ra --durations=5

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
	docker-compose run --rm app pytest -vv -n auto -ra --durations=5

# =============================================================================
# MONITORING COMMANDS
# =============================================================================

.PHONY: monitoring-status
monitoring-status:  ## Show Uptime Kuma status
	@echo "Uptime Kuma is available at: http://localhost:3001"
	@docker-compose ps uptime-kuma

.PHONY: monitoring-logs
monitoring-logs:  ## View Uptime Kuma logs
	docker-compose logs -f uptime-kuma

.PHONY: monitoring-backup
monitoring-backup:  ## Backup Uptime Kuma data
	@echo "Creating Uptime Kuma backup..."
	@docker run --rm -v $$(basename $$(pwd))_uptime-kuma-data:/data -v $$(pwd):/backup alpine tar czf /backup/uptime-kuma-backup-$$(date +%Y%m%d-%H%M%S).tar.gz -C /data .
	@echo "✅ Backup created: uptime-kuma-backup-$$(date +%Y%m%d-%H%M%S).tar.gz"

.PHONY: health-check
health-check:  ## Check health of all services
	@echo "🏥 Checking health of all services..."
	@echo "Django App: " && curl -s http://localhost:8000/api/health/ | python -m json.tool || echo "❌ Failed"
	@echo "\nPostgreSQL: " && docker-compose exec -T db pg_isready && echo "✅ Healthy" || echo "❌ Failed"
	@echo "\nRedis: " && docker-compose exec -T redis redis-cli ping && echo "✅ Healthy" || echo "❌ Failed"
	@echo "\nCelery: " && docker-compose exec -T celery celery -A config inspect ping && echo "✅ Healthy" || echo "❌ Failed"


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
pre-commit: pre-requirements check-lint check-format check-typing test

.PHONY: pre-push
pre-push: test
