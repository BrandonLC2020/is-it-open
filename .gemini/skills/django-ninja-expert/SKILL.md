---
name: django-ninja-expert
description: Expertise in Django Ninja for building APIs. Use when creating or modifying API endpoints, schemas, authentication, or routers in the backend.
---

# Django Ninja Expert

## Overview
This skill provides idiomatic patterns for Django Ninja, focusing on performance, type safety, and clean API design.

## Best Practices

### Schemas
- Use `ninja.Schema` for request/response bodies.
- Prefer `ModelSchema` when mapping directly to Django models, but use `Schema` for custom payloads.
- Always define `response={200: MySchema, 404: ErrorSchema}` for clarity.

### Routers
- Organize endpoints into `api.py` files within each app.
- Use `Router` instances and include them in the main API in `config/api.py`.

### Authentication
- Use `HttpBearer` or `APIKeyHeader` for token-based auth.
- Define auth at the Router or API level to ensure consistency.

### Async Support
- Django Ninja supports async handlers. Use `async def` for I/O bound operations if the DB driver supports it.

## Resources
- [Django Ninja Documentation](https://django-ninja.rest-framework.com/)
