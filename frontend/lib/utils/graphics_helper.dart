import 'package:flutter/material.dart';
import '../../models/saved_place.dart';

class GraphicsHelper {
  static final Map<String, IconData> availableIcons = {
    'restaurant': Icons.restaurant,
    'local_cafe': Icons.local_cafe,
    'local_bar': Icons.local_bar,
    'store': Icons.store,
    'shopping_cart': Icons.shopping_cart,
    'fitness_center': Icons.fitness_center,
    'local_hospital': Icons.local_hospital,
    'park': Icons.park,
    'star': Icons.star,
    'home': Icons.home,
    'work': Icons.work,
  };

  static Widget buildProfileGraphic(SavedPlace savedPlace, {double size = 40}) {
    final currentColorHex =
        savedPlace.color ?? Colors.blue.toARGB32().toRadixString(16);
    final currentColor = Color(
      int.parse(currentColorHex, radix: 16),
    ).withValues(alpha: 1.0);
    final currentIconName = savedPlace.icon ?? 'star';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: currentColor, shape: BoxShape.circle),
      child: Icon(
        availableIcons[currentIconName] ?? Icons.star,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}
