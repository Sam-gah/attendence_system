import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class TimeTrackingService {
  static const String _clockInKey = 'clock_in_time';
  static const String _totalTimeKey = 'total_time_today';
  static const String _breakStartKey = 'break_start_time';
  static const String _totalBreakTimeKey = 'total_break_time';
  static const String _dailyRecordsKey = 'daily_time_records';
  static const String _lastWorkDateKey = 'last_work_date';
  static const Duration standardWorkDay = Duration(hours: 8);
  
  // Firebase instance - will be null if Firebase is not available
  FirebaseService? _firebaseService;
  
  // Constructor to optionally accept Firebase service
  TimeTrackingService([this._firebaseService]);
  
  bool get hasFirebase => _firebaseService != null;

  // Check if user has already worked today
  Future<bool> hasWorkedToday() async {
    final String today = _getTodayDateString();
    final prefs = await SharedPreferences.getInstance();
    final lastWorkDate = prefs.getString(_lastWorkDateKey);
    
    // Check if there's any recorded time today
    final totalMinutesToday = prefs.getInt(_totalTimeKey) ?? 0;
    
    return lastWorkDate == today && totalMinutesToday > 0;
  }
  
  // Get today's date string in YYYY-MM-DD format
  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
  
  // Check if this is a new day since last check
  Future<bool> _isNewDay() async {
    final today = _getTodayDateString();
    final prefs = await SharedPreferences.getInstance();
    final lastWorkDate = prefs.getString(_lastWorkDateKey);
    
    if (lastWorkDate == null || lastWorkDate != today) {
      await prefs.setString(_lastWorkDateKey, today);
      return true;
    }
    
    return false;
  }
  
  // Handle end of day reset
  Future<void> checkAndResetForNewDay() async {
    if (await _isNewDay()) {
      final prefs = await SharedPreferences.getInstance();
      
      // If clocked in from previous day, automatically clock out
      if (await isCurrentlyWorking()) {
        await clockOut(); // Clock out from previous day
      }
      
      // Reset daily counters
      await resetDailyTime();
      
      // Archive previous day's data if needed
      // TODO: Implement archiving logic
    }
  }

  // Clock in/out methods
  Future<void> clockIn({required String project, required String task, String employeeId = ''}) async {
    // Check if this is a new day
    await checkAndResetForNewDay();
    
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = _getTodayDateString();
    
    await prefs.setBool('is_working', true);
    await prefs.setString(_clockInKey, now.toIso8601String());
    await prefs.setString('current_project', project);
    await prefs.setString('current_task', task);
    await prefs.setString(_lastWorkDateKey, today);

    // Save to attendance record
    final records = await getDailyRecords();
    final clockInRecord = {
      'timestamp': now.toIso8601String(),
      'action': 'clock_in',
      'project': project,
      'task': task,
      'employeeId': employeeId,
      'date': today,
    };
    
    records.add(clockInRecord);
    await prefs.setStringList(
      'attendance_records',
      records.map((r) => jsonEncode(r)).toList(),
    );

    // Initialize break time for the day
    await prefs.setInt(_totalBreakTimeKey, 0);

    // Add record to daily records
    await _addDailyRecord('clock_in', now, extraData: {
      'project': project,
      'task': task,
      'date': today,
    });
    
    // If Firebase is available, store in Firestore
    if (hasFirebase && employeeId.isNotEmpty) {
      try {
        await _firebaseService!.recordTimeEntry({
          'employeeId': employeeId,
          'action': 'clock_in',
          'project': project,
          'task': task,
          'timestamp': FieldValue.serverTimestamp(),
          'localTimestamp': now.toIso8601String(),
          'date': today,
        });
        
        // Update the employee's status in Firestore
        await _firebaseService!.updateEmployeeStatus(employeeId, {
          'status': 'working',
          'currentProject': project,
          'currentTask': task,
          'clockInTime': now.toIso8601String(),
          'workDate': today,
        });
        
        debugPrint('Successfully recorded clock-in to Firestore');
      } catch (e) {
        debugPrint('Error recording clock-in to Firestore: $e');
      }
    }
  }

  Future<void> clockOut({String employeeId = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    final clockInStr = prefs.getString(_clockInKey);
    final currentProject = prefs.getString('current_project');
    final currentTask = prefs.getString('current_task');
    final now = DateTime.now();
    final today = _getTodayDateString();

    if (clockInStr != null) {
      final clockIn = DateTime.parse(clockInStr);
      final duration = now.difference(clockIn);

      // Subtract break time from total duration
      final breakMinutes = prefs.getInt(_totalBreakTimeKey) ?? 0;
      final workMinutes = duration.inMinutes - breakMinutes;

      // Add to total time
      final totalMinutes = prefs.getInt(_totalTimeKey) ?? 0;
      await prefs.setInt(_totalTimeKey, totalMinutes + workMinutes);

      // Calculate work hours for today
      final workHours = workMinutes / 60.0;
      
      // Add record to daily records
      final clockOutRecord = {
        'action': 'clock_out',
        'timestamp': now.toIso8601String(),
        'duration': workMinutes,
        'project': currentProject,
        'task': currentTask,
        'employeeId': employeeId,
        'date': today,
      };
      
      // Save to local storage
      await _addDailyRecord('clock_out', now, extraData: {
        'duration': workMinutes,
        'project': currentProject,
        'task': currentTask,
        'date': today,
      });
      
      // Clear clock in and break times
      await prefs.remove(_clockInKey);
      await prefs.remove(_breakStartKey);
      await prefs.remove(_totalBreakTimeKey);
      await prefs.remove('current_project');
      await prefs.remove('current_task');
      
      // If Firebase is available, store in Firestore
      if (hasFirebase && employeeId.isNotEmpty) {
        try {
          await _firebaseService!.recordTimeEntry({
            'employeeId': employeeId,
            'action': 'clock_out',
            'timestamp': FieldValue.serverTimestamp(),
            'localTimestamp': now.toIso8601String(),
            'date': today,
            'duration': workMinutes,
            'durationHours': workHours,
            'project': currentProject,
            'task': currentTask,
          });
          
          // Update the employee's status in Firestore
          await _firebaseService!.updateEmployeeStatus(employeeId, {
            'status': 'off',
            'currentProject': null,
            'currentTask': null,
            'clockInTime': null,
            'lastClockOut': now.toIso8601String(),
            'lastWorkDuration': workMinutes,
            'workDate': today,
          });
          
          // Update attendance summary in Firestore
          final summaryRef = _firebaseService!.firestore
              .collection('attendance_summary')
              .doc('${employeeId}_$today');
          
          final summaryDoc = await summaryRef.get();
          
          if (summaryDoc.exists) {
            // Update existing summary
            final data = summaryDoc.data() as Map<String, dynamic>;
            final totalMinutesToday = (data['totalMinutes'] ?? 0) + workMinutes;
            
            await summaryRef.update({
              'totalMinutes': totalMinutesToday,
              'totalHours': totalMinutesToday / 60.0,
              'lastUpdated': FieldValue.serverTimestamp(),
              'sessions': FieldValue.arrayUnion([
                {
                  'clockIn': clockIn.toIso8601String(),
                  'clockOut': now.toIso8601String(),
                  'duration': workMinutes,
                  'project': currentProject,
                  'task': currentTask,
                }
              ]),
            });
          } else {
            // Create new summary
            await summaryRef.set({
              'employeeId': employeeId,
              'date': today,
              'totalMinutes': workMinutes,
              'totalHours': workHours,
              'lastUpdated': FieldValue.serverTimestamp(),
              'sessions': [
                {
                  'clockIn': clockIn.toIso8601String(),
                  'clockOut': now.toIso8601String(),
                  'duration': workMinutes,
                  'project': currentProject,
                  'task': currentTask,
                }
              ],
            });
          }
          
          debugPrint('Successfully recorded clock-out to Firestore');
        } catch (e) {
          debugPrint('Error recording clock-out to Firestore: $e');
        }
      }
    }
  }

  // Break tracking methods
  Future<void> startBreak({String employeeId = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString(_breakStartKey, now.toIso8601String());
    await _addDailyRecord('break_start', now);
    
    // If Firebase is available, store in Firestore
    if (hasFirebase && employeeId.isNotEmpty) {
      try {
        await _firebaseService!.recordTimeEntry({
          'employeeId': employeeId,
          'action': 'break_start',
          'timestamp': FieldValue.serverTimestamp(),
          'localTimestamp': now.toIso8601String(),
          'date': DateTime(now.year, now.month, now.day).toIso8601String(),
        });
        
        // Update employee status
        await _firebaseService!.updateEmployeeStatus(employeeId, {
          'status': 'on_break',
          'breakStartTime': now.toIso8601String(),
        });
      } catch (e) {
        debugPrint('Error recording break start to Firestore: $e');
      }
    }
  }

  Future<void> endBreak({String employeeId = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    final breakStartStr = prefs.getString(_breakStartKey);

    if (breakStartStr != null) {
      final breakStart = DateTime.parse(breakStartStr);
      final now = DateTime.now();
      final breakDuration = now.difference(breakStart);
      final breakMinutes = breakDuration.inMinutes;

      // Add to total break time
      final totalBreakMinutes = prefs.getInt(_totalBreakTimeKey) ?? 0;
      await prefs.setInt(
        _totalBreakTimeKey,
        totalBreakMinutes + breakMinutes,
      );

      // Clear break start time
      await prefs.remove(_breakStartKey);
      await _addDailyRecord('break_end', now, extraData: {
        'duration': breakMinutes,
      });
      
      // If Firebase is available, store in Firestore
      if (hasFirebase && employeeId.isNotEmpty) {
        try {
          await _firebaseService!.recordTimeEntry({
            'employeeId': employeeId,
            'action': 'break_end',
            'timestamp': FieldValue.serverTimestamp(),
            'localTimestamp': now.toIso8601String(),
            'date': DateTime(now.year, now.month, now.day).toIso8601String(),
            'breakDuration': breakMinutes,
            'breakStart': breakStart.toIso8601String(),
          });
          
          // Update employee status
          await _firebaseService!.updateEmployeeStatus(employeeId, {
            'status': 'working',
            'breakStartTime': null,
            'lastBreakDuration': breakMinutes,
          });
        } catch (e) {
          debugPrint('Error recording break end to Firestore: $e');
        }
      }
    }
  }

  // The rest of the methods remain mostly unchanged
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
  Future<void> _addDailyRecord(String action, DateTime time, {Map<String, dynamic>? extraData}) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getDailyRecords();

    final record = <String, dynamic>{'action': action, 'timestamp': time.toIso8601String()};
    if (extraData != null) {
      record.addAll(extraData);
    }
    
    records.add(record);
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
    // Don't remove last work date - we use it to track day changes
    // await prefs.remove(_lastWorkDateKey);
  }

  // Archive day's records before reset
  Future<void> archiveDailyRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getDailyRecords();
    final dateStr = _getTodayDateString();
    
    if (records.isNotEmpty) {
      // Get existing archives
      final archivesStr = prefs.getString('attendance_archives') ?? '{}';
      final Map<String, dynamic> archives = jsonDecode(archivesStr);
      
      // Add today's records to archive
      archives[dateStr] = records;
      
      // Save updated archives
      await prefs.setString('attendance_archives', jsonEncode(archives));
      
      // Clear today's records
      await prefs.setString(_dailyRecordsKey, '[]');
    }
  }

  // Get daily statistics
  Future<Map<String, dynamic>> getDailyStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final totalMinutes = prefs.getInt(_totalTimeKey) ?? 0;
    final totalTime = Duration(minutes: totalMinutes);
    final records = await getDailyRecords();
    
    // Count number of sessions
    int sessionCount = 0;
    records.forEach((record) {
      if (record['action'] == 'clock_in') {
        sessionCount++;
      }
    });
    
    // Count breaks
    int breakCount = 0;
    int breakMinutes = 0;
    records.forEach((record) {
      if (record['action'] == 'break_start') {
        breakCount++;
      }
      if (record.containsKey('duration') && record['action'] == 'break_end') {
        breakMinutes += (record['duration'] as int);
      }
    });
    
    return {
      'totalTime': totalTime,
      'totalMinutes': totalMinutes,
      'sessionCount': sessionCount,
      'breakCount': breakCount,
      'breakMinutes': breakMinutes,
      'date': _getTodayDateString(),
      'isCompleted': totalTime >= standardWorkDay,
      'overtimeMinutes': totalTime > standardWorkDay 
          ? totalTime.inMinutes - standardWorkDay.inMinutes
          : 0,
    };
  }
}
