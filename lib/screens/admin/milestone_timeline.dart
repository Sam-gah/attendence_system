import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../models/project.dart';

class MilestoneTimeline extends StatelessWidget {
  final Project project;
  final List<Milestone> milestones;
  final Function(Milestone) onMilestoneUpdate;

  const MilestoneTimeline({
    super.key,
    required this.project,
    required this.milestones,
    required this.onMilestoneUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Timeline',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...List.generate(milestones.length, (index) {
          final milestone = milestones[index];
          return TimelineTile(
            isFirst: index == 0,
            isLast: index == milestones.length - 1,
            indicatorStyle: IndicatorStyle(
              width: 25,
              color: _getMilestoneColor(milestone.status),
              iconStyle: IconStyle(
                color: Colors.white,
                iconData: _getMilestoneIcon(milestone.status),
              ),
            ),
            beforeLineStyle: LineStyle(
              color: milestone.status == MilestoneStatus.completed
                  ? Colors.green
                  : Colors.grey.shade300,
            ),
            endChild: _buildMilestoneCard(context, milestone),
          );
        }),
      ],
    );
  }

  Widget _buildMilestoneCard(BuildContext context, Milestone milestone) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    milestone.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                PopupMenuButton<MilestoneStatus>(
                  initialValue: milestone.status,
                  onSelected: (status) {
                    onMilestoneUpdate(milestone.copyWith(status: status));
                  },
                  itemBuilder: (context) => MilestoneStatus.values
                      .map((status) => PopupMenuItem(
                            value: status,
                            child: Text(status.toString().split('.').last),
                          ))
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(milestone.description),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Due: ${milestone.dueDate.toString().split(' ')[0]}',
                  style: TextStyle(
                    color: milestone.dueDate.isBefore(DateTime.now())
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
                Text(
                  'Budget: \$${milestone.budget.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (milestone.dependencies.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Dependencies:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children: milestone.dependencies
                    .map((dep) => Chip(
                          label: Text(
                            milestones
                                .firstWhere((m) => m.id == dep)
                                .title
                                .split(' ')[0],
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getMilestoneColor(MilestoneStatus status) {
    switch (status) {
      case MilestoneStatus.pending:
        return Colors.grey;
      case MilestoneStatus.inProgress:
        return Colors.blue;
      case MilestoneStatus.completed:
        return Colors.green;
      case MilestoneStatus.delayed:
        return Colors.orange;
      case MilestoneStatus.blocked:
        return Colors.red;
    }
  }

  IconData _getMilestoneIcon(MilestoneStatus status) {
    switch (status) {
      case MilestoneStatus.pending:
        return Icons.schedule;
      case MilestoneStatus.inProgress:
        return Icons.trending_up;
      case MilestoneStatus.completed:
        return Icons.check;
      case MilestoneStatus.delayed:
        return Icons.warning;
      case MilestoneStatus.blocked:
        return Icons.block;
    }
  }
} 