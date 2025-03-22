import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../providers/project_provider.dart';
import '../../constants/app_theme.dart';
import 'task_form_dialog.dart';
import 'task_details_screen.dart';
import 'add_task_dialog.dart';

class TaskListScreen extends StatefulWidget {
  final String projectId;

  const TaskListScreen({super.key, required this.projectId});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  TaskStatus _selectedStatus = TaskStatus.open;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Subscribe to project tasks if not viewing all tasks
    if (widget.projectId != 'all') {
      Future.microtask(() {
        context.read<TaskProvider>().subscribeToProjectTasks(widget.projectId);
      });
    }
  }

  @override
  void dispose() {
    // Unsubscribe from project tasks if not viewing all tasks
    if (widget.projectId != 'all') {
      context.read<TaskProvider>().unsubscribeFromProjectTasks(
        widget.projectId,
      );
    }
    super.dispose();
  }

  List<Task> _getAllTasks(
    TaskProvider taskProvider,
    ProjectProvider projectProvider,
  ) {
    if (widget.projectId == 'all') {
      // Combine tasks from all projects
      final allTasks = <Task>[];
      for (final projectId in projectProvider.projects.map((p) => p.id)) {
        allTasks.addAll(taskProvider.getProjectTasks(projectId));
      }
      return allTasks;
    } else {
      return taskProvider.getProjectTasks(widget.projectId);
    }
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectId == 'all' ? 'All Tasks' : 'Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddTaskDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          _buildSearchBar(),
          Expanded(
            child: Consumer2<TaskProvider, ProjectProvider>(
              builder: (context, taskProvider, projectProvider, child) {
                if (taskProvider.isLoading) {
                  return _buildLoadingSkeleton();
                }

                if (taskProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${taskProvider.error}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (widget.projectId != 'all') {
                              taskProvider.subscribeToProjectTasks(widget.projectId);
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final tasks = _getAllTasks(taskProvider, projectProvider)
                    .where(
                      (task) =>
                          task.status == _selectedStatus &&
                          task.name.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                    )
                    .toList();

                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskCard(
                      task: task,
                      showProject: widget.projectId == 'all',
                      onTap: () => _showTaskDetails(task),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        projectId: widget.projectId,
        onAdd: (task) {
          setState(() {
            // Add the new task to the existing tasks
            // This is a placeholder. You might want to update this part
            // to actually add the task to your task provider
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task "${task.name}" created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _showTaskDetails(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: task)),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Status',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TaskStatus.values.map((status) {
                final isSelected = _selectedStatus == status;
                final color = _getStatusColor(status);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(
                      status.toString().split('.').last,
                      style: TextStyle(
                        color: isSelected ? Colors.white : color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: color.withOpacity(0.1),
                    selectedColor: color,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? color : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.open:
        return Colors.blue;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final bool showProject;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.showProject = false,
    required this.onTap,
  });

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.open:
        return Colors.blue;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildPriorityChip(task.priority),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatusChip(task.status),
                  const SizedBox(width: 8),
                  if (showProject) ...[
                    _buildProjectChip(task.projectId),
                    const SizedBox(width: 8),
                  ],
                  const Spacer(),
                  _buildDueDateChip(task.dueDate!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    final color = _getPriorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flag,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            priority.toString().split('.').last,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(TaskStatus status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toString().split('.').last,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProjectChip(String projectId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder,
            size: 16,
            color: Colors.blue,
          ),
          const SizedBox(width: 4),
          Text(
            projectId,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueDateChip(DateTime dueDate) {
    final isOverdue = dueDate.isBefore(DateTime.now());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOverdue ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: 16,
            color: isOverdue ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            DateFormat('MMM d').format(dueDate),
            style: TextStyle(
              color: isOverdue ? Colors.red : Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return Colors.red;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.normal:
        return Colors.blue;
      case TaskPriority.low:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
