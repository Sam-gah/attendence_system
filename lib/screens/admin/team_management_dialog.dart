import 'package:flutter/material.dart';
import '../../models/project.dart';
import '../../models/employee.dart';

class TeamManagementDialog extends StatefulWidget {
  final Project project;
  final List<Employee>? employees;

  const TeamManagementDialog({
    super.key,
    required this.project,
    this.employees,
  });

  @override
  State<TeamManagementDialog> createState() => _TeamManagementDialogState();
}

class _TeamManagementDialogState extends State<TeamManagementDialog> {
  late List<String> selectedMembers;

  @override
  void initState() {
    super.initState();
    selectedMembers = List.from(widget.project.teamMembers);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manage Team'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project: ${widget.project.name}'),
            const SizedBox(height: 16),
            const Text('Team Members:'),
            const SizedBox(height: 8),
            if (widget.employees != null) ...[
              Wrap(
                spacing: 8,
                children: widget.employees!.map((employee) {
                  final isSelected = selectedMembers.contains(employee.id);
                  return FilterChip(
                    label: Text(employee.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedMembers.add(employee.id);
                        } else {
                          selectedMembers.remove(employee.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
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
          onPressed: () => Navigator.pop(context, selectedMembers),
          child: const Text('Save'),
        ),
      ],
    );
  }
} 