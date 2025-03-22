import '../models/attendance_record.dart';
import 'package:collection/collection.dart';

class AttendanceService {
  // Mock database for demonstration purposes
  final List<AttendanceRecord> _mockDb = [];

  Future<AttendanceRecord> clockIn(String employeeId) async {
    final now = DateTime.now();
    final newRecord = AttendanceRecord(
      id: _generateId(),
      employeeId: employeeId,
      clockIn: now,
    );
    _mockDb.add(newRecord);
    return newRecord;
  }

  Future<bool> clockOut(String recordId) async {
    final now = DateTime.now();
    final record = _mockDb.firstWhereOrNull((rec) => rec.id == recordId);
    if (record != null) {
      record.clockOut = now;
      return true;
    }
    return false;
  }

  Stream<List<AttendanceRecord>> getEmployeeAttendance(String employeeId) async* {
    yield _mockDb
        .where((record) => record.employeeId == employeeId)
        .toList();
  }

  Future<List<AttendanceRecord>> getAttendanceHistory(
    String employeeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _mockDb
        .where((record) =>
            record.employeeId == employeeId &&
            record.clockIn.isAfter(startDate) &&
            record.clockIn.isBefore(endDate))
        .toList();
  }

  String _generateId() {
    // Simple ID generation logic
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
} 