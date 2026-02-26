import 'package:flutter/material.dart';
import '../../models/place.dart';
import '../shared/glass_container.dart';
import '../../screens/places/place_detail_screen.dart';

class SearchResultCard extends StatelessWidget {
  final Place place;

  const SearchResultCard({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: BorderRadius.circular(12),
      color: isDarkTheme ? Colors.black : Colors.white,
      opacity: isDarkTheme ? 0.3 : 0.7,
      child: ListTile(
        title: Text(place.name),
        subtitle: Text(place.address),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaceDetailScreen(place: place),
            ),
          );
        },
      ),
    );
  }
}
