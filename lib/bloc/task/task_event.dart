import 'package:equatable/equatable.dart';

import '../../models/task.dart';

sealed class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  const LoadTasks();
}

class AddTask extends TaskEvent {
  final Task task;

  const AddTask(this.task);

  @override
  List<Object?> get props => [task.id];
}

class UpdateTask extends TaskEvent {
  final Task task;

  const UpdateTask(this.task);

  @override
  List<Object?> get props => [task.id];
}

class DeleteTask extends TaskEvent {
  final String taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class ToggleTask extends TaskEvent {
  final String taskId;

  const ToggleTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class SearchTasks extends TaskEvent {
  final String query;

  const SearchTasks(this.query);

  @override
  List<Object?> get props => [query];
}

class ChangeFilter extends TaskEvent {
  final TaskFilter filter;

  const ChangeFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

enum TaskFilter {
  all,
  active,
  completed,
}
