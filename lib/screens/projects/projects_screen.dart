import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/project.dart';
import '../../providers/project_provider.dart';
import 'add_project_dialog.dart';


class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  bool _isGridView = true;
  String _searchQuery = '';
  ProjectStatus? _statusFilter;
  String _sortBy = 'deadline';

  @override
  void initState() {
    super.initState();
    // Initialize projects data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddProjectDialog,
          ),
        ],
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, child) {
          if (projectProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${projectProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      projectProvider.loadProjects();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (projectProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading projects...'),
                ],
              ),
            );
          }

          final filteredProjects = _filterProjects(projectProvider.projects);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildControls(),
                const SizedBox(height: 16),
                if (filteredProjects.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No projects found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create a new project to get started',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _showAddProjectDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Create Project'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: _isGridView 
                      ? _buildGridView(filteredProjects)
                      : _buildListView(filteredProjects),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search projects...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<ProjectStatus?>(
                value: _statusFilter,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: [
                  const DropdownMenuItem<ProjectStatus?>(
                    value: null,
                    child: Text('All'),
                  ),
                  ...ProjectStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.toString().split('.').last),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _statusFilter = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _sortBy,
                decoration: InputDecoration(
                  labelText: 'Sort By',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'deadline', child: Text('Deadline')),
                  DropdownMenuItem(value: 'progress', child: Text('Progress')),
                  DropdownMenuItem(value: 'budget', child: Text('Budget')),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortBy = value ?? 'deadline';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridView(List<Project> projects) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectCard(project);
      },
    );
  }

  Widget _buildListView(List<Project> projects) {
    return ListView.separated(
      itemCount: projects.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectListTile(project);
      },
    );
  }

  Widget _buildProjectCard(Project project) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showProjectDetails(project),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(project.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                project.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              LinearProgressIndicator(
                value: project.progress / 100,
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${project.progress}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Due ${_formatDate(project.deadline)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectListTile(Project project) {
    return Card(
      elevation: 2,
      child: ListTile(
        onTap: () => _showProjectDetails(project),
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Expanded(
              child: Text(project.name),
            ),
            _buildStatusChip(project.status),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(project.description),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: project.progress / 100,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progress: ${project.progress}%'),
                Text('Due: ${_formatDate(project.deadline)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ProjectStatus status) {
    Color color;
    switch (status) {
      case ProjectStatus.notStarted:
        color = Colors.grey;
        break;
      case ProjectStatus.planning:
        color = Colors.blue;
        break;
      case ProjectStatus.inProgress:
        color = Colors.orange;
        break;
      case ProjectStatus.completed:
        color = Colors.green;
        break;
      case ProjectStatus.onHold:
        color = Colors.purple;
        break;
      case ProjectStatus.cancelled:
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toString().split('.').last,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showProjectDetails(Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(project.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Status', project.status.toString().split('.').last),
              _buildDetailRow('Progress', '${project.progress}%'),
              _buildDetailRow('Client', project.clientName),
              _buildDetailRow('Budget', '\$${project.budget}'),
              _buildDetailRow('Project Manager', project.projectManager),
              _buildDetailRow('Start Date', _formatDate(project.startDate)),
              _buildDetailRow('Deadline', _formatDate(project.deadline)),
              const SizedBox(height: 16),
              Text(
                'Team Members',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Wrap(
                spacing: 8,
                children: project.teamMembers.map((member) {
                  return Chip(
                    label: Text(member),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Technologies',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Wrap(
                spacing: 8,
                children: project.technologies.map((tech) {
                  return Chip(
                    label: Text(tech),
                    backgroundColor: Colors.green.withOpacity(0.1),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Milestones',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              ...project.milestones.map((milestone) {
                return CheckboxListTile(
                  title: Text(milestone['title'] as String),
                  value: milestone['completed'] as bool,
                  onChanged: null,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement edit functionality
              Navigator.of(context).pop();
            },
            child: const Text('Edit'),
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<Project> _filterProjects(List<Project> projects) {
    return projects.where((project) {
      // Apply search filter
      if (_searchQuery.isNotEmpty &&
          !project.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      // Apply status filter
      if (_statusFilter != null && project.status != _statusFilter) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        switch (_sortBy) {
          case 'deadline':
            return a.deadline.compareTo(b.deadline);
          case 'progress':
            return b.progress.compareTo(a.progress);
          case 'budget':
            return b.budget.compareTo(a.budget);
          default:
            return a.deadline.compareTo(b.deadline);
        }
      });
  }

  void _showAddProjectDialog() {
    showDialog(
      context: context,
      builder: (context) => AddProjectDialog(
        onAdd: (project) {
          // Add the project using the ProjectProvider
          context.read<ProjectProvider>().addProject(project);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Project "${project.name}" created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }
}
