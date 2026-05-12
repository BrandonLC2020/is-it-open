# iCal Parsing and Event Mapping Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a dedicated `IcalParserService` to robustly parse iCal data, handle recurring events (RRULE), and normalize timezones for the `calendar_view` UI.

**Architecture:** Stateless Service Pattern. Logic is moved from `CalendarDataBloc` to `IcalParserService`. Timezone normalization ensures consistent display.

**Tech Stack:** Flutter, `icalendar_parser`, `rrule`, `timezone`.

---

## File Mapping
- Create: `frontend/lib/services/ical_parser_service.dart` (Core parsing logic)
- Modify: `frontend/pubspec.yaml` (Add dependencies)
- Modify: `frontend/lib/main.dart` (Initialize timezone data)
- Modify: `frontend/lib/bloc/calendar/calendar_data_bloc.dart` (Refactor to use service)
- Test: `frontend/test/services/ical_parser_service_test.dart` (Unit tests)

---

### Task 1: Dependencies and Initialization

**Files:**
- Modify: `frontend/pubspec.yaml`
- Modify: `frontend/lib/main.dart`

- [ ] **Step 1: Add dependencies**
Run: `cd frontend && flutter pub add rrule timezone`

- [ ] **Step 2: Initialize timezone data in main.dart**
```dart
// Modify frontend/lib/main.dart
import 'package:timezone/data/latest.dart' as tz;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones(); // Initialize timezone data
  // ... rest of main
}
```

- [ ] **Step 3: Commit**
```bash
git add frontend/pubspec.yaml frontend/lib/main.dart
git commit -m "chore: add rrule and timezone dependencies and initialize"
```

---

### Task 2: Implement Base IcalParserService

**Files:**
- Create: `frontend/lib/services/ical_parser_service.dart`
- Test: `frontend/test/services/ical_parser_service_test.dart`

- [ ] **Step 1: Write initial test for single event parsing**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/ical_parser_service.dart';
import 'package:flutter/material.dart';

void main() {
  final service = IcalParserService();
  test('should parse a single timed event', () {
    const ics = '''BEGIN:VCALENDAR
BEGIN:VEVENT
SUMMARY:Test Event
DTSTART:20231010T100000Z
DTEND:20231010T110000Z
END:VEVENT
END:VCALENDAR''';
    final events = service.parse(ics);
    expect(events.length, 1);
    expect(events.first.title, 'Test Event');
    expect(events.first.startTime?.hour, 10);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**
Run: `flutter test test/services/ical_parser_service_test.dart`
Expected: FAIL (Service doesn't exist)

- [ ] **Step 3: Implement base IcalParserService**
```dart
import 'package:flutter/material.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:calendar_view/calendar_view.dart';

class IcalParserService {
  List<CalendarEventData<Object?>> parse(
    String icsString, {
    Color eventColor = Colors.blue,
  }) {
    final iCalendar = ICalendar.fromString(icsString);
    final List<CalendarEventData<Object?>> events = [];
    
    for (final entry in iCalendar.data) {
      if (entry['type'] == 'VEVENT') {
        events.addAll(_processEvent(entry, eventColor));
      }
    }
    return events;
  }

  List<CalendarEventData<Object?>> _processEvent(Map<String, dynamic> entry, Color color) {
    final title = entry['summary'] ?? 'Event';
    final dtstart = entry['dtstart'] as IcsDateTime?;
    final dtend = entry['dtend'] as IcsDateTime?;
    final description = entry['description'];

    if (dtstart == null) return [];

    final start = dtstart.toDateTime();
    final end = dtend?.toDateTime() ?? start?.add(const Duration(hours: 1));
    
    if (start == null) return [];

    return [
      CalendarEventData(
        title: title,
        date: start,
        startTime: start,
        endTime: end ?? start,
        description: description,
        color: color,
      )
    ];
  }
}
```

- [ ] **Step 4: Run test to verify it passes**
Run: `flutter test test/services/ical_parser_service_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**
```bash
git add frontend/lib/services/ical_parser_service.dart frontend/test/services/ical_parser_service_test.dart
git commit -m "feat: implement base IcalParserService"
```

---

### Task 3: Support Recurring Events (RRULE)

**Files:**
- Modify: `frontend/lib/services/ical_parser_service.dart`
- Modify: `frontend/test/services/ical_parser_service_test.dart`

- [ ] **Step 1: Write test for recurring event expansion**
```dart
test('should expand weekly recurring event', () {
  const ics = '''BEGIN:VCALENDAR
BEGIN:VEVENT
SUMMARY:Weekly Meeting
DTSTART:20231010T100000Z
DTEND:20231010T110000Z
RRULE:FREQ=WEEKLY;COUNT=3
END:VEVENT
END:VCALENDAR''';
  final events = service.parse(ics);
  expect(events.length, 3);
});
```

- [ ] **Step 2: Implement RRULE expansion**
Integrate `rrule` package in `_processEvent`. Expand instances between `DateTime.now() - 30 days` and `DateTime.now() + 180 days`.

- [ ] **Step 3: Run test to verify it passes**

- [ ] **Step 4: Commit**
```bash
git commit -am "feat: add RRULE expansion support to IcalParserService"
```

---

### Task 4: Support Timezones

**Files:**
- Modify: `frontend/lib/services/ical_parser_service.dart`

- [ ] **Step 1: Write test for timezone offsets**
```dart
test('should handle events with TZID', () {
  // Use a specific TZID in ICS and verify UTC/Local conversion
});
```

- [ ] **Step 2: Implement TZID parsing using `timezone` package**

- [ ] **Step 3: Run test to verify it passes**

- [ ] **Step 4: Commit**
```bash
git commit -am "feat: add timezone support to IcalParserService"
```

---

### Task 5: Refactor CalendarDataBloc

**Files:**
- Modify: `frontend/lib/bloc/calendar/calendar_data_bloc.dart`

- [ ] **Step 1: Inject IcalParserService into CalendarDataBloc**
Modify constructor to accept `IcalParserService` (or instantiate it).

- [ ] **Step 2: Replace `_parseIcsString` with `_icalParserService.parse`**
Update `_onImportIcalFile` and `_onLoadRemoteEvents`.

- [ ] **Step 3: Verify overall calendar functionality**
Run: `flutter test` (all tests should pass)

- [ ] **Step 4: Commit**
```bash
git commit -am "refactor: use IcalParserService in CalendarDataBloc"
```
