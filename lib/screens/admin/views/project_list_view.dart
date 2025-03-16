import 'package:flutter/material.dart';
import '../../../models/project.dart';

class ProjectListView extends StatelessWidget {
  final List<Project> projects;

  const ProjectListView({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: _getStatusIcon(project.status),
            title: Text(project.name),
            subtitle: Text(
              '${project.clientName} • Due: ${project.deadline.toString().split(' ')[0]}',
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text('${project.teamMembers.length} members'),
                  backgroundColor: Colors.blue.shade100,
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showProjectMenu(context, project),
                ),
              ],
            ),
            onTap: () => _openProjectDetails(context, project),
          ),
        );
      },
    );
  }

  Widget _getStatusIcon(ProjectStatus status) {
    final color = _getStatusColor(status);
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(Icons.lens, color: color, size: 12),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return Colors.grey;
      case ProjectStatus.inProgress:
        return Colors.blue;
      case ProjectStatus.onHold:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.green;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }
} 