import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/ical_parser_service.dart';
import 'package:flutter/material.dart';

void main() {
  final service = IcalParserService();
  test('should parse a single timed event', () {
    const ics = '''BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Test Product//EN
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
