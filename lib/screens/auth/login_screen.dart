import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../models/employee.dart';
import '../admin/admin_dashboard.dart';
import '../attendance/attendance_dashboard.dart';
import '../../roles/role.dart';
import '../../constants/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../services/firebase_service.dart';
import '../../services/api_service.dart';
import '../home/main_layout.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // Parse string role to Role enum
  Role _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Role.admin;
      case 'manager':
        return Role.manager;
      case 'employee':
      default:
        return Role.employee;
    }
  }

  // Parse string employment type to EmploymentType enum
  EmploymentType _parseEmploymentType(String type) {
    switch (type.toLowerCase()) {
      case 'parttime':
      case 'part-time':
      case 'part_time':
        return EmploymentType.partTime;
      case 'contract':
        return EmploymentType.contract;
      case 'intern':
      case 'internship':
        return EmploymentType.intern;
      case 'fulltime':
      case 'full-time':
      case 'full_time':
      default:
        return EmploymentType.fullTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final bodyTextTheme =
        isDarkMode ? AppTheme.bodyTextDark : AppTheme.bodyTextLight;

    // Safely check if Firebase is available without throwing an exception
    FirebaseService? firebaseService;
    try {
      firebaseService = Provider.of<FirebaseService>(context, listen: false);
    } catch (e) {
      firebaseService = null;
      print('FirebaseService not available: $e');
    }
    final isFirebaseAvailable = firebaseService != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () => themeProvider.toggleTheme(),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                SvgPicture.asset('assets/images/Group 7.svg', height: 120),
                const SizedBox(height: 40),
                Text(
                  'Welcome Back!',
                  style:
                      isDarkMode
                          ? AppTheme.heading1Dark
                          : AppTheme.heading1Light,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please sign in to your account',
                  style: bodyTextTheme,
                  textAlign: TextAlign.center,
                ),
                if (!isFirebaseAvailable)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '(Firebase not available, using mock data)',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(
                      Icons.email,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(
                      Icons.lock,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Implement social account login
                    },
                    child: Text(
                      'Continue with Social Account',
                      style: bodyTextTheme,
                    ),
                  ),
                ),
                
                // Show hint for test login
                const SizedBox(height: 24),
                Text(
                  'For testing, use: test@example.com / password',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey : Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      // For testing, accept hard-coded credentials
      if (email == "test@example.com" && password == "password") {
        final mockEmployee = Employee(
          id: 'mock-user-123',
          name: 'Test User',
          email: email,
          phone: '123-456-7890',
          position: 'Developer',
          department: 'Engineering',
          role: Role.employee,
          employmentType: EmploymentType.fullTime,
          workType: 'onsite',
          assignedProjects: ['project-1', 'project-2'],
          reportingTo: 'manager-1',
          joiningDate: DateTime.now().subtract(const Duration(days: 365)),
        );
        
        // Create and save the user object
        final mockUser = User(
          id: 'mock-user-123',
          name: 'Test User',
          email: email,
          phone: '123-456-7890',
          role: Role.employee,
        );
        
        // Save the user to SharedPreferences
        await Provider.of<AuthService>(context, listen: false).saveUser(mockUser);
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainLayout(),
          ),
        );
        return;
      }
      
      // Safely get Firebase service
      FirebaseService? firebaseService;
      try {
        firebaseService = Provider.of<FirebaseService>(context, listen: false);
      } catch (e) {
        print('FirebaseService not available for login: $e');
      }
      
      if (firebaseService != null) {
        try {
          // Sign in with Firebase
          final userCredential = await firebaseService.signInWithEmailAndPassword(email, password);
          final user = userCredential.user;
          
          if (user == null) {
            throw Exception('Failed to sign in');
          }
          
          // Get the user profile from Firestore
          final userSnapshot = await firebaseService.getUserProfile(user.uid);
          
          if (!userSnapshot.exists) {
            throw Exception('User profile not found');
          }
          
          final userData = userSnapshot.data() as Map<String, dynamic>;
          final userRole = userData['role'] as String;
          
          // Determine where to navigate based on user role
          if (userRole == 'admin') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainLayout()),
            );
          } else {
            // Get employee data for attendance dashboard
            final employeeSnapshot = await firebaseService.getEmployee(user.uid);
            
            if (!employeeSnapshot.exists) {
              throw Exception('Employee profile not found');
            }
            
            final employeeData = employeeSnapshot.data() as Map<String, dynamic>;
            
            // Convert Firestore data to Employee model
            final employee = Employee(
              id: user.uid,
              name: employeeData['name'] ?? '',
              email: employeeData['email'] ?? '',
              phone: employeeData['phone'] ?? '',
              position: employeeData['position'] ?? '',
              department: employeeData['department'] ?? '',
              role: _parseRole(employeeData['role'] ?? 'employee'),
              employmentType: _parseEmploymentType(employeeData['employmentType'] ?? 'fullTime'),
              workType: employeeData['workType'] ?? 'onsite',
              assignedProjects: List<String>.from(employeeData['assignedProjects'] ?? []),
              reportingTo: employeeData['reportingTo'] ?? '',
              joiningDate: employeeData['joiningDate']?.toDate() ?? DateTime.now(),
            );
            
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const MainLayout(),
              ),
            );
          }
        } catch (e) {
          print("Firebase login error: $e");
          setState(() {
            _errorMessage = e.toString();
          });
        }
      } else {
        // Use mock auth service
        try {
          final apiService = Provider.of<ApiService>(context, listen: false);
          final response = await apiService.login(email, password);
          
          final userData = response['user'];
          final userRole = userData['role'];
          
          if (userRole == 'admin') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainLayout()),
            );
          } else {
            final mockEmployee = Employee(
              id: userData['id'],
              name: userData['name'],
              email: userData['email'],
              phone: userData['phone'] ?? '',
              position: 'Developer',
              department: 'Engineering',
              role: _parseRole(userRole),
              employmentType: EmploymentType.fullTime,
              workType: 'onsite',
              assignedProjects: [],
              reportingTo: '',
              joiningDate: DateTime.now().subtract(const Duration(days: 365)),
            );
            
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const MainLayout(),
              ),
            );
          }
        } catch (e) {
          print("Mock login error: $e");
          setState(() {
            _errorMessage = 'Login failed: $e';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
