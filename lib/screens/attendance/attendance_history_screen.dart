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
            FutureBuilder<Duration>(
              future: _timeTrackingService.getTotalTimeToday(),
              builder: (context, snapshot) {
                final totalHours = snapshot.data?.inHours ?? 0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Today', '$totalHours hrs'),
                    _buildStatItem('This Week', '${totalHours * 5} hrs'),
                    _buildStatItem('This Month', '${totalHours * 20} hrs'),
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
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(Map<String, dynamic> record) {
    final timestamp = DateTime.parse(record['timestamp']);
    final action = record['action'];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getActionColor(action),
            shape: BoxShape.circle,
          ),
          child: Icon(_getActionIcon(action), color: Colors.white),
        ),
        title: Text(action),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('HH:mm').format(timestamp)),
            if (record['project'] != null) ...[
              const SizedBox(height: 4),
              Text(
                'Project: ${record['project']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            if (record['task'] != null) ...[
              const SizedBox(height: 2),
              Text('Task: ${record['task']}'),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'clock_in':
        return Colors.green;
      case 'clock_out':
        return Colors.red;
      case 'break_start':
        return Colors.orange;
      case 'break_end':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'clock_in':
        return Icons.login;
      case 'clock_out':
        return Icons.logout;
      case 'break_start':
        return Icons.coffee;
      case 'break_end':
        return Icons.coffee_outlined;
      default:
        return Icons.access_time;
    }
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
