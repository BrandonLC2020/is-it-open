from ninja import Router, Schema
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from django.shortcuts import get_object_or_404
from ninja.errors import HttpError
from .models import AuthToken, UserProfile
from typing import Optional

router = Router()

class LoginInput(Schema):
    username: str
    password: str

class AuthOutput(Schema):
    token: str
    username: str
    id: int
    email: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    city: Optional[str] = ''
    state: Optional[str] = ''
    country: Optional[str] = ''
    street: Optional[str] = ''

class RegisterInput(Schema):
    username: str
    password: str
    email: Optional[str] = None

@router.post("/login", response=AuthOutput)
def login(request, data: LoginInput):
    user = authenticate(username=data.username, password=data.password)
    if not user:
        raise HttpError(401, "Invalid credentials")
    
    token, created = AuthToken.objects.get_or_create(user=user)
    # Ensure profile exists
    if not hasattr(user, 'profile'):
        UserProfile.objects.create(user=user)
    
    return {
        "token": token.key,
        "username": user.username,
        "id": user.id,
        "email": user.email,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "city": user.profile.city,
        "state": user.profile.state,
        "country": user.profile.country,
        "street": user.profile.street
    }

@router.post("/register", response=AuthOutput)
def register(request, data: RegisterInput):
    if User.objects.filter(username=data.username).exists():
        raise HttpError(400, "Username already taken")
    
    user = User.objects.create_user(
        username=data.username,
        password=data.password,
        email=data.email
    )
    
    token = AuthToken.objects.create(user=user)
    # Create UserProfile
    profile = UserProfile.objects.create(user=user)
    
    return {
        "token": token.key,
        "username": user.username,
        "id": user.id,
        "email": user.email,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "city": profile.city,
        "state": profile.state,
        "country": profile.country,
        "street": profile.street
    }

@router.get("/me", response=AuthOutput)
def me(request):
    # This endpoint will require auth, handled by global or router level security
    if not request.user.is_authenticated:
        raise HttpError(401, "Unauthorized")
    
    # We need to get the token for the response schema
    # If using standard django auth (session), there is no token.
    # But we are using token auth, so we can get it from the user.
    try:
        token = request.user.auth_token.key
    except AuthToken.DoesNotExist:
        # Create one if missing for some reason
        token_obj = AuthToken.objects.create(user=request.user)
        token = token_obj.key

    # Ensure profile exists
    if not hasattr(request.user, 'profile'):
        UserProfile.objects.create(user=request.user)

    return {
        "token": token,
        "username": request.user.username,
        "id": request.user.id,
        "email": request.user.email,
        "first_name": request.user.first_name,
        "last_name": request.user.last_name,
        "city": request.user.profile.city,
        "state": request.user.profile.state,
        "country": request.user.profile.country,
        "street": request.user.profile.street
    }
