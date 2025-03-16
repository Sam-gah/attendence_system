import 'package:flutter/material.dart';
import '../../models/project.dart';

class ProjectCalendarView extends StatelessWidget {
  final List<Project> projects;

  const ProjectCalendarView({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendar header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  // Handle previous month
                },
              ),
              const Text('Current Month'), // Replace with actual month
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  // Handle next month
                },
              ),
            ],
          ),
        ),
        // Calendar grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 2.0,
              crossAxisSpacing: 2.0,
            ),
            itemCount: 42, // 6 weeks * 7 days
            itemBuilder: (context, index) {
              return Card(child: Center(child: Text('${index + 1}')));
            },
          ),
        ),
      ],
    );
  }
}
