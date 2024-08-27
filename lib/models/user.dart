class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    this.name = "",
    this.email = "",
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Name',
      email: json['email'] ?? 'Unknown Email',
    );
  }
}
