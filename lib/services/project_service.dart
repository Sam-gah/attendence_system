import 'dart:async';
import '../models/project.dart';

class ProjectService {
  // In-memory storage
  final Map<String, Project> _projects = {};
  final _projectController = StreamController<List<Project>>.broadcast();

  // Mock data
  ProjectService() {
    // Initialize with some mock projects
    _projects['1'] = Project(
      id: '1',
      name: 'Sample Project 1',
      description: 'This is a sample project',
      startDate: DateTime.now(),
      deadline: DateTime.now().add(const Duration(days: 30)),
      status: ProjectStatus.inProgress,
      progress: 0.3,
      clientName: 'Sample Client 1',
      budget: 50000.0,
      projectManager: 'user1',
      teamMembers: ['user1', 'user2'],
      milestones: [
        {
          'id': 'milestone1',
          'title': 'Initial Setup',
          'description': 'Project setup and planning',
          'dueDate': DateTime.now().add(const Duration(days: 7)),
          'isCompleted': false,
          'dependencies': [],
          'budget': 5000.0,
          'assignedMembers': ['user1'],
          'status': 'pending',
        },
        {
          'id': 'milestone2',
          'title': 'Development Phase',
          'description': 'Main development work',
          'dueDate': DateTime.now().add(const Duration(days: 21)),
          'isCompleted': false,
          'dependencies': ['milestone1'],
          'budget': 30000.0,
          'assignedMembers': ['user1', 'user2'],
          'status': 'pending',
        },
      ],
      technologies: ['Flutter', 'Dart', 'Firebase'],
    );

    _projects['2'] = Project(
      id: '2',
      name: 'Sample Project 2',
      description: 'Another sample project',
      startDate: DateTime.now(),
      deadline: DateTime.now().add(const Duration(days: 60)),
      status: ProjectStatus.planning,
      progress: 0.0,
      clientName: 'Sample Client 2',
      budget: 75000.0,
      projectManager: 'user2',
      teamMembers: ['user2', 'user3'],
      milestones: [
        {
          'id': 'milestone3',
          'title': 'Planning Phase',
          'description': 'Project planning and requirements',
          'dueDate': DateTime.now().add(const Duration(days: 14)),
          'isCompleted': false,
          'dependencies': [],
          'budget': 7500.0,
          'assignedMembers': ['user2'],
          'status': 'pending',
        },
      ],
      technologies: ['React', 'Node.js', 'MongoDB'],
    );

    // Notify listeners of initial data
    _notifyListeners();
  }

  // Get all projects
  Future<List<Project>> getProjects() async {
    return _projects.values.toList();
  }

  // Get project by ID
  Future<Project?> getProjectById(String projectId) async {
    return _projects[projectId];
  }

  // Create new project
  Future<Project> addProject(Project project) async {
    _projects[project.id] = project;
    _notifyListeners();
    return project;
  }

  // Update project
  Future<Project> updateProject(Project project) async {
    if (!_projects.containsKey(project.id)) {
      throw Exception('Project not found');
    }
    _projects[project.id] = project;
    _notifyListeners();
    return project;
  }

  // Delete project
  Future<void> deleteProject(String projectId) async {
    _projects.remove(projectId);
    _notifyListeners();
  }

  // Get project stream
  Stream<List<Project>> streamProjects() {
    return _projectController.stream;
  }

  // Stream single project
  Stream<Project?> streamProject(String projectId) {
    return _projectController.stream.map((projects) {
      try {
        return projects.firstWhere((project) => project.id == projectId);
      } catch (e) {
        return null;
      }
    });
  }

  // Update project status
  Future<Project> updateProjectStatus(String projectId, ProjectStatus status) async {
    final project = _projects[projectId];
    if (project == null) {
      throw Exception('Project not found');
    }
    final updatedProject = project.copyWith(status: status);
    _projects[projectId] = updatedProject;
    _notifyListeners();
    return updatedProject;
  }

