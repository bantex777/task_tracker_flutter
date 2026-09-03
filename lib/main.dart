import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/task/task_bloc.dart';
import 'repositories/task_repository.dart';
import 'screens/task_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = TaskRepository();
  await repository.init();

  runApp(TaskTrackerApp(repository: repository));
}

class TaskTrackerApp extends StatelessWidget {
  final TaskRepository repository;

  const TaskTrackerApp({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: repository,
      child: BlocProvider(
        create: (_) => TaskBloc(repository)..add(const LoadTasks()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Task Tracker',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
          ),
          home: const TaskListScreen(),
        ),
      ),
    );
  }
}
