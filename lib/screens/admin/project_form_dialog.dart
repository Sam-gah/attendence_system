import 'package:flutter/material.dart';
import '../../models/project.dart';
import '../../models/employee.dart';

class ProjectFormDialog extends StatefulWidget {
  final Project? project;
  final List<Employee> employees;
  final Function(Project) onSubmit;

  const ProjectFormDialog({
    super.key,
    this.project,
    required this.employees,
    required this.onSubmit,
  });

  @override
  State<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _budgetController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  ProjectStatus _status = ProjectStatus.planning;
  String? _projectManager;
  final List<String> _selectedTeamMembers = [];
  final List<String> _technologies = [];
  final _techController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description;
      _clientNameController.text = widget.project!.clientName;
      _budgetController.text = widget.project!.budget.toString();
      _startDate = widget.project!.startDate;
      _deadline = widget.project!.deadline;
      _status = widget.project!.status;
      _projectManager = widget.project!.projectManager;
      _selectedTeamMembers.addAll(widget.project!.teamMembers);
      _technologies.addAll(widget.project!.technologies);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.project == null ? 'Add Project' : 'Edit Project'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Project Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter project name' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter description' : null,
              ),
              TextFormField(
                controller: _clientNameController,
                decoration: const InputDecoration(labelText: 'Client Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter client name' : null,
              ),
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(labelText: 'Budget'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter budget';
                  if (double.tryParse(value!) == null) {
                    return 'Please enter valid amount';
                  }
                  return null;
                },
              ),
              _buildDatePicker(
                label: 'Start Date',
                selectedDate: _startDate,
                onSelect: (date) => setState(() => _startDate = date),
              ),
              _buildDatePicker(
                label: 'Deadline',
                selectedDate: _deadline,
                onSelect: (date) => setState(() => _deadline = date),
              ),
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
              DropdownButtonFormField<String>(
                value: _projectManager,
                decoration: const InputDecoration(labelText: 'Project Manager'),
                items: widget.employees
                    .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                    .toList(),
                onChanged: (value) => setState(() => _projectManager = value),
                validator: (value) =>
                    value == null ? 'Please select project manager' : null,
              ),
              const SizedBox(height: 16),
              _buildTeamMemberSelection(),
              const SizedBox(height: 16),
              _buildTechnologyInput(),
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
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime selectedDate,
    required Function(DateTime) onSelect,
  }) {
    return ListTile(
      title: Text(label),
      subtitle: Text(selectedDate.toString().split(' ')[0]),
      trailing: IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (date != null) onSelect(date);
        },
      ),
    );
  }

  Widget _buildTeamMemberSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Team Members'),
        Wrap(
          spacing: 8,
          children: [
            ...widget.employees.map((employee) {
              final isSelected = _selectedTeamMembers.contains(employee.id);
              return FilterChip(
                label: Text(employee.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTeamMembers.add(employee.id);
                    } else {
                      _selectedTeamMembers.remove(employee.id);
                    }
                  });
                },
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildTechnologyInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _techController,
                decoration: const InputDecoration(labelText: 'Technologies'),
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
                setState(() => _technologies.remove(tech));
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final project = Project(
        id: widget.project?.id ?? 'PRJ${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        description: _descriptionController.text,
        startDate: _startDate,
        deadline: _deadline,
        status: _status,
        clientName: _clientNameController.text,
        teamMembers: _selectedTeamMembers,
        projectManager: _projectManager!,
        budget: double.parse(_budgetController.text),
        technologies: _technologies,
        milestones: widget.project?.milestones ?? [],
      );

      widget.onSubmit(project);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _clientNameController.dispose();
    _budgetController.dispose();
    _techController.dispose();
    super.dispose();
  }
} 