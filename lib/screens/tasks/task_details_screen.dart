import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../constants/app_theme.dart';
import 'task_form_dialog.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Task task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _timeDescriptionController =
      TextEditingController();
  bool _isTrackingTime = false;

  @override
  void dispose() {
    _commentController.dispose();
    _timeController.dispose();
    _timeDescriptionController.dispose();
    super.dispose();
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder:
          (context) => TaskFormDialog(
            projectId: widget.task.projectId,
            task: widget.task,
          ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: const Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<TaskProvider>().deleteTask(widget.task);
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to task list
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
    );
  }

  void _toggleTimeTracking() {
    setState(() {
      _isTrackingTime = !_isTrackingTime;
    });
  }

  void _submitTimeEntry() {
    final minutes = int.tryParse(_timeController.text);
    if (minutes == null || minutes <= 0) return;

    context.read<TaskProvider>().trackTaskTime(
      widget.task.id,
      minutes,
      _timeDescriptionController.text,
    );

    setState(() {
      _isTrackingTime = false;
      _timeController.clear();
      _timeDescriptionController.clear();
    });
  }

  void _submitComment() {
    if (_commentController.text.isEmpty) return;

    context.read<TaskProvider>().addTaskComment(
      widget.task.id,
      'currentUserId', // TODO: Get from auth
      _commentController.text,
    );

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.name),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _showEditDialog),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteConfirmation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusSection(isDarkMode),
            const SizedBox(height: 24),
            _buildDescriptionSection(isDarkMode),
            const SizedBox(height: 24),
            _buildTimeTrackingSection(isDarkMode),
            const SizedBox(height: 24),
            _buildCommentsSection(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(bool isDarkMode) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status',
              style:
                  isDarkMode ? AppTheme.heading2Dark : AppTheme.heading2Light,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Priority',
                      style:
                          isDarkMode
                              ? AppTheme.captionDark
                              : AppTheme.captionLight,
                    ),
                    Text(
                      widget.task.priority.toString().split('.').last,
                      style:
                          isDarkMode
                              ? AppTheme.bodyTextDark
                              : AppTheme.bodyTextLight,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Due Date',
                      style:
                          isDarkMode
                              ? AppTheme.captionDark
                              : AppTheme.captionLight,
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(widget.task.dueDate),
                      style:
                          isDarkMode
                              ? AppTheme.bodyTextDark
                              : AppTheme.bodyTextLight,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: widget.task.progress,
              backgroundColor: isDarkMode ? Colors.white24 : Colors.grey[200],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(bool isDarkMode) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style:
                  isDarkMode ? AppTheme.heading2Dark : AppTheme.heading2Light,
            ),
            const SizedBox(height: 8),
            Text(
              widget.task.description,
              style:
                  isDarkMode ? AppTheme.bodyTextDark : AppTheme.bodyTextLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTrackingSection(bool isDarkMode) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Time Tracking',
                  style:
                      isDarkMode
                          ? AppTheme.heading2Dark
                          : AppTheme.heading2Light,
                ),
                IconButton(
                  icon: Icon(_isTrackingTime ? Icons.close : Icons.add),
                  onPressed: _toggleTimeTracking,
                ),
              ],
            ),
            if (_isTrackingTime) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Time (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _timeDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _submitTimeEntry,
                child: const Text('Add Time Entry'),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Total Time: ${widget.task.timeSpent} minutes',
              style:
                  isDarkMode ? AppTheme.bodyTextDark : AppTheme.bodyTextLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection(bool isDarkMode) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comments',
              style:
                  isDarkMode ? AppTheme.heading2Dark : AppTheme.heading2Light,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _submitComment,
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: context.read<TaskProvider>().streamTaskComments(
                widget.task.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final comments = snapshot.data!;

                if (comments.isEmpty) {
                  return const Text('No comments yet');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      title: Text(comment['comment']),
                      subtitle: Text(
                        DateFormat(
                          'MMM dd, yyyy HH:mm',
                        ).format((comment['createdAt'] as DateTime)),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
