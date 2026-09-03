import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/task/task_bloc.dart';
import '../models/task.dart';
import 'create_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  void _openTaskForm(
    BuildContext context, {
    Task? task,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TaskBloc>(),
          child: CreateTaskScreen(task: task),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Task task,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete task?'),
          content: Text(
            'Are you sure you want to delete "${task.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      context.read<TaskBloc>().add(DeleteTask(task.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskForm(context),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: TextField(
                    onChanged: (value) {
                      context.read<TaskBloc>().add(SearchTasks(value));
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search tasks...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<TaskFilter>(
                      segments: [
                        ButtonSegment(
                          value: TaskFilter.all,
                          label: Text('All (${state.tasks.length})'),
                        ),
                        ButtonSegment(
                          value: TaskFilter.active,
                          label: Text('Active (${state.activeCount})'),
                        ),
                        ButtonSegment(
                          value: TaskFilter.completed,
                          label: Text(
                            'Done (${state.completedCount})',
                          ),
                        ),
                      ],
                      selected: {state.filter},
                      onSelectionChanged: (value) {
                        context
                            .read<TaskBloc>()
                            .add(ChangeFilter(value.first));
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: state.visibleTasks.isEmpty
                      ? _EmptyState(
                          hasTasks: state.tasks.isNotEmpty,
                          query: state.query,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            100,
                          ),
                          itemCount: state.visibleTasks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final task = state.visibleTasks[index];

                            return _TaskCard(
                              task: task,
                              onToggle: () {
                                context
                                    .read<TaskBloc>()
                                    .add(ToggleTask(task.id));
                              },
                              onEdit: () {
                                _openTaskForm(
                                  context,
                                  task: task,
                                );
                              },
                              onDelete: () {
                                _confirmDelete(context, task);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasTasks;
  final String query;

  const _EmptyState({
    required this.hasTasks,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final searching = query.trim().isNotEmpty;

    String title;
    String subtitle;
    IconData icon;

    if (searching) {
      title = 'No matching tasks';
      subtitle = 'Try a different search keyword.';
      icon = Icons.search_off;
    } else if (hasTasks) {
      title = 'No tasks in this filter';
      subtitle = 'Choose another filter to see your tasks.';
      icon = Icons.filter_alt_off;
    } else {
      title = 'No tasks yet';
      subtitle = 'Tap New Task to create your first task.';
      icon = Icons.task_alt;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  String _priorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  IconData _priorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.keyboard_arrow_down;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.keyboard_arrow_up;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final dueDate = task.dueDate;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: task.completed,
                onChanged: (_) => onToggle(),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          avatar: Icon(
                            _priorityIcon(task.priority),
                            size: 18,
                          ),
                          label: Text(
                            '${_priorityText(task.priority)} priority',
                          ),
                        ),
                        if (dueDate != null)
                          Chip(
                            avatar: const Icon(
                              Icons.calendar_today,
                              size: 16,
                            ),
                            label: Text(
                              'Due ${_formatDate(dueDate)}',
                            ),
                          ),
                        if (task.completed)
                          const Chip(
                            avatar: Icon(
                              Icons.check_circle,
                              size: 18,
                            ),
                            label: Text('Completed'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
