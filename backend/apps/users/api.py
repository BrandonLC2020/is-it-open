from ninja import Router, Schema
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from django.shortcuts import get_object_or_404
from ninja.errors import HttpError
from .models import AuthToken, UserProfile
from .auth import GlobalAuth
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
    home_address: Optional[str] = ''
    home_street: Optional[str] = ''
    home_city: Optional[str] = ''
    home_state: Optional[str] = ''
    home_zip: Optional[str] = ''
    home_lat: Optional[float] = None
    home_lng: Optional[float] = None
    work_address: Optional[str] = ''
    work_street: Optional[str] = ''
    work_city: Optional[str] = ''
    work_state: Optional[str] = ''
    work_zip: Optional[str] = ''
    work_lat: Optional[float] = None
    work_lng: Optional[float] = None
    use_current_location: bool = False

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
        "home_address": user.profile.home_address,
        "home_street": user.profile.home_street,
        "home_city": user.profile.home_city,
        "home_state": user.profile.home_state,
        "home_zip": user.profile.home_zip,
        "home_lat": user.profile.home_lat,
        "home_lng": user.profile.home_lng,
        "work_address": user.profile.work_address,
        "work_street": user.profile.work_street,
        "work_city": user.profile.work_city,
        "work_state": user.profile.work_state,
        "work_zip": user.profile.work_zip,
        "work_lat": user.profile.work_lat,
        "work_lng": user.profile.work_lng,
        "use_current_location": user.profile.use_current_location
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
        "home_address": profile.home_address,
        "home_street": profile.home_street,
        "home_city": profile.home_city,
        "home_state": profile.home_state,
        "home_zip": profile.home_zip,
        "home_lat": profile.home_lat,
        "home_lng": profile.home_lng,
        "work_address": profile.work_address,
        "work_street": profile.work_street,
        "work_city": profile.work_city,
        "work_state": profile.work_state,
        "work_zip": profile.work_zip,
        "work_lat": profile.work_lat,
        "work_lng": profile.work_lng,
        "use_current_location": profile.use_current_location
    }

@router.get("/me", response=AuthOutput, auth=GlobalAuth())
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
        "home_address": request.user.profile.home_address,
        "home_street": request.user.profile.home_street,
        "home_city": request.user.profile.home_city,
        "home_state": request.user.profile.home_state,
        "home_zip": request.user.profile.home_zip,
        "home_lat": request.user.profile.home_lat,
        "home_lng": request.user.profile.home_lng,
        "work_address": request.user.profile.work_address,
        "work_street": request.user.profile.work_street,
        "work_city": request.user.profile.work_city,
        "work_state": request.user.profile.work_state,
        "work_zip": request.user.profile.work_zip,
        "work_lat": request.user.profile.work_lat,
        "work_lng": request.user.profile.work_lng,
        "use_current_location": request.user.profile.use_current_location
    }

class ProfileUpdateInput(Schema):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    home_address: Optional[str] = None
    home_street: Optional[str] = None
    home_city: Optional[str] = None
    home_state: Optional[str] = None
    home_zip: Optional[str] = None
    home_lat: Optional[float] = None
    home_lng: Optional[float] = None
    work_address: Optional[str] = None
    work_street: Optional[str] = None
    work_city: Optional[str] = None
    work_state: Optional[str] = None
    work_zip: Optional[str] = None
    work_lat: Optional[float] = None
    work_lng: Optional[float] = None
    use_current_location: Optional[bool] = None

