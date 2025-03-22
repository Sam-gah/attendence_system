import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/project_controller.dart';
import '../models/project.dart';
import '../screens/project_detail_screen.dart';

class ProjectListView extends StatelessWidget {
  final bool isAdmin;

  ProjectListView({super.key, this.isAdmin = false}) {
    // Initialize the controller when the widget is created
    Get.put(ProjectController());
  }

  @override
  Widget build(BuildContext context) {
    return GetX<ProjectController>(
      builder: (controller) {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${controller.error.value}',
                  style: const TextStyle(color: Colors.red),
                ),
                ElevatedButton(
                  onPressed: controller.loadProjects,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.projects.isEmpty) {
          return const Center(
            child: Text('No projects found'),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadProjects,
          child: ListView.builder(
            itemCount: controller.projects.length,
            itemBuilder: (context, index) {
              final project = controller.projects[index];
              return ProjectCard(
                project: project,
                isAdmin: isAdmin,
                onTap: () => _showProjectDetails(context, project),
              );
            },
          ),
        );
      },
    );
  }

  void _showProjectDetails(BuildContext context, Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailScreen(
          project: project,
          isAdmin: isAdmin,
        ),
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final Project project;
  final bool isAdmin;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.isAdmin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
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
              const SizedBox(height: 8),
              Text(
                project.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
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
                  Text('Due: ${_formatDate(project.deadline)}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
} 