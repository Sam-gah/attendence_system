import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TimeTrackingService {
  static const String _clockInKey = 'clock_in_time';
  static const String _totalTimeKey = 'total_time_today';
  static const String _breakStartKey = 'break_start_time';
  static const String _totalBreakTimeKey = 'total_break_time';
  static const String _dailyRecordsKey = 'daily_time_records';
  static const Duration standardWorkDay = Duration(hours: 8);

  // Clock in/out methods
  Future<void> clockIn({required String project, required String task}) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setBool('is_working', true);
    await prefs.setString('clock_in_time', now.toIso8601String());
    await prefs.setString('current_project', project);
    await prefs.setString('current_task', task);

    // Save to attendance record
    final records = await getDailyRecords();
    records.add({
      'timestamp': now.toIso8601String(),
      'action': 'clock_in',
      'project': project,
      'task': task,
    });
    await prefs.setStringList(
      'attendance_records',
      records.map((r) => jsonEncode(r)).toList(),
    );

    // Initialize break time for the day
    await prefs.setInt(_totalBreakTimeKey, 0);

    // Add record to daily records
    await _addDailyRecord('clock_in', now);
  }

  Future<void> clockOut() async {
    final prefs = await SharedPreferences.getInstance();
    final clockInStr = prefs.getString(_clockInKey);
    final now = DateTime.now();

    if (clockInStr != null) {
      final clockIn = DateTime.parse(clockInStr);
      final duration = now.difference(clockIn);

      // Subtract break time from total duration
      final breakMinutes = prefs.getInt(_totalBreakTimeKey) ?? 0;
      final workMinutes = duration.inMinutes - breakMinutes;

      // Add to total time
      final totalMinutes = prefs.getInt(_totalTimeKey) ?? 0;
      await prefs.setInt(_totalTimeKey, totalMinutes + workMinutes);

      // Clear clock in and break times
      await prefs.remove(_clockInKey);
      await prefs.remove(_breakStartKey);
      await prefs.remove(_totalBreakTimeKey);

      // Add record to daily records
      await _addDailyRecord('clock_out', now);
    }
  }

  // Break tracking methods
  Future<void> startBreak() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString(_breakStartKey, now.toIso8601String());
    await _addDailyRecord('break_start', now);
  }

  Future<void> endBreak() async {
    final prefs = await SharedPreferences.getInstance();
    final breakStartStr = prefs.getString(_breakStartKey);

    if (breakStartStr != null) {
      final breakStart = DateTime.parse(breakStartStr);
      final now = DateTime.now();
      final breakDuration = now.difference(breakStart);

      // Add to total break time
      final totalBreakMinutes = prefs.getInt(_totalBreakTimeKey) ?? 0;
      await prefs.setInt(
        _totalBreakTimeKey,
        totalBreakMinutes + breakDuration.inMinutes,
      );

      // Clear break start time
      await prefs.remove(_breakStartKey);
      await _addDailyRecord('break_end', now);
    }
  }

  Future<bool> isOnBreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_breakStartKey) != null;
  }

  // Status check methods
  Future<bool> isCurrentlyWorking() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_clockInKey) != null;
  }

  Future<DateTime?> getClockInTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString(_clockInKey);
    return timeStr != null ? DateTime.parse(timeStr) : null;
  }

  // Time calculation methods
  Future<Duration> getTotalTimeToday() async {
    final prefs = await SharedPreferences.getInstance();
    final totalMinutes = prefs.getInt(_totalTimeKey) ?? 0;
    return Duration(minutes: totalMinutes);
  }

  Future<Duration> getCurrentBreakDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final breakStartStr = prefs.getString(_breakStartKey);

    if (breakStartStr != null) {
      final breakStart = DateTime.parse(breakStartStr);
      return DateTime.now().difference(breakStart);
    }
    return Duration.zero;
  }

  Future<Duration> getTotalBreakTime() async {
    final prefs = await SharedPreferences.getInstance();
    final totalMinutes = prefs.getInt(_totalBreakTimeKey) ?? 0;
    return Duration(minutes: totalMinutes);
  }

  Future<Duration> getOvertime() async {
    final totalTime = await getTotalTimeToday();
    if (totalTime > standardWorkDay) {
      return totalTime - standardWorkDay;
    }
    return Duration.zero;
  }

  // Record keeping methods
  Future<void> _addDailyRecord(String action, DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getDailyRecords();

    records.add({'action': action, 'timestamp': time.toIso8601String()});

    await prefs.setString(_dailyRecordsKey, jsonEncode(records));
  }

  Future<List<Map<String, dynamic>>> getDailyRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsStr = prefs.getString(_dailyRecordsKey);

    if (recordsStr != null) {
      final List<dynamic> decoded = jsonDecode(recordsStr);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> resetDailyTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_totalTimeKey, 0);
    await prefs.setInt(_totalBreakTimeKey, 0);
    await prefs.remove(_clockInKey);
    await prefs.remove(_breakStartKey);
    await prefs.setString(_dailyRecordsKey, '[]');
  }
}
