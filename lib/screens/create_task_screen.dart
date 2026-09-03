import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/task/task_bloc.dart';
import '../models/task.dart';

class CreateTaskScreen extends StatefulWidget {
  final Task? task;

  const CreateTaskScreen({
    super.key,
    this.task,
  });

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late TaskPriority _priority;
  DateTime? _dueDate;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.task?.title ?? '',
    );

    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );

    _priority = widget.task?.priority ?? TaskPriority.medium;
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final existing = widget.task;

    if (existing == null) {
      final now = DateTime.now();

      final task = Task(
        id: now.microsecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        completed: false,
        priority: _priority,
        dueDate: _dueDate,
        createdAt: now,
      );

      context.read<TaskBloc>().add(AddTask(task));
    } else {
      final updated = existing.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        clearDueDate: _dueDate == null,
      );

      context.read<TaskBloc>().add(UpdateTask(updated));
    }

    Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Create Task'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Task title',
                    hintText: 'Example: Build Flutter app',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a task title';
                    }

                    if (value.trim().length < 3) {
                      return 'Title must be at least 3 characters';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe what needs to be done',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Priority',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                SegmentedButton<TaskPriority>(
                  segments: const [
                    ButtonSegment(
                      value: TaskPriority.low,
                      label: Text('Low'),
                    ),
                    ButtonSegment(
                      value: TaskPriority.medium,
                      label: Text('Medium'),
                    ),
                    ButtonSegment(
                      value: TaskPriority.high,
                      label: Text('High'),
                    ),
                  ],
                  selected: {_priority},
                  onSelectionChanged: (value) {
                    setState(() {
                      _priority = value.first;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Due date',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDueDate,
                        icon: const Icon(Icons.calendar_month),
                        label: Text(
                          _dueDate == null
                              ? 'Choose due date'
                              : _formatDate(_dueDate!),
                        ),
                      ),
                    ),
                    if (_dueDate != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Clear due date',
                        onPressed: () {
                          setState(() {
                            _dueDate = null;
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _saveTask,
                  icon: Icon(
                    isEditing ? Icons.save : Icons.add_task,
                  ),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      isEditing ? 'SAVE CHANGES' : 'CREATE TASK',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
