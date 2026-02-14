from ninja import Router
from typing import List
from app.services.tomtom import TomTomClient
from app.services.tomtom import TomTomClient
from .models import Place
from app.hours.models import BusinessHours
from django.shortcuts import get_object_or_404
from ninja import Schema

router = Router()

class PlaceSchema(Schema):
    id: int
    name: str
    address: str
    latitude: float
    longitude: float
    # hours: List[BusinessHoursSchema] # To be defined

class BusinessHoursSchema(Schema):
    day_of_week: int
    open_time: str
    close_time: str

class PlaceCreateSchema(Schema):
    tomtom_id: str
    name: str
    address: str
    latitude: float
    longitude: float
    hours: List[BusinessHoursSchema] = []

@router.get("/search")
def search_places(request, query: str):
    client = TomTomClient()
    results = client.search_place(query)
    # We might want to format this
    return results

@router.post("/", response=PlaceSchema)
def create_place(request, payload: PlaceCreateSchema):
    place, created = Place.objects.get_or_create(
        tomtom_id=payload.tomtom_id,
        defaults={
            "name": payload.name,
            "address": payload.address,
            "latitude": payload.latitude,
            "longitude": payload.longitude,
        }
    )
    
    # Update hours
    if payload.hours:
        place.hours.all().delete()
        for hour in payload.hours:
            BusinessHours.objects.create(
                place=place,
                day_of_week=hour.day_of_week,
                open_time=hour.open_time,
                close_time=hour.close_time
            )
            
    return place

@router.get("/{place_id}", response=PlaceSchema)
def get_place(request, place_id: int):
    place = get_object_or_404(Place, id=place_id)
    return place
