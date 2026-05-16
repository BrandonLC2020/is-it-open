import 'package:flutter/material.dart';

import '../../components/places/quick_add_place_sheet.dart';
import '../../models/place.dart';
import '../../utils/places_theme.dart';
import 'place_detail_screen.dart';

// Backward-compat wrapper: search_screen.dart pushes this as a full route.
// The body is the same QuickAddPlaceSheet used as a bottom sheet from
// my_places' empty state. On save, the user lands on the new place's detail.
class CreatePlaceScreen extends StatelessWidget {
  const CreatePlaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.places;
    return Scaffold(
      backgroundColor: theme.paper,
      appBar: AppBar(
        backgroundColor: theme.paper,
        surfaceTintColor: theme.paper,
        elevation: 0,
        foregroundColor: theme.ink,
        title: Text('Add a place', style: PlacesType.headline(theme.ink)),
      ),
      body: SafeArea(
        child: QuickAddPlaceSheet(
          onSaved: (Place saved) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PlaceDetailScreen(place: saved),
              ),
            );
          },
        ),
      ),
    );
  }
}
