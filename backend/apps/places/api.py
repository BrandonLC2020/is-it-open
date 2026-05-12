from ninja import Router, Schema
from typing import List, Optional
from django.shortcuts import get_object_or_404
from django.db import transaction
from django.contrib.gis.geos import Point
from django.contrib.gis.measure import D

from services.tomtom import TomTomClient
from .models import Place, SavedPlace
from apps.hours.models import BusinessHours

router = Router()

# Schemes
class BusinessHoursSchema(Schema):
    day_of_week: int
    open_time: str
    close_time: str

class LocationSchema(Schema):
    lat: float
    lng: float

class PlaceSchema(Schema):
    id: int
    tomtom_id: str
    name: str
    address: str
    location: LocationSchema
    phone: Optional[str] = None
    website: Optional[str] = None
    categories: List[str] = []
    hours: List[BusinessHoursSchema] = []

    @staticmethod
    def resolve_location(obj):
        return {"lat": obj.location.y, "lng": obj.location.x}

    @staticmethod
    def resolve_hours(obj):
        return [
            {
                "day_of_week": h.day_of_week,
                "open_time": h.open_time.strftime("%H:%M"),
                "close_time": h.close_time.strftime("%H:%M"),
            }
            for h in obj.hours.all()
        ]

class PlaceCreateSchema(Schema):
    tomtom_id: str
    name: str
    address: str
    location: LocationSchema
    phone: Optional[str] = None
    website: Optional[str] = None
    categories: List[str] = []
    hours: List[BusinessHoursSchema] = []

class SavedPlaceSchema(Schema):
    id: int
    place: PlaceSchema
    custom_name: Optional[str] = None
    icon: Optional[str] = None
    color: Optional[str] = None
    is_pinned: bool
    is_check_it_out: bool = False
    average_visit_length: Optional[int] = None

class TogglePinInput(Schema):
    is_pinned: bool

class ToggleCheckItOutInput(Schema):
    is_check_it_out: bool

class UpdateGraphicInput(Schema):
    icon: Optional[str] = None
    color: Optional[str] = None
    custom_name: Optional[str] = None

class UpdateVisitLengthInput(Schema):
    visit_length: Optional[int] = None

class SavePlaceInput(Schema):
    tomtom_id: str
    custom_name: Optional[str] = None

def _update_or_create_place_from_data(data: dict) -> Place:
    """Helper to save TomTom data to our local Place model."""
    with transaction.atomic():
        location_data = data.get("location", {})
        location = Point(location_data.get("lng"), location_data.get("lat"), srid=4326)
        
        place, created = Place.objects.get_or_create(
            tomtom_id=data.get("tomtom_id"),
            defaults={
                "name": data.get("name"),
                "address": data.get("address"),
                "location": location,
                "phone": data.get("phone"),
                "website": data.get("website"),
                "categories": data.get("categories", []),
            }
        )
        
        if not created:
            updated = False
            if location_data.get("lat") != place.location.y or location_data.get("lng") != place.location.x:
                place.location = location
                updated = True
            if data.get("name") and place.name != data.get("name"):
                place.name = data.get("name")
                updated = True
            if data.get("address") and place.address != data.get("address"):
                place.address = data.get("address")
                updated = True
            if data.get("phone") and place.phone != data.get("phone"):
                place.phone = data.get("phone")
                updated = True
            if data.get("website") and place.website != data.get("website"):
                place.website = data.get("website")
                updated = True
            if data.get("categories") and place.categories != data.get("categories"):
                place.categories = data.get("categories")
                updated = True
                
            if updated:
                place.save()
        
        # Update hours
        hours_data = data.get("hours", [])
        if hours_data:
            place.hours.all().delete()
            for hour in hours_data:
                BusinessHours.objects.create(
                    place=place,
                    day_of_week=hour.get("day_of_week") if isinstance(hour, dict) else hour.day_of_week,
                    open_time=hour.get("open_time") if isinstance(hour, dict) else hour.open_time,
                    close_time=hour.get("close_time") if isinstance(hour, dict) else hour.close_time
                )
        return place

# Endpoints

@router.get("/search", response=List[PlaceCreateSchema])
def search_places(request, query: str):
    client = TomTomClient()
    results = client.search_place(query)
    
    # Search local database for custom places
    local_places = Place.objects.filter(name__icontains=query)
    tomtom_ids = {r.get('tomtom_id') for r in results if isinstance(r, dict)}
    
    for place in local_places:
        if place.tomtom_id not in tomtom_ids:
            results.append({
                "tomtom_id": place.tomtom_id,
                "name": place.name,
                "address": place.address,
                "location": {"lat": place.location.y, "lng": place.location.x},
                "phone": place.phone,
                "website": place.website,
                "categories": place.categories,
                "hours": PlaceSchema.resolve_hours(place)
            })
            tomtom_ids.add(place.tomtom_id)
            
    return results

