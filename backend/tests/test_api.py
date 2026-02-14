from django.test import TestCase, Client
from apps.places.models import Place
import json

class PlaceApiTest(TestCase):
    def setUp(self):
        self.client = Client()

    def test_create_place(self):
        payload = {
            "tomtom_id": "123",
            "name": "Test Place",
            "address": "123 Test St",
            "latitude": 10.0,
            "longitude": 20.0,
            "hours": [
                {
                    "day_of_week": 0,
                    "open_time": "09:00",
                    "close_time": "17:00"
                }
            ]
        }
        response = self.client.post(
            "/api/places/",
            data=json.dumps(payload),
            content_type="application/json"
        )
        self.assertEqual(response.status_code, 200)
        self.assertTrue(Place.objects.filter(tomtom_id="123").exists())
        place = Place.objects.get(tomtom_id="123")
        self.assertEqual(place.hours.count(), 1)
        self.assertEqual(place.hours.first().open_time.strftime("%H:%M"), "09:00")
