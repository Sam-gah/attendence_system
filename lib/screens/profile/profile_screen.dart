import 'package:flutter/material.dart';
import '../../models/employee.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final Employee user;

  const ProfileScreen({super.key, required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late String _phone;
  late final AuthService authService;

  @override
  void initState() {
    super.initState();
    _name = widget.user.name;
    _email = widget.user.email;
    _phone = widget.user.phone;
    // Initialize the AuthService with required dependencies
    final databaseService = DatabaseService(); // Ensure this is properly initialized
    final apiService = ApiService(); // Ensure this is properly initialized
    authService = AuthService(databaseService, apiService);
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Update user profile in the backend
      await authService.updateUserFields(
        userId: widget.user.id,
        name: _name,
        email: _email,
        phone: _phone,
      );
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                initialValue: _phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                onSaved: (value) => _phone = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
