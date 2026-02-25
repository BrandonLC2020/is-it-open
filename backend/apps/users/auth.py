from ninja.security import HttpBearer
from .models import AuthToken

class GlobalAuth(HttpBearer):
    def authenticate(self, request, token):
        try:
            auth_token = AuthToken.objects.get(key=token)
            request.user = auth_token.user
            return auth_token.user
        except AuthToken.DoesNotExist:
            return None
