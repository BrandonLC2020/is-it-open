import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/place.dart';
import '../../bloc/search/search_bloc.dart';
import '../../bloc/search/search_event.dart';
import '../shared/glass_container.dart';
import '../../screens/places/place_detail_screen.dart';

class SearchResultGridCard extends StatelessWidget {
  final Place place;

  const SearchResultGridCard({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(16),
      color: isDarkTheme ? Colors.black : Colors.white,
      opacity: isDarkTheme ? 0.3 : 0.7,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.read<SearchBloc>().add(AddRecentPlace(place));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaceDetailScreen(place: place),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  place.address,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
