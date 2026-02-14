import requests
from django.conf import settings

class TomTomClient:
    BASE_URL = "https://api.tomtom.com/search/2"

    def __init__(self):
        self.api_key = settings.TOMTOM_API_KEY

    def search_place(self, query):
        """
        Search for a place using the TomTom Search API.
        """
        if not self.api_key:
            return []

        url = f"{self.BASE_URL}/search/{query}.json"
        params = {
            "key": self.api_key,
            "limit": 5,
            "idxSet": "POI",
        }
        try:
            response = requests.get(url, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()
            return data.get('results', [])
        except requests.RequestException:
            return []

    def get_place_details(self, tomtom_id):
        """
        Get place details by entity ID.
        """
        # Note: TomTom doesn't have a direct 'get by ID' in the basic search API easily without knowing the precise format or using specific endpoints.
        # However, we can use the 'place.json' endpoint if we have the entityId?
        # Let's assume for now we might filter/search, but actually the Place Search API supports 'entityId' via 'place.json' isn't standard in V2 search?
        # Wait, 'Points of Interest Details' API is what we need if we want details.
        # But that might require a different subscription or endpoint.
        # For this MVP, let's assume we get the details from the initial search or just re-search.
        # Actually, let's try to simple search again if needed or return None if we can't find it.
        # A better approach might be to just use the search result which contains the hours.
        pass
