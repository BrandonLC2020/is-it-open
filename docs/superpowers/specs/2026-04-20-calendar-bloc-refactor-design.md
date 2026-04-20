# Calendar Refactor to Bloc Design

## Overview
Refactor the Calendar screen (`frontend/lib/screens/calendar/calendar_screen.dart`) to use `flutter_bloc` for state management, migrating away from a large, complex `StatefulWidget` with mixed concerns.

## Architecture

We will implement **Option C** from our brainstorming: separating purely visual UI state from complex data fetching state.

### 1. `CalendarUiCubit` (Visual State)
Manages synchronous UI state that changes frequently based on user interaction.
- **State (`CalendarUiState`):**
  - `currentView` (`CalendarViewType`: singleDay, threeDay, week)
  - `baseDate` (`DateTime`)
  - `isCalendarExpanded` (`bool`)
  - `isCalendarMinimized` (`bool`)
- **Methods:**
  - `changeViewType(CalendarViewType type)`
  - `navigateDate(DateTime newDate)`
  - `toggleExpanded()`
  - `toggleMinimized()`

### 2. `CalendarDataBloc` (Data State)
Manages all asynchronous data fetching and aggregation for the calendar events.
- **State (`CalendarDataState`):**
  - `status` (`enum`: initial, loading, loaded, error)
  - `savedPlaces` (`List<SavedPlace>`)
  - `checkedPlaceIds` (`Set<String>`)
  - `deviceCalendars` (`List<Calendar>`)
  - `deviceEvents` (`List<CalendarEventData>`)
  - `checkedCalendarIds` (`Set<String>`)
  - `hasCalendarPermission` (`bool`)
  - `importedEvents` (`List<CalendarEventData>`)
  - `remoteEvents` (`List<CalendarEventData>`)
  - `errorMessage` (`String?`)
- **Events (`CalendarDataEvent`):**
  - `LoadSavedPlaces`
  - `TogglePlaceFilter(String tomtomId)`
  - `InitDeviceCalendar`
  - `LoadDeviceEvents`
  - `ToggleDeviceCalendar(String calendarId)`
  - `ImportIcalFile`
  - `ClearImportedEvents`
  - `LoadRemoteEvents`
- **Controller Building:**
  - The Bloc will expose a method or a derived property (e.g., `buildEventController()`) that aggregates all active events from the various sources based on the current filters.

### 3. UI Refactor (`CalendarScreen`)
- Wrap the screen content in `MultiBlocProvider` providing both the `CalendarUiCubit` and the `CalendarDataBloc`.
- Use `BlocBuilder<CalendarUiCubit, CalendarUiState>` for the main calendar rendering area to react instantly to view/date changes.
- Use `BlocBuilder<CalendarDataBloc, CalendarDataState>` for the sidebars (filters) and to provide the aggregated events to the calendar view.
- Remove all complex data fetching and state variables from `_CalendarScreenState`.

## Data Flow
1. **Initial Load:** `CalendarScreen` dispatches initial events to `CalendarDataBloc` (`LoadSavedPlaces`, `InitDeviceCalendar`, `LoadRemoteEvents`).
2. **UI Interaction (Navigation):** User clicks "Next Week". `CalendarUiCubit.navigateDate()` is called. UI rebuilds instantly. Data Bloc is untouched.
3. **UI Interaction (Filtering):** User toggles a saved place filter. `CalendarDataBloc` receives `TogglePlaceFilter`. It recalculates the active events and emits a new state. `BlocBuilder` rebuilds the event layer on the calendar.

## Error Handling
- `CalendarDataBloc` will catch exceptions during data fetching (e.g., parsing iCal, permission denied for device calendar) and emit a state with an `errorMessage`.
- A `BlocListener` in the UI will listen for `errorMessage` changes and show a `SnackBar`.

## Testing
- Unit tests for `CalendarUiCubit` verifying state transitions.
- Unit tests for `CalendarDataBloc` using `bloc_test` to mock repositories/services and verify complex state aggregation.
