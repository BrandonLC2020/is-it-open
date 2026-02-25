# backend/Dockerfile
FROM python:3.11-slim

# Install system libs for PostGIS
RUN apt-get update && apt-get install -y \
    binutils libproj-dev gdal-bin curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /code

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1

# Copy from the cache instead of linking since it's a separate volume
ENV UV_LINK_MODE=copy

# Place the virtual environment outside of the code mount
ENV UV_PROJECT_ENVIRONMENT=/opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install dependencies
# Note: we copy pyproject.toml and uv.lock first for caching
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-install-project --no-dev

# Copy project code
COPY . .

EXPOSE 8000

# Use the virtualenv's python
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
