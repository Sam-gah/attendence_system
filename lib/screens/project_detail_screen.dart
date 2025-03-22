import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/project.dart';
import '../controllers/project_controller.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Project project;
  final bool isAdmin;

  const ProjectDetailScreen({
    super.key,
    required this.project,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: isAdmin
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editProject(context),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteProject(context),
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusSection(),
              const SizedBox(height: 16),
              _buildDetailsSection(context),
              const SizedBox(height: 16),
              _buildProgressSection(),
              const SizedBox(height: 16),
              _buildTeamSection(),
              const SizedBox(height: 16),
              _buildMilestonesSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _addMilestone(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: project.progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(project.statusColor),
                  ),
                  const SizedBox(height: 4),
                  Text('${(project.progress * 100).toInt()}% Complete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Client', project.clientName),
            _buildDetailRow('Start Date', _formatDate(project.startDate)),
            _buildDetailRow('Deadline', _formatDate(project.deadline)),
            _buildDetailRow(
              'Budget',
              '\$${project.budget.toStringAsFixed(2)}',
            ),
            _buildDetailRow('Manager', project.projectManager),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTeamSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Team Members',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: project.teamMembers.map((member) {
                return Chip(
                  label: Text(member),
                  backgroundColor: Colors.blue[100],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestonesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Milestones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: project.milestones.length,
              itemBuilder: (context, index) {
                final milestone = project.milestones[index];
                return ListTile(
                  title: Text(milestone['title']),
                  subtitle: Text(milestone['description']),
                  trailing: Text(_formatDate(DateTime.parse(milestone['dueDate']))),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: project.progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(project.statusColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Current Progress: ${(project.progress * 100).toInt()}%',
              style: const TextStyle(fontSize: 16),
            ),
            if (project.endDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Completed on: ${_formatDate(project.endDate!)}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _editProject(BuildContext context) {
    // TODO: Implement edit project
  }

  void _deleteProject(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure you want to delete this project?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.find<ProjectController>().deleteProject(project.id);
              Navigator.pop(context); // Go back to projects list
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _addMilestone(BuildContext context) {
    // TODO: Implement add milestone
  }
} 