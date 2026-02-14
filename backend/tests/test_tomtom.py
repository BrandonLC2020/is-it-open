from django.test import TestCase
from unittest.mock import patch, Mock
from app.services.tomtom import TomTomClient

class TomTomClientTest(TestCase):
    def setUp(self):
        self.client = TomTomClient()
        self.client.api_key = "test_key"

    @patch('app.services.tomtom.requests.get')
    def test_search_place_success(self, mock_get):
        mock_response = Mock()
        expected_data = {'results': [{'id': '123', 'poi': {'name': 'Test Place'}}]}
        mock_response.json.return_value = expected_data
        mock_response.status_code = 200
        mock_get.return_value = mock_response

        results = self.client.search_place("query")
        self.assertEqual(results, expected_data['results'])
        mock_get.assert_called_once()
        args, kwargs = mock_get.call_args
        self.assertIn('key', kwargs['params'])
        self.assertEqual(kwargs['params']['key'], 'test_key')

    @patch('app.services.tomtom.requests.get')
    def test_search_place_failure(self, mock_get):
        import requests
        mock_get.side_effect = requests.RequestException("Network error")
        results = self.client.search_place("query")
        self.assertEqual(results, [])
