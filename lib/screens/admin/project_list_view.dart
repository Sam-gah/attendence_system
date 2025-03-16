import 'package:flutter/material.dart';
import '../../models/project.dart';

class ProjectListView extends StatelessWidget {
  final List<Project> projects;

  const ProjectListView({
    super.key,
    required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return ListTile(
          leading: const Icon(Icons.folder),
          title: Text(project.name),
          subtitle: Text(project.status.toString()),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
            onSelected: (value) {
              // Handle menu item selection
            },
          ),
        );
      },
    );
  }
} 