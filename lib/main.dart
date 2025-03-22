import 'package:attendence_system/screens/attendance/attendance_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/employee.dart';
import 'models/user.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/auth/login_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'services/auth_service.dart';
import 'services/task_assignment_service.dart';
import 'roles/role.dart';
import 'providers/theme_provider.dart';
import 'providers/project_provider.dart';
import 'providers/task_provider.dart';
import 'services/api_service.dart';
import 'services/database_service.dart';
import 'services/firebase_service.dart';
import 'screens/home/main_layout.dart';

void main() async {
  try {
    print("Starting app initialization...");
    WidgetsFlutterBinding.ensureInitialized();
    print("Flutter binding initialized");

    // Initialize Firebase with error handling for desktop platforms
    bool firebaseInitialized = false;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseInitialized = true;
      print("Firebase initialized successfully");
    } catch (e) {
      print("Firebase initialization error: $e");
      print("Continuing without Firebase - some features may be limited");
    }

    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    
    // Clear any corrupted theme preferences
    if (prefs.get('theme_mode') != null) {
      await prefs.remove('theme_mode');
    }

    // Initialize services
    final apiService = ApiService();
    final databaseService = DatabaseService();
    
    // Conditionally initialize Firebase service
    final firebaseService = firebaseInitialized ? FirebaseService() : null;
    
    // Initialize auth service with available dependencies
    final authService = firebaseInitialized 
      ? AuthService(databaseService, apiService, firebaseService)
      : AuthService(databaseService, apiService);
    
    // Initialize task assignment service
    final taskAssignmentService = TaskAssignmentService(authService);
    
    // Initialize providers
    final themeProvider = ThemeProvider(prefs);
    final projectProvider = ProjectProvider();
    final taskProvider = TaskProvider();
    
    // Run app with providers
    runApp(
      MultiProvider(
        providers: [
          Provider<ApiService>(create: (_) => apiService),
          Provider<DatabaseService>(create: (_) => databaseService),
          if (firebaseInitialized) Provider<FirebaseService>(create: (_) => firebaseService!),
          Provider<AuthService>(create: (_) => authService),
          Provider<TaskAssignmentService>(create: (_) => taskAssignmentService),
          ChangeNotifierProvider.value(value: themeProvider),
          ChangeNotifierProvider.value(value: projectProvider),
          ChangeNotifierProvider.value(value: taskProvider),
        ],
        child: const BichitrasApp(),
      ),
    );
    print("App started successfully");
  } catch (e, stackTrace) {
    print('Fatal initialization error: $e');
    print('Stack trace: $stackTrace');
    // Show error UI instead of crashing
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error initializing app: $e'),
          ),
        ),
      ),
    );
  }
}

class BichitrasApp extends StatelessWidget {
  const BichitrasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Bichitras Attendance',
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const AuthWrapper(),
          routes: {
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
  
  ThemeData _buildLightTheme() {
    return ThemeData(
      primarySwatch: Colors.indigo,
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.grey[50],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.indigo,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 1,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
  
  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      brightness: Brightness.dark,
      useMaterial3: true,
      primaryColor: const Color(0xFF5E35B1),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF7B5DD7),
        secondary: Color(0xFF7B5DD7),
        surface: Color(0xFF1E1E1E),
        background: Color(0xFF151515),
        error: Color(0xFFCF6679),
      ),
      scaffoldBackgroundColor: const Color(0xFF151515),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1E1E1E),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: Color(0xFF7B5DD7),
        unselectedItemColor: Colors.grey,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF7B5DD7),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return FutureBuilder(
      future: authService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in, navigate to the main app layout
          return const MainLayout();
        }
        
        // User is not logged in, show login screen
        return const LoginScreen();
      },
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
