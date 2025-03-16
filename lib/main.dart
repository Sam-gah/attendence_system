import 'package:flutter/material.dart';
import 'models/employee.dart';
import 'models/user.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/auth/login_screen.dart';
import 'services/auth_service.dart';
import 'services/time_tracking_service.dart';
import 'dart:async';
import 'screens/attendance/attendance_history_screen.dart';
import 'screens/attendance/project_task_dialog.dart';

void main() {
  runApp(const BichitrasApp());
}

class BichitrasApp extends StatelessWidget {
  const BichitrasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bichitras Attendance',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: FutureBuilder<User?>(
        future: AuthService().getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            if (snapshot.data?.role == 'admin') {
              return const AdminDashboard();
            }
            // Create a mock employee for the dashboard
            final employee = Employee(
              id: snapshot.data!.id,
              name: snapshot.data!.name,
              email: snapshot.data!.email,
              phone: '',
              position: '',
              role: EmployeeRole.Developer,
              department: '',
              designation: '',
              employmentType: EmploymentType.fullTime,
              workType: 'onsite',
              assignedProjects: [],
              reportingTo: '',
              joiningDate: DateTime.now(),
            );
            return AttendanceDashboard(
              title: 'Bichitras Attendance',
              employee: employee, // Pass the employee
            );
          }

          return const LoginScreen();
        },
      ),
    );
  }
}

class AttendanceDashboard extends StatefulWidget {
  final String title;
  final Employee employee; // Add this

  const AttendanceDashboard({
    super.key,
    required this.title,
    required this.employee, // Add this
  });

  @override
  State<AttendanceDashboard> createState() => _AttendanceDashboardState();
}

class _AttendanceDashboardState extends State<AttendanceDashboard> {
  final _timeTrackingService = TimeTrackingService();
  bool _isClockedIn = false;
  String _workStatus = 'Not Working';
  DateTime? _clockInTime;
  Duration _totalTimeToday = Duration.zero;
  Timer? _timer;
  String? _currentProject;
  String? _currentTask;

  @override
  void initState() {
    super.initState();
    _loadWorkStatus();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadWorkStatus() async {
    _isClockedIn = await _timeTrackingService.isCurrentlyWorking();
    _clockInTime = await _timeTrackingService.getClockInTime();
    _totalTimeToday = await _timeTrackingService.getTotalTimeToday();
    _updateWorkStatus();
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

  Future<void> _toggleAttendance() async {
    if (!_isClockedIn) {
      final result = await showDialog<Map<String, String>>(
        context: context,
        barrierDismissible: false,
        builder: (context) => ProjectTaskDialog(employee: widget.employee),
      );

      if (result != null) {
        setState(() => _isClockedIn = true);
        await _timeTrackingService.clockIn(
          project: result['project']!,
          task: result['task']!,
        );
        _clockInTime = await _timeTrackingService.getClockInTime();
        _updateWorkStatus();
      }
    } else {
      setState(() => _isClockedIn = false);
      await _timeTrackingService.clockOut();
      _clockInTime = null;
      _totalTimeToday = await _timeTrackingService.getTotalTimeToday();
      _updateWorkStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        subtitle: Text(widget.employee.designation),
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

              // Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Status: $_workStatus',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (_clockInTime != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Clocked in at: ${_clockInTime!.hour}:${_clockInTime!.minute}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ActionButton(
                            icon: _isClockedIn ? Icons.stop : Icons.play_arrow,
                            label: _isClockedIn ? 'Clock Out' : 'Clock In',
                            onPressed: _toggleAttendance,
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
            ],
          ),
        ),
      ),
      drawer: _buildDrawer(),
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
                CircleAvatar(radius: 30, child: Text(widget.employee.name[0])),
                const SizedBox(height: 10),
                Text(
                  widget.employee.name,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
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
            leading: const Icon(Icons.history),
            title: const Text('Attendance History'),
            onTap: _navigateToHistory,
          ),
          ListTile(
            leading: const Icon(Icons.work),
            title: const Text('Projects'),
            onTap: () {
              // TODO: Navigate to projects
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
              await AuthService().logout();
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
            future: AuthService().getCurrentUser(),
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
