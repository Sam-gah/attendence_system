import 'package:flutter/material.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportSection(
            context,
            'Project Overview',
            [
              _buildMetricCard(
                context,
                'Project Completion Rate',
                '75%',
                Icons.trending_up,
                Colors.green,
                '+5% from last month',
              ),
              _buildMetricCard(
                context,
                'Average Project Duration',
                '45 days',
                Icons.timer,
                Colors.orange,
                '2 days faster than average',
              ),
              _buildMetricCard(
                context,
                'Active Projects',
                '8',
                Icons.work,
                Colors.blue,
                '3 due this month',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildReportSection(
            context,
            'Team Performance',
            [
              _buildMetricCard(
                context,
                'Team Utilization',
                '85%',
                Icons.groups,
                Colors.purple,
                'Optimal range',
              ),
              _buildMetricCard(
                context,
                'Tasks Completed',
                '156',
                Icons.task_alt,
                Colors.green,
                'This month',
              ),
              _buildMetricCard(
                context,
                'Overdue Tasks',
                '3',
                Icons.warning,
                Colors.red,
                'Needs attention',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildReportSection(
            context,
            'Resource Allocation',
            [
              _buildMetricCard(
                context,
                'Budget Utilization',
                '65%',
                Icons.account_balance,
                Colors.blue,
                'Under budget',
              ),
              _buildMetricCard(
                context,
                'Team Distribution',
                '4 teams',
                Icons.people,
                Colors.orange,
                'Across 8 projects',
              ),
              _buildMetricCard(
                context,
                'Resource Availability',
                '90%',
                Icons.person_outline,
                Colors.green,
                'Good availability',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection(
    BuildContext context,
    String title,
    List<Widget> metrics,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: metrics.map((metric) => Expanded(child: metric)).toList(),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(right: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 