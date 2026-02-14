from ninja import NinjaAPI
from ninja.security import HttpBearer
from apps.places.api import router as places_router
from apps.users.api import router as users_router
from apps.users.models import AuthToken
from typing import Optional

class GlobalAuth(HttpBearer):
    def authenticate(self, request, token):
        try:
            auth_token = AuthToken.objects.get(key=token)
            return auth_token.user
        except AuthToken.DoesNotExist:
            return None

api = NinjaAPI(auth=GlobalAuth()) # Apply global auth by default, or per router

# We actually want Auth endpoints to be public (login/register)
# So we should probably NOT set global auth on the API instance if we want those to be open easily,
# OR we can override auth on the specific router. 
# Ninja allows overriding auth.
# Let's keep it simple: No global auth, but apply auth to the routers that need it.
# Wait, user wants "auth flow where user HAS to login".
# So most things should be checking for auth.
# But login/register MUST be public.

# Let's refine:
# initialize API without global auth.
# Apply auth to protected routers.

api = NinjaAPI()

# Auth Router (Login/Register) - Public
api.add_router("/auth", users_router)

# Places Router - Protected
api.add_router("/places", places_router, auth=GlobalAuth())
