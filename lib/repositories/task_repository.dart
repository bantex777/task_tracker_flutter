import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskRepository {
  static const _storageKey = 'task_tracker_tasks';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<Task>> getTasks() async {
    final raw = _prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;

      return decoded
          .map(
            (item) => Task.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final raw = jsonEncode(
      tasks.map((task) => task.toJson()).toList(),
    );

    await _prefs.setString(_storageKey, raw);
  }
}
