import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/time_tracking_service.dart';
import '../../models/employee.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final String employeeId;
  final Employee employee;

  const AttendanceHistoryScreen({
    super.key,
    required this.employeeId,
    required this.employee,
  });

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final _timeTrackingService = TimeTrackingService();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance History')),
      body: Column(
        children: [
          _buildProfileHeader(),
          _buildDateNavigation(),
          Expanded(child: _buildDailyAttendance()),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(radius: 30, child: Text(widget.employee.name[0])),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.employee.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        widget.employee.role.toString().split('.').last,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        'Department: ${widget.employee.department}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            FutureBuilder<Map<String, dynamic>>(
              future: _getEmployeeStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final stats = snapshot.data ?? {
                  'totalHours': 0,
                  'tasksCompleted': 0,
                  'daysAbsent': 0,
                  'productivity': 0,
                };
                
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Total Hours', '${stats['totalHours']} hrs', Icons.access_time),
                        _buildStatItem('Tasks Done', '${stats['tasksCompleted']}', Icons.task_alt),
                        _buildStatItem('Days Absent', '${stats['daysAbsent']}', Icons.event_busy),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Productivity', style: Theme.of(context).textTheme.bodyLarge),
                              Text('${stats['productivity']}%', style: Theme.of(context).textTheme.bodyLarge),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: stats['productivity'] / 100,
                            minHeight: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              stats['productivity'] > 75
                                  ? Colors.green
                                  : stats['productivity'] > 50
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          TextButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
            child: Text(
              DateFormat('MMMM dd, yyyy').format(_selectedDate),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed:
                _selectedDate.isBefore(DateTime.now())
                    ? () {
                      setState(() {
                        _selectedDate = _selectedDate.add(
                          const Duration(days: 1),
                        );
                      });
                    }
                    : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyAttendance() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _timeTrackingService.getDailyRecords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No records for ${DateFormat('MMMM dd').format(_selectedDate)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        final records =
            snapshot.data!.where((record) {
              final date = DateTime.parse(record['timestamp']);
              return DateUtils.isSameDay(date, _selectedDate);
            }).toList();

        return Column(
          children: [
            _buildProjectAnalytics(records),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  return _buildTimelineCard(records[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProjectAnalytics(List<Map<String, dynamic>> records) {
    // Group records by project
    final projectTimes = <String, Duration>{};
    String? currentProject;
    DateTime? projectStart;

    for (final record in records) {
      final timestamp = DateTime.parse(record['timestamp']);

      if (record['action'] == 'clock_in') {
        currentProject = record['project'];
        projectStart = timestamp;
      } else if (record['action'] == 'clock_out' &&
          currentProject != null &&
          projectStart != null) {
        final duration = timestamp.difference(projectStart);
        projectTimes[currentProject] =
            (projectTimes[currentProject] ?? Duration.zero) + duration;
        currentProject = null;
        projectStart = null;
      }
    }

    // Calculate total minutes for percentage calculation
    final totalMinutes = projectTimes.values.fold<int>(
      0,
      (sum, duration) => sum + duration.inMinutes,
    );

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Time Distribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...projectTimes.entries.map((entry) {
              // Calculate percentage using total minutes
              final percentage =
                  totalMinutes > 0
                      ? (entry.value.inMinutes / totalMinutes) * 100
                      : 0.0;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(flex: 3, child: Text(entry.key)),
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[200],
                            ),
                            Text(
                              '${_formatDuration(entry.value)} (${percentage.toStringAsFixed(1)}%)',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(Map<String, dynamic> record) {
    final timestamp = DateTime.parse(record['timestamp']);
    final time = DateFormat('HH:mm').format(timestamp);
    final action = record['action'] as String;
    
    // Extract project and task information if available
    final String project = record['project'] as String? ?? 'Not specified';
    final String task = record['task'] as String? ?? 'Not specified';
    final String? taskLink = record['taskLink'] as String?;
    final String? duration = record['duration'] != null ? '${record['duration']} min' : null;
    
    // Determine icon and color based on action type
    IconData actionIcon;
    Color iconColor;
    String actionText;
    
    switch (action) {
      case 'clock_in':
        actionIcon = Icons.login;
        iconColor = Colors.green;
        actionText = 'Started working';
        break;
      case 'clock_out':
        actionIcon = Icons.logout;
        iconColor = Colors.red;
        actionText = 'Finished working';
        break;
      case 'break_start':
        actionIcon = Icons.coffee;
        iconColor = Colors.orange;
        actionText = 'Started break';
        break;
      case 'break_end':
        actionIcon = Icons.coffee_outlined;
        iconColor = Colors.blue;
        actionText = 'Ended break';
        break;
      default:
        actionIcon = Icons.device_unknown;
        iconColor = Colors.grey;
        actionText = action;
    }
    
    // Determine priority color if available
    final String priority = record['priority'] as String? ?? 'Medium';
    final Color priorityColor = _getPriorityColor(priority);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Header with time and action
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(actionIcon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(actionText),
                const Spacer(),
                if (duration != null)
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(duration),
                    ],
                  ),
              ],
            ),
          ),
          
          // Project and task details
          if (action == 'clock_in' || action == 'clock_out')
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project
                  Row(
                    children: [
                      const Icon(Icons.folder_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Project:',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          project,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Task with priority indicator
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.task_alt, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Task:',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(right: 8, top: 4),
                              decoration: BoxDecoration(
                                color: priorityColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                task,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Task link if available
                  if (taskLink != null && taskLink.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: InkWell(
                        onTap: () {
                          // TODO: Open task link
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.link, size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                taskLink,
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.blue;
      case 'medium':
        return Colors.green;
      case 'high':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
  
  Future<Map<String, dynamic>> _getEmployeeStats() async {
    try {
      // This would normally come from an API or database
      // For now, we'll create some mock data
      
      // Get time tracking data from the service
      final totalTimeToday = await _timeTrackingService.getTotalTimeToday();
      final dailyRecords = await _timeTrackingService.getDailyRecords();
      
      // Count unique tasks
      final uniqueTasks = <String>{};
      for (final record in dailyRecords) {
        if (record.containsKey('task') && record['task'] != null) {
          uniqueTasks.add(record['task'] as String);
        }
      }
      
      // Calculate productivity (based on time worked vs expected 8 hours)
      final totalMinutesWorked = totalTimeToday.inMinutes;
      final expectedMinutes = 8 * 60; // 8 hours expected workday
      final productivity = (totalMinutesWorked / expectedMinutes * 100).clamp(0, 100).toInt();
      
      return {
        'totalHours': (totalTimeToday.inMinutes / 60).ceil(),
        'tasksCompleted': uniqueTasks.length,
        'daysAbsent': 2, // Mock data for demonstration
        'productivity': productivity,
      };
    } catch (e) {
      print('Error getting employee stats: $e');
      return {
        'totalHours': 0,
        'tasksCompleted': 0,
        'daysAbsent': 0,
        'productivity': 0,
      };
    }
  }
}
