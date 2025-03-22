import 'dart:async';

import 'package:attendence_system/main.dart';
import 'package:attendence_system/models/employee.dart';
import 'package:attendence_system/models/user.dart';
import 'package:attendence_system/screens/admin/admin_dashboard.dart';
import 'package:attendence_system/screens/attendance/attendance_history_screen.dart';
import 'package:attendence_system/screens/attendance/project_task_dialog.dart';
import 'package:attendence_system/screens/auth/login_screen.dart';
import 'package:attendence_system/screens/profile/profile_screen.dart';
import 'package:attendence_system/services/auth_service.dart';
import 'package:attendence_system/services/time_tracking_service.dart';
import 'package:flutter/material.dart';
import 'package:attendence_system/screens/user/user_projects_view.dart';
import 'package:provider/provider.dart';
import 'package:attendence_system/services/api_service.dart';
import 'package:attendence_system/services/database_service.dart';
import 'package:attendence_system/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AttendanceDashboard extends StatefulWidget {
  final String title;
  final Employee employee;

  const AttendanceDashboard({
    super.key,
    required this.title,
    required this.employee,
  });

  @override
  State<AttendanceDashboard> createState() => _AttendanceDashboardState();
}

class _AttendanceDashboardState extends State<AttendanceDashboard> {
  late final ApiService _api;
  late final DatabaseService _db;
  late final AuthService authService;
  late Future<List<Map<String, dynamic>>> _attendanceHistory;
  late final TimeTrackingService _timeTrackingService;
  FirebaseService? _firebaseService;
  bool _isClockedIn = false;
  String _workStatus = 'Not Working';
  DateTime? _clockInTime;
  Duration _totalTimeToday = Duration.zero;
  Timer? _timer;
  String? _currentProject;
  String? _currentTask;
  bool _isLoading = false;
  String _todayDate = DateTime.now().toIso8601String().split('T')[0]; // Today's date in YYYY-MM-DD format

  @override
  void initState() {
    super.initState();
    // Initialize services
    _api = Provider.of<ApiService>(context, listen: false);
    _db = Provider.of<DatabaseService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);
    
    // Try to get Firebase service
    try {
      _firebaseService = Provider.of<FirebaseService>(context, listen: false);
      print("Firebase service initialized: ${_firebaseService != null}");
    } catch (e) {
      print("Firebase service not available: $e");
      _firebaseService = null;
    }
    
    // Initialize time tracking service with Firebase if available
    _timeTrackingService = TimeTrackingService(_firebaseService);
    
    _loadWorkStatus();
    _startTimer();
    _loadAttendanceHistory();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadWorkStatus() async {
    try {
      _isClockedIn = await _timeTrackingService.isCurrentlyWorking();
      _clockInTime = await _timeTrackingService.getClockInTime();
      _totalTimeToday = await _timeTrackingService.getTotalTimeToday();
      
      // Load the current project and task from shared preferences
      final prefs = await SharedPreferences.getInstance();
      if (_isClockedIn) {
        _currentProject = prefs.getString('current_project');
        _currentTask = prefs.getString('current_task');
      }
      
      _updateWorkStatus();
    } catch (e) {
      print('Error loading work status: $e');
      // Default to not working if there's an error
      setState(() {
        _isClockedIn = false;
        _workStatus = 'Not Working (Error: $e)';
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isClockedIn && _clockInTime != null) {
        setState(() {
          _updateWorkStatus();
        });
      }
    });
  }

  void _updateWorkStatus() {
    if (_isClockedIn && _clockInTime != null) {
      final currentSessionDuration = DateTime.now().difference(_clockInTime!);
      final total = _totalTimeToday + currentSessionDuration;
      final currentSession = _formatDuration(currentSessionDuration);
      final totalTime = _formatDuration(total);
      _workStatus = 'Current Session: $currentSession\nTotal Today: $totalTime';
      if (_currentProject != null && _currentTask != null) {
        _workStatus += '\nProject: $_currentProject\nTask: $_currentTask';
      }
    } else {
      _workStatus = 'Not Working (Today: ${_formatDuration(_totalTimeToday)})';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _loadAttendanceHistory() {
    // If Firebase is available, load from Firestore
    if (_firebaseService != null) {
      // Create a date range for the past 7 days
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      
      // Use the Firebase service to get time entries
      _attendanceHistory = _getAttendanceHistoryFromFirebase(
        widget.employee.id, 
        sevenDaysAgo, 
        now
      );
    } else {
      // Otherwise, use the API service
      _attendanceHistory = _api.getAttendanceHistory(widget.employee.id);
    }
  }
  
  Future<List<Map<String, dynamic>>> _getAttendanceHistoryFromFirebase(
    String employeeId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      final querySnapshot = await _firebaseService!.timeEntries
          .where('employeeId', isEqualTo: employeeId)
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .orderBy('timestamp', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Process the Firestore timestamp
        final timestamp = data['timestamp'] as DateTime?;
        final localTimestamp = data['localTimestamp'] as String?;
        final dateStr = timestamp?.toIso8601String().split('T')[0] ?? 
                      localTimestamp?.split('T')[0] ?? 
                      DateTime.now().toIso8601String().split('T')[0];
        
        return {
          'id': doc.id,
          'date': dateStr,
          'status': data['action'] ?? 'unknown',
          'checkIn': data['action'] == 'clock_in' ? 
                     timestamp?.toIso8601String() ?? localTimestamp : null,
          'checkOut': data['action'] == 'clock_out' ? 
                      timestamp?.toIso8601String() ?? localTimestamp : null,
          'duration': data['duration'],
          'project': data['project'],
          'task': data['task'],
        };
      }).toList();
    } catch (e) {
      print('Error loading attendance history from Firebase: $e');
      return [];
    }
  }

