import 'package:latlong2/latlong.dart';
import 'hours.dart';

class Place {
  final int? id;
  final String tomtomId;
  final String name;
  final String address;
  final LatLng location;
  final String? phone;
  final String? website;
  final List<String> categories;
  final List<BusinessHours> hours;

  Place({
    this.id,
    required this.tomtomId,
    required this.name,
    required this.address,
    required this.location,
    this.phone,
    this.website,
    this.categories = const [],
    this.hours = const [],
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      tomtomId: json['tomtom_id'] ?? json['id'].toString(),
      name: json['name'],
      address: json['address'],
      location: LatLng(
        json['location']['lat'].toDouble(),
        json['location']['lng'].toDouble(),
      ),
      phone: json['phone'],
      website: json['website'],
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      hours:
          (json['hours'] as List<dynamic>?)
              ?.map((e) => BusinessHours.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tomtom_id': tomtomId,
      'name': name,
      'address': address,
      'location': {'lat': location.latitude, 'lng': location.longitude},
      'phone': phone,
      'website': website,
      'categories': categories,
      'hours': hours.map((e) => e.toJson()).toList(),
    };
  }
}
