import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import 'package:intl/intl.dart';

class AttendanceDetailsDialog extends StatefulWidget {
  final String employeeId;

  const AttendanceDetailsDialog({
    Key? key,
    required this.employeeId,
  }) : super(key: key);

  @override
  State<AttendanceDetailsDialog> createState() => _AttendanceDetailsDialogState();
}

class _AttendanceDetailsDialogState extends State<AttendanceDetailsDialog> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  List<Map<String, dynamic>> _attendanceRecords = [];
  
  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }
  
  Future<void> _loadAttendanceData() async {
    setState(() => _isLoading = true);
    
    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
      
      final querySnapshot = await firebaseService.timeEntries
          .where('employeeId', isEqualTo: widget.employeeId)
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .orderBy('timestamp', descending: true)
          .get();
          
      final records = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Format dates and times
        final timestamp = data['timestamp'] as Timestamp?;
        final dateTime = timestamp?.toDate() ?? DateTime.now();
        final formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
        final formattedTime = DateFormat('HH:mm:ss').format(dateTime);
        
        return {
          'id': doc.id,
          'date': formattedDate,
          'time': formattedTime,
          'action': data['action'] ?? 'unknown',
          'project': data['project'] ?? '',
          'task': data['task'] ?? '',
          'duration': data['duration'],
          'dateTime': dateTime,
        };
      }).toList();
      
      setState(() {
        _attendanceRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading attendance data: $e');
      setState(() => _isLoading = false);
    }
  }
  
  void _changeMonth(int monthOffset) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + monthOffset,
        1,
      );
    });
    _loadAttendanceData();
  }
  
  @override
  Widget build(BuildContext context) {
    final formattedMonth = DateFormat('MMMM yyyy').format(_selectedDate);
    
    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Attendance Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Month selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  formattedMonth,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Attendance data
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_attendanceRecords.isEmpty)
              const Center(child: Text('No attendance records found'))
            else
              Expanded(
                child: SingleChildScrollView(
                  child: _buildAttendanceTable(),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAttendanceTable() {
    // Group records by date
    final Map<String, List<Map<String, dynamic>>> recordsByDate = {};
    
    for (final record in _attendanceRecords) {
      final date = record['date'] as String;
      if (!recordsByDate.containsKey(date)) {
        recordsByDate[date] = [];
      }
      recordsByDate[date]!.add(record);
    }
    
    // Sort dates
    final sortedDates = recordsByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Latest dates first
    
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Date',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Time',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Activity',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Project',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Task',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Duration',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Records by date
        for (final date in sortedDates)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                child: Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              for (final record in recordsByDate[date]!)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: _getActivityColor(record['action']),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(date),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(record['time'] ?? ''),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(_formatActivity(record['action'])),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(record['project'] ?? ''),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(record['task'] ?? ''),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          record['duration'] != null
                              ? _formatDuration(record['duration'])
                              : '',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
  
  String _formatActivity(String action) {
    switch (action) {
      case 'clock_in':
        return 'Clock In';
      case 'clock_out':
        return 'Clock Out';
      case 'break_start':
        return 'Break Start';
      case 'break_end':
        return 'Break End';
      default:
        return action;
    }
  }
  
  String _formatDuration(dynamic duration) {
    if (duration == null) return '';
    
    try {
      final minutes = duration as int;
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      
      if (hours > 0) {
        return '$hours h $mins min';
      } else {
        return '$mins min';
      }
    } catch (e) {
      return duration.toString();
    }
  }
  
  Color _getActivityColor(String action) {
    switch (action) {
      case 'clock_in':
        return Colors.green.shade50;
      case 'clock_out':
        return Colors.red.shade50;
      case 'break_start':
        return Colors.orange.shade50;
      case 'break_end':
        return Colors.blue.shade50;
      default:
        return Colors.transparent;
    }
  }
} 