import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../roles/role.dart';

class PreferencesService {
  static const String KEY_CURRENT_USER = 'current_user';

  Future<void> saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'role': user.role.toString(),
      'phone': user.phone,
    };
    await prefs.setString(KEY_CURRENT_USER, json.encode(userData));
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(KEY_CURRENT_USER);
    if (userStr == null) return null;

    final userData = json.decode(userStr);
    return User(
      id: userData['id'],
      name: userData['name'],
      email: userData['email'],
      role: userData['role'] == 'Role.admin' ? Role.admin : Role.employee,
      phone: userData['phone'],
    );
  }

  Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(KEY_CURRENT_USER);
  }
} 