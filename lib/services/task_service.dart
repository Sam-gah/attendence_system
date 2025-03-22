// import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/task.dart';

class TaskService {
  // In-memory storage
  final Map<String, Task> _tasks = {};
  final _taskController = StreamController<List<Task>>.broadcast();

  // Mock data
  TaskService() {
    // Initialize with some mock tasks
    _tasks['1'] = Task(
      id: '1',
      name: 'Sample Task 1',
      description: 'This is a sample task',
      projectId: '1',
      createdBy: 'admin',
      assignees: ['user1'],
      dueDate: DateTime.now().add(const Duration(days: 7)),
      createdAt: DateTime.now(),
    );

    _tasks['2'] = Task(
      id: '2',
      name: 'Sample Task 2',
      description: 'Another sample task',
      projectId: '1',
      createdBy: 'admin',
      assignees: ['user2'],
      dueDate: DateTime.now().add(const Duration(days: 14)),
      createdAt: DateTime.now(),
    );
  }

  // Get all tasks
  Future<List<Task>> getAllTasks() async {
    return _tasks.values.toList();
  }

  // Get task by ID
  Future<Task?> getTaskById(String id) async {
    return _tasks[id];
  }

  // Get tasks by project ID
  Future<List<Task>> getTasksByProject(String projectId) async {
    return _tasks.values.where((task) => task.projectId == projectId).toList();
  }

  // Get tasks by user ID
  Future<List<Task>> getTasksByUser(String userId) async {
    return _tasks.values
        .where((task) => task.assignees.contains(userId))
        .toList();
  }

  // Create new task
  Future<Task> createTask(Task task) async {
    _tasks[task.id] = task;
    _notifyListeners();
    return task;
  }

  // Update task
  Future<Task> updateTask(Task task) async {
    if (!_tasks.containsKey(task.id)) {
      throw Exception('Task not found');
    }
    _tasks[task.id] = task;
    _notifyListeners();
    return task;
  }

  // Delete task
  Future<void> deleteTask(String id) async {
    _tasks.remove(id);
    _notifyListeners();
  }

  // Get task stream
  Stream<List<Task>> getTaskStream() {
    return _taskController.stream;
  }

  // Subscribe to user tasks
  Stream<List<Task>> subscribeToUserTasks(String userId) {
    return _taskController.stream.map((tasks) => 
      tasks.where((task) => task.assignees.contains(userId)).toList()
    );
  }

  // Subscribe to project tasks
  Stream<List<Task>> subscribeToProjectTasks(String projectId) {
    return _taskController.stream.map((tasks) => 
      tasks.where((task) => task.projectId == projectId).toList()
    );
  }

  // Update task status
  Future<Task> updateTaskStatus(String taskId, TaskStatus status) async {
    final task = _tasks[taskId];
    if (task == null) {
      throw Exception('Task not found');
    }
    final updatedTask = task.copyWith(status: status);
    _tasks[taskId] = updatedTask;
    _notifyListeners();
    return updatedTask;
  }

  // Update task progress
  Future<Task> updateTaskProgress(String taskId, double progress) async {
    final task = _tasks[taskId];
    if (task == null) {
      throw Exception('Task not found');
    }
    final updatedTask = task.copyWith(progress: progress);
    _tasks[taskId] = updatedTask;
    _notifyListeners();
    return updatedTask;
  }

  // Add assignee to task
  Future<Task> addAssignee(String taskId, String userId) async {
    final task = _tasks[taskId];
    if (task == null) {
      throw Exception('Task not found');
    }
    final updatedAssignees = List<String>.from(task.assignees)..add(userId);
    final updatedTask = task.copyWith(assignees: updatedAssignees);
    _tasks[taskId] = updatedTask;
    _notifyListeners();
    return updatedTask;
  }

