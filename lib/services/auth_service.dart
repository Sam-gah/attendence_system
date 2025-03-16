import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Simulated login - replace with actual API call
  Future<bool> login(String email, String password) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      User? user;
      if (email == 'admin@bichitras.com' && password == 'admin123') {
        user = User(id: '1', email: email, name: 'Admin User', role: 'admin');
      } else if (email == 'user@bichitras.com' && password == 'user123') {
        user = User(id: '2', email: email, name: 'Regular User', role: 'user');
      }

      if (user != null) {
        await _saveUserData(user);
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e'); // Add logging for debugging
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Logout error: $e'); // Add logging for debugging
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      if (userData != null) {
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Get current user error: $e'); // Add logging for debugging
      return null;
    }
  }

  Future<void> _saveUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, user.toJson());
    } catch (e) {
      print('Save user data error: $e'); // Add logging for debugging
    }
  }
}
