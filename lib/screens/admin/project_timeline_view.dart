import 'package:flutter/material.dart';
import '../../models/project.dart';

class ProjectTimelineView extends StatelessWidget {
  final List<Project> projects;

  const ProjectTimelineView({
    super.key,
    required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                // Add timeline visualization here
                LinearProgressIndicator(
                  value: 0.7, // Replace with actual progress
                ),
                const SizedBox(height: 8),
                Text('Status: ${project.status}'),
              ],
            ),
          ),
        );
      },
    );
  }
} 