import 'package:flutter/material.dart';
import '../../../models/project.dart';

class ProjectBoardView extends StatelessWidget {
  final List<Project> projects;

  const ProjectBoardView({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ProjectStatus.values.map((status) {
          final statusProjects = projects.where((p) => p.status == status).toList();
          return Container(
            width: 300,
            margin: const EdgeInsets.all(8),
            child: Card(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          status.toString().split('.').last,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Chip(label: Text(statusProjects.length.toString())),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: statusProjects.length,
                      itemBuilder: (context, index) {
                        final project = statusProjects[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(project.name),
                            subtitle: Text(
                              'Due: ${project.deadline.toString().split(' ')[0]}',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
} 