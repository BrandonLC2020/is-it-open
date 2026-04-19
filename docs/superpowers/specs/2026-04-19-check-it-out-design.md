# Check It Out Feature Design

## Overview
A feature to distinguish between frequently visited places ("Visited") and places a user wants to visit ("Check It Out").

## Architecture

### Backend (Django Ninja)
- **Model (`apps/places/models.py`)**: Add an `is_check_it_out` BooleanField (default: False) to the `SavedPlace` model.
- **Schema (`apps/places/api.py`)**: Add `is_check_it_out` (bool) to `SavedPlaceSchema` and create `ToggleCheckItOutInput`.
- **Endpoint**: Create a PATCH endpoint `/bookmarks/{tomtom_id}/check-it-out` that updates the `is_check_it_out` flag and returns the updated `SavedPlaceSchema`.

### Frontend (Flutter)
- **Model (`lib/models/saved_place.dart`)**: Update `SavedPlace` class to include `isCheckItOut` (bool).
- **Service (`lib/services/api_service.dart`)**: Add `toggleCheckItOut(String tomtomId, bool isCheckItOut)` to make the PATCH request.
- **UI Components**:
  - `MyPlacesScreen`: Implement a `SegmentedButton` or `ToggleButtons` above the list to filter between "All", "Want to Visit" (`isCheckItOut == true`), and "Visited" (`isCheckItOut == false`).
  - `SavedPlaceListCard` & `SavedPlaceGridCard`: Introduce a new button (e.g., a bookmark or eye icon) to toggle `isCheckItOut`. Change the visual style (e.g., border color or a subtle overlay icon) if `isCheckItOut` is true.

## Data Flow
1. User clicks the "Check It Out" toggle on a place card.
2. The UI invokes `ApiService.toggleCheckItOut` sending a PATCH request.
3. On success, the UI triggers a refresh of the bookmarks list (or updates state locally for immediate feedback) and updates the filters on `MyPlacesScreen`.

## Error Handling
- The `ApiService` will catch network or parsing errors and throw them.
- `MyPlacesScreen` and the cards will display a SnackBar or an inline error text if toggling fails.

## Testing
- **Backend**: Add a test in `backend/tests/test_api.py` to assert the PATCH endpoint toggles `is_check_it_out` and the change is returned in the GET list.
- **Frontend**: Add a unit/widget test in `frontend/test/` to verify that the filter buttons show the correct places based on their `isCheckItOut` state.
