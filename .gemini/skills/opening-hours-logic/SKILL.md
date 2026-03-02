---
name: opening-hours-logic
description: Expert logic for business hours, availability, and timezones. Use when implementing "is open" logic, parsing hour strings, or calculating future availability.
---

# Opening Hours Logic

## Overview
This skill focuses on business hours and availability logic, including complex schedules and timezone-aware calculations.

## Best Practices

### Models
- Use a `DayOfWeek` Enum and separate `OpeningHours` model linked to a `Place`.
- Use `time` fields for `open_at` and `close_at`.
- Handle cases where `close_at` is earlier than `open_at` (overnight shifts).

### Availability Check
- Convert the current UTC time to the place's local timezone.
- Compare current time with `open_at` and `close_at` for the current day.
- Check previous day's hours for overnight shifts.

### Timezone Handling
- Always store and use `pytz` or `zoneinfo` timezones.
- Ensure the frontend receives timezone-aware availability strings.

### Holiday Overrides
- Implement a `SpecialHours` model for holidays or specific dates.
- Check `SpecialHours` before regular `OpeningHours`.

## Resources
- [Python-dateutil Documentation](https://dateutil.readthedocs.io/en/stable/)
- [Business-hours-parsing-spec](https://wiki.openstreetmap.org/wiki/Key:opening_hours)
