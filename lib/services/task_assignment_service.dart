import 'dart:convert';
import 'package:attendence_system/models/task.dart';
import 'package:attendence_system/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskAssignmentService {
  final AuthService _authService;
  
  TaskAssignmentService(this._authService);
  
  // Assign a task to an employee
  Future<bool> assignTaskToEmployee({
    required String taskId,
    required String employeeId,
    required String assignedBy,
    required String taskName,
    required String projectName,
    String? priority,
    double? estimatedHours,
    String? taskLink,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Get the tasks list
      final tasksJson = prefs.getString('tasks') ?? '[]';
      List<dynamic> tasks = jsonDecode(tasksJson);
      
      // 2. Find the task and update its assignees
      bool taskFound = false;
      for (int i = 0; i < tasks.length; i++) {
        if (tasks[i]['id'] == taskId) {
          // Add the employee to assignees if not already there
          if (tasks[i]['assignees'] == null) {
            tasks[i]['assignees'] = [employeeId];
          } else if (tasks[i]['assignees'] is List && !tasks[i]['assignees'].contains(employeeId)) {
            tasks[i]['assignees'].add(employeeId);
          }
          taskFound = true;
          break;
        }
      }
      
      // Save the updated tasks list
      if (taskFound) {
        await prefs.setString('tasks', jsonEncode(tasks));
      }
      
      // 3. Add to employee's assigned tasks
      final assignedTasksJson = prefs.getString('assigned_tasks_$employeeId') ?? '[]';
      List<dynamic> assignedTasks = jsonDecode(assignedTasksJson);
      
      // Create assignment record
      final assignment = {
        'taskId': taskId,
        'taskName': taskName,
        'projectName': projectName,
        'assignedBy': assignedBy,
        'assignedAt': DateTime.now().toIso8601String(),
        'status': 'pending', // pending, in_progress, completed
        'priority': priority ?? 'normal',
        'estimatedHours': estimatedHours ?? 1.0,
        'taskLink': taskLink,
        'startedAt': null,
        'completedAt': null,
        'progress': 0.0,
      };
      
      assignedTasks.add(assignment);
      await prefs.setString('assigned_tasks_$employeeId', jsonEncode(assignedTasks));
      
      // 4. Add to employee's recent activities
      _addToEmployeeRecentActivity(
        employeeId: employeeId,
        taskName: taskName,
        projectName: projectName,
        assignedBy: assignedBy,
        priority: priority ?? 'normal'
      );
      
      return true;
    } catch (e) {
      print('Error assigning task: $e');
      return false;
    }
  }
  
  // Get all tasks assigned to current user
  Future<List<Map<String, dynamic>>> getAssignedTasks() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return [];
      
      final prefs = await SharedPreferences.getInstance();
      final assignedTasksJson = prefs.getString('assigned_tasks_${currentUser.id}') ?? '[]';
      List<dynamic> assignedTasks = jsonDecode(assignedTasksJson);
      
      // Convert to List<Map<String, dynamic>>
      return assignedTasks.map<Map<String, dynamic>>((task) => 
        Map<String, dynamic>.from(task)).toList();
    } catch (e) {
      print('Error getting assigned tasks: $e');
      return [];
    }
  }
  
  // Get pending (not started) tasks assigned to current user
  Future<List<Map<String, dynamic>>> getPendingTasks() async {
    final assignedTasks = await getAssignedTasks();
    return assignedTasks.where((task) => task['status'] == 'pending').toList();
  }
  
  // Get in-progress tasks for current user
  Future<List<Map<String, dynamic>>> getInProgressTasks() async {
    final assignedTasks = await getAssignedTasks();
    return assignedTasks.where((task) => task['status'] == 'in_progress').toList();
  }
  
  // Start working on a task (link with attendance)
  Future<bool> startTask({
    required String taskId,
    required String employeeId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Update the task status in assigned tasks
      final assignedTasksJson = prefs.getString('assigned_tasks_$employeeId') ?? '[]';
      List<dynamic> assignedTasks = jsonDecode(assignedTasksJson);
      
      bool taskFound = false;
      Map<String, dynamic>? taskDetails;
      
      for (int i = 0; i < assignedTasks.length; i++) {
        if (assignedTasks[i]['taskId'] == taskId) {
          assignedTasks[i]['status'] = 'in_progress';
          assignedTasks[i]['startedAt'] = DateTime.now().toIso8601String();
          taskFound = true;
          taskDetails = Map<String, dynamic>.from(assignedTasks[i]);
          break;
        }
      }
      
      if (!taskFound) return false;
      
      await prefs.setString('assigned_tasks_$employeeId', jsonEncode(assignedTasks));
      
      // 2. Save current task details to shared preferences for attendance tracking
      if (taskDetails != null) {
        await prefs.setString('current_project', taskDetails['projectName']);
        await prefs.setString('current_task', taskDetails['taskName']);
        if (taskDetails['taskLink'] != null) {
          await prefs.setString('current_task_link', taskDetails['taskLink']);
        }
        if (taskDetails['estimatedHours'] != null) {
          await prefs.setString('current_estimated_hours', taskDetails['estimatedHours'].toString());
        }
        await prefs.setString('current_priority', taskDetails['priority']);
        await prefs.setString('current_task_id', taskId);
      }
      
      // 3. Add to recent activities
      await _addToEmployeeRecentActivity(
        employeeId: employeeId,
        taskName: taskDetails?['taskName'] ?? 'Unknown task',
        projectName: taskDetails?['projectName'] ?? 'Unknown project',
        status: 'started',
        icon: 'Icons.play_circle',
        iconColor: 'Colors.green'
      );
      
      return true;
    } catch (e) {
      print('Error starting task: $e');
      return false;
    }
  }
  
  // Update task progress
  Future<bool> updateTaskProgress({
    required String taskId,
    required String employeeId,
    required double progress,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Update in assigned tasks
      final assignedTasksJson = prefs.getString('assigned_tasks_$employeeId') ?? '[]';
      List<dynamic> assignedTasks = jsonDecode(assignedTasksJson);
      
      bool taskFound = false;
      
      for (int i = 0; i < assignedTasks.length; i++) {
        if (assignedTasks[i]['taskId'] == taskId) {
          assignedTasks[i]['progress'] = progress;
          
          // If 100% progress, mark as completed
          if (progress >= 1.0) {
            assignedTasks[i]['status'] = 'completed';
            assignedTasks[i]['completedAt'] = DateTime.now().toIso8601String();
          }
          
          taskFound = true;
          break;
        }
      }
      
      if (!taskFound) return false;
      await prefs.setString('assigned_tasks_$employeeId', jsonEncode(assignedTasks));
      
      // If project task, update the project task list
      final tasksJson = prefs.getString('tasks') ?? '[]';
      List<dynamic> tasks = jsonDecode(tasksJson);
      
      for (int i = 0; i < tasks.length; i++) {
        if (tasks[i]['id'] == taskId) {
          tasks[i]['progress'] = progress;
          
          if (progress >= 1.0) {
            tasks[i]['status'] = 'completed';
            
            // Update project completion if this is a project task
            if (tasks[i]['projectId'] != null) {
              await _updateProjectTaskCompletion(
                projectId: tasks[i]['projectId'],
                taskId: taskId,
                isCompleted: true
              );
            }
          }
          
          await prefs.setString('tasks', jsonEncode(tasks));
          break;
        }
      }
      
      return true;
    } catch (e) {
      print('Error updating task progress: $e');
      return false;
    }
  }
  
  // Complete a task
  Future<bool> completeTask({
    required String taskId,
    required String employeeId,
  }) async {
    return updateTaskProgress(
      taskId: taskId,
      employeeId: employeeId,
      progress: 1.0,
    );
  }
  
  // Get current task being worked on
  Future<Map<String, dynamic>?> getCurrentTask() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return null;
      
      final prefs = await SharedPreferences.getInstance();
      final currentTaskId = prefs.getString('current_task_id');
      
      if (currentTaskId == null) return null;
      
      final assignedTasksJson = prefs.getString('assigned_tasks_${currentUser.id}') ?? '[]';
      List<dynamic> assignedTasks = jsonDecode(assignedTasksJson);
      
      for (var task in assignedTasks) {
        if (task['taskId'] == currentTaskId && task['status'] == 'in_progress') {
          return Map<String, dynamic>.from(task);
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting current task: $e');
      return null;
    }
  }
  
  // Clear current task when clocking out
  Future<void> clearCurrentTask() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_task_id');
      await prefs.remove('current_project');
      await prefs.remove('current_task');
      await prefs.remove('current_task_link');
      await prefs.remove('current_estimated_hours');
      await prefs.remove('current_priority');
    } catch (e) {
      print('Error clearing current task: $e');
    }
  }
  
  // Add to employee's recent activities
  Future<void> _addToEmployeeRecentActivity({
    required String employeeId,
    required String taskName,
    required String projectName,
    String? assignedBy,
    String status = 'assigned',
    String icon = 'Icons.assignment',
    String iconColor = 'Colors.blue',
    String? priority,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activitiesJson = prefs.getString('recent_activities_$employeeId') ?? '[]';
      List<dynamic> activities = jsonDecode(activitiesJson);
      
      // Get today's date string
      final today = DateTime.now();
      final dateStr = '${_getMonthName(today.month)} ${today.day}';
      
      // Create activity record
      final activity = {
        'title': taskName,
        'space': projectName,
        'icon': icon,
        'iconColor': iconColor,
        'status': status,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      if (assignedBy != null) {
        activity['assignedBy'] = assignedBy;
      }
      
      if (priority != null) {
        activity['priority'] = priority;
      }
      
      // Find today's group or create new one
      bool foundDateGroup = false;
      for (var group in activities) {
        if (group['date'] == dateStr) {
          group['activities'].add(activity);
          foundDateGroup = true;
          break;
        }
      }
      
      if (!foundDateGroup) {
        activities.add({
          'date': dateStr,
          'activities': [activity]
        });
      }
      
      await prefs.setString('recent_activities_$employeeId', jsonEncode(activities));
      
      // Also update the global recent activities
      final globalActivitiesJson = prefs.getString('recent_activities') ?? '[]';
      List<dynamic> globalActivities = jsonDecode(globalActivitiesJson);
      
      foundDateGroup = false;
      for (var group in globalActivities) {
        if (group['date'] == dateStr) {
          group['activities'].add(activity);
          foundDateGroup = true;
          break;
        }
      }
      
      if (!foundDateGroup) {
        globalActivities.add({
          'date': dateStr,
          'activities': [activity]
        });
      }
      
      await prefs.setString('recent_activities', jsonEncode(globalActivities));
    } catch (e) {
      print('Error adding to recent activities: $e');
    }
  }
  
  // Update project task completion status
  Future<void> _updateProjectTaskCompletion({
    required String projectId,
    required String taskId,
    required bool isCompleted,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectsJson = prefs.getString('projects') ?? '[]';
      List<dynamic> projects = jsonDecode(projectsJson);
      
      for (int i = 0; i < projects.length; i++) {
        if (projects[i]['id'] == projectId) {
          int completedCount = projects[i]['completed'] ?? 0;
          
          if (isCompleted) {
            completedCount++;
          } else if (completedCount > 0) {
            completedCount--;
          }
          
          projects[i]['completed'] = completedCount;
          break;
        }
      }
      
      await prefs.setString('projects', jsonEncode(projects));
    } catch (e) {
      print('Error updating project completion: $e');
    }
  }
  
  String _getMonthName(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }
} 