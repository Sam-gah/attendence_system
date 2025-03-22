// import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority { urgent, high, normal, low }

enum TaskStatus { open, inProgress, review, blocked, completed, cancelled }

class Task {
  final String id;
  final String name;
  final String description;
  final String projectId;
  final String? parentTaskId; // For subtasks
  final String createdBy;
  final List<String> assignees;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final double progress;
  final List<String> tags;
  final List<String> watchers;
  final List<String> dependencies;
  final int estimatedTime; // in minutes
  final int timeSpent; // in minutes
  final DateTime createdAt;
  final DateTime? startDate;
  final DateTime? completedAt;
  final String? spaceId; // ClickUp-like space organization
  final String? listId; // ClickUp-like list organization
  final Map<String, dynamic> customFields;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.projectId,
    this.parentTaskId,
    required this.createdBy,
    required this.assignees,
    required this.dueDate,
    this.priority = TaskPriority.normal,
    this.status = TaskStatus.open,
    this.progress = 0.0,
    this.tags = const [],
    this.watchers = const [],
    this.dependencies = const [],
    this.estimatedTime = 0,
    this.timeSpent = 0,
    required this.createdAt,
    this.startDate,
    this.completedAt,
    this.spaceId,
    this.listId,
    this.customFields = const {},
  });

  Task copyWith({
    String? name,
    String? description,
    String? projectId,
    String? parentTaskId,
    List<String>? assignees,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    double? progress,
    List<String>? tags,
    List<String>? watchers,
    List<String>? dependencies,
    int? estimatedTime,
    int? timeSpent,
    DateTime? startDate,
    DateTime? completedAt,
    String? spaceId,
    String? listId,
    Map<String, dynamic>? customFields,
  }) {
    return Task(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      createdBy: createdBy,
      assignees: assignees ?? this.assignees,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      tags: tags ?? this.tags,
      watchers: watchers ?? this.watchers,
      dependencies: dependencies ?? this.dependencies,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      timeSpent: timeSpent ?? this.timeSpent,
      createdAt: createdAt,
      startDate: startDate ?? this.startDate,
      completedAt: completedAt ?? this.completedAt,
      spaceId: spaceId ?? this.spaceId,
      listId: listId ?? this.listId,
      customFields: customFields ?? this.customFields,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'projectId': projectId,
      'parentTaskId': parentTaskId,
      'createdBy': createdBy,
      'assignees': assignees,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.toString(),
      'status': status.toString(),
      'progress': progress,
      'tags': tags,
      'watchers': watchers,
      'dependencies': dependencies,
      'estimatedTime': estimatedTime,
      'timeSpent': timeSpent,
      'createdAt': createdAt.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'spaceId': spaceId,
      'listId': listId,
      'customFields': customFields,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  factory Task.fromFirestore(Map<String, dynamic> data) {
    return Task(
      id: data['id'],
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      projectId: data['projectId'] ?? '',
      parentTaskId: data['parentTaskId'],
      createdBy: data['createdBy'] ?? '',
      assignees: List<String>.from(data['assignees'] ?? []),
      dueDate: DateTime.parse(data['dueDate']),
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString() == data['priority'],
        orElse: () => TaskPriority.normal,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => TaskStatus.open,
      ),
      progress: (data['progress'] ?? 0.0).toDouble(),
      tags: List<String>.from(data['tags'] ?? []),
      watchers: List<String>.from(data['watchers'] ?? []),
      dependencies: List<String>.from(data['dependencies'] ?? []),
      estimatedTime: data['estimatedTime'] ?? 0,
      timeSpent: data['timeSpent'] ?? 0,
      createdAt: DateTime.parse(data['createdAt']),
      startDate: data['startDate'] != null ? DateTime.parse(data['startDate']) : null,
      completedAt: data['completedAt'] != null ? DateTime.parse(data['completedAt']) : null,
      spaceId: data['spaceId'],
      listId: data['listId'],
      customFields: Map<String, dynamic>.from(data['customFields'] ?? {}),
    );
  }
}
