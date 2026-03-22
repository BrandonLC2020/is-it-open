class User {
  final int id;
  final String username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? homeAddress;
  final String? homeStreet;
  final String? homeCity;
  final String? homeState;
  final String? homeZip;
  final double? homeLat;
  final double? homeLng;
  final String? workAddress;
  final String? workStreet;
  final String? workCity;
  final String? workState;
  final String? workZip;
  final double? workLat;
  final double? workLng;
  final bool useCurrentLocation;
  final String? calendarSubscriptionUrl;
  final String? token;

  User({
    required this.id,
    required this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.homeAddress,
    this.homeStreet,
    this.homeCity,
    this.homeState,
    this.homeZip,
    this.homeLat,
    this.homeLng,
    this.workAddress,
    this.workStreet,
    this.workCity,
    this.workState,
    this.workZip,
    this.workLat,
    this.workLng,
    this.useCurrentLocation = false,
    this.calendarSubscriptionUrl,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      homeAddress: json['home_address'],
      homeStreet: json['home_street'],
      homeCity: json['home_city'],
      homeState: json['home_state'],
      homeZip: json['home_zip'],
      homeLat: json['home_lat']?.toDouble(),
      homeLng: json['home_lng']?.toDouble(),
      workAddress: json['work_address'],
      workStreet: json['work_street'],
      workCity: json['work_city'],
      workState: json['work_state'],
      workZip: json['work_zip'],
      workLat: json['work_lat']?.toDouble(),
      workLng: json['work_lng']?.toDouble(),
      useCurrentLocation: json['use_current_location'] ?? false,
      calendarSubscriptionUrl: json['calendar_subscription_url'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'home_address': homeAddress,
      'home_street': homeStreet,
      'home_city': homeCity,
      'home_state': homeState,
      'home_zip': homeZip,
      'home_lat': homeLat,
      'home_lng': homeLng,
      'work_address': workAddress,
      'work_street': workStreet,
      'work_city': workCity,
      'work_state': workState,
      'work_zip': workZip,
      'work_lat': workLat,
      'work_lng': workLng,
      'use_current_location': useCurrentLocation,
      'calendar_subscription_url': calendarSubscriptionUrl,
      'token': token,
    };
  }
}
