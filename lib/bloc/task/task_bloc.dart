import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/task.dart';
import '../../repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

export 'task_event.dart';
export 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;

  TaskBloc(this.repository) : super(const TaskState()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTask>(_onToggleTask);
    on<SearchTasks>(_onSearchTasks);
    on<ChangeFilter>(_onChangeFilter);
  }

  Future<void> _onLoadTasks(
    LoadTasks event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      clearError: true,
    ));

    try {
      final tasks = await repository.getTasks();

      emit(state.copyWith(
        tasks: tasks,
        isLoading: false,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load tasks: $e',
      ));
    }
  }

  Future<void> _onAddTask(
    AddTask event,
    Emitter<TaskState> emit,
  ) async {
    final updated = [...state.tasks, event.task];
    await _saveAndEmit(updated, emit);
  }

  Future<void> _onUpdateTask(
    UpdateTask event,
    Emitter<TaskState> emit,
  ) async {
    final updated = state.tasks
        .map(
          (task) => task.id == event.task.id ? event.task : task,
        )
        .toList();

    await _saveAndEmit(updated, emit);
  }

  Future<void> _onDeleteTask(
    DeleteTask event,
    Emitter<TaskState> emit,
  ) async {
    final updated = state.tasks
        .where((task) => task.id != event.taskId)
        .toList();

    await _saveAndEmit(updated, emit);
  }

  Future<void> _onToggleTask(
    ToggleTask event,
    Emitter<TaskState> emit,
  ) async {
    final updated = state.tasks.map((task) {
      if (task.id != event.taskId) {
        return task;
      }

      return task.copyWith(completed: !task.completed);
    }).toList();

    await _saveAndEmit(updated, emit);
  }

  void _onSearchTasks(
    SearchTasks event,
    Emitter<TaskState> emit,
  ) {
    emit(state.copyWith(query: event.query));
  }

  void _onChangeFilter(
    ChangeFilter event,
    Emitter<TaskState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }

  Future<void> _saveAndEmit(
    List<Task> tasks,
    Emitter<TaskState> emit,
  ) async {
    try {
      await repository.saveTasks(tasks);

      emit(state.copyWith(
        tasks: tasks,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to save tasks: $e',
      ));
    }
  }
}
