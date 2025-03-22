import 'dart:convert';
import '../roles/role.dart';

class User {
  final String id;
  final String email;
  final String name;
  final Role role;
  final String phone; // 'admin' or 'employee'

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.phone,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    // Fix role parsing to handle string format
    Role role;
    try {
      if (map['role'] is String) {
        String roleStr = map['role'];
        // Handle the case where role might be stored as 'Role.employee'
        if (roleStr.contains('.')) {
          roleStr = roleStr.split('.').last;
        }
        // Find role by name
        role = Role.values.firstWhere(
          (e) => e.name.toLowerCase() == roleStr.toLowerCase(),
          orElse: () => Role.employee,
        );
      } else {
        role = Role.employee;
      }
    } catch (e) {
      print('Error parsing role from map: ${map['role']} - $e');
      role = Role.employee;
    }
    
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      role: role,
      phone: map['phone'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toString(),
      'phone': phone,
    };
  }

  factory User.fromJson(String source) {
    final data = json.decode(source);
    
    // Fix role parsing to handle string format
    Role role;
    try {
      if (data['role'] is String) {
        String roleStr = data['role'];
        // Handle the case where role might be stored as 'Role.employee'
        if (roleStr.contains('.')) {
          roleStr = roleStr.split('.').last;
        }
        // Find role by name
        role = Role.values.firstWhere(
          (e) => e.name.toLowerCase() == roleStr.toLowerCase(),
          orElse: () => Role.employee,
        );
      } else {
        role = Role.employee;
      }
    } catch (e) {
      print('Error parsing role: ${data['role']} - $e');
      role = Role.employee;
    }
    
    return User(
      id: data['id'],
      email: data['email'],
      name: data['name'],
      role: role,
      phone: data['phone'],
    );
  }

  String toJson() {
    final data = {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'phone': phone,
    };
    return json.encode(data);
  }
}
