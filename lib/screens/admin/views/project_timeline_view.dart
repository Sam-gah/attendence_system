import 'package:flutter/material.dart';
import '../../../models/project.dart';
import 'package:timeline_tile/timeline_tile.dart';

class ProjectTimelineView extends StatelessWidget {
  final List<Project> projects;

  const ProjectTimelineView({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    final sortedProjects = List<Project>.from(projects)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    return ListView.builder(
      itemCount: sortedProjects.length,
      itemBuilder: (context, index) {
        final project = sortedProjects[index];
        return TimelineTile(
          isFirst: index == 0,
          isLast: index == sortedProjects.length - 1,
          indicatorStyle: IndicatorStyle(
            width: 20,
            color: Colors.blue,
          ),
          endChild: Card(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildProgressBar(project),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Start: ${project.startDate.toString().split(' ')[0]}'),
                      Text('Due: ${project.deadline.toString().split(' ')[0]}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(Project project) {
    final now = DateTime.now();
    final totalDuration = project.deadline.difference(project.startDate);
    final elapsed = now.difference(project.startDate);
    final progress = elapsed.inDays / totalDuration.inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Progress: ${(progress * 100).toStringAsFixed(1)}%'),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0, 1),
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation(Colors.blueGrey),
        ),
      ],
    );
  }

  // Color _getStatusColor(ProjectStatus status) {
  //   switch (status) {
  //     case ProjectStatus.planning:
  //       return Colors.grey;
  //     case ProjectStatus.inProgress:
  //       return Colors.blue;
  //     case ProjectStatus.onHold:
  //       return Colors.orange;
  //     case ProjectStatus.completed:
  //       return Colors.green;
  //     case ProjectStatus.cancelled:
  //       return Colors.red;
  //   }
  // }
} 