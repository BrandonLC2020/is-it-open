import 'place.dart';

class SavedPlace {
  final int id;
  final Place place;
  final String? customName;
  final bool isPinned;

  SavedPlace({
    required this.id,
    required this.place,
    this.customName,
    this.isPinned = false,
  });

  factory SavedPlace.fromJson(Map<String, dynamic> json) {
    return SavedPlace(
      id: json['id'],
      place: Place.fromJson(json['place']),
      customName: json['custom_name'],
      isPinned: json['is_pinned'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'place': place.toJson(),
      'custom_name': customName,
      'is_pinned': isPinned,
    };
  }
}
