enum TaskPriority {
  low,
  medium,
  high,
}

class Task {
  final String id;
  final String title;
  final String description;
  final bool completed;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.priority,
    required this.dueDate,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
    TaskPriority? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final priorityName = json['priority'] as String? ?? 'medium';

    return Task(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      priority: TaskPriority.values.firstWhere(
        (item) => item.name == priorityName,
        orElse: () => TaskPriority.medium,
      ),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.tryParse(json['dueDate'] as String),
      createdAt: DateTime.tryParse(
            json['createdAt'] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }
}
