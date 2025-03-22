import 'package:flutter/material.dart';
import '../../models/employee.dart';
import '../../roles/role.dart';

class TeamManagement extends StatefulWidget {
  const TeamManagement({super.key});

  @override
  State<TeamManagement> createState() => _TeamManagementState();
}

class _TeamManagementState extends State<TeamManagement> {
  // Mock data - replace with actual data later
  final List<Employee> _employees = [
    Employee(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      phone: '1234567890',
      position: 'Senior Developer',
      department: 'Engineering',
      role: Role.employee,
      employmentType: EmploymentType.fullTime,
      workType: 'onsite',
      assignedProjects: ['1', '2'],
      reportingTo: 'Jane Manager',
      joiningDate: DateTime.now().subtract(const Duration(days: 365)),
    ),
    Employee(
      id: '2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      phone: '0987654321',
      position: 'Project Manager',
      department: 'Management',
      role: Role.admin,
      employmentType: EmploymentType.fullTime,
      workType: 'hybrid',
      assignedProjects: ['1', '3'],
      reportingTo: 'CEO',
      joiningDate: DateTime.now().subtract(const Duration(days: 730)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTeamStats(),
          const SizedBox(height: 24),
          _buildEmployeeList(),
        ],
      ),
    );
  }

  Widget _buildTeamStats() {
    return Row(
      children: [
        _buildStatCard(
          'Total Employees',
          _employees.length.toString(),
          Icons.people,
          Colors.blue,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          'Departments',
          _getUniqueDepartments().length.toString(),
          Icons.business,
          Colors.green,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          'Project Teams',
          _getUniqueProjects().length.toString(),
          Icons.groups,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeList() {
    return Expanded(
      child: Card(
        elevation: 2,
        child: ListView.builder(
          itemCount: _employees.length,
          itemBuilder: (context, index) {
            final employee = _employees[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(employee.name[0]),
              ),
              title: Text(employee.name),
              subtitle: Text('${employee.position} - ${employee.department}'),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'projects',
                    child: Text('View Projects'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
                onSelected: (value) => _handleEmployeeAction(value, employee),
              ),
              onTap: () => _showEmployeeDetails(employee),
            );
          },
        ),
      ),
    );
  }

  void _showEmployeeDetails(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(employee.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email', employee.email),
            _buildDetailRow('Phone', employee.phone),
            _buildDetailRow('Position', employee.position),
            _buildDetailRow('Department', employee.department),
            _buildDetailRow('Work Type', employee.workType),
            _buildDetailRow('Reports To', employee.reportingTo),
            _buildDetailRow(
              'Joining Date',
              employee.joiningDate.toString().split(' ')[0],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _handleEmployeeAction(String action, Employee employee) {
    switch (action) {
      case 'edit':
        // TODO: Implement edit employee
        break;
      case 'projects':
        _showEmployeeProjects(employee);
        break;
      case 'delete':
        _showDeleteConfirmation(employee);
        break;
    }
  }

  void _showEmployeeProjects(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${employee.name}\'s Projects'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: employee.assignedProjects.map((projectId) {
            return ListTile(
              leading: const Icon(Icons.folder),
              title: Text('Project $projectId'),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _employees.remove(employee);
              });
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Set<String> _getUniqueDepartments() {
    return _employees.map((e) => e.department).toSet();
  }

  Set<String> _getUniqueProjects() {
    return _employees
        .expand((e) => e.assignedProjects)
        .toSet();
  }
} 