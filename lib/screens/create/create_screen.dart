import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:attendence_system/services/auth_service.dart';
import 'package:attendence_system/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CreateScreen extends StatefulWidget {
  final VoidCallback? onClose;
  // Add a projectId parameter for when creating a task in a specific project
  final String? projectId;
  
  const CreateScreen({Key? key, this.onClose, this.projectId}) : super(key: key);

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form values
  String _taskName = '';
  String _description = '';
  String _selectedSpace = 'Work';
  String _selectedList = 'To-Do';
  String _selectedAssignee = 'Me';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 2));
  String _selectedPriority = 'Normal';
  double _estimatedTime = 1.0;
  String _taskLink = '';
  
  // Options for dropdowns
  final List<String> _spaces = ['Work', 'Personal', 'Bichitras', 'Side Projects'];
  final List<String> _lists = ['To-Do', 'In Progress', 'Backlog', 'Done'];
  final List<String> _assignees = ['Me', 'Smarak', 'Ankit', 'Rahul', 'Priya'];
  final List<String> _priorities = ['Urgent', 'High', 'Normal', 'Low'];

  @override
  void initState() {
    super.initState();
    
    // If a project ID was provided, populate spaces with that project
    if (widget.projectId != null) {
      _loadProjectDetails();
    }
  }

  Future<void> _loadProjectDetails() async {
    // In a real app, this would fetch from a database
    // For now, we'll just set the space based on the projectId
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = prefs.getString('projects') ?? '[]';
    final List<dynamic> projects = jsonDecode(projectsJson);
    
    for (var project in projects) {
      if (project['id'] == widget.projectId) {
        setState(() {
          _selectedSpace = project['name'];
        });
        break;
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'Create',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Use the callback or default to home tab
            if (widget.onClose != null) {
              widget.onClose!();
            } else {
              // Fall back to pop if no callback (for standalone use)
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: Text(
              'Create',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task type selector
              Row(
                children: [
                  _buildTypeButton('Task', Icons.check_circle_outline, isSelected: true),
                  const SizedBox(width: 12),
                  _buildTypeButton('Doc', Icons.description_outlined),
                  const SizedBox(width: 12),
                  _buildTypeButton('Whiteboard', Icons.dashboard_outlined),
                  const SizedBox(width: 12),
                  _buildTypeButton('Form', Icons.list_alt_outlined),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Task name field
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Task name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task name';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _taskName = value;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Description field
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                maxLines: 3,
                onChanged: (value) {
                  setState(() {
                    _description = value;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Space & List selector
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Space',
                      value: _selectedSpace,
                      items: _spaces,
                      onChanged: (value) {
                        setState(() {
                          _selectedSpace = value ?? _selectedSpace;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      label: 'List',
                      value: _selectedList,
                      items: _lists,
                      onChanged: (value) {
                        setState(() {
                          _selectedList = value ?? _selectedList;
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Assignee & Due date
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Assignee',
                      value: _selectedAssignee,
                      items: _assignees,
                      onChanged: (value) {
                        setState(() {
                          _selectedAssignee = value ?? _selectedAssignee;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker(),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Priority & Estimated time
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Priority',
                      value: _selectedPriority,
                      items: _priorities,
                      onChanged: (value) {
                        setState(() {
                          _selectedPriority = value ?? _selectedPriority;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildEstimatedTimePicker(),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Task link field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Task Link (Optional)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'https://...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      prefixIcon: const Icon(Icons.link),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _taskLink = value;
                      });
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Tags & Attachments
              Row(
                children: [
                  _buildIconButton(Icons.label_outline, 'Tags'),
                  const SizedBox(width: 16),
                  _buildIconButton(Icons.attachment, 'Attach'),
                  const SizedBox(width: 16),
                  _buildIconButton(Icons.push_pin_outlined, 'Pin'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTypeButton(String label, IconData icon, {bool isSelected = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            isExpanded: true,
            underline: Container(),
            icon: const Icon(Icons.arrow_drop_down),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Due Date',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: _dueDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (pickedDate != null && pickedDate != _dueDate) {
              setState(() {
                _dueDate = pickedDate;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(_dueDate),
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(Icons.calendar_today, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildEstimatedTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estimated Hours',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 16),
                onPressed: () {
                  setState(() {
                    if (_estimatedTime > 0.5) {
                      _estimatedTime -= 0.5;
                    }
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${_estimatedTime.toStringAsFixed(1)} hrs',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                onPressed: () {
                  setState(() {
                    _estimatedTime += 0.5;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildIconButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(icon, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final user = await Provider.of<AuthService>(context, listen: false).getCurrentUser();
        
        // 1. Create the task object
        final task = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'name': _taskName,
          'description': _description,
          'space': _selectedSpace,
          'list': _selectedList,
          'assignee': _selectedAssignee,
          'dueDate': _dueDate.toIso8601String(),
          'priority': _selectedPriority,
          'estimatedTime': _estimatedTime,
          'taskLink': _taskLink,
          'createdAt': DateTime.now().toIso8601String(),
          'createdBy': user?.id ?? 'unknown',
          'status': 'open',
          'projectId': widget.projectId,
        };
        
        // 2. Save to tasks list
        final tasksJson = prefs.getString('tasks') ?? '[]';
        final List<dynamic> tasks = jsonDecode(tasksJson);
        tasks.add(task);
        await prefs.setString('tasks', jsonEncode(tasks));
        
        // 3. Add to project if projectId is provided
        if (widget.projectId != null) {
          final projectsJson = prefs.getString('projects') ?? '[]';
          List<dynamic> projects = jsonDecode(projectsJson);
          
          for (int i = 0; i < projects.length; i++) {
            if (projects[i]['id'] == widget.projectId) {
              // Update project task counts
              projects[i]['tasks'] = (projects[i]['tasks'] ?? 0) + 1;
              
              // Add task ID to project's task list if it exists
              if (projects[i]['taskIds'] == null) {
                projects[i]['taskIds'] = [];
              }
              projects[i]['taskIds'].add(task['id']);
              
              break;
            }
          }
          
          await prefs.setString('projects', jsonEncode(projects));
        }
        
        // 4. Add to recent activities
        final activitiesJson = prefs.getString('recent_activities') ?? '[]';
        List<dynamic> activities = jsonDecode(activitiesJson);
        
        // Find today's date group or create a new one
        final today = DateTime.now();
        final dateStr = '${_getMonthName(today.month)} ${today.day}';
        
        bool foundDateGroup = false;
        for (var group in activities) {
          if (group['date'] == dateStr) {
            group['activities'].add({
              'title': _taskName,
              'space': _selectedSpace,
              'icon': 'Icons.check_circle_outline',
              'iconColor': 'Colors.green',
              'status': 'created',
              'timestamp': DateTime.now().toIso8601String(),
            });
            foundDateGroup = true;
            break;
          }
        }
        
        if (!foundDateGroup) {
          activities.add({
            'date': dateStr,
            'activities': [
              {
                'title': _taskName,
                'space': _selectedSpace,
                'icon': 'Icons.check_circle_outline',
                'iconColor': 'Colors.green',
                'status': 'created',
                'timestamp': DateTime.now().toIso8601String(),
              }
            ]
          });
        }
        
        await prefs.setString('recent_activities', jsonEncode(activities));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created successfully!')),
        );
        
        // Return to the home screen or the project screen
        if (widget.onClose != null) {
          widget.onClose!();
        } else if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
        
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating task: $e')),
        );
      }
    }
  }
  
  String _getMonthName(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }
} 