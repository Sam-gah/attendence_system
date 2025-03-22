import 'package:flutter/material.dart';
import '../../models/employee.dart';
import 'package:attendence_system/services/task_assignment_service.dart';
import 'package:attendence_system/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ProjectTaskDialog extends StatefulWidget {
  final Employee employee;

  const ProjectTaskDialog({
    super.key,
    required this.employee,
  });

  @override
  State<ProjectTaskDialog> createState() => _ProjectTaskDialogState();
}

class _ProjectTaskDialogState extends State<ProjectTaskDialog> {
  String? selectedProject;
  String? selectedTaskId;
  final taskController = TextEditingController();
  final taskLinkController = TextEditingController();
  double estimatedHours = 1.0;
  String priority = 'Medium';
  bool _isLoading = true;
  String _currentDate = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
  
  List<Map<String, dynamic>> _assignedTasks = [];
  List<Map<String, dynamic>> _projectList = [];

  final List<String> priorities = ['Low', 'Medium', 'High', 'Urgent'];

  @override
  void initState() {
    super.initState();
    _loadAssignedTasks();
    _loadProjects();
  }
  
  Future<void> _loadProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectsJson = prefs.getString('projects');
      
      if (projectsJson != null && projectsJson.isNotEmpty) {
        final List<dynamic> projects = jsonDecode(projectsJson);
        _projectList = projects.map<Map<String, dynamic>>((project) {
          return {
            'id': project['id'],
            'name': project['name'],
            'description': project['description'] ?? '',
            'color': project['color'] ?? 0xFF2196F3,
          };
        }).toList();
      }
    } catch (e) {
      print('Error loading projects: $e');
      _projectList = [];
    }
  }
  
  Future<void> _loadAssignedTasks() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final taskService = TaskAssignmentService(authService);
      
      // Get pending tasks
      final pendingTasks = await taskService.getPendingTasks();
      
      // Get current in-progress task if any
      final currentTask = await taskService.getCurrentTask();
      
      if (currentTask != null) {
        // If there's already a task in progress, pre-select it
        selectedTaskId = currentTask['taskId'];
        selectedProject = currentTask['projectId'];
        taskController.text = currentTask['taskName'];
        taskLinkController.text = currentTask['taskLink'] ?? '';
        estimatedHours = double.tryParse(currentTask['estimatedHours'].toString()) ?? 1.0;
        priority = currentTask['priority'] ?? 'Medium';
      }
      
      // Set state
      setState(() {
        _assignedTasks = pendingTasks;
        _isLoading = false;
        
        // Set default project if none selected and employee has assigned projects
        if (selectedProject == null && widget.employee.assignedProjects.isNotEmpty) {
          selectedProject = widget.employee.assignedProjects.first;
        }
      });
    } catch (e) {
      print('Error loading assigned tasks: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading your tasks...'),
            ],
          ),
        ),
      );
    }

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Today: $_currentDate',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Start Today\'s Work',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              
              if (_assignedTasks.isNotEmpty) ...[
                Text(
                  'Your Assigned Tasks',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _assignedTasks.length,
                  itemBuilder: (context, index) {
                    final task = _assignedTasks[index];
                    return RadioListTile<String>(
                      title: Text(task['taskName']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Project: ${task['projectName']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 4, right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(task['priority']),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  task['priority'].toUpperCase(),
                                  style: const TextStyle(fontSize: 10, color: Colors.white),
                                ),
                              ),
                              Text('Est: ${task['estimatedHours']} hrs'),
                            ],
                          ),
                        ],
                      ),
                      value: task['taskId'],
                      groupValue: selectedTaskId,
                      onChanged: (value) {
                        setState(() {
                          selectedTaskId = value;
                          selectedProject = task['projectId'];
                          taskController.text = task['taskName'];
                          taskLinkController.text = task['taskLink'] ?? '';
                          estimatedHours = double.tryParse(task['estimatedHours'].toString()) ?? 1.0;
                          priority = task['priority'] ?? 'Medium';
                        });
                      },
                    );
                  },
                ),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Or create a new task for today',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                RadioListTile<String?>(
                  title: const Text('New Task'),
                  value: null,
                  groupValue: selectedTaskId,
                  onChanged: (value) {
                    setState(() {
                      selectedTaskId = value;
                      // Clear fields for custom task
                      taskController.clear();
                      taskLinkController.clear();
                      estimatedHours = 1.0;
                      priority = 'Medium';
                    });
                  },
                ),
                const SizedBox(height: 8),
              ],
              
              Text(
                'What are you working on today?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              
              // Project selection with enhanced UI
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Project',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_projectList.isEmpty) ...[
                      DropdownButtonFormField<String>(
                        value: selectedProject,
                        decoration: const InputDecoration(
                          labelText: 'Project',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.folder_outlined),
                        ),
                        items: widget.employee.assignedProjects.map((project) {
                          return DropdownMenuItem(
                            value: project,
                            child: Text(project),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedProject = value);
                        },
                        validator: (value) => value == null ? 'Please select a project' : null,
                      ),
                    ] else ...[
                      // Project cards grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: _projectList.length,
                        itemBuilder: (context, index) {
                          final project = _projectList[index];
                          final bool isSelected = selectedProject == project['id'];
                          final color = Color(project['color']);
                          
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedProject = project['id'];
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? color.withOpacity(0.2)
                                    : Theme.of(context).colorScheme.surface,
                                border: Border.all(
                                  color: isSelected ? color : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder,
                                    color: color,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    project['name'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? color : null,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              TextField(
                controller: taskController,
                decoration: const InputDecoration(
                  labelText: 'Task Description',
                  border: OutlineInputBorder(),
                  hintText: 'What are you working on today?',
                  prefixIcon: Icon(Icons.task_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: taskLinkController,
                decoration: const InputDecoration(
                  labelText: 'Task Link (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. https://clickup.com/t/123456',
                  prefixIcon: Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Hours for Today',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                if (estimatedHours > 0.5) {
                                  setState(() {
                                    estimatedHours -= 0.5;
                                  });
                                }
                              },
                            ),
                            Expanded(
                              child: Slider(
                                value: estimatedHours,
                                min: 0.5,
                                max: 8.0,
                                divisions: 15,
                                label: estimatedHours.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    estimatedHours = value;
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                if (estimatedHours < 8.0) {
                                  setState(() {
                                    estimatedHours += 0.5;
                                  });
                                }
                              },
                            ),
                            Text(
                              '${estimatedHours.toStringAsFixed(1)} hrs',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Priority',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: priorities
                    .map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(p),
                          selected: priority == p,
                          selectedColor: _getPriorityColor(p),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                priority = p;
                              });
                            }
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
              
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Today\'s Work'),
                    onPressed: selectedProject == null
                        ? null
                        : () async {
                            // Ensure non-null values
                            final String task = taskController.text.trim().isEmpty 
                                ? "General Work" 
                                : taskController.text.trim();
                            
                            // Get project name from selected project
                            String projectName = "";
                            if (_projectList.isNotEmpty) {
                              final selectedProjectData = _projectList.firstWhere(
                                (p) => p['id'] == selectedProject,
                                orElse: () => {'name': selectedProject!},
                              );
                              projectName = selectedProjectData['name'];
                            } else {
                              projectName = selectedProject!;
                            }
                            
                            // Create result map with all the details
                            final Map<String, String> result = {
                              'project': projectName,
                              'projectId': selectedProject!,
                              'task': task,
                              'taskLink': taskLinkController.text.trim(),
                              'estimatedHours': estimatedHours.toString(),
                              'priority': priority,
                              'date': DateTime.now().toIso8601String().split('T')[0],
                            };
                            
                            // If this is an assigned task, start it in the task system
                            if (selectedTaskId != null) {
                              final authService = Provider.of<AuthService>(context, listen: false);
                              final taskService = TaskAssignmentService(authService);
                              
                              await taskService.startTask(
                                taskId: selectedTaskId!,
                                employeeId: widget.employee.id,
                              );
                            }
                            
                            Navigator.pop(context, result);
                          },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

  @override
  void dispose() {
    taskController.dispose();
    taskLinkController.dispose();
    super.dispose();
  }
} 