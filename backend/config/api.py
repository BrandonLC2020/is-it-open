from ninja import NinjaAPI
from apps.places.api import router as places_router

api = NinjaAPI()

api.add_router("/places", places_router)