  // Add team member
  Future<Project> addTeamMember(String projectId, String userId) async {
    final project = _projects[projectId];
    if (project == null) {
      throw Exception('Project not found');
    }
    final updatedTeamMembers = List<String>.from(project.teamMembers)..add(userId);
    final updatedProject = project.copyWith(teamMembers: updatedTeamMembers);
    _projects[projectId] = updatedProject;
    _notifyListeners();
    return updatedProject;
  }

  // Remove team member
  Future<Project> removeTeamMember(String projectId, String userId) async {
    final project = _projects[projectId];
    if (project == null) {
      throw Exception('Project not found');
    }
    final updatedTeamMembers = List<String>.from(project.teamMembers)..remove(userId);
    final updatedProject = project.copyWith(teamMembers: updatedTeamMembers);
    _projects[projectId] = updatedProject;
    _notifyListeners();
    return updatedProject;
  }

  // Add milestone
  Future<Project> addMilestone(String projectId, Map<String, dynamic> milestone) async {
    final project = _projects[projectId];
    if (project == null) {
      throw Exception('Project not found');
    }
    final updatedMilestones = List<Map<String, dynamic>>.from(project.milestones)..add(milestone);
    final updatedProject = project.copyWith(milestones: updatedMilestones);
    _projects[projectId] = updatedProject;
    _notifyListeners();
    return updatedProject;
  }

  // Update milestone
  Future<Project> updateMilestone(String projectId, String milestoneId, Map<String, dynamic> updatedMilestone) async {
    final project = _projects[projectId];
    if (project == null) {
      throw Exception('Project not found');
    }
    final updatedMilestones = project.milestones.map((milestone) {
      if (milestone['id'] == milestoneId) {
        return updatedMilestone;
      }
      return milestone;
    }).toList();
    final updatedProject = project.copyWith(milestones: updatedMilestones);
    _projects[projectId] = updatedProject;
    _notifyListeners();
    return updatedProject;
  }

  // Delete milestone
  Future<Project> deleteMilestone(String projectId, String milestoneId) async {
    final project = _projects[projectId];
    if (project == null) {
      throw Exception('Project not found');
    }
    final updatedMilestones = project.milestones.where((milestone) => milestone['id'] != milestoneId).toList();
    final updatedProject = project.copyWith(milestones: updatedMilestones);
    _projects[projectId] = updatedProject;
    _notifyListeners();
    return updatedProject;
  }

  // Get projects by status
  Future<List<Project>> getProjectsByStatus(ProjectStatus status) async {
    return _projects.values.where((project) => project.status == status).toList();
  }

  // Get projects by team member
  Future<List<Project>> getProjectsByTeamMember(String userId) async {
    return _projects.values.where((project) => project.teamMembers.contains(userId)).toList();
  }

  // Get projects by date range
  Future<List<Project>> getProjectsByDateRange(DateTime start, DateTime end) async {
    return _projects.values.where((project) =>
      project.startDate.isAfter(start) && project.deadline.isBefore(end)
    ).toList();
  }

  // Search projects
  Future<List<Project>> searchProjects(String query) async {
    final lowercaseQuery = query.toLowerCase();
    return _projects.values.where((project) =>
      project.name.toLowerCase().contains(lowercaseQuery) ||
      project.description.toLowerCase().contains(lowercaseQuery) ||
      project.clientName.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  // Get projects by multiple criteria
  Future<List<Project>> getProjectsByCriteria({
    ProjectStatus? status,
    String? teamMember,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _projects.values.where((project) {
      if (status != null && project.status != status) return false;
      if (teamMember != null && !project.teamMembers.contains(teamMember)) return false;
      if (startDate != null && project.startDate.isBefore(startDate)) return false;
      if (endDate != null && project.deadline.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  // Notify listeners of changes
  void _notifyListeners() {
    _projectController.add(_projects.values.toList());
  }

  // Dispose of resources
  void dispose() {
    _projectController.close();
  }
}
