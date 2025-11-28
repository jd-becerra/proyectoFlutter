class User {
  final String id;
  String name;
  final String email;
  String photoUrl;
  final String preferredZone;
  final String preferredTheme;


  User({required this.id, required this.name, required this.email, required this.photoUrl, required this.preferredZone, required this.preferredTheme});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      photoUrl: json['photo_url'],
      preferredZone: json['preferred_zone'],
      preferredTheme: json['preferred_theme'],
    );
  }
}