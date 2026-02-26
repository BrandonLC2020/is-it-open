import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:calendar_view/calendar_view.dart';
import '../../models/place.dart';
import '../../services/api_service.dart';

class PlaceDetailScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
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
            child: DayView(
              controller:
                  EventController(), // We need to populate this with hours
              // For now, just showing the empty calendar view to integrity check dependencies
              minDay: DateTime.now(),
              maxDay: DateTime.now().add(const Duration(days: 7)),
              initialDay: DateTime.now(),
              heightPerMinute: 1, // Compact view
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
