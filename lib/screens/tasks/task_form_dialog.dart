import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';

class TaskFormDialog extends StatefulWidget {
  final String projectId;
  final Task? task; // If provided, we're editing an existing task

  const TaskFormDialog({super.key, required this.projectId, this.task});

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;
  late TaskPriority _priority;
  late TaskStatus _status;
  late int _estimatedTime;
  List<String> _assignees = [];
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing task data if editing
    _nameController = TextEditingController(text: widget.task?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _dueDate =
        widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _priority = widget.task?.priority ?? TaskPriority.normal;
    _status = widget.task?.status ?? TaskStatus.open;
    _estimatedTime = widget.task?.estimatedTime ?? 0;
    _assignees = widget.task?.assignees ?? [];
    _tags = widget.task?.tags ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final taskProvider = context.read<TaskProvider>();
    final task = Task(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      projectId: widget.projectId,
      createdBy: 'currentUserId', // TODO: Get from auth
      assignees: _assignees,
      dueDate: _dueDate,
      priority: _priority,
      status: _status,
      progress: widget.task?.progress ?? 0.0,
      tags: _tags,
      estimatedTime: _estimatedTime,
      timeSpent: widget.task?.timeSpent ?? 0,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
    );

    if (widget.task == null) {
      taskProvider.createTask(task);
    } else {
      taskProvider.updateTask(task);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.task == null ? 'Create Task' : 'Edit Task',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Task Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a task name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Due Date'),
                        subtitle: Text(
                          DateFormat('MMM dd, yyyy').format(_dueDate),
                        ),
                        onTap: _selectDueDate,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _selectDueDate,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskPriority>(
                  value: _priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      TaskPriority.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority.toString().split('.').last),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _priority = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskStatus>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      TaskStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.toString().split('.').last),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _estimatedTime.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Estimated Time (minutes)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _estimatedTime = int.tryParse(value) ?? 0;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      child: Text(widget.task == null ? 'Create' : 'Update'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
