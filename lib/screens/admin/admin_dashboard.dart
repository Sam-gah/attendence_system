import 'package:flutter/material.dart';
import '../../models/employee.dart';
import '../../models/project.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'employee_form_dialog.dart';
import 'project_management.dart';
import 'project_dashboard.dart';
import 'delete_confirmation_dialog.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Initialize with mock data
  final List<Employee> employees = [
    Employee(
      id: 'EMP001',
      name: 'John Doe',
      email: 'john@bichitras.com',
      phone: '1234567890',
      position: 'Senior Developer',
      role: EmployeeRole.Developer,
      department: 'Engineering',
      designation: 'Senior Developer',
      employmentType: EmploymentType.fullTime,
      workType: 'hybrid',
      assignedProjects: ['PRJ001'],
      reportingTo: 'ADMIN',
      joiningDate: DateTime(2023, 1, 1),
    ),
    // Add more mock employees if needed
  ];

  // Add this with your other state variables
  final List<Project> projects = [
    Project(
      id: 'PRJ001',
      name: 'Website Redesign',
      description: 'Redesign company website with modern UI/UX',
      startDate: DateTime.now(),
      deadline: DateTime.now().add(const Duration(days: 30)),
      status: ProjectStatus.inProgress,
      clientName: 'Acme Corp',
      teamMembers: ['EMP001', 'EMP002'],
      projectManager: 'EMP001',
      budget: 15000,
      technologies: ['React', 'Node.js'],
      milestones: [],
    ),
    // Add more mock projects as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnalyticsDashboard(),
              const SizedBox(height: 16),
              _buildEmployeeManagement(),
              const SizedBox(height: 16),
              _buildProjectManagement(),
              const SizedBox(height: 16),
              _buildAttendanceOverview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeManagement() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text('Employee Management'),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddEmployeeDialog(context),
            ),
          ),
          const Divider(),
          _buildEmployeeList(),
        ],
      ),
    );
  }

  Widget _buildEmployeeList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        return ListTile(
          leading: CircleAvatar(child: Text(employee.name[0])),
          title: Text(employee.name),
          subtitle: Text('${employee.role} - ${employee.department}'),
          onTap: () => _showEmployeeDetails(context, employee),
          trailing: PopupMenuButton(
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                    value: 'view_attendance',
                    child: Text('View Attendance'),
                  ),
                  const PopupMenuItem(
                    value: 'assign_project',
                    child: Text('Assign Project'),
                  ),
                ],
            onSelected: (value) => _handleEmployeeAction(value, employee),
          ),
        );
      },
    );
  }

  void _showAddEmployeeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => EmployeeFormDialog(
            allEmployees: employees,
            onSubmit: (Employee employee) {
              setState(() {
                employees.add(employee);
              });
            },
          ),
    );
  }

  void _showEditEmployeeDialog(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder:
          (context) => EmployeeFormDialog(
            employee: employee,
            allEmployees: employees,
            onSubmit: (Employee updatedEmployee) {
              setState(() {
                final index = employees.indexWhere((e) => e.id == employee.id);
                if (index != -1) {
                  employees[index] = updatedEmployee;
                }
              });
            },
          ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      await AuthService().logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _handleEmployeeAction(String value, Employee employee) {
    switch (value) {
      case 'edit':
        _showEditEmployeeDialog(context, employee);
        break;
      case 'view_attendance':
        _showAttendanceHistory(employee);
        break;
      case 'assign_project':
        _showAssignProjectDialog(employee);
        break;
      case 'delete':
        _showDeleteConfirmation(context, employee);
        break;
    }
  }

  Widget _buildAnalyticsDashboard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildAnalyticCard(
                    'Total Employees',
                    '45',
                    Icons.people,
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildAnalyticCard(
                    'Active Projects',
                    '12',
                    Icons.work,
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildAnalyticCard(
                    'Today\'s Attendance',
                    '92%',
                    Icons.timer,
                    Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildAnalyticCard(
                    'On Leave',
                    '3',
                    Icons.beach_access,
                    Colors.purple,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: _buildAttendanceChart(),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: _buildProjectProgress(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      width: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.bodyLarge),
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceChart() {
    // Implementation of _buildAttendanceChart method
    return Container(); // Placeholder, actual implementation needed
  }

  Widget _buildProjectProgress() {
    // Implementation of _buildProjectProgress method
    return Container(); // Placeholder, actual implementation needed
  }

  Widget _buildAttendanceOverview() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text('Today\'s Attendance'),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _exportAttendanceReport(),
            ),
          ),
          const Divider(),
          _buildAttendanceList(),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    // Implementation of _buildAttendanceList method
    return Container(); // Placeholder, actual implementation needed
  }

  Future<void> _exportAttendanceReport() {
    // Implementation of _exportAttendanceReport method
    return Future.value(); // Placeholder, actual implementation needed
  }

  Widget _buildProjectManagement() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text('Project Management'),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProjectManagement(employees: employees),
                    ),
                  ),
            ),
          ),
          const Divider(),
          _buildProjectList(),
        ],
      ),
    );
  }

  Widget _buildProjectList() {
    // Get first 5 projects or all if less than 5
    final displayProjects = projects.take(5).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayProjects.length + 1, // +1 for "View All" button
      itemBuilder: (context, index) {
        if (index == displayProjects.length) {
          return ListTile(
            title: const Text('View All Projects'),
            trailing: const Icon(Icons.arrow_forward),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ProjectDashboard(
                          projects: projects, // Pass the full projects list
                          employees: employees, // Pass the employees list
                        ),
                  ),
                ),
          );
        }

        final project = displayProjects[index];
        return ListTile(
          title: Text(project.name),
          subtitle: Text(
            'Due: ${project.deadline.toString().split(' ')[0]} • ${project.status.toString().split('.').last}',
          ),
          trailing: Wrap(
            spacing: 8,
            children: [
              Text('${project.teamMembers.length} members'),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ProjectDashboard(
                        projects: projects, // Pass the full projects list
                        employees: employees, // Pass the employees list
                      ),
                ),
              ),
        );
      },
    );
  }

  void _showEmployeeDetails(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        child: Text(
                          employee.name[0],
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employee.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(employee.designation),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildDetailRow('Email', employee.email),
                  _buildDetailRow('Phone', employee.phone),
                  _buildDetailRow('Department', employee.department),
                  _buildDetailRow(
                    'Role',
                    employee.role.toString().split('.').last,
                  ),
                  _buildDetailRow(
                    'Employment',
                    employee.employmentType.toString().split('.').last,
                  ),
                  _buildDetailRow('Work Type', employee.workType),
                  const Divider(height: 32),
                  Text(
                    'Assigned Projects',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildAssignedProjects(employee),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditEmployeeDialog(context, employee);
                        },
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
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

  Widget _buildAssignedProjects(Employee employee) {
    final assignedProjects =
        projects
            .where((p) => employee.assignedProjects.contains(p.id))
            .toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          assignedProjects.map((project) {
            return Chip(
              label: Text(project.name),
              backgroundColor: _getStatusColor(project.status).withOpacity(0.2),
              deleteIcon: const Icon(Icons.remove_circle_outline, size: 18),
              onDeleted: () => _removeProjectAssignment(employee, project),
            );
          }).toList(),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    // Implementation of _getStatusColor method
    return Colors.black; // Placeholder, actual implementation needed
  }

  void _removeProjectAssignment(Employee employee, Project project) {
    setState(() {
      employee.assignedProjects.remove(project.id);
    });
  }

  void _showAssignProjectDialog(Employee employee) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Assign Project'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Select projects for ${employee.name}'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        projects.map((project) {
                          final isAssigned = employee.assignedProjects.contains(
                            project.id,
                          );
                          return FilterChip(
                            label: Text(project.name),
                            selected: isAssigned,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  employee.assignedProjects.add(project.id);
                                } else {
                                  employee.assignedProjects.remove(project.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
    );
  }

  void _showAttendanceHistory(Employee employee) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${employee.name}\'s Attendance History',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  // Add attendance history list here
                  const Text('Attendance history will be displayed here'),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder:
          (context) => DeleteConfirmationDialog(
            title: 'Delete Employee',
            message: 'Are you sure you want to delete ${employee.name}?',
            onConfirm: () {
              setState(() {
                employees.remove(employee);
              });
            },
          ),
    );
  }
}
