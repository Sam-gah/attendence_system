import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../projects/projects_screen.dart';
import '../tasks/task_list_screen.dart';
import '../../providers/theme_provider.dart';
import '../../services/firebase_service.dart';
import 'team_management.dart';
import 'reports_view.dart';
import 'settings_view.dart';
import '../../dialogs/attendance_details_dialog.dart';
import 'package:attendence_system/services/auth_service.dart';
import 'package:attendence_system/models/user.dart';
import 'package:attendence_system/services/task_assignment_service.dart';
import 'package:attendence_system/roles/role.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;
  List<User> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      // In a real app, this would be fetched from a database
      // Mock employees for demo purposes
      final currentUser = await authService.getCurrentUser();
      
      setState(() {
        _employees = [
          User(
            id: '1',
            name: 'Jane Smith',
            email: 'jane@example.com',
            role: Role.employee,
            phone: '123-456-7890',
          ),
          User(
            id: '2',
            name: 'John Doe',
            email: 'john@example.com',
            role: Role.employee,
            phone: '987-654-3210',
          ),
          User(
            id: '3',
            name: 'Alice Johnson',
            email: 'alice@example.com',
            role: Role.employee,
            phone: '555-123-4567',
          ),
          if (currentUser != null)
            currentUser,
        ];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading employees: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Employees'),
            Tab(text: 'Assign Tasks'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildEmployeesTab(),
          _buildAssignTasksTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildOverviewItem(
                        Icons.people,
                        '${_employees.length}',
                        'Total Employees',
                        Colors.blue,
                      ),
                      _buildOverviewItem(
                        Icons.check_circle,
                        '${(_employees.length * 0.8).round()}',
                        'Present Today',
                        Colors.green,
                      ),
                      _buildOverviewItem(
                        Icons.event_busy,
                        '${(_employees.length * 0.2).round()}',
                        'Absent Today',
                        Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project Status',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildProjectProgress('E-commerce App', 0.7, Colors.blue),
                  const SizedBox(height: 8),
                  _buildProjectProgress('Social Media Dashboard', 0.4, Colors.green),
                  const SizedBox(height: 8),
                  _buildProjectProgress('Attendance System', 0.9, Colors.purple),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Activities',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildRecentActivity(
                    'Jane Smith',
                    'Clocked in',
                    '08:45 AM',
                    Icons.login,
                    Colors.green,
                  ),
                  const Divider(),
                  _buildRecentActivity(
                    'John Doe',
                    'Completed task: UI Design',
                    '09:30 AM',
                    Icons.task_alt,
                    Colors.blue,
                  ),
                  const Divider(),
                  _buildRecentActivity(
                    'Alice Johnson',
                    'Requested leave',
                    '10:15 AM',
                    Icons.event_busy,
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 40),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildProjectProgress(String name, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name),
            Text('${(progress * 100).round()}%'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          color: color,
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildRecentActivity(
      String user, String activity, String time, IconData icon, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(user),
      subtitle: Text(activity),
      trailing: Text(time),
    );
  }

  Widget _buildEmployeesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _employees.length,
      itemBuilder: (context, index) {
        final employee = _employees[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(employee.name[0]),
            ),
            title: Text(employee.name),
            subtitle: Text(employee.email),
            trailing: Text(employee.role.toString().split('.').last),
            onTap: () {
              // View employee details
            },
          ),
        );
      },
    );
  }

  Widget _buildAssignTasksTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final prefs = snapshot.data!;
        
        return FutureBuilder<List<dynamic>>(
          future: _loadProjects(prefs),
          builder: (context, projectsSnapshot) {
            if (!projectsSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final projects = projectsSnapshot.data!;
            
            return FutureBuilder<List<dynamic>>(
              future: _loadTasks(prefs),
              builder: (context, tasksSnapshot) {
                if (!tasksSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final tasks = tasksSnapshot.data!;
                
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assign Tasks to Employees',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _employees.length,
                          itemBuilder: (context, index) {
                            final employee = _employees[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          child: Text(employee.name[0]),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                employee.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                employee.email,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.assignment_add),
                                          label: const Text('Assign Task'),
                                          onPressed: () {
                                            _showAssignTaskDialog(
                                              context, 
                                              employee, 
                                              projects, 
                                              tasks,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Recent Assignments:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    FutureBuilder<List<Map<String, dynamic>>>(
                                      future: _getEmployeeAssignedTasks(employee.id),
                                      builder: (context, assignedTasksSnapshot) {
                                        if (!assignedTasksSnapshot.hasData) {
                                          return const Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: CircularProgressIndicator(),
                                            ),
                                          );
                                        }
                                        
                                        final assignedTasks = assignedTasksSnapshot.data!;
                                        
                                        if (assignedTasks.isEmpty) {
                                          return const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('No recent assignments'),
                                          );
                                        }
                                        
                                        return Column(
                                          children: assignedTasks.take(3).map((task) {
                                            String statusText = 'Pending';
                                            Color statusColor = Colors.grey;
                                            
                                            if (task['status'] == 'in_progress') {
                                              statusText = 'In Progress';
                                              statusColor = Colors.green;
                                            } else if (task['status'] == 'completed') {
                                              statusText = 'Completed';
                                              statusColor = Colors.blue;
                                            }
                                            
                                            return ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              title: Text(task['taskName']),
                                              subtitle: Text('Project: ${task['projectName']}'),
                                              trailing: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: statusColor.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  statusText,
                                                  style: TextStyle(
                                                    color: statusColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
  
  Future<List<dynamic>> _loadProjects(SharedPreferences prefs) async {
    final projectsJson = prefs.getString('projects') ?? '[]';
    try {
      return jsonDecode(projectsJson);
    } catch (e) {
      print('Error decoding projects: $e');
      return [];
    }
  }
  
  Future<List<dynamic>> _loadTasks(SharedPreferences prefs) async {
    final tasksJson = prefs.getString('tasks') ?? '[]';
    try {
      return jsonDecode(tasksJson);
    } catch (e) {
      print('Error decoding tasks: $e');
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> _getEmployeeAssignedTasks(String employeeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assignedTasksJson = prefs.getString('assigned_tasks_$employeeId') ?? '[]';
      List<dynamic> assignedTasks = jsonDecode(assignedTasksJson);
      
      // Convert to List<Map<String, dynamic>> and sort by assigned time (newest first)
      return assignedTasks
        .map<Map<String, dynamic>>((task) => Map<String, dynamic>.from(task))
        .toList()
        ..sort((a, b) {
          final aTime = a['assignedAt'] ?? '';
          final bTime = b['assignedAt'] ?? '';
          return bTime.compareTo(aTime); // Sort descending (newest first)
        });
    } catch (e) {
      print('Error getting assigned tasks: $e');
      return [];
    }
  }
  
  void _showAssignTaskDialog(
    BuildContext context, 
    User employee,
    List<dynamic> projects,
    List<dynamic> tasks,
  ) {
    String? selectedProjectId;
    String? selectedTaskId;
    
    // Find tasks with no assignees or where this employee isn't assigned yet
    List<dynamic> availableTasks = [];
    
    // Create a new task if needed
    final taskNameController = TextEditingController();
    final taskDescriptionController = TextEditingController();
    final taskLinkController = TextEditingController();
    String taskPriority = 'medium';
    double estimatedHours = 2.0;
    bool createNewTask = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Filter tasks based on selected project
          if (selectedProjectId != null) {
            availableTasks = tasks.where((task) {
              // Check if task belongs to selected project
              if (task['projectId'] != selectedProjectId) {
                return false;
              }
              
              // Check if employee is already assigned
              if (task['assignees'] != null && task['assignees'] is List) {
                return !task['assignees'].contains(employee.id);
              }
              
              return true;
            }).toList();
          }
          
          return AlertDialog(
            title: Text('Assign Task to ${employee.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Project',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedProjectId,
                    items: projects.map<DropdownMenuItem<String>>((project) {
                      return DropdownMenuItem<String>(
                        value: project['id'],
                        child: Text(project['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedProjectId = value;
                        selectedTaskId = null; // Reset task selection
                        createNewTask = false;
                      });
                    },
                  ),
                  
                  if (selectedProjectId != null) ...[
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        const Text('Task:'),
                        const Spacer(),
                        TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Create New Task'),
                          onPressed: () {
                            setState(() {
                              createNewTask = true;
                              selectedTaskId = null;
                            });
                          },
                        ),
                      ],
                    ),
                    
                    if (!createNewTask) ...[
                      if (availableTasks.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('No available tasks in this project'),
                        )
                      else
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Select Task',
                            border: OutlineInputBorder(),
                          ),
                          value: selectedTaskId,
                          items: availableTasks.map<DropdownMenuItem<String>>((task) {
                            return DropdownMenuItem<String>(
                              value: task['id'],
                              child: Text(task['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedTaskId = value;
                            });
                          },
                        ),
                    ] else ...[
                      TextField(
                        controller: taskNameController,
                        decoration: const InputDecoration(
                          labelText: 'Task Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: taskDescriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Task Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: taskLinkController,
                        decoration: const InputDecoration(
                          labelText: 'Task Link (Optional)',
                          border: OutlineInputBorder(),
                          hintText: 'e.g. https://clickup.com/t/123456',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Priority:'),
                          const SizedBox(width: 16),
                          ChoiceChip(
                            label: const Text('Low'),
                            selected: taskPriority == 'low',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => taskPriority = 'low');
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Medium'),
                            selected: taskPriority == 'medium',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => taskPriority = 'medium');
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('High'),
                            selected: taskPriority == 'high',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => taskPriority = 'high');
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Est. Hours:'),
                          Expanded(
                            child: Slider(
                              value: estimatedHours,
                              min: 0.5,
                              max: 8.0,
                              divisions: 15,
                              label: estimatedHours.toString(),
                              onChanged: (value) {
                                setState(() => estimatedHours = value);
                              },
                            ),
                          ),
                          Text('${estimatedHours.toStringAsFixed(1)} hrs'),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: (selectedProjectId == null || 
                            (selectedTaskId == null && !createNewTask) ||
                            (createNewTask && taskNameController.text.trim().isEmpty))
                  ? null
                  : () async {
                      // Get the admin user (current user)
                      final authService = Provider.of<AuthService>(context, listen: false);
                      final currentUser = await authService.getCurrentUser();
                      
                      if (currentUser == null) {
                        // Not logged in as admin
                        Navigator.pop(context);
                        return;
                      }
                      
                      // Get the task assignment service
                      final taskAssignmentService = Provider.of<TaskAssignmentService>(
                        context, 
                        listen: false
                      );
                      
                      // Get the project details
                      final project = projects.firstWhere(
                        (p) => p['id'] == selectedProjectId,
                        orElse: () => null,
                      );
                      
                      if (project == null) {
                        Navigator.pop(context);
                        return;
                      }
                      
                      // Create a new task if needed
                      String taskId;
                      String taskName;
                      
                      if (createNewTask) {
                        // Create a new task
                        taskId = 't${DateTime.now().millisecondsSinceEpoch}';
                        taskName = taskNameController.text.trim();
                        
                        // Save the task
                        final prefs = await SharedPreferences.getInstance();
                        final tasksJson = prefs.getString('tasks') ?? '[]';
                        List<dynamic> tasksList = [];
                        
                        try {
                          tasksList = jsonDecode(tasksJson);
                        } catch (e) {
                          print('Error decoding tasks: $e');
                        }
                        
                        final newTask = {
                          'id': taskId,
                          'name': taskName,
                          'description': taskDescriptionController.text.trim(),
                          'projectId': selectedProjectId,
                          'assignees': [employee.id],
                          'dueDate': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
                          'priority': taskPriority,
                          'status': 'open',
                          'createdAt': DateTime.now().toIso8601String(),
                          'estimatedTime': estimatedHours,
                          'taskLink': taskLinkController.text.trim(),
                        };
                        
                        tasksList.add(newTask);
                        await prefs.setString('tasks', jsonEncode(tasksList));
                        
                        // Update project task count
                        final projectsJson = prefs.getString('projects') ?? '[]';
                        List<dynamic> projectsList = [];
                        
                        try {
                          projectsList = jsonDecode(projectsJson);
                        } catch (e) {
                          print('Error decoding projects: $e');
                        }
                        
                        for (int i = 0; i < projectsList.length; i++) {
                          if (projectsList[i]['id'] == selectedProjectId) {
                            projectsList[i]['tasks'] = (projectsList[i]['tasks'] ?? 0) + 1;
                            if (projectsList[i]['taskIds'] == null) {
                              projectsList[i]['taskIds'] = [taskId];
                            } else {
                              projectsList[i]['taskIds'].add(taskId);
                            }
                            break;
                          }
                        }
                        
                        await prefs.setString('projects', jsonEncode(projectsList));
                      } else {
                        // Use existing task
                        final task = tasks.firstWhere(
                          (t) => t['id'] == selectedTaskId,
                          orElse: () => null,
                        );
                        
                        if (task == null) {
                          Navigator.pop(context);
                          return;
                        }
                        
                        taskId = task['id'];
                        taskName = task['name'];
                      }
                      
                      // Assign the task to the employee
                      await taskAssignmentService.assignTaskToEmployee(
                        taskId: taskId,
                        employeeId: employee.id,
                        assignedBy: currentUser.name,
                        taskName: taskName,
                        projectName: project['name'],
                        priority: createNewTask ? taskPriority : null,
                        estimatedHours: createNewTask ? estimatedHours : null,
                        taskLink: createNewTask ? taskLinkController.text.trim() : null,
                      );
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Task assigned to ${employee.name}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                        setState(() {}); // Refresh the UI
                      }
                    },
                child: const Text('Assign Task'),
              ),
            ],
          );
        },
      ),
    );
  }
}
