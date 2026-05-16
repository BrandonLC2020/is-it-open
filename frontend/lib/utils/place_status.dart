import 'package:flutter/material.dart' show TimeOfDay;

import '../models/hours.dart';
import '../models/place.dart';
import 'places_theme.dart' show PlaceStatusKind;

class PlaceStatus {
  const PlaceStatus({
    required this.kind,
    required this.supporting,
    this.nextChange,
  });

  final PlaceStatusKind kind;

  // The fragment that follows the leading "Open"/"Closes"/"Closed" word in the
  // pill — e.g. "until 7:00pm" / "in 28 min" / "opens 9am Tue". Empty when
  // unknown. Composition happens in the widget, not here.
  final String supporting;

  // When the kind will next change (close time for open, open time for closed).
  // Used to sort groups by "closing soonest" / "opening soonest".
  final DateTime? nextChange;
}

class PlaceStatusCalculator {
  static const closingSoonThreshold = Duration(minutes: 60);

  // Backend uses Python/Django weekday convention: Mon=0..Sun=6. Flutter's
  // DateTime.weekday is Mon=1..Sun=7. One-line conversion isolates the
  // assumption if it turns out the backend ships ISO instead.
  static int _modelDayOfWeek(DateTime dt) => dt.weekday - 1;

  static PlaceStatus compute(
    Place place, {
    required DateTime now,
    bool use24HourFormat = false,
  }) {
    if (place.hours.isEmpty) {
      return const PlaceStatus(kind: PlaceStatusKind.unknown, supporting: '');
    }

    final today = _modelDayOfWeek(now);
    final nowMin = now.hour * 60 + now.minute;

    // Resolve any block currently active. A block from the previous day that
    // crosses midnight is also active "today" until its close minute.
    for (final h in place.hours) {
      final span = _spanOnDay(h, today, prevDay: false);
      if (span != null && nowMin >= span.startMin && nowMin < span.endMin) {
        final remaining = span.endMin - nowMin;
        final closeAt = _dateTimeFor(now, span.endMin);
        if (remaining <= closingSoonThreshold.inMinutes) {
          return PlaceStatus(
            kind: PlaceStatusKind.closingSoon,
            supporting: 'in $remaining min',
            nextChange: closeAt,
          );
        }
        return PlaceStatus(
          kind: PlaceStatusKind.open,
          supporting: 'until ${_fmtMin(span.endMin, use24HourFormat)}',
          nextChange: closeAt,
        );
      }
    }

    // Yesterday's late block that crosses midnight into today.
    final yesterday = (today - 1 + 7) % 7;
    for (final h in place.hours.where((h) => h.dayOfWeek == yesterday)) {
      if (_endsAfterMidnight(h)) {
        final endMin = h.closeTime.hour * 60 + h.closeTime.minute;
        if (nowMin < endMin) {
          final remaining = endMin - nowMin;
          final closeAt = _dateTimeFor(now, endMin);
          if (remaining <= closingSoonThreshold.inMinutes) {
            return PlaceStatus(
              kind: PlaceStatusKind.closingSoon,
              supporting: 'in $remaining min',
              nextChange: closeAt,
            );
          }
          return PlaceStatus(
            kind: PlaceStatusKind.open,
            supporting: 'until ${_fmtMin(endMin, use24HourFormat)}',
            nextChange: closeAt,
          );
        }
      }
    }

    // Closed. Find the next open moment within the next 7 days.
    final next = _nextOpening(place.hours, now: now);
    if (next == null) {
      return const PlaceStatus(kind: PlaceStatusKind.closed, supporting: '');
    }
    return PlaceStatus(
      kind: PlaceStatusKind.closed,
      supporting: 'opens ${_fmtFuture(next, now, use24HourFormat)}',
      nextChange: next,
    );
  }

  static _Span? _spanOnDay(
    BusinessHours h,
    int dayOfWeek, {
    required bool prevDay,
  }) {
    if (h.dayOfWeek != dayOfWeek) return null;
    final start = h.openTime.hour * 60 + h.openTime.minute;
    var end = h.closeTime.hour * 60 + h.closeTime.minute;
    if (end <= start) {
      // Crosses midnight; end belongs to the next day, not "today".
      end = 24 * 60;
    }
    return _Span(start, end);
  }

  static bool _endsAfterMidnight(BusinessHours h) {
    final start = h.openTime.hour * 60 + h.openTime.minute;
    final end = h.closeTime.hour * 60 + h.closeTime.minute;
    return end <= start;
  }

  static DateTime? _nextOpening(
    List<BusinessHours> hours, {
    required DateTime now,
  }) {
    for (var offset = 0; offset < 7; offset++) {
      final dt = now.add(Duration(days: offset));
      final dow = _modelDayOfWeek(dt);
      final dayBlocks = hours.where((h) => h.dayOfWeek == dow).toList()
        ..sort(
          (a, b) => _minutesOf(a.openTime).compareTo(_minutesOf(b.openTime)),
        );
      for (final h in dayBlocks) {
        final openMin = _minutesOf(h.openTime);
        if (offset == 0 && openMin <= now.hour * 60 + now.minute) continue;
        return DateTime(
          dt.year,
          dt.month,
          dt.day,
          h.openTime.hour,
          h.openTime.minute,
        );
      }
    }
    return null;
  }

  static int _minutesOf(TimeOfDay t) => t.hour * 60 + t.minute;

  static DateTime _dateTimeFor(DateTime now, int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h >= 24) {
      final tomorrow = now.add(const Duration(days: 1));
      return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, h - 24, m);
    }
    return DateTime(now.year, now.month, now.day, h, m);
  }

  static String _fmtMin(int minutes, bool use24) {
    final h = (minutes ~/ 60) % 24;
    final m = minutes % 60;
    return _fmtClock(h, m, use24);
  }

  static String _fmtClock(int h, int m, bool use24) {
    if (use24) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    }
    final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final suffix = h < 12 ? 'am' : 'pm';
    if (m == 0) return '$hour12$suffix';
    return '$hour12:${m.toString().padLeft(2, '0')}$suffix';
  }

  static String _fmtFuture(DateTime when, DateTime now, bool use24) {
    final today = DateTime(now.year, now.month, now.day);
    final whenDay = DateTime(when.year, when.month, when.day);
    final daysAhead = whenDay.difference(today).inDays;
    final clock = _fmtClock(when.hour, when.minute, use24);
    if (daysAhead == 0) return clock;
    if (daysAhead == 1) return '$clock tomorrow';
    return '$clock ${_shortDay(when.weekday)}';
  }

  static String _shortDay(int weekday) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
}

class _Span {
  const _Span(this.startMin, this.endMin);
  final int startMin;
  final int endMin;
}
