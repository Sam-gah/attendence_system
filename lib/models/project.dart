import 'package:flutter/material.dart';

enum ProjectStatus {
  notStarted,
  planning,
  inProgress,
  completed,
  onHold,
  cancelled
}

extension ProjectStatusExtension on ProjectStatus {
  String toJson() => toString().split('.').last;
  
  static ProjectStatus fromJson(String json) {
    return ProjectStatus.values.firstWhere(
      (status) => status.toString().split('.').last == json,
      orElse: () => ProjectStatus.notStarted,
    );
  }
}

class Project {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime deadline;
  final DateTime? endDate;
  final ProjectStatus status;
  final double progress;
  final String clientName;
  final double budget;
  final String projectManager;
  final List<Map<String, dynamic>> milestones;
  final List<String> technologies;
  final List<String> teamMembers;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.deadline,
    this.endDate,
    required this.status,
    required this.progress,
    required this.clientName,
    required this.budget,
    required this.projectManager,
    this.milestones = const [],
    this.technologies = const [],
    this.teamMembers = const [],
  });

  Color get statusColor {
    switch (status) {
      case ProjectStatus.planning:
        return Colors.blue;
      case ProjectStatus.cancelled:
        return Colors.red;
      case ProjectStatus.notStarted:
        return Colors.grey;
      case ProjectStatus.inProgress:
        return Colors.blue;
      case ProjectStatus.completed:
        return Colors.green;
      case ProjectStatus.onHold:
        return Colors.orange;
    }
  }

  String get statusText {
    return status.toString().split('.').last;
  }

  Project copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? deadline,
    DateTime? endDate,
    ProjectStatus? status,
    String? managerId,
    double? progress,
    String? clientName,
    double? budget,
    String? projectManager,
    List<Map<String, dynamic>>? milestones,
    List<String>? technologies,
    List<String>? teamMembers,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      deadline: deadline ?? this.deadline,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      clientName: clientName ?? this.clientName,
      budget: budget ?? this.budget,
      projectManager: projectManager ?? this.projectManager,
      milestones: milestones ?? this.milestones,
      technologies: technologies ?? this.technologies,
      teamMembers: teamMembers ?? this.teamMembers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'deadline': deadline.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status.toString(),
    
      'progress': progress,
      'clientName': clientName,
      'budget': budget,
      'projectManager': projectManager,
      'milestones': milestones,
      'technologies': technologies,
      'teamMembers': teamMembers,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      deadline: DateTime.parse(json['deadline']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      status: ProjectStatusExtension.fromJson(json['status']),
  
      progress: json['progress'].toDouble(),
      clientName: json['clientName'],
      budget: json['budget'].toDouble(),
      projectManager: json['projectManager'],
      milestones: List<Map<String, dynamic>>.from(json['milestones'] ?? []),
      technologies: List<String>.from(json['technologies'] ?? []),
      teamMembers: List<String>.from(json['teamMembers'] ?? []),
    );
  }

  factory Project.fromFirestore(Map<String, dynamic> data) {
    return Project(
      id: data['id'],
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      startDate: DateTime.parse(data['startDate']),
      deadline: DateTime.parse(data['deadline']),
      endDate: data['endDate'] != null ? DateTime.parse(data['endDate']) : null,
      status: ProjectStatusExtension.fromJson(data['status'] ?? 'notStarted'),
      progress: (data['progress'] ?? 0.0).toDouble(),
      clientName: data['clientName'] ?? '',
      budget: (data['budget'] ?? 0.0).toDouble(),
      projectManager: data['projectManager'] ?? '',
      milestones: List<Map<String, dynamic>>.from(data['milestones'] ?? []),
      technologies: List<String>.from(data['technologies'] ?? []),
      teamMembers: List<String>.from(data['teamMembers'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'deadline': deadline.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status.toJson(),
      'progress': progress,
      'clientName': clientName,
      'budget': budget,
      'projectManager': projectManager,
      'milestones': milestones,
      'technologies': technologies,
      'teamMembers': teamMembers,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
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