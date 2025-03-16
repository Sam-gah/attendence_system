import 'package:flutter/material.dart';
import '../../models/project.dart';

class ProjectBoardView extends StatelessWidget {
  final List<Project> projects;

  const ProjectBoardView({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(project.name),
            subtitle: Text(project.status.toString()),
            // Add more project details as needed
          ),
        );
      },
    );
  }
}
