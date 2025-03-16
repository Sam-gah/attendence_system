import 'package:flutter/material.dart';
import '../../../models/project.dart';

class ProjectCalendarView extends StatelessWidget {
  final List<Project> projects;

  const ProjectCalendarView({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 42, // 6 weeks
      itemBuilder: (context, index) {
        final date = DateTime.now().subtract(
          Duration(days: DateTime.now().weekday - 1),
        ).add(Duration(days: index));
        
        final dayProjects = projects.where((p) =>
          p.deadline.year == date.year &&
          p.deadline.month == date.month &&
          p.deadline.day == date.day
        ).toList();

        return Card(
          color: dayProjects.isNotEmpty ? Colors.blue.shade50 : null,
          child: InkWell(
            onTap: () => _showDayProjects(context, date, dayProjects),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  date.day.toString(),
                  style: TextStyle(
                    fontWeight: date.month == DateTime.now().month
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (dayProjects.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDayProjects(BuildContext context, DateTime date, List<Project> projects) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return ListTile(
            title: Text(project.name),
            subtitle: Text('Due: ${project.deadline.toString().split(' ')[0]}'),
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(project.status),
              child: Text(project.name[0]),
            ),
          );
        },
      ),
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