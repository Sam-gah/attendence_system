import 'package:flutter/material.dart';
import 'dart:async';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  final Map<String, List<Task>> _projectTasks = {};
  List<Task> _userTasks = [];
  bool _isLoading = false;
  String? _error;

  // Stream subscriptions
  final Map<String, StreamSubscription<List<Task>>> _projectSubscriptions = {};
  StreamSubscription<List<Task>>? _userTasksSubscription;
  final Map<String, StreamSubscription<List<Map<String, dynamic>>>>
  _commentSubscriptions = {};

  // Getters
  List<Task> getProjectTasks(String projectId) =>
      _projectTasks[projectId] ?? [];
  List<Task> get userTasks => _userTasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter getters
  List<Task> getTasksByStatus(String projectId, TaskStatus status) {
    return getProjectTasks(
      projectId,
    ).where((task) => task.status == status).toList();
  }

  List<Task> getTasksByPriority(String projectId, TaskPriority priority) {
    return getProjectTasks(
      projectId,
    ).where((task) => task.priority == priority).toList();
  }

  List<Task> getTasksByAssignee(String projectId, String userId) {
    return getProjectTasks(
      projectId,
    ).where((task) => task.assignees.contains(userId)).toList();
  }

  // Subscribe to project tasks
  void subscribeToProjectTasks(String projectId) {
    if (_projectSubscriptions.containsKey(projectId)) return;

    final subscription = _taskService
        .subscribeToProjectTasks(projectId)
        .listen(
          (tasks) {
            _projectTasks[projectId] = tasks;
            _error = null;
            notifyListeners();
          },
          onError: (error) {
            _error = 'Failed to load tasks: $error';
            notifyListeners();
          },
        );

    _projectSubscriptions[projectId] = subscription;
  }

  // Subscribe to user tasks
  void subscribeToUserTasks(String userId) {
    _userTasksSubscription?.cancel();

    _userTasksSubscription = _taskService
        .subscribeToUserTasks(userId)
        .listen(
          (tasks) {
            _userTasks = tasks;
            _error = null;
            notifyListeners();
          },
          onError: (error) {
            _error = 'Failed to load user tasks: $error';
            notifyListeners();
          },
        );
  }

  // Subscribe to task comments
  Stream<List<Map<String, dynamic>>> streamTaskComments(String taskId) {
    return _taskService.getTaskStream().map((tasks) => 
      tasks.where((task) => task.id == taskId)
          .expand((task) => (task.customFields['comments'] as List<dynamic>? ?? [])
              .map((comment) => comment as Map<String, dynamic>))
          .toList()
    );
  }

  // Unsubscribe from project tasks
  void unsubscribeFromProjectTasks(String projectId) {
    _projectSubscriptions[projectId]?.cancel();
    _projectSubscriptions.remove(projectId);
    _projectTasks.remove(projectId);
    notifyListeners();
  }

  // Create task
  Future<void> createTask(Task task) async {
    _setLoading(true);
    try {
      await _taskService.createTask(task);
      _error = null;
    } catch (e) {
      _error = 'Failed to create task: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update task
  Future<void> updateTask(Task task) async {
    _setLoading(true);
    try {
      await _taskService.updateTask(task);
      _error = null;
    } catch (e) {
      _error = 'Failed to update task: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Delete task
  Future<void> deleteTask(Task task) async {
    _setLoading(true);
    try {
      await _taskService.deleteTask(task.id);
      _error = null;
    } catch (e) {
      _error = 'Failed to delete task: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Add comment
  Future<void> addTaskComment(
    String taskId,
    String userId,
    String comment,
  ) async {
    try {
      await _taskService.addComment(taskId, comment);
      _error = null;
    } catch (e) {
      _error = 'Failed to add comment: $e';
      rethrow;
    }
  }

  // Track time
  Future<void> trackTaskTime(
    String taskId,
    int minutes,
    String description,
  ) async {
    try {
      await _taskService.addTimeEntry(taskId, minutes);
      _error = null;
    } catch (e) {
      _error = 'Failed to track time: $e';
      rethrow;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Cancel all subscriptions
    for (var subscription in _projectSubscriptions.values) {
      subscription.cancel();
    }
    _projectSubscriptions.clear();
    _userTasksSubscription?.cancel();

    // Cancel comment subscriptions
    for (var subscription in _commentSubscriptions.values) {
      subscription.cancel();
    }
    _commentSubscriptions.clear();

    super.dispose();
  }
}
