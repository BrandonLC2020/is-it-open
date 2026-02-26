import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:calendar_view/calendar_view.dart';
import '../../models/place.dart';
import '../../services/api_service.dart';

class PlaceDetailScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailScreen({super.key, required this.place});

  String _weekDayShortName(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }

  EventController<Object?> _buildEventController() {
    final controller = EventController<Object?>();
    final now = DateTime.now();
    // Monday is 1 in Dart, so subtracting `now.weekday - 1` gets us Monday
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    for (final hours in place.hours) {
      final baseDate = startOfWeek.add(Duration(days: hours.dayOfWeek));
      final startTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        hours.openTime.hour,
        hours.openTime.minute,
      );

      var endTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        hours.closeTime.hour,
        hours.closeTime.minute,
      );

      if (endTime.isBefore(startTime)) {
        endTime = endTime.add(const Duration(days: 1));
      }

      controller.add(
        CalendarEventData(
          title: 'Open',
          date: baseDate,
          startTime: startTime,
          endTime: endTime,
          color: Colors.green.withOpacity(0.7),
        ),
      );
    }

    return controller;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final textSmallColor = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      appBar: AppBar(title: Text(place.name)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.address,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Business Hours',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: WeekView(
              controller: _buildEventController(),
              minDay: DateTime.now().subtract(
                Duration(days: DateTime.now().weekday - 1),
              ),
              maxDay: DateTime.now().add(const Duration(days: 7)),
              initialDay: DateTime.now(),
              heightPerMinute: 1, // Compact view
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              headerStyle: HeaderStyle(
                headerTextStyle: TextStyle(
                  color:
                      Theme.of(context).textTheme.bodyLarge?.color ?? textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
              hourIndicatorSettings: HourIndicatorSettings(
                color: Theme.of(context).dividerColor,
              ),
              liveTimeIndicatorSettings: LiveTimeIndicatorSettings(
                color: Theme.of(context).colorScheme.primary,
              ),
              timeLineBuilder: (date) => Center(
                child: Text(
                  "${date.hour.toString().padLeft(2, '0')}:00",
                  style: TextStyle(
                    color:
                        Theme.of(context).textTheme.bodySmall?.color ??
                        textSmallColor,
                    fontSize: 12,
                  ),
                ),
              ),
              weekDayBuilder: (date) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _weekDayShortName(date.weekday),
                      style: TextStyle(
                        color:
                            Theme.of(context).textTheme.bodySmall?.color ??
                            textSmallColor,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        color:
                            Theme.of(context).textTheme.bodyLarge?.color ??
                            textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final apiService = context.read<ApiService>();
            await apiService.savePlace(place);
            await apiService.bookmarkPlace(place.tomtomId);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Saved to My Places!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error saving place'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: const Icon(Icons.bookmark_add),
      ),
    );
  }
}
