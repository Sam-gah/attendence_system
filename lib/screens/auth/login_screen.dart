import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../main.dart'; // Import for AttendanceDashboard
import '../admin/admin_dashboard.dart';
import '../../models/employee.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Please enter email'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Please enter password'
                                : null,
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                        onPressed: _handleLogin,
                        child: const Text('Login'),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final success = await _authService.login(
          _emailController.text,
          _passwordController.text,
        );

        if (!mounted) return;

        if (success) {
          final user = await _authService.getCurrentUser();

          if (!mounted) return;

          if (user != null) {
            if (user.role == 'admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboard()),
              );
            } else {
              final employee = Employee(
                id: user.id,
                name: user.name,
                email: user.email,
                phone: '',
                position: '',
                role: EmployeeRole.Developer,
                department: '',
                designation: '',
                employmentType: EmploymentType.fullTime,
                workType: 'onsite',
                assignedProjects: const [],
                reportingTo: '',
                joiningDate: DateTime.now(),
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AttendanceDashboard(
                        title: 'Bichitras Attendance',
                        employee: employee,
                      ),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User data not found')),
            );
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
