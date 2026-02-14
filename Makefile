# Makefile

.PHONY: up down build logs shell migrate makemigrations

# Start the containers in the background
up:
	docker compose up -d

# Stop the containers
down:
	docker compose down

# Rebuild the containers (use after adding new Poetry packages)
build:
	docker compose up -d --build

# View logs (follow mode)
logs:
	docker compose logs -f

# Access the backend container shell
shell:
	docker compose exec backend bash

# Run database migrations
migrate:
	docker compose exec backend python manage.py migrate

# Create new migrations (after changing models)
makemigrations:
	docker compose exec backend python manage.py makemigrations

# Create a superuser for the Django Admin
superuser:
	docker compose exec backend python manage.py createsuperuser
