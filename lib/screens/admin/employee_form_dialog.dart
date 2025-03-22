import 'package:flutter/material.dart';
import '../../models/employee.dart';
import '../../roles/role.dart';

class EmployeeFormDialog extends StatefulWidget {
  final Employee? employee;
  final List<Employee> allEmployees;
  final Function(Employee) onSubmit;

  const EmployeeFormDialog({
    super.key,
    this.employee,
    required this.allEmployees,
    required this.onSubmit,
  });

  @override
  State<EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _id;
  late String _name;
  late String _email;
  late String _phone;
  late String _department;
  late String _designation;
  late EmploymentType _employmentType;
  late String _workType;
  late String _reportingTo;
  late DateTime _joiningDate;

  @override
  void initState() {
    super.initState();
    _id = widget.employee?.id ?? '';
    _name = widget.employee?.name ?? '';
    _email = widget.employee?.email ?? '';
    _phone = widget.employee?.phone ?? '';
    _department = widget.employee?.department ?? '';
    _employmentType = widget.employee?.employmentType ?? EmploymentType.fullTime;
    _workType = widget.employee?.workType ?? 'onsite';
    _reportingTo = widget.employee?.reportingTo ?? '';
    _joiningDate = widget.employee?.joiningDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.employee == null ? 'Add Employee' : 'Edit Employee'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _id,
                decoration: const InputDecoration(labelText: 'Employee ID'),
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Please enter ID' : null,
                onSaved: (value) => _id = value!,
              ),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Please enter name' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Please enter email' : null,
                onSaved: (value) => _email = value!,
              ),

              TextFormField(
                initialValue: _phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Please enter phone' : null,
                onSaved: (value) => _phone = value!,
              ),
              DropdownButtonFormField<String>(
                value: _reportingTo.isEmpty ? null : _reportingTo,
                decoration: const InputDecoration(labelText: 'Reporting To'),
                items:
                    widget.allEmployees
                        .where((e) => e.id != _id)
                        .map(
                          (employee) => DropdownMenuItem(
                            value: employee.id,
                            child: Text(
                              '${employee.name} (${employee.role.toString().split('.').last})',
                            ),
                          ),
                        )
                        .toList(),
                onChanged:
                    (value) => setState(() => _reportingTo = value ?? ''),
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? 'Please select reporting manager'
                            : null,
              ),
              TextFormField(
                initialValue: _department,
                decoration: const InputDecoration(labelText: 'Department'),
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? 'Please enter department'
                            : null,
                onSaved: (value) => _department = value!,
              ),
              TextFormField(
                initialValue: _designation,
                decoration: const InputDecoration(labelText: 'Designation'),
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? 'Please enter designation'
                            : null,
                onSaved: (value) => _designation = value!,
              ),
              DropdownButtonFormField<EmploymentType>(
                value: _employmentType,
                decoration: const InputDecoration(labelText: 'Employment Type'),
                items:
                    EmploymentType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.toString().split('.').last),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _employmentType = value!),
              ),
              DropdownButtonFormField<String>(
                value: _workType,
                decoration: const InputDecoration(labelText: 'Work Type'),
                items:
                    ['onsite', 'remote', 'hybrid']
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _workType = value!),
              ),
              ListTile(
                title: const Text('Joining Date'),
                subtitle: Text(_joiningDate.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submitForm, child: const Text('Save')),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      widget.onSubmit(
        Employee(
          id: _id,
          name: _name,
          email: _email,
          phone: _phone,
          position: _designation,
          department: _department,
          employmentType: _employmentType,
          workType: _workType,
          assignedProjects: widget.employee?.assignedProjects ?? [],
          reportingTo: _reportingTo,
          joiningDate: _joiningDate,
          role: Role.employee,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _joiningDate) {
      setState(() {
        _joiningDate = picked;
      });
    }
  }
}
