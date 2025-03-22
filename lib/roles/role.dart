// role.dart
import 'package:attendence_system/models/user.dart';

enum Role { admin, employee, manager, hr, intern }

extension RoleExtension on Role {
  String get name {
    switch (this) {
      case Role.admin:
        return "admin";
      case Role.employee:
        return "employee";
      case Role.manager:
        return "manager";
      case Role.hr:
        return "hr";
      case Role.intern:
        return "intern";
    }
  }
}

bool canAccessFeature(User user, String feature) {
  Map<Role, List<String>> rolePermissions = {
    Role.admin: ["dashboard", "edit_users", "manage_employees"],
    Role.manager: ["dashboard", "manage_employees"],
    Role.employee: ["view_tasks"],
    Role.intern: ["view_tasks"],
  };

  return rolePermissions[user.role]?.contains(feature) ?? false;
}
// Compare this snippet from lib/screens/admin/admin_dashboard.dart: