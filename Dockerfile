FROM python:3.12-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV UV_CACHE_DIR=/tmp/uv-cache

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

ENV UV_PROJECT_ENVIRONMENT=/opt/venv

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
        build-essential \
        libpq-dev \
        git \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

ENV PYTHONPATH=/app/src:$PYTHONPATH

COPY pyproject.toml uv.lock ./

RUN mkdir -p /opt/venv \
    && uv sync --no-dev --no-install-project \
    && rm -rf /tmp/uv-cache

# Copy project
COPY . .

# Create a non-root user
RUN addgroup --system django \
    && adduser --system --ingroup django django

# Change ownership of the app directory
RUN chown -R django:django /app /opt/venv

USER django

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
