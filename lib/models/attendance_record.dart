class AttendanceRecord {
  final String id;
  final String employeeId;
  DateTime clockIn;
  DateTime? clockOut;
  final Duration breakTime;
  final Duration totalTime;

  AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.clockIn,
    this.clockOut,
    this.breakTime = Duration.zero,
    this.totalTime = Duration.zero,
  });

  Map<String, dynamic> toMap() => {
    'employeeId': employeeId,
    'clockIn': clockIn.toIso8601String(),
    'clockOut': clockOut?.toIso8601String(),
    'breakTime': breakTime.inMinutes,
    'totalTime': totalTime.inMinutes,
  };

  factory AttendanceRecord.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceRecord(
      id: id,
      employeeId: map['employeeId'],
      clockIn: DateTime.parse(map['clockIn']),
      clockOut: map['clockOut'] != null ? DateTime.parse(map['clockOut']) : null,
      breakTime: Duration(minutes: map['breakTime'] ?? 0),
      totalTime: Duration(minutes: map['totalTime'] ?? 0),
    );
  }
} 