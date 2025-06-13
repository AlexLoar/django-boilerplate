# Django Boilerplate ![status](https://github.com/AlexLoar/django-boilerplate/actions/workflows/ci.yml/badge.svg)


- This repository serves as a quick starting point for Django projects.
- The project uses Python 3.12.
- A [Github Action](https://github.com/AlexLoar/django-boilerplate/actions/) is configured to run on every push to the `main` branch.
- Includes Docker configuration for development.
- Pre-configured with Celery and Redis for background tasks.

## Folder structure

- The `tests` folder contains the test files.
- To add new tests, please follow the [pytest](https://docs.pytest.org/en/7.1.x/getting-started.html) recommendations.
- The production code goes inside the `src` folder.
- Inside the `scripts` folder you can find the git hooks files.
- The `config` folder contains Django settings for different environments.

## Project commands

The project uses [Makefiles](https://www.gnu.org/software/make/manual/html_node/Introduction.html) to run the most common tasks:

🏠 Local Development

- `local-setup`: Install git hooks.
- `install`: Install app packages with Poetry.
- `update`: Update app packages.
- `add-package package=XXX`: Install new package Example: `make add-package package=requests`.
- `run`: Run Django development server locally

✅ Code Quality

- `check-lint`: Check code style with Ruff.
- `check-format`: Check code formatting.
- `check-typing`: Run static type analysis with ty.
- `lint`: Fix code style issues automatically.
- `format`: Format code automatically.
- `pre-commit`: Run all quality checks (lint, format, typing, tests)

🐳 Docker Commands

- `build`: Build Docker images.
- `up`: Build and start all services
- `up-d`: Build and start all services (background).
- `stop`: Stop Docker services.
- `down`: Stop and remove containers.
- `down-v`: Stop and remove containers with volumes.
- `restart`: Restart all services.
- `logs`: Show logs for all services.
- `ps`: Show running containers.

🔧 Django Commands

- `migrate`: Run Django migrations.
- `makemigrations`: Create Django migrations.
- `createsuperuser`: Create Django superuser.
- `collectstatic`: Collect static files.

🧪 Testing Commands

- `test`: Run tests in Docker (lightweight, no external services).
- `test-local`: Run tests locally with Poetry.

🧹 Utility Commands

- `pyclean`: Clean temporary files and caches.
- `env-example`: Create .env from template.
help: Show all available commands

🔴 **Important: Please run the `make local-setup` command before starting development.**

_You must pass the pre-commit checks—which include formatting and testing—to create a commit._

## Packages

This project uses [Poetry](https://python-poetry.org/) as the package manager.

### Testing

- [pytest](https://docs.pytest.org/en/stable/): Testing runner.
- [pytest-django](https://pytest-django.readthedocs.io/en/latest/index.html): Pytest plugin with utilities for testing Django projects.
- [factory-boy](https://factoryboy.readthedocs.io/en/stable/index.html): Factory library for generating test data.

### Utility

Since we are using Celery to run tasks we can also use [Flower](https://flower.readthedocs.io/en/latest/) to monitor them via its [Dashboard](http://localhost:5555/).

### Code style

- [ty](https://github.com/astral-sh/ty): A static type checker.
- [ruff](https://github.com/astral-sh/ruff): An extremely fast Python linter, written in Rust.


## Services

🌐 Django Application

- Main web application
- Pre-configured with DRF for API development

🗄️ PostgreSQL Database

- Primary database
- Persistent storage with Docker volumes
- Health checks for reliable startup

🔄 Redis Cache

- Celery message broker
- Caching

⚙️ Celery Worker

- Background task processing

⏰ Celery Beat

- Scheduled task runner
- Database-backed scheduler

🌸 Flower

- Real-time task monitoring
