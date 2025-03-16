import 'package:flutter/material.dart';
import '../../models/employee.dart';

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
  final taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Project & Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedProject,
            decoration: const InputDecoration(
              labelText: 'Project',
              border: OutlineInputBorder(),
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
          const SizedBox(height: 16),
          TextField(
            controller: taskController,
            decoration: const InputDecoration(
              labelText: 'Task Description',
              border: OutlineInputBorder(),
              hintText: 'What are you working on?',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedProject == null
              ? null
              : () {
                  Navigator.pop(context, {
                    'project': selectedProject,
                    'task': taskController.text.trim(),
                  });
                },
          child: const Text('Start Session'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }
} 