  Future<void> _markAttendance() async {
    try {
      setState(() => _isLoading = true);
      
      if (_firebaseService != null) {
        // Use Firebase to mark attendance
        await _firebaseService!.markAttendance(widget.employee.id, {
          'status': 'present',
          'date': DateTime.now().toIso8601String().split('T')[0],
        });
      } else {
        // Use API service as fallback
        await _api.markAttendance(widget.employee.id);
      }
      
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance marked successfully')),
      );
      _loadAttendanceHistory();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark attendance: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's Date Header
              Card(
                color: Theme.of(context).colorScheme.primary,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _formatTodayDate(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _buildDailyStatusIndicator(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Employee Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          child: Text(widget.employee.name[0]),
                        ),
                        title: Text(widget.employee.name),
                        trailing: Chip(
                          label: Text(
                            widget.employee.role.toString().split('.').last,
                          ),
                        ),
                      ),
                      const Divider(),
                      Text('Department: ${widget.employee.department}'),
                      Text('Work Type: ${widget.employee.workType}'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Status Card with enhanced project visibility
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isClockedIn 
                                ? Icons.play_circle_fill
                                : Icons.pause_circle_outline,
                            color: _isClockedIn ? Colors.green : Colors.grey,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isClockedIn ? 'Currently Working' : 'Not Working',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                Text(
                                  _isClockedIn 
                                      ? 'Session started at ${_clockInTime!.hour.toString().padLeft(2, '0')}:${_clockInTime!.minute.toString().padLeft(2, '0')}'
                                      : 'Today: ${_formatDuration(_totalTimeToday)}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      if (_isClockedIn) ...[
                        const Divider(height: 32),

                        if (_currentProject != null && _currentProject!.isNotEmpty) ...[
                          // Enhanced project display
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  child: const Icon(
                                    Icons.folder,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'CURRENT PROJECT',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _currentProject!,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Current task info
                        _buildCurrentTaskInfo(),
                        
                        const SizedBox(height: 16),
                        
                        // Timer display
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer_outlined),
                              const SizedBox(width: 16),
                              Text(
                                _formatDuration(DateTime.now().difference(_clockInTime!)),
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ActionButton(
                            icon: _isClockedIn ? Icons.stop : Icons.play_arrow,
                            label: _isClockedIn ? 'Clock Out' : 'Clock In',
                            onPressed: _toggleAttendance,
                          ),
                          if (_isClockedIn)
                            ActionButton(
                              icon: Icons.coffee,
                              label: 'Take Break',
                              onPressed: () {
                                // TODO: Implement break functionality
                              },
                            ),
                          ActionButton(
                            icon: Icons.history,
                            label: 'View History',
                            onPressed: _navigateToHistory,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick Actions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          ActionButton(
                            icon: Icons.assignment,
                            label: 'My Tasks',
                            onPressed: () {},
                          ),
                          ActionButton(
                            icon: Icons.calendar_today,
                            label: 'Apply Leave',
                            onPressed: () {},
                          ),
                          ActionButton(
                            icon: Icons.people,
                            label: 'Team',
                            onPressed: () {},
                          ),
                          ActionButton(
                            icon: Icons.assessment,
                            label: 'Reports',
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _markAttendance,
                child: Text('Mark Attendance'),
              ),

              const SizedBox(height: 16),
              
              // Attendance History Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Attendance',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200, // Fixed height instead of Expanded
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: _attendanceHistory,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(child: Text('No attendance records found'));
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final attendance = snapshot.data![index];
                                return ListTile(
                                  title: Text('Date: ${attendance['date']}'),
                                  subtitle: Text('Status: ${attendance['status']}'),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30, 
                  backgroundColor: Colors.white,
                  child: Text(
                    widget.employee.name.isNotEmpty ? widget.employee.name[0] : '?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.employee.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.employee.email,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(user: widget.employee),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Attendance History'),
            onTap: _navigateToHistory,
          ),
          ListTile(
            leading: const Icon(Icons.work),
            title: const Text('Projects'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProjectsView(
                    userId: widget.employee.id,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // TODO: Navigate to settings
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await authService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          // Admin panel section
          FutureBuilder<User?>(
            future: authService.getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data?.role == 'admin') {
                return Column(
                  children: [
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings),
                      title: const Text('Admin Panel'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminDashboard(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AttendanceHistoryScreen(
              employeeId: widget.employee.id,
              employee: widget.employee,
            ),
      ),
    );
  }

  Future<void> _toggleAttendance() async {
    try {
      if (!_isClockedIn) {
        final result = await showDialog<Map<String, String>>(
          context: context,
          barrierDismissible: false,
          builder: (context) => ProjectTaskDialog(employee: widget.employee),
        );

        if (result != null) {
          // Save task details to shared preferences for display
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('current_project', result['project']!);
          await prefs.setString('current_task', result['task']!);
          
          // Save additional task details if available
          if (result.containsKey('taskLink') && result['taskLink']!.isNotEmpty) {
            await prefs.setString('current_task_link', result['taskLink']!);
          }
          
          if (result.containsKey('estimatedHours')) {
            await prefs.setString('current_estimated_hours', result['estimatedHours']!);
          }
          
          if (result.containsKey('priority')) {
            await prefs.setString('current_priority', result['priority']!);
          }
          
          if (result.containsKey('date')) {
            await prefs.setString('current_work_date', result['date']!);
          }
          
          if (result.containsKey('projectId')) {
            await prefs.setString('current_project_id', result['projectId']!);
          }
          
          setState(() {
            _isClockedIn = true;
            _currentProject = result['project'];
            _currentTask = result['task'];
          });
          
          // Include employee ID when using Firebase
          await _timeTrackingService.clockIn(
            project: result['project']!,
            task: result['task']!,
            employeeId: widget.employee.id,
          );
          
          _clockInTime = await _timeTrackingService.getClockInTime();
          _updateWorkStatus();
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully clocked in for today')),
          );
        }
      } else {
        // Clean up task details from shared preferences when clocking out
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('current_project');
        await prefs.remove('current_task');
        await prefs.remove('current_task_link');
        await prefs.remove('current_estimated_hours');
        await prefs.remove('current_priority');
        await prefs.remove('current_project_id');
        // Keep the date for reference: prefs.remove('current_work_date');
        
        setState(() {
          _isClockedIn = false;
          _currentProject = null;
          _currentTask = null;
        });
        
        // Include employee ID when using Firebase
        await _timeTrackingService.clockOut(
          employeeId: widget.employee.id,
        );
        
        _clockInTime = null;
        _totalTimeToday = await _timeTrackingService.getTotalTimeToday();
        _updateWorkStatus();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully clocked out for today')),
        );
        
        // Refresh attendance history
        _loadAttendanceHistory();
      }
    } catch (e) {
      print("Error toggling attendance: $e");
      setState(() => _isLoading = false);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildCurrentTaskInfo() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final prefs = snapshot.data!;
        
        // Get task details from shared preferences
        final String taskPriority = prefs.getString('current_priority') ?? 'Medium';
        final String estimatedHours = prefs.getString('current_estimated_hours') ?? '1.0';
        final String? taskLink = prefs.getString('current_task_link');
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project and task
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.folder_outlined),
              title: Text('Project: $_currentProject'),
              subtitle: Text('Task: $_currentTask'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(taskPriority),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  taskPriority,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Estimated time
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Estimated: $estimatedHours hours',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            
            // Task link if available
            if (taskLink != null && taskLink.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: InkWell(
                  onTap: () {
                    // TODO: Open task link
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.link, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          taskLink,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
  
  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.blue;
      case 'medium':
        return Colors.green;
      case 'high':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTodayDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June', 
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayIndex = now.weekday - 1; // weekday is 1-7, we need 0-6
    
    return '${days[dayIndex]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Widget _buildDailyStatusIndicator() {
    Color statusColor;
    String statusText;
    
    if (_isClockedIn) {
      statusColor = Colors.green;
      statusText = 'CLOCKED IN';
    } else if (_totalTimeToday.inMinutes > 0) {
      statusColor = Colors.orange;
      statusText = 'WORKED ${_formatDuration(_totalTimeToday)}';
    } else {
      statusColor = Colors.red;
      statusText = 'NOT STARTED';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
