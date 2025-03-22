import 'package:flutter/material.dart';
import 'dart:async';
import '../models/project.dart';
import '../services/project_service.dart';
import 'package:flutter/foundation.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Project>>? _projectsSubscription;

  List<Project> get projects => List.unmodifiable(_projects);
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProjectProvider() {
    _initializeProjects();
  }

  void _initializeProjects() {
    _setLoading(true);

    // Subscribe to real-time updates
    _projectsSubscription = _projectService.streamProjects().listen(
      _updateProjects,
      onError: _handleError,
    );
  }

  void _updateProjects(List<Project> newProjects) {
    _projects = newProjects;
    _error = null;
    _setLoading(false);
    notifyListeners();
  }

  void _handleError(dynamic error) {
    _error = 'Failed to load projects: $error';
    _setLoading(false);
    notifyListeners();
  }

  Future<void> loadProjects() async {
    _setLoading(true);
    _error = null;
    notifyListeners();

    try {
      final projects = await _projectService.getProjects();
      _projects = projects;
      _error = null;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> addProject(Project project) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      _projects.add(project);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        // TODO: Replace with actual API call
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
        _projects[index] = project;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      _projects.removeWhere((p) => p.id == projectId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  List<Project> getProjectsByStatus(ProjectStatus status) {
    return _projects.where((p) => p.status == status).toList();
  }

  Project? getProjectById(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
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
    _projectsSubscription?.cancel();
    super.dispose();
  }
}
