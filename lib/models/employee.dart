import 'package:attendence_system/roles/role.dart';

import 'user.dart';

enum EmploymentType { fullTime, partTime, contract, intern }

class Employee extends User {
  final String position;
  final String department;
  final EmploymentType employmentType;
  final String workType;
  final List<String> assignedProjects;
  final String reportingTo;
  final DateTime joiningDate;

  Employee({
    required super.id,
    required super.email,
    required super.name,
    required super.phone,
    required super.role,
    required this.position,
    required this.department,
    required this.employmentType,
    required this.workType,
    required this.assignedProjects,
    required this.reportingTo,
    required this.joiningDate,
  });

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      role: Role.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => Role.employee,
      ),
      position: map['position'],
      department: map['department'],

      employmentType: EmploymentType.values.firstWhere(
        (e) => e.toString() == map['employmentType'],
        orElse: () => EmploymentType.fullTime,
      ),
      workType: map['workType'],
      assignedProjects: List<String>.from(map['assignedProjects']),
      reportingTo: map['reportingTo'],
      joiningDate: DateTime.parse(map['joiningDate']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'position': position,
      'department': department,
      'employmentType': employmentType.toString(),
      'workType': workType,
      'assignedProjects': assignedProjects,
      'reportingTo': reportingTo,
      'joiningDate': joiningDate.toIso8601String(),
    });
    return map;
  }
}
