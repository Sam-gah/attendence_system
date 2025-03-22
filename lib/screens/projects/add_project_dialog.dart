import 'package:flutter/material.dart';
import '../../models/project.dart';

class AddProjectDialog extends StatefulWidget {
  final Function(Project) onAdd;

  const AddProjectDialog({super.key, required this.onAdd});

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _budgetController = TextEditingController();
  final _projectManagerController = TextEditingController();
  final _techController = TextEditingController();
  final _teamMemberController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  ProjectStatus _status = ProjectStatus.planning;
  final List<String> _teamMembers = [];
  final List<String> _technologies = [];
  final List<Map<String, dynamic>> _milestones = [];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: 600,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add New Project',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Project Name'),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Please enter project name' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(labelText: 'Description'),
                          maxLines: 3,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Please enter description' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _clientNameController,
                          decoration: const InputDecoration(labelText: 'Client Name'),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Please enter client name' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _budgetController,
                          decoration: const InputDecoration(labelText: 'Budget'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Please enter budget';
                            if (double.tryParse(value!) == null) {
                              return 'Please enter valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _projectManagerController,
                          decoration: const InputDecoration(labelText: 'Project Manager'),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Please enter project manager' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildDatePicker(
                          label: 'Start Date',
                          selectedDate: _startDate,
                          onSelect: (date) => setState(() => _startDate = date),
                        ),
                        const SizedBox(height: 16),
                        _buildDatePicker(
                          label: 'Deadline',
                          selectedDate: _deadline,
                          onSelect: (date) => setState(() => _deadline = date),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<ProjectStatus>(
                          value: _status,
                          decoration: const InputDecoration(labelText: 'Status'),
                          items: ProjectStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status.toString().split('.').last),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _status = value!),
                        ),
                        const SizedBox(height: 16),
                        _buildTeamMembersSection(),
                        const SizedBox(height: 16),
                        _buildTechnologiesSection(),
                        const SizedBox(height: 16),
                        _buildMilestonesSection(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    child: const Text('Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
              firstDate: DateTime(2000),
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

  Widget _buildTeamMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Team Members'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _teamMemberController,
                decoration: const InputDecoration(
                  hintText: 'Add team member',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (_teamMemberController.text.isNotEmpty) {
                  setState(() {
                    _teamMembers.add(_teamMemberController.text);
                    _teamMemberController.clear();
                  });
                }
              },
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: _teamMembers.map((member) {
            return Chip(
              label: Text(member),
              onDeleted: () {
                setState(() {
                  _teamMembers.remove(member);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTechnologiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Technologies'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _techController,
                decoration: const InputDecoration(
                  hintText: 'Add technology',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (_techController.text.isNotEmpty) {
                  setState(() {
                    _technologies.add(_techController.text);
                    _techController.clear();
                  });
                }
              },
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: _technologies.map((tech) {
            return Chip(
              label: Text(tech),
              onDeleted: () {
                setState(() {
                  _technologies.remove(tech);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMilestonesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Milestones'),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Milestone'),
              onPressed: _showAddMilestoneDialog,
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _milestones.length,
          itemBuilder: (context, index) {
            final milestone = _milestones[index];
            return ListTile(
              title: Text(milestone['title'] as String),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _milestones.removeAt(index);
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }

  void _showAddMilestoneDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Milestone'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Milestone Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  _milestones.add({
                    'title': titleController.text,
                    'completed': false,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final project = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate a unique ID
        name: _nameController.text,
        description: _descriptionController.text,
        startDate: _startDate,
        deadline: _deadline,
        status: _status,
        progress: 0, // New projects start at 0% progress
        clientName: _clientNameController.text,
        budget: double.parse(_budgetController.text),
        projectManager: _projectManagerController.text,
        teamMembers: _teamMembers,
        technologies: _technologies,
        milestones: _milestones,
      );

      widget.onAdd(project);
      Navigator.pop(context);
    }
  }
} 