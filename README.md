# Django Boilerplate ![status](https://github.com/AlexLoar/django-boilerplate/actions/workflows/ci.yml/badge.svg)


- This repository serves as a quick starting point for Django projects.
- The project uses Python 3.12.
- A [Github Action](https://github.com/AlexLoar/django-boilerplate/actions/) is configured to run on every push to the `main` branch.

## Requirements

- You only need to have [Poetry](https://python-poetry.org/) installed.

## Folder structure

- The `tests` folder contains the test files.
- To add new tests, please follow the [pytest](https://docs.pytest.org/en/7.1.x/getting-started.html) recommendations.
- The production code goes inside the `src` folder.
- Inside the `scripts` folder you can find the git hooks files.

## Project commands

The project uses [Makefiles](https://www.gnu.org/software/make/manual/html_node/Introduction.html) to run the most common tasks:

- `add-package package=XXX`: Installs the package XXX in the app. Example: `make install package=requests`.
- `check-format`: Checks code formatting.
- `check-lint`: Checks code style.
- `check-typing`: Runs static type checks to detect issues.
- `format`: Formats the code.
- `lint`: Lints the code.
- `help` : Shows this help.
- `install`: Installs the app packages.
- `local-setup`: Sets up the local environment (e.g. install git hooks).
- `run`: Runs the app.
- `test`: Run all tests.
- `update`: Updates the app packages.

**Important: Please run the `make local-setup` command before starting development.**

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
