import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_record.dart';

class AttendanceService {
  final _db = FirebaseFirestore.instance;

  Future<AttendanceRecord> clockIn(String employeeId) async {
    final doc = await _db.collection('attendance').add({
      'employeeId': employeeId,
      'clockIn': DateTime.now().toIso8601String(),
      'breakTime': 0,
      'totalTime': 0,
    });

    return AttendanceRecord(
      id: doc.id,
      employeeId: employeeId,
      clockIn: DateTime.now(),
    );
  }

  Future<void> clockOut(String recordId) async {
    final now = DateTime.now();
    await _db.collection('attendance').doc(recordId).update({
      'clockOut': now.toIso8601String(),
    });
  }

  Stream<List<AttendanceRecord>> getEmployeeAttendance(String employeeId) {
    return _db
        .collection('attendance')
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('clockIn', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceRecord.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<AttendanceRecord>> getAttendanceHistory(
    String employeeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _db
        .collection('attendance')
        .where('employeeId', isEqualTo: employeeId)
        .where('clockIn', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('clockIn', isLessThan: endDate.toIso8601String())
        .get();

    return snapshot.docs
        .map((doc) => AttendanceRecord.fromMap(doc.data(), doc.id))
        .toList();
  }
} 