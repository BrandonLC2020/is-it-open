class User {
  final int id;
  final String username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? city;
  final String? state;
  final String? country;
  final String? street;
  final String? token;

  User({
    required this.id,
    required this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.city,
    this.state,
    this.country,
    this.street,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      street: json['street'],
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
      'city': city,
      'state': state,
      'country': country,
      'street': street,
      'token': token,
    };
  }
}
