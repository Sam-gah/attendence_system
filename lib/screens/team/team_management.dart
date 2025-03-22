import 'package:flutter/material.dart';
import '../../models/employee.dart';
import 'add_member_dialog.dart';

class TeamManagement extends StatefulWidget {
  const TeamManagement({super.key});

  @override
  State<TeamManagement> createState() => _TeamManagementState();
}

class _TeamManagementState extends State<TeamManagement> {
  final List<Employee> _employees = []; // This would typically be fetched from a service
  String _searchQuery = '';
  String _departmentFilter = 'All';
  String _sortBy = 'name';

  final List<String> _departments = [
    'All',
    'Engineering',
    'Design',
    'Product',
    'Marketing',
    'Sales',
    'HR',
    'Finance',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddMemberDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _buildEmployeeList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search employees...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _departmentFilter,
            items: _departments.map((department) {
              return DropdownMenuItem(
                value: department,
                child: Text(department),
              );
            }).toList(),
            onChanged: (value) => setState(() => _departmentFilter = value!),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _sortBy,
            items: const [
              DropdownMenuItem(value: 'name', child: Text('Name')),
              DropdownMenuItem(value: 'department', child: Text('Department')),
              DropdownMenuItem(value: 'role', child: Text('Role')),
            ],
            onChanged: (value) => setState(() => _sortBy = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeList() {
    final filteredEmployees = _filterEmployees();
    
    if (filteredEmployees.isEmpty) {
      return const Center(
        child: Text('No employees found'),
      );
    }

    return ListView.builder(
      itemCount: filteredEmployees.length,
      itemBuilder: (context, index) {
        final employee = filteredEmployees[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(employee.name[0]),
            ),
            title: Text(employee.name),
            subtitle: Text('${employee.position} - ${employee.department}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditMemberDialog(employee),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmation(employee),
                ),
              ],
            ),
            onTap: () => _showEmployeeDetails(employee),
          ),
        );
      },
    );
  }

  List<Employee> _filterEmployees() {
    var filtered = List<Employee>.from(_employees);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((employee) {
        return employee.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            employee.position.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            employee.department.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply department filter
    if (_departmentFilter != 'All') {
      filtered = filtered.where((employee) => employee.department == _departmentFilter).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return a.name.compareTo(b.name);
        case 'department':
          return a.department.compareTo(b.department);
        case 'role':
          return a.role.toString().compareTo(b.role.toString());
        default:
          return 0;
      }
    });

    return filtered;
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AddMemberDialog(
        onAdd: (employee) {
          setState(() {
            _employees.add(employee);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${employee.name} added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _showEditMemberDialog(Employee employee) {
    // TODO: Implement edit functionality
  }

  void _showDeleteConfirmation(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _employees.remove(employee);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${employee.name} deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
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
            Text('Email: ${employee.email}'),
            Text('Phone: ${employee.phone}'),
            Text('Position: ${employee.position}'),
            Text('Department: ${employee.department}'),
            Text('Role: ${employee.role.toString().split('.').last}'),
            Text('Employment Type: ${employee.employmentType.toString().split('.').last}'),
            Text('Work Type: ${employee.workType}'),
            Text('Reporting To: ${employee.reportingTo}'),
            Text('Joining Date: ${employee.joiningDate.toString().split(' ')[0]}'),
            const SizedBox(height: 8),
            const Text('Assigned Projects:'),
            Wrap(
              spacing: 8,
              children: employee.assignedProjects.map((project) => Chip(
                label: Text(project),
              )).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 