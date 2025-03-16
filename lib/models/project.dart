enum ProjectStatus {
  planning,
  inProgress,
  onHold,
  completed,
  cancelled
}

class Project {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime deadline;
  final ProjectStatus status;
  final String clientName;
  final List<String> teamMembers;
  final String projectManager;
  final double budget;
  final List<String> technologies;
  final List<Map<String, dynamic>> milestones;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.deadline,
    required this.status,
    required this.clientName,
    required this.teamMembers,
    required this.projectManager,
    required this.budget,
    required this.technologies,
    required this.milestones,
  });

  Project copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? deadline,
    ProjectStatus? status,
    String? clientName,
    List<String>? teamMembers,
    String? projectManager,
    double? budget,
    List<String>? technologies,
    List<Map<String, dynamic>>? milestones,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      clientName: clientName ?? this.clientName,
      teamMembers: teamMembers ?? this.teamMembers,
      projectManager: projectManager ?? this.projectManager,
      budget: budget ?? this.budget,
      technologies: technologies ?? this.technologies,
      milestones: milestones ?? this.milestones,
    );
  }
}

class Milestone {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final List<String> dependencies; // IDs of milestones this depends on
  final double budget;
  final List<String> assignedMembers;
  final MilestoneStatus status;

  Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.dependencies = const [],
    required this.budget,
    this.assignedMembers = const [],
    this.status = MilestoneStatus.pending,
  });

  Milestone copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    List<String>? dependencies,
    double? budget,
    List<String>? assignedMembers,
    MilestoneStatus? status,
  }) {
    return Milestone(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      dependencies: dependencies ?? this.dependencies,
      budget: budget ?? this.budget,
      assignedMembers: assignedMembers ?? this.assignedMembers,
      status: status ?? this.status,
    );
  }
}

enum MilestoneStatus {
  pending,
  inProgress,
  completed,
  delayed,
  blocked
} 