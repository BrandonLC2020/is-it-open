---
name: docker-manager
description: Management of the Docker Compose stack. Use when rebuilding services, managing volumes, or troubleshooting the backend environment.
---

# Docker Manager

## Overview
This skill focuses on managing the `docker-compose.yml` stack, including service lifecycle and volume management.

## Best Practices

### Service Control
- `docker compose up -d` to start in detached mode.
- `docker compose down` to stop and remove containers.
- `docker compose restart <service>` to restart a single container.

### Rebuilding
- Use `docker compose build --no-cache` to force a rebuild.
- Rebuild the `backend` container after updating `pyproject.toml` or `uv.lock`.

### Troubleshooting
- `docker compose logs -f <service>` for real-time logs.
- `docker compose exec <service> bash` for interactive shell access.
- `docker compose ps` to check container status and ports.

### Data Management
- Use `docker volume ls` and `docker volume rm <volume>` for persistent storage management (e.g., PostgreSQL data).

## Resources
- [Docker Compose Documentation](https://docs.docker.com/compose/reference/)
