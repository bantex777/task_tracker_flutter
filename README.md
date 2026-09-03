# Task Tracker Flutter App

A complete local Flutter Task Tracker using:

- Flutter
- BLoC
- Repository pattern
- SharedPreferences
- Material 3

## Features

- Create task
- Edit task
- Delete task
- Mark task complete/incomplete
- Search tasks
- Filter All / Active / Completed
- Low / Medium / High priority
- Optional due date
- Persistent local storage
- Empty states
- Delete confirmation
- Form validation

## Run the project

This ZIP contains the important Flutter source files.

### Option A — Create a fresh Flutter shell

```bash
flutter create task_tracker
cd task_tracker
```

Replace:

- `lib/`
- `pubspec.yaml`
- `analysis_options.yaml`

with the files from this package.

Then:

```bash
flutter pub get
flutter run
```

### Option B — Use this folder directly

If Flutter-generated platform folders are missing, run:

```bash
flutter create .
flutter pub get
flutter run
```

Flutter will generate Android, iOS, Web, macOS, Windows, and Linux project files without replacing your `lib` source code.

## Folder structure

```text
lib/
├── main.dart
├── bloc/
│   └── task/
│       ├── task_bloc.dart
│       ├── task_event.dart
│       └── task_state.dart
├── models/
│   └── task.dart
├── repositories/
│   └── task_repository.dart
└── screens/
    ├── create_task_screen.dart
    └── task_list_screen.dart
```

## Architecture

UI
↓
TaskBloc
↓
TaskRepository
↓
SharedPreferences

The UI sends events such as:

```dart
context.read<TaskBloc>().add(AddTask(task));
```

The BLoC updates state:

```dart
emit(state.copyWith(tasks: tasks));
```

The UI automatically rebuilds with:

```dart
BlocConsumer<TaskBloc, TaskState>
```

## Useful commands

```bash
flutter doctor
flutter pub get
flutter analyze
flutter run
```
