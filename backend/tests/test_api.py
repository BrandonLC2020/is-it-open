from django.test import TestCase, Client
from django.contrib.auth.models import User
from apps.places.models import Place, SavedPlace
from apps.users.models import AuthToken
import json

class SavedPlaceModelTest(TestCase):
    def test_check_it_out_default_false(self):
        user = User.objects.create_user(username="testuser", password="password")
        place = Place.objects.create(tomtom_id="123", name="Test", address="123", latitude=0, longitude=0)
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
            content_type="application/json",
            **self.auth_headers
        )
        self.assertEqual(response.status_code, 200)
        self.assertTrue(Place.objects.filter(tomtom_id="123").exists())
        place = Place.objects.get(tomtom_id="123")
        self.assertEqual(place.hours.count(), 1)
        self.assertEqual(place.hours.first().open_time.strftime("%H:%M"), "09:00")

    def test_toggle_check_it_out(self):
        place = Place.objects.create(tomtom_id="1234", name="Test2", address="123", latitude=0, longitude=0)
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
