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

  List<CalendarEventData<Object?>> _processEvent(
    Map<String, dynamic> entry,
    Color color,
  ) {
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
      ),
    ];
  }
}
