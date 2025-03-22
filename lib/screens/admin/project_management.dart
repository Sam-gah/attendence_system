import 'package:flutter/material.dart';
import '../../models/project.dart';
import '../../models/employee.dart';
import '../../roles/role.dart';
import './project_form_dialog.dart';
import 'team_management_dialog.dart';
import 'delete_confirmation_dialog.dart';
import 'milestone_timeline.dart';

class ProjectManagement extends StatefulWidget {
  final List<Employee> employees;

  const ProjectManagement({super.key, required this.employees});

  @override
  State<ProjectManagement> createState() => _ProjectManagementState();
}

class _ProjectManagementState extends State<ProjectManagement> {
  final List<Project> projects = [
    // Add mock projects here
  ];

  final _searchController = TextEditingController();
  ProjectStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddProjectDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProjectStats(),
              const SizedBox(height: 16),
              _buildSearchAndFilter(),
              const SizedBox(height: 16),
              _buildProjectList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatCard(
                    'Total Projects',
                    projects.length.toString(),
                    Icons.work,
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildStatCard(
                    'In Progress',
                    projects
                        .where((p) => p.status == ProjectStatus.inProgress)
                        .length
                        .toString(),
                    Icons.trending_up,
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildStatCard(
                    'On Hold',
                    projects
                        .where((p) => p.status == ProjectStatus.onHold)
                        .length
                        .toString(),
                    Icons.pause_circle,
                    Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildStatCard(
                    'Completed',
                    projects
                        .where((p) => p.status == ProjectStatus.completed)
                        .length
                        .toString(),
                    Icons.check_circle,
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Card(
          child: ExpansionTile(
            title: Text(project.name),
            subtitle: Text(project.status.toString().split('.').last),
            leading: _getProjectStatusIcon(project.status),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description: ${project.description}'),
                    Text('Client: ${project.clientName}'),
                    Text(
                      'Deadline: ${project.deadline.toString().split(' ')[0]}',
                    ),
                    Text('Budget: \$${project.budget.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _buildTeamSection(project),
                    const SizedBox(height: 8),
                    _buildProjectProgress(project),
                    const SizedBox(height: 16),
                    MilestoneTimeline(
                      project: project,
                      milestones: _getMilestonesFromProject(project),
                      onMilestoneUpdate:
                          (milestone) => _updateMilestone(project, milestone),
                    ),
                    const SizedBox(height: 8),
                    _buildActionButtons(project),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeamSection(Project project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Team Members',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 8,
          children:
              project.teamMembers.map((memberId) {
                final employee = widget.employees.firstWhere(
                  (e) => e.id == memberId,
                  orElse:
                      () => Employee(
                        id: memberId,
                        name: 'Unknown',
                        email: '',
                        phone: '',
                        position: '',
                        department: '',
                        role: Role.employee,
                        employmentType: EmploymentType.fullTime,
                        workType: '',
                        assignedProjects: [],
                        reportingTo: '',
                        joiningDate: DateTime.now(),
                      ),
                );
                return Chip(
                  avatar: CircleAvatar(child: Text(employee.name[0])),
                  label: Text(employee.name),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildProjectProgress(Project project) {
    final now = DateTime.now();
    final totalDuration = project.deadline.difference(project.startDate);
    final elapsed = now.difference(project.startDate);
    final progress = elapsed.inDays / totalDuration.inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Progress (${(progress * 100).toStringAsFixed(1)}%)'),
            Text('${elapsed.inDays} / ${totalDuration.inDays} days'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0, 1),
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation(
            progress > 0.9 ? Colors.red : Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Project project) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
          onPressed: () => _showEditProjectDialog(project),
        ),
        TextButton.icon(
          icon: const Icon(Icons.people),
          label: const Text('Manage Team'),
          onPressed: () => _showManageTeamDialog(project),
        ),
        TextButton.icon(
          icon: const Icon(Icons.delete),
          label: const Text('Delete'),
          onPressed: () => _showDeleteConfirmation(project),
        ),
      ],
    );
  }

  Widget _buildStatCard(
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

  Icon _getProjectStatusIcon(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.notStarted:
        return const Icon(Icons.schedule, color: Colors.grey);
      case ProjectStatus.planning:
        return const Icon(Icons.schedule, color: Colors.blue);
      case ProjectStatus.inProgress:
        return const Icon(Icons.trending_up, color: Colors.green);
      case ProjectStatus.onHold:
        return const Icon(Icons.pause_circle, color: Colors.orange);
      case ProjectStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.purple);
      case ProjectStatus.cancelled:
        return const Icon(Icons.cancel, color: Colors.red);
    }
  }

  void _showAddProjectDialog() {
    showDialog(
      context: context,
      builder:
          (context) => ProjectFormDialog(
            employees: widget.employees,
            onSubmit: (project) {
              // Add a sample milestone
              final milestones = [
                {
                  'id': 'MS${DateTime.now().millisecondsSinceEpoch}',
                  'title': 'Project Setup',
                  'description': 'Initial project setup and planning',
                  'dueDate':
                      project.startDate
                          .add(const Duration(days: 7))
                          .toIso8601String(),
                  'isCompleted': false,
                  'dependencies': [],
                  'budget': project.budget * 0.1,
                  'assignedMembers': [project.projectManager],
                  'status': 'pending',
                },
              ];

              setState(
                () => projects.add(project.copyWith(milestones: milestones)),
              );
            },
          ),
    );
  }

  void _showEditProjectDialog(Project project) {
    showDialog(
      context: context,
      builder:
          (context) => ProjectFormDialog(
            project: project,
            employees: widget.employees,
            onSubmit: (updatedProject) {
              setState(() {
                final index = projects.indexWhere((p) => p.id == project.id);
                if (index != -1) {
                  projects[index] = updatedProject;
                }
              });
            },
          ),
    );
  }

  void _showManageTeamDialog(Project project) {
    showDialog(
      context: context,
      builder:
          (context) => TeamManagementDialog(
            project: project,
            employees: widget.employees,
          ),
    ).then((selectedMembers) {
      if (selectedMembers != null) {
        setState(() {
          final index = projects.indexWhere((p) => p.id == project.id);
          if (index != -1) {
            projects[index] = project.copyWith(teamMembers: selectedMembers);
          }
        });
      }
    });
  }

  void _showDeleteConfirmation(Project project) {
    showDialog(
      context: context,
      builder:
          (context) => DeleteConfirmationDialog(
            title: 'Delete Project',
            message: 'Are you sure you want to delete ${project.name}?',
            onConfirm: () {
              setState(() => projects.remove(project));
            },
          ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search projects...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: _filterProjects,
              ),
            ),
            const SizedBox(width: 16),
            DropdownButton<ProjectStatus?>(
              value: _statusFilter,
              hint: const Text('Filter by status'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...ProjectStatus.values.map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.toString().split('.').last),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _statusFilter = value);
                _filterProjects(_searchController.text);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _filterProjects(String query) {
    // Implement project filtering logic here
  }

  List<Milestone> _getMilestonesFromProject(Project project) {
    return project.milestones
        .map(
          (m) => Milestone(
            id: m['id'] as String,
            title: m['title'] as String,
            description: m['description'] as String,
            dueDate: DateTime.parse(m['dueDate'] as String),
            isCompleted: m['isCompleted'] as bool? ?? false,
            dependencies: List<String>.from(m['dependencies'] as List? ?? []),
            budget: (m['budget'] as num?)?.toDouble() ?? 0.0,
            assignedMembers: List<String>.from(
              m['assignedMembers'] as List? ?? [],
            ),
            status: MilestoneStatus.values.firstWhere(
              (s) =>
                  s.toString() == 'MilestoneStatus.${m['status'] ?? 'pending'}',
              orElse: () => MilestoneStatus.pending,
            ),
          ),
        )
        .toList();
  }

  void _updateMilestone(Project project, Milestone updatedMilestone) {
    setState(() {
      final projectIndex = projects.indexWhere((p) => p.id == project.id);
      if (projectIndex != -1) {
        final milestones = List<Map<String, dynamic>>.from(project.milestones);
        final milestoneIndex = milestones.indexWhere(
          (m) => m['id'] == updatedMilestone.id,
        );

        if (milestoneIndex != -1) {
          milestones[milestoneIndex] = {
            'id': updatedMilestone.id,
            'title': updatedMilestone.title,
            'description': updatedMilestone.description,
            'dueDate': updatedMilestone.dueDate.toIso8601String(),
            'isCompleted': updatedMilestone.isCompleted,
            'dependencies': updatedMilestone.dependencies,
            'budget': updatedMilestone.budget,
            'assignedMembers': updatedMilestone.assignedMembers,
            'status': updatedMilestone.status.toString().split('.').last,
          };

          projects[projectIndex] = project.copyWith(milestones: milestones);
        }
      }
    });
  }
}
