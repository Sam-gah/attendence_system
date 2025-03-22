import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../roles/role.dart'; // Import the Role enum
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static const String _userKey = 'user';
  final DatabaseService _db;
  final ApiService _api;
  final FirebaseService? _firebaseService;
  bool get hasFirebase => _firebaseService != null;

  AuthService(this._db, this._api, [this._firebaseService]);

  Future<User?> login(String email, String password) async {
    try {
      if (_firebaseService != null) {
        final userCredential = await _firebaseService.signInWithEmailAndPassword(
          email,
          password,
        );
        
        if (userCredential.user == null) {
          return null;
        }
        
        final user = userCredential.user!;
        
        // Update last login timestamp
        await _firebaseService.users.doc(user.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
        
        // Return user data
        return getCurrentUser();
      } else {
        // Fallback to mock login when Firebase is not available
        return signInWithEmailAndPassword(email, password);
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      if (_firebaseService != null) {
        final firebaseUser = _firebaseService.auth.currentUser;
        if (firebaseUser == null) {
          return null;
        }

        // Get user profile from Firestore
        final userDoc = await _firebaseService.getUserProfile(firebaseUser.uid);
        
        if (!userDoc.exists) {
          return null;
        }
        
        final userData = userDoc.data() as Map<String, dynamic>;
        
        return User(
          id: firebaseUser.uid,
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          phone: userData['phone'] ?? '',
          role: _parseRole(userData['role'] ?? 'employee'),
        );
      } else {
        // Fallback to local storage when Firebase is not available
        final prefs = await SharedPreferences.getInstance();
        final userJson = prefs.getString(_userKey);
        if (userJson == null) {
          return null;
        }
        return User.fromJson(userJson);
      }
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  Future<void> logout() async {
    if (_firebaseService != null) {
      await _firebaseService.signOut();
    } else {
      await signOut(); // Use the legacy signOut method
    }
  }

  Future<void> _saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toMap()));
    } catch (e) {
      print('Save user error: $e');
    }
  }
  
  // Public method to save user for external access
  Future<void> saveUser(User user) async {
    await _saveUser(user);
  }

  /// Update user profile in Firebase
  Future<void> updateUserProfile(User user) async {
    if (_firebaseService != null) {
      await _firebaseService.updateUserProfile(user.id, user.toMap());
    }
    await _saveUser(user); // Also save locally
  }

  /// Update specific user profile fields
  Future<void> updateUserFields({
    required String userId,
    String? name,
    String? phone,
    String? email,
  }) async {
    final Map<String, dynamic> updateData = {};
    if (name != null) updateData['name'] = name;
    if (phone != null) updateData['phone'] = phone;
    if (email != null) updateData['email'] = email;
    
    if (updateData.isNotEmpty) {
      if (_firebaseService != null) {
        await _firebaseService.updateUserProfile(userId, updateData);
      }
      
      // Also update local storage if we have a complete user
      final currentUser = await getCurrentUser();
      if (currentUser != null && currentUser.id == userId) {
        final updatedUser = User(
          id: currentUser.id,
          name: name ?? currentUser.name,
          email: email ?? currentUser.email,
          phone: phone ?? currentUser.phone,
          role: currentUser.role,
        );
        await _saveUser(updatedUser);
      }
    }
  }

  // Helper method to parse role string to Role enum
  Role _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Role.admin;
      case 'manager':
        return Role.manager;
      case 'employee':
        return Role.employee;
      default:
        return Role.employee;
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final response = await _api.login(email, password);
      return User(
        id: response['user']['id'],
        email: response['user']['email'],
        name: response['user']['name'],
        role: _parseRole(response['user']['role']),
        phone: response['user']['phone'],
      );
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _api.logout();
  }

  // Create new user without Firestore
  Future<User?> createUser({
    required String email,
    required String password,
    required String name,
    Role role = Role.employee,
  }) async {
    try {
      // Simulate user creation logic
      final userId = 'generated_user_id'; // Replace with actual logic to generate user ID

      // Simulate saving user data
      final userData = {
        'id': userId,
        'name': name,
        'email': email,
        'role': role.toString().split('.').last,
        'createdAt': DateTime.now().toIso8601String(), // Use DateTime instead of FieldValue
      };

      // Simulate updating display name
      // Replace with actual logic if needed

      return User(
        id: userId,
        email: email,
        name: name,
        role: role,
        phone: '', // Add phone if needed
      );
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    try {
      // Create user in Firebase Auth
      if (_firebaseService != null) {
        final userCredential = await _firebaseService.createUserWithEmailAndPassword(
          email,
          password,
        );
        
        if (userCredential.user == null) {
          throw Exception('Failed to create user');
        }
        
        final user = userCredential.user!;
        
        // Create user profile in Firestore
        await _firebaseService.createUserProfile(user.uid, {
          'name': name,
          'email': email,
          'phone': phone,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
        
        return User(
          id: user.uid,
          name: name,
          email: email,
          phone: phone,
          role: _parseRole(role),
        );
      } else {
        // Fallback to local user creation
        return await createUser(
          email: email,
          password: password,
          name: name,
          role: _parseRole(role),
        ) ?? User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          email: email,
          phone: phone,
          role: _parseRole(role),
        );
      }
    } catch (e) {
      debugPrint('Error during registration: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    if (_firebaseService != null) {
      await _firebaseService.auth.sendPasswordResetEmail(email: email);
    } else {
      // Mock implementation or error
      debugPrint('Password reset not available without Firebase');
    }
  }
}