@router.put("/me", response=AuthOutput, auth=GlobalAuth())
def update_me(request, data: ProfileUpdateInput):
    from services.tomtom import TomTomClient # Import locally to avoid circular imports if any, though likely fine at top

    if not request.user.is_authenticated:
        raise HttpError(401, "Unauthorized")
    
    user = request.user
    
    # ... (User update logic remains the same)
    user_updated = False
    if data.first_name is not None:
        user.first_name = data.first_name
        user_updated = True
    if data.last_name is not None:
        user.last_name = data.last_name
        user_updated = True
        
    if user_updated:
        user.save()
        
    # Ensure profile exists
    if not hasattr(user, 'profile'):
        UserProfile.objects.create(user=user)
        
    profile = user.profile
    
    # We will track if address fields changed to determine if we need to geocode
    home_address_changed = False
    work_address_changed = False

    # Update UserProfile fields if provided
    profile_updated = False
    if data.home_address is not None:
        profile.home_address = data.home_address
        profile_updated = True
        home_address_changed = True
    if data.home_street is not None:
        profile.home_street = data.home_street
        profile_updated = True
        home_address_changed = True
    if data.home_city is not None:
        profile.home_city = data.home_city
        profile_updated = True
        home_address_changed = True
    if data.home_state is not None:
        profile.home_state = data.home_state
        profile_updated = True
        home_address_changed = True
    if data.home_zip is not None:
        profile.home_zip = data.home_zip
        profile_updated = True
        home_address_changed = True
        
    # Allow explicit lat/lng overrides from frontend
    if data.home_lat is not None:
        profile.home_lat = data.home_lat
        profile_updated = True
        home_address_changed = False # Don't re-geocode if explicitly provided
    if data.home_lng is not None:
        profile.home_lng = data.home_lng
        profile_updated = True
        home_address_changed = False

    if data.work_address is not None:
        profile.work_address = data.work_address
        profile_updated = True
        work_address_changed = True
    if data.work_street is not None:
        profile.work_street = data.work_street
        profile_updated = True
        work_address_changed = True
    if data.work_city is not None:
        profile.work_city = data.work_city
        profile_updated = True
        work_address_changed = True
    if data.work_state is not None:
        profile.work_state = data.work_state
        profile_updated = True
        work_address_changed = True
    if data.work_zip is not None:
        profile.work_zip = data.work_zip
        profile_updated = True
        work_address_changed = True
        
    if data.work_lat is not None:
        profile.work_lat = data.work_lat
        profile_updated = True
        work_address_changed = False
    if data.work_lng is not None:
        profile.work_lng = data.work_lng
        profile_updated = True
        work_address_changed = False
        
    if data.use_current_location is not None:
        profile.use_current_location = data.use_current_location
        profile_updated = True

    # Perform geocoding if needed
    if home_address_changed or work_address_changed:
        client = TomTomClient()
        
        if home_address_changed:
            address_parts = [p for p in [profile.home_street, profile.home_city, profile.home_state, profile.home_zip] if p]
            full_address = ", ".join(address_parts)
            if full_address:
                coords = client.geocode_address(full_address)
                if coords:
                    profile.home_lat = coords['lat']
                    profile.home_lng = coords['lon']
                    profile_updated = True

        if work_address_changed:
            address_parts = [p for p in [profile.work_street, profile.work_city, profile.work_state, profile.work_zip] if p]
            full_address = ", ".join(address_parts)
            if full_address:
                coords = client.geocode_address(full_address)
                if coords:
                    profile.work_lat = coords['lat']
                    profile.work_lng = coords['lon']
                    profile_updated = True
        
    if profile_updated:
        profile.save()

    try:
        token = user.auth_token.key
    except AuthToken.DoesNotExist:
        token_obj = AuthToken.objects.create(user=user)
        token = token_obj.key

    return {
        "token": token,
        "username": user.username,
        "id": user.id,
        "email": user.email,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "home_address": profile.home_address,
        "home_street": profile.home_street,
        "home_city": profile.home_city,
        "home_state": profile.home_state,
        "home_zip": profile.home_zip,
        "home_lat": profile.home_lat,
        "home_lng": profile.home_lng,
        "work_address": profile.work_address,
        "work_street": profile.work_street,
        "work_city": profile.work_city,
        "work_state": profile.work_state,
        "work_zip": profile.work_zip,
        "work_lat": profile.work_lat,
        "work_lng": profile.work_lng,
        "use_current_location": profile.use_current_location
    }
