import 'package:flutter/material.dart';
import '../../models/project.dart';

class UserProjectsView extends StatelessWidget {
  final String userId; // To filter projects assigned to this user

  const UserProjectsView({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
      ),
      body: FutureBuilder<List<Project>>(
        future: _getUserProjects(userId), // You'll need to implement this
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No projects assigned yet'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final project = snapshot.data![index];
              return ProjectCard(project: project);
            },
          );
        },
      ),
    );
  }

  Future<List<Project>> _getUserProjects(String userId) async {
    // TODO: Implement this method to fetch projects where teamMembers contains userId
    // This should come from your project service
    return [];
  }
}

class ProjectCard extends StatelessWidget {
  final Project project;

  const ProjectCard({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailView(project: project),
            ),
          );
        },
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
              Text(project.description),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: project.progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(project.statusColor),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progress: ${(project.progress * 100).toInt()}%'),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: project.statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      project.statusText,
                      style: TextStyle(color: project.statusColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProjectDetailView extends StatelessWidget {
  final Project project;

  const ProjectDetailView({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text('Description: ${project.description}'),
                    const SizedBox(height: 8),
                    Text('Start Date: ${_formatDate(project.startDate)}'),
                    const SizedBox(height: 8),
                    Text('Deadline: ${_formatDate(project.deadline)}'),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: project.progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(project.statusColor),
                    ),
                    const SizedBox(height: 8),
                    Text('Progress: ${(project.progress * 100).toInt()}%'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Add more sections like Milestones, Tasks, etc.
            _buildMilestonesSection(context),
            const SizedBox(height: 16),
            _buildUpdateProgressButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestonesSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Milestones',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Add milestone list here
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateProgressButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // TODO: Implement progress update dialog
      },
      child: const Text('Update Progress'),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
} 