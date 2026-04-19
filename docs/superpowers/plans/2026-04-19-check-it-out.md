# Check It Out Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a "Check It Out" feature to distinguish between visited places and places a user wants to visit.

**Architecture:** Add an `is_check_it_out` flag to the `SavedPlace` backend model and expose a PATCH endpoint to toggle it. Update the Flutter frontend's `SavedPlace` model, API service, and UI to display the filter and toggle button.

**Tech Stack:** Django Ninja (Python), PostGIS, Flutter (Dart).

---

### Task 1: Backend Model & Migration

**Files:**
- Modify: `backend/apps/places/models.py`
- Create: `backend/apps/places/migrations/...`

- [ ] **Step 1: Write the failing test**

```python
# backend/tests/test_api.py (or a new test file like test_models.py)
from django.test import TestCase
from django.contrib.auth import get_user_model
from apps.places.models import Place, SavedPlace

User = get_user_model()

class SavedPlaceModelTest(TestCase):
    def test_check_it_out_default_false(self):
        user = User.objects.create(username="testuser")
        place = Place.objects.create(tomtom_id="123", name="Test", address="123", latitude=0, longitude=0)
        saved_place = SavedPlace.objects.create(user=user, place=place)
        
        self.assertFalse(saved_place.is_check_it_out)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd backend && uv run pytest tests/test_api.py -v` (or use make test if available, let's use `uv run pytest`)
Expected: FAIL with "SavedPlace has no attribute is_check_it_out"

- [ ] **Step 3: Write minimal implementation**

```python
# backend/apps/places/models.py
# In SavedPlace class, add:
    is_check_it_out = models.BooleanField(default=False)
```

- [ ] **Step 4: Create and run migrations**

Run: `cd backend && uv run python manage.py makemigrations`
Run: `cd backend && uv run python manage.py migrate`

- [ ] **Step 5: Run test to verify it passes**

Run: `cd backend && uv run pytest tests/test_api.py -v`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add backend/apps/places/models.py backend/apps/places/migrations/ backend/tests/
git commit -m "feat(backend): add is_check_it_out to SavedPlace model"
```

---

### Task 2: Backend API Schema & Endpoint

**Files:**
- Modify: `backend/apps/places/api.py`
- Modify: `backend/tests/test_api.py`

- [ ] **Step 1: Write the failing test**

```python
# In backend/tests/test_api.py
def test_toggle_check_it_out(self):
    # Assuming self.client is a Django/Ninja test client and user is authenticated
    user = User.objects.create(username="testuser")
    place = Place.objects.create(tomtom_id="123", name="Test", address="123", latitude=0, longitude=0)
    saved_place = SavedPlace.objects.create(user=user, place=place)
    
    # Authenticate client here depending on setup (e.g. self.client.force_login(user))
    # Or test API via function calls if needed. Let's mock a request or use TestClient.
    
    response = self.client.patch(
        "/api/places/bookmarks/123/check-it-out", 
        {"is_check_it_out": True},
        content_type="application/json"
    )
    self.assertEqual(response.status_code, 200)
    saved_place.refresh_from_db()
    self.assertTrue(saved_place.is_check_it_out)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd backend && uv run pytest tests/test_api.py -v`
Expected: FAIL (404 endpoint not found)

- [ ] **Step 3: Write minimal implementation**

```python
# backend/apps/places/api.py

# Add to schemas:
class ToggleCheckItOutInput(Schema):
    is_check_it_out: bool

# Update SavedPlaceSchema:
class SavedPlaceSchema(Schema):
    # existing fields...
    is_check_it_out: bool = False

# Add endpoint:
@router.patch("/bookmarks/{tomtom_id}/check-it-out", response=SavedPlaceSchema)
def toggle_check_it_out(request, tomtom_id: str, payload: ToggleCheckItOutInput):
    place = get_object_or_404(Place, tomtom_id=tomtom_id)
    saved_place = get_object_or_404(SavedPlace, user=request.auth, place=place)
    saved_place.is_check_it_out = payload.is_check_it_out
    saved_place.save()
    return saved_place
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd backend && uv run pytest tests/test_api.py -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add backend/apps/places/api.py backend/tests/test_api.py
git commit -m "feat(backend): add check-it-out API endpoint and schema"
```

---

### Task 3: Frontend Model & ApiService

**Files:**
- Modify: `frontend/lib/models/saved_place.dart`
- Modify: `frontend/lib/services/api_service.dart`
- Modify: `frontend/test/models/saved_place_test.dart` (or create)

- [ ] **Step 1: Write the failing test**

```dart
// frontend/test/models/saved_place_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:is_it_open/models/saved_place.dart';
import 'package:is_it_open/models/place.dart';

void main() {
  test('SavedPlace parses is_check_it_out from json', () {
    final json = {
      'id': 1,
      'place': {
        'id': 1,
        'tomtom_id': '123',
        'name': 'Test',
        'address': '123',
        'latitude': 0.0,
        'longitude': 0.0,
      },
      'is_pinned': false,
      'is_check_it_out': true,
    };
    
    final savedPlace = SavedPlace.fromJson(json);
    expect(savedPlace.isCheckItOut, true);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd frontend && flutter test test/models/saved_place_test.dart`
Expected: FAIL (isCheckItOut not defined)

- [ ] **Step 3: Write minimal implementation**

```dart
// frontend/lib/models/saved_place.dart
// Add field:
final bool isCheckItOut;

// Add to constructor:
this.isCheckItOut = false,

// Update fromJson:
isCheckItOut: json['is_check_it_out'] ?? false,

// Update toJson:
'is_check_it_out': isCheckItOut,

// Update copyWith if it exists.
```

```dart
// frontend/lib/services/api_service.dart
// Inside ApiService class:
Future<SavedPlace> toggleCheckItOut(String tomtomId, bool isCheckItOut) async {
  final response = await _dio.patch(
    '/places/bookmarks/$tomtomId/check-it-out',
    data: {'is_check_it_out': isCheckItOut},
  );
  return SavedPlace.fromJson(response.data);
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd frontend && flutter test test/models/saved_place_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/models/saved_place.dart frontend/lib/services/api_service.dart frontend/test/
git commit -m "feat(frontend): add isCheckItOut to SavedPlace and ApiService"
```

---

### Task 4: Frontend UI - Filter on MyPlacesScreen

**Files:**
- Modify: `frontend/lib/screens/places/my_places_screen.dart`

- [ ] **Step 1: Write the failing test**

```dart
// frontend/test/screens/my_places_screen_test.dart
// Minimal widget test checking for the filter buttons
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:is_it_open/screens/places/my_places_screen.dart';

void main() {
  testWidgets('MyPlacesScreen has SegmentedButton for filters', (tester) async {
    // Setup boilerplate with ApiService mock ...
    // Verify SegmentedButton is present
  });
}
```
*(Note: Since Flutter widget testing with API mocks requires setup, keep the test realistic to the codebase. If test infra is too complex, ensure manual testing steps are documented.)*

- [ ] **Step 2: Write minimal implementation**

```dart
// frontend/lib/screens/places/my_places_screen.dart

// Add state enum
enum PlaceFilter { all, wantToVisit, visited }

// In _MyPlacesScreenState add:
PlaceFilter _currentFilter = PlaceFilter.all;

// In build(), above the CustomScrollView slivers, add a SliverToBoxAdapter:
SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: SegmentedButton<PlaceFilter>(
      segments: const [
        ButtonSegment(value: PlaceFilter.all, label: Text('All')),
        ButtonSegment(value: PlaceFilter.wantToVisit, label: Text('Want to Visit')),
        ButtonSegment(value: PlaceFilter.visited, label: Text('Visited')),
      ],
      selected: {_currentFilter},
      onSelectionChanged: (Set<PlaceFilter> newSelection) {
        setState(() {
          _currentFilter = newSelection.first;
        });
      },
    ),
  ),
),

// When filtering places, apply the filter:
var filteredPlaces = places;
if (_currentFilter == PlaceFilter.wantToVisit) {
  filteredPlaces = places.where((p) => p.isCheckItOut).toList();
} else if (_currentFilter == PlaceFilter.visited) {
  filteredPlaces = places.where((p) => !p.isCheckItOut).toList();
}

final pinnedPlaces = filteredPlaces.where((p) => p.isPinned).toList();
final unpinnedPlaces = filteredPlaces.where((p) => !p.isPinned).toList();
```

- [ ] **Step 3: Run test/app to verify it passes**

Run: `cd frontend && flutter run` or run tests.
Expected: Filters display and work when data is mocked/loaded.

- [ ] **Step 4: Commit**

```bash
git add frontend/lib/screens/places/my_places_screen.dart
git commit -m "feat(frontend): add filter segmented button to MyPlacesScreen"
```

---

### Task 5: Frontend UI - Toggle button on cards

**Files:**
- Modify: `frontend/lib/components/places/saved_place_list_card.dart`
- Modify: `frontend/lib/components/places/saved_place_grid_card.dart`

- [ ] **Step 1: Write the minimal implementation**

```dart
// Update both card files to include an eye/bookmark icon.
// Inside SavedPlaceListCard and SavedPlaceGridCard:

// Add to imports:
import 'package:provider/provider.dart';
import '../../../services/api_service.dart';

// In the actions row (e.g., next to the pin icon):
IconButton(
  icon: Icon(
    widget.savedPlace.isCheckItOut ? Icons.visibility : Icons.visibility_off,
    color: widget.savedPlace.isCheckItOut ? Theme.of(context).colorScheme.primary : null,
  ),
  tooltip: widget.savedPlace.isCheckItOut ? 'Mark as Visited' : 'Check It Out',
  onPressed: () async {
    try {
      await context.read<ApiService>().toggleCheckItOut(
        widget.savedPlace.place.tomtomId, // or however it is exposed
        !widget.savedPlace.isCheckItOut,
      );
      widget.onRefresh();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    }
  },
)
```

- [ ] **Step 2: Run test/app to verify it passes**

Run: `cd frontend && flutter run`
Verify toggling the visibility icon updates the UI and filters correctly.

- [ ] **Step 3: Commit**

```bash
git add frontend/lib/components/places/
git commit -m "feat(frontend): add toggle check-it-out button to place cards"
```
