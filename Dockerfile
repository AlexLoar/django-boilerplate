FROM python:3.12-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV POETRY_NO_INTERACTION=1
ENV POETRY_VENV_IN_PROJECT=1
ENV POETRY_CACHE_DIR=/opt/poetry-cache

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
        build-essential \
        libpq-dev \
        git \
    && rm -rf /var/lib/apt/lists/*

RUN pip install poetry

WORKDIR /app

ENV PYTHONPATH=/app/src:$PYTHONPATH

COPY pyproject.toml poetry.lock ./

# Configure poetry
RUN poetry config virtualenvs.create false \
    && poetry install --no-root \
    && pip install flower \
    && rm -rf $POETRY_CACHE_DIR

# Copy project
COPY . .

# Create a non-root user
RUN addgroup --system django \
    && adduser --system --ingroup django django

# Change ownership of the app directory
RUN chown -R django:django /app
USER django

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
