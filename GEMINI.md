# GEMINI.md

## Project Overview
**Is It Open** is a full-stack application for determining business hours and availability for various places. It consists of a Django-based backend and a Flutter-based frontend.

### Architecture
- **Backend**: Django 5.2 with Django Ninja (for API), PostgreSQL 15 with PostGIS (for geospatial data). Managed with `uv`.
- **Frontend**: Flutter (Dart) with Bloc for state management, `flutter_map` for maps, and `dio` for networking.
- **Infrastructure**: Docker and Docker Compose for the backend services.

## Building and Running

### Prerequisites
- Docker & Docker Compose
- Flutter SDK
- `make` (for shortcut commands)

### Backend (Docker-based)
Commands are provided via a `Makefile` in the root directory:
- `make up`: Start the database and backend services in detached mode.
- `make down`: Stop and remove containers.
- `make build`: Rebuild the backend container (essential after updating `pyproject.toml`).
- `make migrate`: Run database migrations.
- `make makemigrations`: Create new migrations after model changes.
- `make superuser`: Create a Django superuser.
- `make logs`: Follow the backend container logs.
- `make shell`: Access the backend container's bash shell.

### Frontend
1. `cd frontend`
2. `flutter pub get`
3. `flutter run` (Ensure the backend is running and accessible).

### Testing
- **Backend**: `pytest` (in the backend environment/container). Tests are located in `backend/tests/`.
- **Frontend**: `flutter test`. Tests are located in `frontend/test/`.

## Development Conventions

### Backend
- **Dependency Management**: Uses `uv`. Add dependencies via `uv add <package>` and rebuild the container.
- **API Framework**: [Django Ninja](https://django-ninja.rest-framework.com/) is used for building APIs. Routers are defined in `api.py` files within each app.
- **Geospatial**: PostGIS is used. Models requiring geospatial capabilities should use `django.contrib.gis.db.models`.
- **Configuration**: Uses `python-decouple` with a `.env` file in `backend/`.
- **App Structure**: Custom apps are located in `backend/apps/`.

### Frontend
- **State Management**: Uses the **Bloc/Cubit** pattern (`flutter_bloc`).
- **Networking**: `Dio` is the preferred HTTP client, wrapped in `ApiService`.
- **Styling**: Modern UI with glassmorphism elements, defined in `utils/app_theme.dart`.
- **Routing**: Handled manually or via Bloc state changes in `main.dart`.

### General
- **Linting/Formatting**: 
  - Backend: Adhere to PEP 8.
  - Frontend: Use `flutter analyze` and `dart format`.
- **Environment Variables**: Never commit the `.env` file. Use `backend/sample.env` as a template.
