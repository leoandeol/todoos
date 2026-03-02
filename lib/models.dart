import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Priority levels for tasks
enum Priority { none, low, medium, high }

extension PriorityExtension on Priority {
  String get label {
    switch (this) {
      case Priority.none:
        return 'None';
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case Priority.none:
        return Colors.grey;
      case Priority.low:
        return const Color(0xFF64B5F6);
      case Priority.medium:
        return const Color(0xFFFFB74D);
      case Priority.high:
        return const Color(0xFFEF5350);
    }
  }

  IconData get icon {
    switch (this) {
      case Priority.none:
        return Icons.remove;
      case Priority.low:
        return Icons.arrow_downward;
      case Priority.medium:
        return Icons.remove;
      case Priority.high:
        return Icons.arrow_upward;
    }
  }
}

/// A subtask within a task
class SubTask {
  final String id;
  String title;
  bool isCompleted;

  SubTask({String? id, required this.title, this.isCompleted = false})
    : id = id ?? _uuid.v4();

  SubTask copyWith({String? title, bool? isCompleted}) {
    return SubTask(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
  };

  factory SubTask.fromJson(Map<String, dynamic> json) => SubTask(
    id: json['id'] as String,
    title: json['title'] as String,
    isCompleted: json['isCompleted'] as bool? ?? false,
  );
}

/// A todo task
class Task {
  final String id;
  String title;
  String description;
  DateTime? deadline;
  TimeOfDay? deadlineTime;
  Priority priority;
  Duration? timeRequired;
  List<String> tagIds;
  String? categoryId;
  String projectId;
  int sortOrder;
  bool isCompleted;
  List<SubTask> subtasks;
  final DateTime createdAt;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.deadline,
    this.deadlineTime,
    this.priority = Priority.none,
    this.timeRequired,
    List<String>? tagIds,
    this.categoryId,
    required this.projectId,
    this.sortOrder = 0,
    this.isCompleted = false,
    List<SubTask>? subtasks,
    DateTime? createdAt,
  }) : id = id ?? _uuid.v4(),
       tagIds = tagIds ?? [],
       subtasks = subtasks ?? [],
       createdAt = createdAt ?? DateTime.now();

  /// Full deadline combining date and optional time
  DateTime? get fullDeadline {
    if (deadline == null) return null;
    if (deadlineTime == null) return deadline;
    return DateTime(
      deadline!.year,
      deadline!.month,
      deadline!.day,
      deadlineTime!.hour,
      deadlineTime!.minute,
    );
  }

  bool get isOverdue {
    final dl = fullDeadline;
    if (dl == null || isCompleted) return false;
    return dl.isBefore(DateTime.now());
  }

  bool get isDueToday {
    if (deadline == null || isCompleted) return false;
    final now = DateTime.now();
    return deadline!.year == now.year &&
        deadline!.month == now.month &&
        deadline!.day == now.day;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'deadline': deadline?.toIso8601String(),
    'deadlineTimeHour': deadlineTime?.hour,
    'deadlineTimeMinute': deadlineTime?.minute,
    'priority': priority.index,
    'timeRequiredMinutes': timeRequired?.inMinutes,
    'tagIds': tagIds,
    'categoryId': categoryId,
    'projectId': projectId,
    'sortOrder': sortOrder,
    'isCompleted': isCompleted,
    'subtasks': subtasks.map((s) => s.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    deadline: json['deadline'] != null
        ? DateTime.parse(json['deadline'] as String)
        : null,
    deadlineTime: json['deadlineTimeHour'] != null
        ? TimeOfDay(
            hour: json['deadlineTimeHour'] as int,
            minute: json['deadlineTimeMinute'] as int? ?? 0,
          )
        : null,
    priority: Priority.values[json['priority'] as int? ?? 0],
    timeRequired: json['timeRequiredMinutes'] != null
        ? Duration(minutes: json['timeRequiredMinutes'] as int)
        : null,
    tagIds:
        (json['tagIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
        [],
    categoryId: json['categoryId'] as String?,
    projectId: json['projectId'] as String,
    sortOrder: json['sortOrder'] as int? ?? 0,
    isCompleted: json['isCompleted'] as bool? ?? false,
    subtasks:
        (json['subtasks'] as List<dynamic>?)
            ?.map((e) => SubTask.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : null,
  );
}

/// A project (e.g. Work, Personal)
class Project {
  final String id;
  String name;
  IconData icon;
  Color color;

  Project({
    String? id,
    required this.name,
    this.icon = Icons.folder_outlined,
    this.color = const Color(0xFF7C4DFF),
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconCodePoint': icon.codePoint,
    'color': color.toARGB32(),
  };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'] as String,
    name: json['name'] as String,
    icon: IconData(json['iconCodePoint'] as int, fontFamily: 'MaterialIcons'),
    color: Color(json['color'] as int),
  );
}

/// A tag that can be applied to tasks
class Tag {
  final String id;
  String name;
  Color color;

  Tag({String? id, required this.name, this.color = const Color(0xFF7C4DFF)})
    : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color.toARGB32(),
  };

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
    id: json['id'] as String,
    name: json['name'] as String,
    color: Color(json['color'] as int),
  );
}

/// A category separator within a project
class Category {
  final String id;
  String name;
  String projectId;
  int sortOrder;

  Category({
    String? id,
    required this.name,
    required this.projectId,
    this.sortOrder = 0,
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'projectId': projectId,
    'sortOrder': sortOrder,
  };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    name: json['name'] as String,
    projectId: json['projectId'] as String,
    sortOrder: json['sortOrder'] as int? ?? 0,
  );
}
