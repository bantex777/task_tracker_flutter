import 'package:equatable/equatable.dart';

import '../../models/task.dart';
import 'task_event.dart';

class TaskState extends Equatable {
  final List<Task> tasks;
  final bool isLoading;
  final String? error;
  final String query;
  final TaskFilter filter;

  const TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
    this.filter = TaskFilter.all,
  });

  List<Task> get visibleTasks {
    var result = tasks.where((task) {
      switch (filter) {
        case TaskFilter.active:
          return !task.completed;
        case TaskFilter.completed:
          return task.completed;
        case TaskFilter.all:
          return true;
      }
    }).toList();

    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isNotEmpty) {
      result = result.where((task) {
        return task.title.toLowerCase().contains(normalizedQuery) ||
            task.description.toLowerCase().contains(normalizedQuery);
      }).toList();
    }

    result.sort((a, b) {
      if (a.completed != b.completed) {
        return a.completed ? 1 : -1;
      }

      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }

      if (a.dueDate != null) return -1;
      if (b.dueDate != null) return 1;

      return b.createdAt.compareTo(a.createdAt);
    });

    return result;
  }

  int get activeCount => tasks.where((task) => !task.completed).length;

  int get completedCount => tasks.where((task) => task.completed).length;

  TaskState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? query,
    TaskFilter? filter,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      query: query ?? this.query,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [
        tasks,
        isLoading,
        error,
        query,
        filter,
      ];
}
