import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendence_system/models/employee.dart';
import 'package:attendence_system/models/user.dart';
import 'package:attendence_system/screens/home/home_screen.dart';
import 'package:attendence_system/screens/create/create_screen.dart';
import 'package:attendence_system/screens/attendance/attendance_dashboard.dart';
import 'package:attendence_system/screens/my_work/my_work_screen.dart';
import 'package:attendence_system/services/auth_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  
  Future<User?> _getUserData() async {
    try {
      return await Provider.of<AuthService>(context, listen: false).getCurrentUser();
    } catch (e) {
      // Handle error
      print('Error getting user data: $e');
      return null;
    }
  }
  
  // Convert User to Employee for the AttendanceDashboard
  Employee _convertUserToEmployee(User user) {
    return Employee(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      position: 'Developer', // Default value
      department: 'Design', // Default value
      employmentType: EmploymentType.fullTime, // Default value
      workType: 'onsite', // Default value
      assignedProjects: ['Project A', 'Project B'], // Sample projects
      reportingTo: 'Manager',
      joiningDate: DateTime.now().subtract(const Duration(days: 90)), // Sample joining date
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error loading user data'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        
        final user = snapshot.data!;
        final employee = _convertUserToEmployee(user);
        
        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              const HomeScreen(),
              CreateScreen(
                onClose: () {
                  setState(() {
                    _selectedIndex = 0; // Switch back to home screen
                  });
                },
              ),
              AttendanceDashboard(
                title: 'Bichitras Attendance',
                employee: employee,
              ),
              const MyWorkScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                activeIcon: Icon(Icons.add_circle),
                label: 'Create',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.access_time_outlined),
                activeIcon: Icon(Icons.access_time_filled),
                label: 'Attendance',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment_outlined),
                activeIcon: Icon(Icons.assignment),
                label: 'My Work',
              ),
            ],
          ),
        );
      },
    );
  }
} 