import 'dart:convert';

class User {
  final String id;
  final String email;
  final String name;
  final String role; // 'admin' or 'employee'

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      role: map['role'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'email': email, 'name': name, 'role': role};
  }

  // Add these methods for JSON serialization
  String toJson() => jsonEncode(toMap());

  factory User.fromJson(String source) => User.fromMap(jsonDecode(source));
}
