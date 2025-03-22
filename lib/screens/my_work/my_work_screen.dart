import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:attendence_system/services/auth_service.dart';

class MyWorkScreen extends StatefulWidget {
  const MyWorkScreen({Key? key}) : super(key: key);

  @override
  State<MyWorkScreen> createState() => _MyWorkScreenState();
}

class _MyWorkScreenState extends State<MyWorkScreen> {
  final List<String> _tabs = ['Assigned', 'Created by me', 'Mentioned', 'Archived'];
  int _selectedTabIndex = 0;
  
  // Mock data for assigned tasks
  final List<Map<String, dynamic>> _assignedTasks = [
    {
      'title': 'Implement new UI for dashboard',
      'space': 'Bichitras Group',
      'list': 'In Progress',
      'dueDate': DateTime.now().add(const Duration(days: 2)),
      'priority': 'High',
      'status': 'in_progress',
      'tags': ['UI/UX', 'Frontend'],
      'estimatedHours': 6.0,
      'timeSpent': 3.5,
    },
    {
      'title': 'Create wireframes for mobile app',
      'space': 'Reels',
      'list': 'To-Do',
      'dueDate': DateTime.now().add(const Duration(days: 4)),
      'priority': 'Normal',
      'status': 'not_started',
      'tags': ['Design', 'Mobile'],
      'estimatedHours': 4.0,
      'timeSpent': 0.0,
    },
    {
      'title': 'Fix login screen bugs',
      'space': 'E-commerce',
      'list': 'Backlog',
      'dueDate': DateTime.now().add(const Duration(days: 7)),
      'priority': 'Urgent',
      'status': 'not_started',
      'tags': ['Bug', 'Authentication'],
      'estimatedHours': 2.0,
      'timeSpent': 0.0,
    },
    {
      'title': 'Review pull requests',
      'space': 'Bichitras Group',
      'list': 'To-Do',
      'dueDate': DateTime.now().add(const Duration(days: 1)),
      'priority': 'Normal',
      'status': 'not_started',
      'tags': ['Code Review'],
      'estimatedHours': 1.5,
      'timeSpent': 0.0,
    },
    {
      'title': 'Weekly Team Meeting',
      'space': 'Team Management',
      'list': 'To-Do',
      'dueDate': DateTime.now(),
      'priority': 'Low',
      'status': 'not_started',
      'tags': ['Meeting'],
      'estimatedHours': 1.0,
      'timeSpent': 0.0,
    },
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'My Work',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show more options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
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
          
          // Progress indicators
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Progress',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildProgressCard(
                        'To-Do',
                        '3',
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildProgressCard(
                        'In Progress',
                        '1',
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildProgressCard(
                        'Complete',
                        '7',
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Task list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _assignedTasks.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final task = _assignedTasks[index];
                return _buildTaskItem(task);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create task
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildProgressCard(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTaskItem(Map<String, dynamic> task) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: task['status'] == 'completed',
              onChanged: (value) {
                // Update task status
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          
          // Task details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and priority
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildPriorityIndicator(task['priority']),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Space and list
                Text(
                  '${task['space']} • ${task['list']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Tags
                if (task['tags'] != null && (task['tags'] as List).isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: (task['tags'] as List).map<Widget>((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                
                const SizedBox(height: 8),
                
                // Due date and time
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: _getDueDateColor(task['dueDate']),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd').format(task['dueDate']),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getDueDateColor(task['dueDate']),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${task['timeSpent']}/${task['estimatedHours']} hrs',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPriorityIndicator(String priority) {
    IconData icon;
    Color color;
    
    switch (priority) {
      case 'Urgent':
        icon = Icons.flag;
        color = Colors.red;
        break;
      case 'High':
        icon = Icons.flag;
        color = Colors.orange;
        break;
      case 'Normal':
        icon = Icons.flag;
        color = Colors.blue;
        break;
      case 'Low':
        icon = Icons.flag;
        color = Colors.grey;
        break;
      default:
        icon = Icons.flag;
        color = Colors.grey;
    }
    
    return Icon(icon, color: color, size: 16);
  }
  
  Color _getDueDateColor(DateTime dueDate) {
    final today = DateTime.now();
    final difference = dueDate.difference(today).inDays;
    
    if (difference < 0) {
      return Colors.red; // Overdue
    } else if (difference == 0) {
      return Colors.orange; // Due today
    } else if (difference <= 2) {
      return Colors.amber; // Due soon
    } else {
      return Colors.grey; // Due later
    }
  }
} 