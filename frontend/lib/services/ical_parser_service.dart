import 'package:flutter/material.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:rrule/rrule.dart';
import 'package:timezone/timezone.dart' as tz;

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

  DateTime? _parseIcsDateTime(IcsDateTime? icsDateTime) {
    if (icsDateTime == null) return null;

    final dtString = icsDateTime.dt;
    final tzid = icsDateTime.tzid;

    if (tzid != null) {
      try {
        final location = tz.getLocation(tzid);
        // ICalendar format: YYYYMMDDTHHMMSS or YYYYMMDD
        final year = int.parse(dtString.substring(0, 4));
        final month = int.parse(dtString.substring(4, 6));
        final day = int.parse(dtString.substring(6, 8));

        if (dtString.length >= 15 && dtString.contains('T')) {
          final hour = int.parse(dtString.substring(9, 11));
          final minute = int.parse(dtString.substring(11, 13));
          final second = int.parse(dtString.substring(13, 15));

          final tzDateTime = tz.TZDateTime(
            location,
            year,
            month,
            day,
            hour,
            minute,
            second,
          );
          return tzDateTime.toLocal();
        } else {
          // All day event or just date
          final tzDateTime = tz.TZDateTime(location, year, month, day);
          return tzDateTime.toLocal();
        }
      } catch (e) {
        // Fallback to default parsing if TZID fails or string is malformed
        return icsDateTime.toDateTime()?.toLocal();
      }
    }

    // Handle UTC (Z) or local time without TZID
    var dt = icsDateTime.toDateTime();
    if (dtString.endsWith('Z')) {
      // If it ends with Z, it's UTC.
      // DateTime.tryParse might not handle YYYYMMDDTHHMMSSZ without dashes.
      if (dt == null && dtString.length >= 16) {
        try {
          final year = int.parse(dtString.substring(0, 4));
          final month = int.parse(dtString.substring(4, 6));
          final day = int.parse(dtString.substring(6, 8));
          final hour = int.parse(dtString.substring(9, 11));
          final minute = int.parse(dtString.substring(11, 13));
          final second = int.parse(dtString.substring(13, 15));
          dt = DateTime.utc(year, month, day, hour, minute, second);
        } catch (_) {}
      }
    }

    return dt?.toLocal();
  }

  List<CalendarEventData<Object?>> _processEvent(
    Map<String, dynamic> entry,
    Color color,
  ) {
    final title = entry['summary'] ?? 'Event';
    final dtstartIcs = entry['dtstart'] as IcsDateTime?;
    final dtendIcs = entry['dtend'] as IcsDateTime?;
    final description = entry['description'];
    final rruleString = entry['rrule'] as String?;

    if (dtstartIcs == null) return [];

    final start = _parseIcsDateTime(dtstartIcs);
    if (start == null) return [];

    final end =
        _parseIcsDateTime(dtendIcs) ?? start.add(const Duration(hours: 1));
    final duration = end.difference(start);

    if (rruleString != null && rruleString.isNotEmpty) {
      final rule = RecurrenceRule.fromString('RRULE:$rruleString');
      final rangeStart = DateTime.now().subtract(const Duration(days: 30));
      final rangeEnd = DateTime.now().add(const Duration(days: 180));

      final instances = rule
          .getInstances(start: start.toUtc())
          .takeWhile((date) => date.isBefore(rangeEnd.toUtc()))
          .map((date) => date.toLocal())
          .where(
            (date) =>
                date.isAfter(rangeStart) || date.isAtSameMomentAs(rangeStart),
          )
          .toList();

      return instances.map((instanceStart) {
        return _createEventData(
          title: title,
          start: instanceStart,
          end: instanceStart.add(duration),
          description: description,
          color: color,
        );
      }).toList();
    }

    return [
      _createEventData(
        title: title,
        start: start,
        end: end,
        description: description,
        color: color,
      ),
    ];
  }

  CalendarEventData<Object?> _createEventData({
    required String title,
    required DateTime start,
    required DateTime end,
    String? description,
    required Color color,
  }) {
    return CalendarEventData(
      title: title,
      date: start,
      startTime: start,
      endTime: end,
      description: description,
      color: color,
    );
  }
}
