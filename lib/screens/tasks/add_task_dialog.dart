import 'package:flutter/material.dart';
import '../../models/task.dart';

class AddTaskDialog extends StatefulWidget {
  final String projectId;
  final Function(Task) onAdd;

  const AddTaskDialog({
    super.key,
    required this.projectId,
    required this.onAdd,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedTimeController = TextEditingController();
  final _tagController = TextEditingController();

  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  TaskPriority _priority = TaskPriority.normal;
  TaskStatus _status = TaskStatus.open;
  final List<String> _assignees = [];
  final List<String> _tags = [];
  final List<String> _dependencies = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Task'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Task Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter task name' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter description' : null,
              ),
              const SizedBox(height: 16),
              _buildDatePicker(
                label: 'Due Date',
                selectedDate: _dueDate,
                onSelect: (date) => setState(() => _dueDate = date),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _priority = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskStatus>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: TaskStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _status = value!),
              ),
              TextFormField(
                controller: _estimatedTimeController,
                decoration: const InputDecoration(
                  labelText: 'Estimated Time (minutes)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter estimated time';
                  }
                  if (int.tryParse(value!) == null) {
                    return 'Please enter valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildAssigneesSection(),
              const SizedBox(height: 16),
              _buildTagsSection(),
              const SizedBox(height: 16),
              _buildDependenciesSection(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: const Text('Create'),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime selectedDate,
    required Function(DateTime) onSelect,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(label),
        ),
        TextButton(
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              onSelect(date);
            }
          },
          child: Text(_formatDate(selectedDate)),
        ),
      ],
    );
  }

  Widget _buildAssigneesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Assignees'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Add assignee',
                ),
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _assignees.add(value);
                    });
                  }
                },
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: _assignees.map((assignee) {
            return Chip(
              label: Text(assignee),
              onDeleted: () {
                setState(() {
                  _assignees.remove(assignee);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tags'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  hintText: 'Add tag',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (_tagController.text.isNotEmpty) {
                  setState(() {
                    _tags.add(_tagController.text);
                    _tagController.clear();
                  });
                }
              },
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: _tags.map((tag) {
            return Chip(
              label: Text(tag),
              onDeleted: () {
                setState(() {
                  _tags.remove(tag);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDependenciesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dependencies (Task IDs)'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Add dependency task ID',
                ),
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _dependencies.add(value);
                    });
                  }
                },
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: _dependencies.map((dependency) {
            return Chip(
              label: Text(dependency),
              onDeleted: () {
                setState(() {
                  _dependencies.remove(dependency);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate a unique ID
        name: _nameController.text,
        description: _descriptionController.text,
        projectId: widget.projectId,
        createdBy: 'current_user', // TODO: Get from auth
        assignees: _assignees,
        dueDate: _dueDate,
        priority: _priority,
        status: _status,
        progress: 0.0, // New tasks start at 0% progress
        tags: _tags,
        dependencies: _dependencies,
        estimatedTime: int.parse(_estimatedTimeController.text),
        timeSpent: 0, // New tasks start with 0 time spent
        createdAt: DateTime.now(),
        customFields: {},
      );

      widget.onAdd(task);
      Navigator.pop(context);
    }
  }
} 