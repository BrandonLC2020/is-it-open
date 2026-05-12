from django.test import TestCase, Client
from django.contrib.auth.models import User
from django.contrib.gis.geos import Point
from apps.places.models import Place, SavedPlace
from apps.users.models import AuthToken
import json

class SavedPlaceModelTest(TestCase):
    def test_check_it_out_default_false(self):
        user = User.objects.create_user(username="testuser", password="password")
        place = Place.objects.create(tomtom_id="123", name="Test", address="123", location=Point(0, 0))
        saved_place = SavedPlace.objects.create(user=user, place=place)
        
        self.assertFalse(saved_place.is_check_it_out)

class PlaceApiTest(TestCase):
    def setUp(self):
        self.client = Client()
        self.user = User.objects.create_user(username="testuser", password="password")
        self.token = AuthToken.objects.create(user=self.user)
        self.auth_headers = {"HTTP_AUTHORIZATION": f"Bearer {self.token.key}"}

    def test_create_place(self):
        payload = {
            "tomtom_id": "123",
            "name": "Test Place",
            "address": "123 Test St",
            "location": {
                "lat": 10.0,
                "lng": 20.0
            },
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
            content_type="application/json",
            **self.auth_headers
        )
        self.assertEqual(response.status_code, 200)
        self.assertTrue(Place.objects.filter(tomtom_id="123").exists())
        place = Place.objects.get(tomtom_id="123")
        self.assertEqual(place.location.y, 10.0)
        self.assertEqual(place.location.x, 20.0)
        self.assertEqual(place.hours.count(), 1)
        self.assertEqual(place.hours.first().open_time.strftime("%H:%M"), "09:00")

    def test_toggle_check_it_out(self):
        place = Place.objects.create(tomtom_id="1234", name="Test2", address="123", location=Point(0, 0))
        saved_place = SavedPlace.objects.create(user=self.user, place=place)
        
        response = self.client.patch(
            "/api/places/bookmarks/1234/check-it-out", 
            data=json.dumps({"is_check_it_out": True}),
            content_type="application/json",
            **self.auth_headers
        )
        self.assertEqual(response.status_code, 200)
        saved_place.refresh_from_db()
        self.assertTrue(saved_place.is_check_it_out)

    def test_get_place_details_fetches_from_tomtom(self):
        from unittest.mock import patch
        
        mock_details = {
            "tomtom_id": "tom123",
            "name": "TomTom Place",
            "address": "456 Tom St",
            "location": {"lat": 40.0, "lng": -70.0},
            "phone": "555-0199",
            "website": "https://tomtom.com",
            "categories": ["Test"],
            "hours": [{"day_of_week": 1, "open_time": "10:00", "close_time": "18:00"}]
        }
        
        with patch("apps.places.api.TomTomClient.get_place_details") as mock_get:
            mock_get.return_value = mock_details
            
            response = self.client.get("/api/places/tom123", **self.auth_headers)
            
            self.assertEqual(response.status_code, 200)
            data = response.json()
            self.assertEqual(data["name"], "TomTom Place")
            self.assertEqual(data["tomtom_id"], "tom123")
            
            # Verify it's saved in DB
            self.assertTrue(Place.objects.filter(tomtom_id="tom123").exists())
            place = Place.objects.get(tomtom_id="tom123")
            self.assertEqual(place.hours.count(), 1)