@router.post("/", response=PlaceSchema)
def create_place(request, payload: PlaceCreateSchema):
    return _update_or_create_place_from_data(payload.dict())

@router.post("/bookmark", response=SavedPlaceSchema)
def bookmark_place(request, payload: SavePlaceInput):
    place = get_object_or_404(Place, tomtom_id=payload.tomtom_id)
    saved_place, created = SavedPlace.objects.get_or_create(
        user=request.auth,
        place=place,
        defaults={"custom_name": payload.custom_name}
    )
    if not created and payload.custom_name:
        saved_place.custom_name = payload.custom_name
        saved_place.save()
    return saved_place

@router.get("/bookmarks", response=List[SavedPlaceSchema])
def get_bookmarks(request):
    return SavedPlace.objects.filter(user=request.auth).select_related("place").prefetch_related("place__hours")

@router.delete("/bookmarks/{tomtom_id}", response={204: None, 404: dict})
def delete_bookmark(request, tomtom_id: str):
    place = get_object_or_404(Place, tomtom_id=tomtom_id)
    deleted, _ = SavedPlace.objects.filter(user=request.auth, place=place).delete()
    if deleted:
        return 204, None
    return 404, {"detail": "Bookmark not found"}

@router.patch("/bookmarks/{tomtom_id}/pin", response=SavedPlaceSchema)
def toggle_pin(request, tomtom_id: str, payload: TogglePinInput):
    place = get_object_or_404(Place, tomtom_id=tomtom_id)
    saved_place = get_object_or_404(SavedPlace, user=request.auth, place=place)
    saved_place.is_pinned = payload.is_pinned
    saved_place.save()
    return saved_place

@router.patch("/bookmarks/{tomtom_id}/check-it-out", response=SavedPlaceSchema)
def toggle_check_it_out(request, tomtom_id: str, payload: ToggleCheckItOutInput):
    place = get_object_or_404(Place, tomtom_id=tomtom_id)
    saved_place = get_object_or_404(SavedPlace, user=request.auth, place=place)
    saved_place.is_check_it_out = payload.is_check_it_out
    saved_place.save()
    return saved_place

@router.patch("/bookmarks/{tomtom_id}/graphic", response=SavedPlaceSchema)
def update_graphic(request, tomtom_id: str, payload: UpdateGraphicInput):
    place = get_object_or_404(Place, tomtom_id=tomtom_id)
    saved_place = get_object_or_404(SavedPlace, user=request.auth, place=place)
    
    data = payload.dict(exclude_unset=True)
    if 'icon' in data:
        saved_place.icon = data['icon']
    if 'color' in data:
        saved_place.color = data['color']
    if 'custom_name' in data:
        cn = data['custom_name']
        saved_place.custom_name = cn if cn and cn.strip() else None

    saved_place.save()
    return saved_place

@router.patch("/bookmarks/{tomtom_id}/visit-length", response=SavedPlaceSchema)
def update_visit_length(request, tomtom_id: str, payload: UpdateVisitLengthInput):
    place = get_object_or_404(Place, tomtom_id=tomtom_id)
    saved_place = get_object_or_404(SavedPlace, user=request.auth, place=place)
    
    saved_place.average_visit_length = payload.visit_length
    saved_place.save()
    return saved_place

@router.get("/nearby", response=List[PlaceSchema])
def get_nearby_places(request, lat: float, lng: float, radius_km: float = 5.0):
    user_location = Point(lng, lat, srid=4326)
    return Place.objects.filter(location__dwithin=(user_location, D(km=radius_km)))

@router.get("/suggestions", response=List[PlaceCreateSchema])
def get_suggestions(request, lat: Optional[float] = None, lng: Optional[float] = None):
    if lat is not None and lng is not None:
        client = TomTomClient()
        return client.nearby_search(lat, lng)
    
    # Fallback: Get some recently added places
    return Place.objects.order_by('-id')[:10]

@router.get("/{tomtom_id}", response=PlaceSchema)
def get_place_details(request, tomtom_id: str):
    # Check if place exists in DB
    place = Place.objects.filter(tomtom_id=tomtom_id).first()
    
    if place:
        return place
    
    # If not, fetch from TomTom and save
    client = TomTomClient()
    details = client.get_place_details(tomtom_id)
    
    if not details:
        return 404, {"detail": "Place not found in TomTom"}
        
    return _update_or_create_place_from_data(details)
