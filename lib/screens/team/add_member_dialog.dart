import 'package:flutter/material.dart';
import '../../models/employee.dart';
import '../../roles/role.dart';

class AddMemberDialog extends StatefulWidget {
  final Function(Employee) onAdd;

  const AddMemberDialog({super.key, required this.onAdd});

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();
  final _reportingToController = TextEditingController();

  String _department = 'Engineering';
  Role _role = Role.employee;
  EmploymentType _employmentType = EmploymentType.fullTime;
  String _workType = 'onsite';
  final List<String> _assignedProjects = [];

  final List<String> _departments = [
    'Engineering',
    'Design',
    'Product',
    'Marketing',
    'Sales',
    'HR',
    'Finance',
  ];

  final List<String> _workTypes = [
    'onsite',
    'remote',
    'hybrid',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Team Member'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter email';
                  if (!value!.contains('@')) return 'Please enter valid email';
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter phone' : null,
              ),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(labelText: 'Position'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter position' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _department,
                decoration: const InputDecoration(labelText: 'Department'),
                items: _departments.map((department) {
                  return DropdownMenuItem(
                    value: department,
                    child: Text(department),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _department = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Role>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: Role.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _role = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<EmploymentType>(
                value: _employmentType,
                decoration: const InputDecoration(labelText: 'Employment Type'),
                items: EmploymentType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _employmentType = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _workType,
                decoration: const InputDecoration(labelText: 'Work Type'),
                items: _workTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _workType = value!),
              ),
              TextFormField(
                controller: _reportingToController,
                decoration: const InputDecoration(labelText: 'Reporting To'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter reporting manager' : null,
              ),
              const SizedBox(height: 16),
              _buildProjectsSection(),
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
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildProjectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Assigned Projects'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Add project ID',
                ),
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _assignedProjects.add(value);
                    });
                  }
                },
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: _assignedProjects.map((project) {
            return Chip(
              label: Text(project),
              onDeleted: () {
                setState(() {
                  _assignedProjects.remove(project);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final employee = Employee(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate a unique ID
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        position: _positionController.text,
        department: _department,
        role: _role,
        employmentType: _employmentType,
        workType: _workType,
        assignedProjects: _assignedProjects,
        reportingTo: _reportingToController.text,
        joiningDate: DateTime.now(),
      );

      widget.onAdd(employee);
      Navigator.pop(context);
    }
  }
} 