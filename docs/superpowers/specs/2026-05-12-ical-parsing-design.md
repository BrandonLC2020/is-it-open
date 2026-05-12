# Design Spec: Frontend iCal Parsing and Event Mapping

**Status:** Draft
**Author:** Gemini CLI
**Date:** 2026-05-12

## 1. Goal
Implement a robust service to parse iCal (`.ics`) data into `CalendarEventData` objects for use in the `calendar_view` package. This includes support for recurring events (RRULE) and timezones.

## 2. Architecture
Following a **Stateless Service Pattern**, we will introduce a dedicated service class to handle the transformation from raw ICS strings to UI-ready event objects.

### 2.1 Component: `IcalParserService`
- **Responsibility:** Parse raw string data, expand recurring rules, and map properties to `CalendarEventData`.
- **Inputs:** Raw ICS string, event color, and an optional expansion range.
- **Output:** `List<CalendarEventData<Object?>>`.

### 2.2 Dependencies
- `icalendar_parser`: Existing dependency for initial structure parsing.
- `rrule`: For expanding recurrence rules as defined in RFC 5545.
- `timezone`: For handling specific timezone identifiers (e.g., `America/New_York`).

## 3. Implementation Details

### 3.1 Recurrence Expansion
- When an event contains an `RRULE`, the service will use the `rrule` package to generate all occurrences within a **Fixed Expansion Range**.
- **Range:** 1 month before current date to 6 months after current date.

### 3.2 Timezone Handling
- Use the `timezone` package's `TZDateTime` for parsing date-time strings with `TZID` or UTC markers (`Z`).
- Normalize all final `CalendarEventData` times to the local timezone for consistent display.

### 3.3 Data Mapping
| iCal Property | CalendarEventData Property |
| :--- | :--- |
| `SUMMARY` | `title` |
| `DESCRIPTION` | `description` |
| `DTSTART` | `date`, `startTime` |
| `DTEND` | `endTime` |
| `RRULE` | *Expanded into multiple instances* |

## 4. BLoC Integration
- `CalendarDataBloc` will be refactored to remove its internal `_parseIcsString` logic.
- It will instantiate (or receive) `IcalParserService` and use it during `ImportIcalFile` and `LoadRemoteEvents` events.

## 5. Testing Strategy
- **Unit Tests (`test/services/ical_parser_service_test.dart`):**
    - Single events (timed and all-day).
    - Recurring events (daily, weekly, monthly).
    - Events with different timezones.
    - Edge cases: Missing `DTEND`, malformed ICS.