  // Remove assignee from task
  Future<Task> removeAssignee(String taskId, String userId) async {
    final task = _tasks[taskId];
    if (task == null) {
      throw Exception('Task not found');
    }
    final updatedAssignees = List<String>.from(task.assignees)..remove(userId);
    final updatedTask = task.copyWith(assignees: updatedAssignees);
    _tasks[taskId] = updatedTask;
    _notifyListeners();
    return updatedTask;
  }

  // Add comment to task
  Future<Task> addComment(String taskId, String comment) async {
    final task = _tasks[taskId];
    if (task == null) {
      throw Exception('Task not found');
    }
    final updatedTask = task.copyWith(
      customFields: {
        ...task.customFields,
        'comments': [...(task.customFields['comments'] as List<dynamic>? ?? []), comment],
      },
    );
    _tasks[taskId] = updatedTask;
    _notifyListeners();
    return updatedTask;
  }

  // Add attachment to task
  Future<Task> addAttachment(String taskId, String attachmentUrl) async {
    final task = _tasks[taskId];
    if (task == null) {
      throw Exception('Task not found');
    }
    final updatedTask = task.copyWith(
      customFields: {
        ...task.customFields,
        'attachments': [...(task.customFields['attachments'] as List<dynamic>? ?? []), attachmentUrl],
      },
    );
    _tasks[taskId] = updatedTask;
    _notifyListeners();
    return updatedTask;
  }

  // Add time entry to task
  Future<Task> addTimeEntry(String taskId, int minutes) async {
    final task = _tasks[taskId];
    if (task == null) {
      throw Exception('Task not found');
    }
    final updatedTask = task.copyWith(timeSpent: task.timeSpent + minutes);
    _tasks[taskId] = updatedTask;
    _notifyListeners();
    return updatedTask;
  }

  // Add subtask
  Future<Task> addSubtask(String parentTaskId, Task subtask) async {
    final parentTask = _tasks[parentTaskId];
    if (parentTask == null) {
      throw Exception('Parent task not found');
    }
    final updatedSubtask = subtask.copyWith(parentTaskId: parentTaskId);
    _tasks[subtask.id] = updatedSubtask;
    _notifyListeners();
    return updatedSubtask;
  }

  // Get subtasks
  Future<List<Task>> getSubtasks(String parentTaskId) async {
    return _tasks.values
        .where((task) => task.parentTaskId == parentTaskId)
        .toList();
  }

  // Add watcher to task
  Future<Task> addWatcher(String taskId, String userId) async {
    final task = _tasks[taskId];
    if (task == null) {
      throw Exception('Task not found');
    }
    final updatedWatchers = List<String>.from(task.watchers)..add(userId);
    final updatedTask = task.copyWith(watchers: updatedWatchers);
    _tasks[taskId] = updatedTask;
    _notifyListeners();
    return updatedTask;
  }

  // Remove watcher from task
  Future<Task> removeWatcher(String taskId, String userId) async {
    final task = _tasks[taskId];
    if (task == null) {
      throw Exception('Task not found');
    }
    final updatedWatchers = List<String>.from(task.watchers)..remove(userId);
    final updatedTask = task.copyWith(watchers: updatedWatchers);
    _tasks[taskId] = updatedTask;
    _notifyListeners();
    return updatedTask;
  }

  // Add dependency
  Future<Task> addDependency(String taskId, String dependencyId) async {
    final task = _tasks[taskId];
    if (task == null) {
      throw Exception('Task not found');
    }
    final updatedDependencies = List<String>.from(task.dependencies)..add(dependencyId);
    final updatedTask = task.copyWith(dependencies: updatedDependencies);
    _tasks[taskId] = updatedTask;
    _notifyListeners();
    return updatedTask;
  }

  // Remove dependency
  Future<Task> removeDependency(String taskId, String dependencyId) async {
    final task = _tasks[taskId];
    if (task == null) {
      throw Exception('Task not found');
    }
    final updatedDependencies = List<String>.from(task.dependencies)..remove(dependencyId);
    final updatedTask = task.copyWith(dependencies: updatedDependencies);
    _tasks[taskId] = updatedTask;
    _notifyListeners();
    return updatedTask;
  }

