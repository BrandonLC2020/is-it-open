import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/utils/availability_calculator.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  test(
    'calculateAvailableWindows subtracts personal events from business hours',
    () {
      final businessBlocks = [
        {
          'id': 'place1',
          'startTime': DateTime(2026, 4, 21, 9, 0),
          'endTime': DateTime(2026, 4, 21, 17, 0),
        },
      ];

      final personalEvents = [
        {
          'startTime': DateTime(2026, 4, 21, 12, 0),
          'endTime': DateTime(2026, 4, 21, 13, 0),
        },
      ];

      final result = AvailabilityCalculator.calculateAvailableWindows(
        businessBlocks: businessBlocks,
        personalEvents: personalEvents,
      );

      // Note: New logic might subdivide differently, but for this case it should be 2 windows
      expect(result.length, 2);
      expect(result[0].startTime, DateTime(2026, 4, 21, 9, 0));
      expect(result[0].endTime, DateTime(2026, 4, 21, 12, 0));
      expect(result[1].startTime, DateTime(2026, 4, 21, 13, 0));
      expect(result[1].endTime, DateTime(2026, 4, 21, 17, 0));
    },
  );
}
