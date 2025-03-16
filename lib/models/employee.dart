enum EmployeeRole { Developer, ProjectLead, HRHead, CEO, Manager, Designer, QA }

enum EmploymentType { fullTime, partTime, contract, intern }

class Employee {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String position;
  final EmployeeRole role;
  final String department;
  final String designation;
  final EmploymentType employmentType;
  final String workType;
  final List<String> assignedProjects;
  final String reportingTo;
  final DateTime joiningDate;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.position,
    required this.role,
    required this.department,
    required this.designation,
    required this.employmentType,
    required this.workType,
    required this.assignedProjects,
    required this.reportingTo,
    required this.joiningDate,
  });

  // Optional: Add toMap and fromMap methods if you need to serialize the data
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'position': position,
      'role': role.toString(),
      'department': department,
      'designation': designation,
      'employmentType': employmentType.toString(),
      'workType': workType,
      'assignedProjects': assignedProjects,
      'reportingTo': reportingTo,
      'joiningDate': joiningDate.toIso8601String(),
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      position: map['position'],
      role: EmployeeRole.values.firstWhere(
        (e) => e.toString() == map['role'],
        orElse: () => EmployeeRole.Developer,
      ),
      department: map['department'],
      designation: map['designation'],
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
}