  // Add tag to task
  Future<Task> addTag(String taskId, String tag) async {
    final task = _tasks[taskId];
    if (task == null) {
      throw Exception('Task not found');
    }
    final updatedTags = List<String>.from(task.tags)..add(tag);
    final updatedTask = task.copyWith(tags: updatedTags);
    _tasks[taskId] = updatedTask;
    _notifyListeners();
    return updatedTask;
  }

  // Remove tag from task
  Future<Task> removeTag(String taskId, String tag) async {
    final task = _tasks[taskId];
    if (task == null) {
      throw Exception('Task not found');
    }
    final updatedTags = List<String>.from(task.tags)..remove(tag);
    final updatedTask = task.copyWith(tags: updatedTags);
    _tasks[taskId] = updatedTask;
    _notifyListeners();
    return updatedTask;
  }

  // Update custom field
  Future<Task> updateCustomField(String taskId, String key, dynamic value) async {
    final task = _tasks[taskId];
    if (task == null) {
      throw Exception('Task not found');
    }
    final updatedCustomFields = Map<String, dynamic>.from(task.customFields)..[key] = value;
    final updatedTask = task.copyWith(customFields: updatedCustomFields);
    _tasks[taskId] = updatedTask;
    _notifyListeners();
    return updatedTask;
  }

  // Get tasks by status
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    return _tasks.values.where((task) => task.status == status).toList();
  }

  // Get tasks by priority
  Future<List<Task>> getTasksByPriority(TaskPriority priority) async {
    return _tasks.values.where((task) => task.priority == priority).toList();
  }

  // Get tasks by due date range
  Future<List<Task>> getTasksByDueDateRange(DateTime start, DateTime end) async {
    return _tasks.values
        .where((task) => task.dueDate.isAfter(start) && task.dueDate.isBefore(end))
        .toList();
  }

  // Get tasks by tag
  Future<List<Task>> getTasksByTag(String tag) async {
    return _tasks.values.where((task) => task.tags.contains(tag)).toList();
  }

  // Get tasks by watcher
  Future<List<Task>> getTasksByWatcher(String userId) async {
    return _tasks.values.where((task) => task.watchers.contains(userId)).toList();
  }

  // Get tasks by dependency
  Future<List<Task>> getTasksByDependency(String taskId) async {
    return _tasks.values.where((task) => task.dependencies.contains(taskId)).toList();
  }

  // Get tasks by custom field
  Future<List<Task>> getTasksByCustomField(String key, dynamic value) async {
    return _tasks.values
        .where((task) => task.customFields[key] == value)
        .toList();
  }

  // Get tasks by search query
  Future<List<Task>> searchTasks(String query) async {
    final lowercaseQuery = query.toLowerCase();
    return _tasks.values.where((task) =>
      task.name.toLowerCase().contains(lowercaseQuery) ||
      task.description.toLowerCase().contains(lowercaseQuery) ||
      task.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  // Get tasks by multiple criteria
  Future<List<Task>> getTasksByCriteria({
    String? projectId,
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
  }) async {
    return _tasks.values.where((task) {
      if (projectId != null && task.projectId != projectId) return false;
      if (userId != null && !task.assignees.contains(userId)) return false;
      if (status != null && task.status != status) return false;
      if (priority != null && task.priority != priority) return false;
      if (startDate != null && task.dueDate.isBefore(startDate)) return false;
      if (endDate != null && task.dueDate.isAfter(endDate)) return false;
      if (tags != null && !tags.every((tag) => task.tags.contains(tag))) return false;
      return true;
    }).toList();
  }

  // Notify listeners of changes
  void _notifyListeners() {
    _taskController.add(_tasks.values.toList());
  }

  // Dispose of resources
  void dispose() {
    _taskController.close();
  }
}
