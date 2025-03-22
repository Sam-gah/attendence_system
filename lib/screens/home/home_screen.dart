import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendence_system/services/auth_service.dart';
import 'package:attendence_system/screens/auth/login_screen.dart';
import 'package:attendence_system/screens/admin/admin_dashboard.dart';
import 'package:attendence_system/models/user.dart';
import 'package:attendence_system/models/employee.dart';
import 'package:attendence_system/screens/profile/profile_screen.dart';
import 'package:attendence_system/screens/user/user_projects_view.dart';
import 'package:attendence_system/roles/role.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:attendence_system/screens/create/create_screen.dart';
import 'package:attendence_system/services/task_assignment_service.dart';
import 'package:attendence_system/screens/attendance/attendance_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Updated tabs to match request
  final List<String> _tabs = ['Recent', 'Projects', 'Settings', 'Profile'];
  int _selectedTabIndex = 0;

  // Mock data for recent activities
  final List<Map<String, dynamic>> _recentActivities = [
    {
      'date': 'Mar 20',
      'activities': [
        {
          'title': 'Reel Upload',
          'space': 'Reels',
          'icon': Icons.check_circle,
          'iconColor': Colors.green,
          'status': 'completed'
        },
      ]
    },
    {
      'date': 'Mar 18',
      'activities': [
        {
          'title': 'E-commerce Home Screen UI',
          'space': 'List',
          'icon': Icons.watch_later,
          'iconColor': Colors.orange,
          'status': 'in_progress'
        },
        {
          'title': 'E-commerce Home Screen UI',
          'space': 'List',
          'icon': Icons.watch_later,
          'iconColor': Colors.orange,
          'status': 'in_progress'
        },
      ]
    },
    {
      'date': 'Mar 17',
      'activities': [
        {
          'title': 'Candidate Tracking',
          'space': 'Recruiting & Hiring',
          'icon': Icons.list,
          'iconColor': Colors.grey,
          'status': 'in_backlog'
        },
        {
          'title': 'In-House Projects',
          'space': 'Bichitras Group',
          'icon': Icons.list,
          'iconColor': Colors.grey,
          'status': 'in_backlog'
        },
      ]
    },
  ];

  // Mock data for projects
  final List<Map<String, dynamic>> _projects = [
    {
      'id': 'p1',
      'name': 'E-commerce App',
      'description': 'Shopping application with personalized recommendations',
      'progress': 0.7,
      'tasks': 24,
      'completed': 16,
      'priority': 'high',
      'color': Colors.blue,
      'members': 5,
    },
    {
      'id': 'p2',
      'name': 'Social Media Dashboard',
      'description': 'Analytics dashboard for tracking engagement metrics',
      'progress': 0.4,
      'tasks': 18,
      'completed': 7,
      'priority': 'medium',
      'color': Colors.green,
      'members': 3,
    },
    {
      'id': 'p3',
      'name': 'Attendance System',
      'description': 'Employee attendance tracking with analytics',
      'progress': 0.9,
      'tasks': 30,
      'completed': 27,
      'priority': 'high',
      'color': Colors.purple,
      'members': 4,
    },
  ];

  Widget _buildProjectsTab() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final prefs = snapshot.data!;
        final projectsJson = prefs.getString('projects') ?? '[]';
        List<dynamic> projects = [];
        
        try {
          projects = jsonDecode(projectsJson);
          
          // If no projects saved yet, use the mock projects
          if (projects.isEmpty) {
            projects = _projects;
            // Save mock projects to SharedPreferences for future use
            prefs.setString('projects', jsonEncode(_projects));
          }
        } catch (e) {
          // If there's an error parsing the JSON, use mock projects
          projects = _projects;
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Projects',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          _createNewProject();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('New'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          // Navigate to all projects view
                          final authService = Provider.of<AuthService>(context, listen: false);
                          authService.getCurrentUser().then((user) {
                            if (user != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserProjectsView(
                                    userId: user.id,
                                  ),
                                ),
                              );
                            }
                          });
                        },
                        icon: const Icon(Icons.visibility),
                        label: const Text('View All'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  
                  // Calculate progress based on completed tasks
                  final int totalTasks = project['tasks'] ?? 0;
                  final int completedTasks = project['completed'] ?? 0;
                  final double progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
                  
                  // Get color as a Color object
                  Color projectColor;
                  if (project['color'] is Color) {
                    projectColor = project['color'];
                  } else {
                    // Default colors if the stored value isn't a Color
                    switch (index % 4) {
                      case 0:
                        projectColor = Colors.blue;
                        break;
                      case 1:
                        projectColor = Colors.green;
                        break;
                      case 2:
                        projectColor = Colors.purple;
                        break;
                      case 3:
                        projectColor = Colors.orange;
                        break;
                      default:
                        projectColor = Colors.blueGrey;
                    }
                  }
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                project['name'],
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(project['priority'] ?? 'medium'),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  (project['priority'] ?? 'Medium').toString().toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            project['description'] ?? 'No description',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[300],
                              minHeight: 8,
                              color: projectColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$completedTasks/$totalTasks tasks',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.people, size: 16),
                                  const SizedBox(width: 4),
                                  Text('${project['members'] ?? 1} members'),
                                ],
                              ),
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      _addTaskToProject(project['id']);
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Task'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () {
                                      _viewProjectTasks(project);
                                    },
                                    icon: const Icon(Icons.visibility),
                                    label: const Text('View Tasks'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _createNewProject() {
    // Project form values
    String name = '';
    String description = '';
    String priority = 'Medium';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  hintText: 'Enter project name',
                ),
                onChanged: (value) {
                  name = value;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter project description',
                ),
                maxLines: 3,
                onChanged: (value) {
                  description = value;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Priority',
                ),
                value: priority,
                items: ['Low', 'Medium', 'High', 'Urgent']
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    priority = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (name.isNotEmpty) {
                final newProject = {
                  'id': 'p${DateTime.now().millisecondsSinceEpoch}',
                  'name': name,
                  'description': description,
                  'progress': 0.0,
                  'tasks': 0,
                  'completed': 0,
                  'priority': priority.toLowerCase(),
                  'color': null, // Will be set to a default based on index
                  'members': 1,
                  'taskIds': [],
                  'createdAt': DateTime.now().toIso8601String(),
                };
                
                final prefs = await SharedPreferences.getInstance();
                final projectsJson = prefs.getString('projects') ?? '[]';
                List<dynamic> projects = [];
                
                try {
                  projects = jsonDecode(projectsJson);
                } catch (e) {
                  // If there's an error parsing JSON, start with empty list
                }
                
                projects.add(newProject);
                await prefs.setString('projects', jsonEncode(projects));
                
                if (context.mounted) {
                  Navigator.pop(context);
                  // Refresh the projects list
                  setState(() {});
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _addTaskToProject(String projectId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateScreen(
          projectId: projectId,
          onClose: () {
            Navigator.pop(context);
            // Refresh the projects list
            setState(() {});
          },
        ),
      ),
    );
  }

  void _viewProjectTasks(Map<String, dynamic> project) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks') ?? '[]';
    List<dynamic> allTasks = [];
    
    try {
      allTasks = jsonDecode(tasksJson);
    } catch (e) {
      // If there's an error parsing JSON, use empty list
    }
    
    // Filter tasks for this project
    final projectTasks = allTasks.where((task) => 
      task['projectId'] == project['id'] || 
      task['space'] == project['name']
    ).toList();
    
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${project['name']} Tasks'),
          content: SizedBox(
            width: double.maxFinite,
            child: projectTasks.isEmpty
              ? const Center(
                  child: Text(
                    'No tasks for this project yet.\nCreate some tasks to get started!',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: projectTasks.length,
                  itemBuilder: (context, index) {
                    final task = projectTasks[index];
                    return ListTile(
                      title: Text(task['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${task['description']}'),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(task['priority']),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  task['priority'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.access_time, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                '${task['estimatedTime']} hrs',
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (task['taskLink'] != null && task['taskLink'].isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Icon(Icons.link, size: 12, color: Colors.blue),
                              ],
                            ],
                          ),
                        ],
                      ),
                      trailing: Checkbox(
                        value: task['status'] == 'completed',
                        onChanged: (value) async {
                          // Update the task status
                          for (int i = 0; i < allTasks.length; i++) {
                            if (allTasks[i]['id'] == task['id']) {
                              allTasks[i]['status'] = value == true ? 'completed' : 'open';
                              break;
                            }
                          }
                          
                          await prefs.setString('tasks', jsonEncode(allTasks));
                          
                          // Update project completion count
                          final projectsJson = prefs.getString('projects') ?? '[]';
                          List<dynamic> projects = [];
                          
                          try {
                            projects = jsonDecode(projectsJson);
                          } catch (e) {
                            // If there's an error parsing JSON, use empty list
                          }
                          
                          for (int i = 0; i < projects.length; i++) {
                            if (projects[i]['id'] == project['id']) {
                              int completedCount = projects[i]['completed'] ?? 0;
                              if (value == true) {
                                completedCount++;
                              } else if (completedCount > 0) {
                                completedCount--;
                              }
                              projects[i]['completed'] = completedCount;
                              break;
                            }
                          }
                          
                          await prefs.setString('projects', jsonEncode(projects));
                          
                          Navigator.pop(context);
                          
                          // Show completion message
                          if (value == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Task marked as completed')),
                            );
                          }
                          
                          // Refresh the projects list
                          setState(() {});
                        },
                      ),
                      onTap: () {
                        // View task details
                      },
                    );
                  },
                ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _addTaskToProject(project['id']);
              },
              child: const Text('Add Task'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'App Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (value) {
                    // Toggle theme
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to notification settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                trailing: const Text('English'),
                onTap: () {
                  // Show language picker
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Account Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Security'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to security settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to privacy settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help & Support'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to help & support
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    return FutureBuilder<User?>(
      future: authService.getCurrentUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final user = snapshot.data!;
        final employee = Employee(
          id: user.id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          role: user.role,
          position: 'Developer', // Default value
          department: 'Design', // Default value
          employmentType: EmploymentType.fullTime,
          workType: 'onsite',
          assignedProjects: ['Project A', 'Project B'],
          reportingTo: 'Manager',
          joiningDate: DateTime.now().subtract(const Duration(days: 90)),
        );
        
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0] : '?',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      user.role.toString().split('.').last.toUpperCase(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(user: employee),
                          ),
                        );
                      },
                      child: const Text('Edit Profile'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Phone'),
                    subtitle: Text(user.phone ?? 'Not provided'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.work),
                    title: const Text('Department'),
                    subtitle: Text(employee.department),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Position'),
                    subtitle: Text(employee.position),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Joined'),
                    subtitle: Text(
                      '${employee.joiningDate.day}/${employee.joiningDate.month}/${employee.joiningDate.year}',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await authService.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  // Recent tab builder
  Widget _buildRecentTab() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final taskAssignmentService = TaskAssignmentService(authService);
    
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final prefs = snapshot.data!;
        
        return FutureBuilder<User?>(
          future: authService.getCurrentUser(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final user = userSnapshot.data!;
            
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: taskAssignmentService.getAssignedTasks(),
              builder: (context, tasksSnapshot) {
                // Activities will include recent activities plus pending and in-progress tasks
                List<dynamic> combinedActivities = [];
                
                // Get recent activities
                final activitiesJson = prefs.getString('recent_activities') ?? '[]';
                List<dynamic> activities = [];
                
                try {
                  activities = jsonDecode(activitiesJson);
                  
                  // If no activities saved yet, use the mock activities
                  if (activities.isEmpty) {
                    activities = _recentActivities;
                    // Save mock activities to SharedPreferences for future use
                    prefs.setString('recent_activities', jsonEncode(_recentActivities));
                  }
                  
                  combinedActivities.addAll(activities);
                } catch (e) {
                  // If there's an error parsing the JSON, use mock activities
                  combinedActivities.addAll(_recentActivities);
                }
                
                // Add assigned tasks to the recent activities
                if (tasksSnapshot.hasData && tasksSnapshot.data!.isNotEmpty) {
                  // Group tasks by status (pending, in_progress)
                  final pendingTasks = tasksSnapshot.data!.where((task) => task['status'] == 'pending').toList();
                  final inProgressTasks = tasksSnapshot.data!.where((task) => task['status'] == 'in_progress').toList();
                  
                  // Create sections for pending tasks
                  if (pendingTasks.isNotEmpty) {
                    final pendingTasksGroup = {
                      'date': 'Assigned Tasks',
                      'activities': pendingTasks.map((task) => {
                        'title': task['taskName'],
                        'space': task['projectName'],
                        'icon': 'Icons.assignment',
                        'iconColor': 'Colors.blue',
                        'status': 'assigned',
                        'assignedBy': task['assignedBy'],
                        'priority': task['priority'],
                        'taskId': task['taskId'],
                        'isTask': true,
                        'estimatedHours': task['estimatedHours'],
                        'taskLink': task['taskLink'],
                      }).toList(),
                    };
                    
                    combinedActivities.insert(0, pendingTasksGroup);
                  }
                  
                  // Create sections for in-progress tasks
                  if (inProgressTasks.isNotEmpty) {
                    final inProgressTasksGroup = {
                      'date': 'In Progress',
                      'activities': inProgressTasks.map((task) => {
                        'title': task['taskName'],
                        'space': task['projectName'],
                        'icon': 'Icons.play_circle',
                        'iconColor': 'Colors.green',
                        'status': 'in_progress',
                        'assignedBy': task['assignedBy'],
                        'priority': task['priority'],
                        'taskId': task['taskId'],
                        'isTask': true,
                        'progress': task['progress'],
                        'estimatedHours': task['estimatedHours'],
                        'startedAt': task['startedAt'],
                        'taskLink': task['taskLink'],
                      }).toList(),
                    };
                    
                    combinedActivities.insert(0, inProgressTasksGroup);
                  }
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: combinedActivities.length,
                  itemBuilder: (context, index) {
                    final dateGroup = combinedActivities[index];
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date/section header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            dateGroup['date'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        
                        // Activities for this date
                        ...dateGroup['activities'].map<Widget>((activity) {
                          // Convert icon string to IconData
                          IconData activityIcon = Icons.check_circle;
                          if (activity['icon'] == 'Icons.check_circle_outline') {
                            activityIcon = Icons.check_circle_outline;
                          } else if (activity['icon'] == 'Icons.watch_later') {
                            activityIcon = Icons.watch_later;
                          } else if (activity['icon'] == 'Icons.list') {
                            activityIcon = Icons.list;
                          } else if (activity['icon'] == 'Icons.assignment') {
                            activityIcon = Icons.assignment;
                          } else if (activity['icon'] == 'Icons.play_circle') {
                            activityIcon = Icons.play_circle;
                          }
                          
                          // Convert color string to Color
                          Color iconColor = Colors.green;
                          if (activity['iconColor'] == 'Colors.orange') {
                            iconColor = Colors.orange;
                          } else if (activity['iconColor'] == 'Colors.grey') {
                            iconColor = Colors.grey;
                          } else if (activity['iconColor'] == 'Colors.blue') {
                            iconColor = Colors.blue;
                          }
                          
                          // Check if this is a task
                          final bool isTask = activity['isTask'] == true;
                          
                          if (isTask) {
                            return _buildTaskItem(activity, user.id, taskAssignmentService);
                          } else {
                            // Regular activity item
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: Icon(
                                  activityIcon,
                                  color: iconColor,
                                ),
                              ),
                              title: Text(activity['title']),
                              subtitle: Text('In ${activity['space']}'),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              onTap: () {
                                // Navigate to activity details
                              },
                            );
                          }
                        }).toList(),
                        
                        const Divider(),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
  
  Widget _buildTaskItem(Map<String, dynamic> task, String userId, TaskAssignmentService taskAssignmentService) {
    // Determine the icon and color based on status
    IconData taskIcon = Icons.assignment;
    Color iconColor = Colors.blue;
    
    if (task['status'] == 'in_progress') {
      taskIcon = Icons.play_circle;
      iconColor = Colors.green;
    } else if (task['status'] == 'completed') {
      taskIcon = Icons.check_circle;
      iconColor = Colors.green;
    }
    
    // For in-progress tasks, calculate the start time difference
    String timeInfo = '';
    if (task['status'] == 'in_progress' && task['startedAt'] != null) {
      try {
        final startTime = DateTime.parse(task['startedAt']);
        final now = DateTime.now();
        final duration = now.difference(startTime);
        
        if (duration.inHours > 0) {
          timeInfo = '${duration.inHours}h ${duration.inMinutes % 60}m';
        } else {
          timeInfo = '${duration.inMinutes}m';
        }
      } catch (e) {
        timeInfo = '';
      }
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(
                taskIcon,
                color: iconColor,
              ),
            ),
            title: Text(
              task['title'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Project: ${task['space']}'),
                if (task['assignedBy'] != null)
                  Text('Assigned by: ${task['assignedBy']}'),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(task['priority']),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task['priority'].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.access_time, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      '${task['estimatedHours']} hrs',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            trailing: task['status'] == 'in_progress'
                ? Text(
                    timeInfo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
            onTap: () {
              _showTaskDetails(task, userId, taskAssignmentService);
            },
          ),
          // Show progress bar for in-progress tasks
          if (task['status'] == 'in_progress' && task['progress'] != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: double.parse(task['progress'].toString()),
                    backgroundColor: Colors.grey[300],
                    minHeight: 8,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(double.parse(task['progress'].toString()) * 100).toInt()}% Complete',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  void _showTaskDetails(
    Map<String, dynamic> task, 
    String userId, 
    TaskAssignmentService taskAssignmentService
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task['title']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Project: ${task['space']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (task['assignedBy'] != null) ...[
                Text('Assigned by: ${task['assignedBy']}'),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task['priority']),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      task['priority'].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Est. time: ${task['estimatedHours']} hrs'),
                ],
              ),
              const SizedBox(height: 16),
              
              // Status information
              Text(
                'Status: ${task['status'] == 'pending' ? 'Not Started' : 
                       task['status'] == 'in_progress' ? 'In Progress' : 'Completed'}',
                style: TextStyle(
                  color: task['status'] == 'pending' ? Colors.grey :
                         task['status'] == 'in_progress' ? Colors.green : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              // Progress tracking for in-progress tasks
              if (task['status'] == 'in_progress') ...[
                const SizedBox(height: 16),
                const Text('Update Progress:'),
                const SizedBox(height: 8),
                StatefulBuilder(
                  builder: (context, setState) {
                    // Get current progress
                    double progress = 0.0;
                    if (task['progress'] != null) {
                      progress = double.parse(task['progress'].toString());
                    }
                    
                    return Column(
                      children: [
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          minHeight: 10,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${(progress * 100).toInt()}%'),
                            Slider(
                              value: progress,
                              min: 0.0,
                              max: 1.0,
                              divisions: 10,
                              onChanged: (value) {
                                setState(() {
                                  progress = value;
                                });
                              },
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await taskAssignmentService.updateTaskProgress(
                                  taskId: task['taskId'],
                                  employeeId: userId,
                                  progress: progress,
                                );
                                
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  // Refresh the screen to show updated progress
                                  setState(() {});
                                }
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
              
              // Task link if available
              if (task['taskLink'] != null && task['taskLink'].toString().isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Task Link:'),
                const SizedBox(height: 4),
                Text(
                  task['taskLink'],
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (task['status'] == 'pending') ...[
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Working'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                // Start the task
                await taskAssignmentService.startTask(
                  taskId: task['taskId'],
                  employeeId: userId,
                );
                
                if (context.mounted) {
                  Navigator.pop(context);
                  
                  // Show the attendance dashboard
                  final authService = Provider.of<AuthService>(context, listen: false);
                  authService.getCurrentUser().then((user) {
                    if (user != null) {
                      // Create employee object for the dashboard
                      final employee = Employee(
                        id: user.id,
                        name: user.name,
                        email: user.email,
                        phone: user.phone,
                        role: user.role,
                        position: 'Developer', // Default
                        department: 'Design', // Default
                        employmentType: EmploymentType.fullTime,
                        workType: 'onsite',
                        assignedProjects: [task['space']],
                        reportingTo: 'Manager',
                        joiningDate: DateTime.now().subtract(Duration(days: 90)),
                      );
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceDashboard(
                            title: 'Attendance',
                            employee: employee,
                          ),
                        ),
                      );
                    }
                  });
                }
              },
            ),
          ],
          if (task['status'] == 'in_progress') ...[
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                // Complete the task
                await taskAssignmentService.completeTask(
                  taskId: task['taskId'],
                  employeeId: userId,
                );
                
                if (context.mounted) {
                  Navigator.pop(context);
                  setState(() {}); // Refresh the screen
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task marked as completed')),
                  );
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Row(
          children: [
            Text(
              'Bichitras',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.keyboard_arrow_down),
          ],
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search
            },
          ),
          PopupMenuButton(
            offset: const Offset(0, 50),
            icon: FutureBuilder(
              future: Provider.of<AuthService>(context, listen: false).getCurrentUser(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CircleAvatar(
                    radius: 16,
                    child: Text(snapshot.data!.name[0]),
                  );
                }
                return const CircleAvatar(
                  radius: 16,
                  child: Icon(Icons.person, size: 16),
                );
              },
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'profile') {
                setState(() {
                  _selectedTabIndex = 3; // Switch to profile tab
                });
              } else if (value == 'settings') {
                setState(() {
                  _selectedTabIndex = 2; // Switch to settings tab
                });
              } else if (value == 'logout') {
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Horizontal tabs
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: _selectedTabIndex == index
                          ? Border(
                              bottom: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          color: _selectedTabIndex == index
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                          fontWeight: _selectedTabIndex == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Tab content
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                // Recent tab
                _buildRecentTab(),
                
                // Projects tab
                _buildProjectsTab(),
                
                // Settings tab
                _buildSettingsTab(),
                
                // Profile tab
                _buildProfileTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    return FutureBuilder<User?>(
      future: authService.getCurrentUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Drawer(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        final user = snapshot.data!;
        
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
                        user.name.isNotEmpty ? user.name[0] : '?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email,
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
                  setState(() {
                    _selectedTabIndex = 3; // Switch to profile tab
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Attendance History'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to attendance history
                },
              ),
              ListTile(
                leading: const Icon(Icons.work),
                title: const Text('Projects'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedTabIndex = 1; // Switch to projects tab
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedTabIndex = 2; // Switch to settings tab
                  });
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await authService.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
              // Admin panel section
              if (user.role == Role.admin) ...[
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
            ],
          ),
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
} 