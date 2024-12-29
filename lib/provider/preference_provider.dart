
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../helper/task_database.dart';
import '../model/task_model.dart';
import '../model/user_preference_model.dart';

final taskProvider = StateNotifierProvider<TaskViewModel, List<Task>>((ref) {
  return TaskViewModel(ref);
});
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) => ThemeNotifier());
final userPreferencesProvider =
StateNotifierProvider<UserPreferencesViewModel, UserPreferences>((ref) {
  return UserPreferencesViewModel(ref);
});

class TaskViewModel extends StateNotifier<List<Task>> {
  final Ref ref;

  TaskViewModel(this.ref) : super([]) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    final tasks = await DatabaseHelper().getTasks();
     final sortOrder = ref.read(userPreferencesProvider).defaultSortOrder;
    //
    if (sortOrder == 'priority') {
      state = _sortByPriority(tasks);
      //tasks.sort((a, b) => a.priority.compareTo(b.priority));
    }else if (sortOrder == 'date') {
      tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      state = tasks;
    }

  }

  Future<void> addTask(Task task) async {
    await DatabaseHelper().insertTask(task);
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await DatabaseHelper().updateTask(task);
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await DatabaseHelper().deleteTask(id);
    await loadTasks();
  }

  List<Task> _sortByPriority(List<Task> tasks) {
    const priorityOrder = {'High': 1, 'Medium': 2, 'Low': 3};
    tasks.sort((a, b) {
      final priorityComparison = priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
      if (priorityComparison != 0) {
        return priorityComparison;
      }
      return priorityComparison; // Secondary sort by due date
    });
    return tasks;
  }
}

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(Hive.box('preferences').get('isDarkTheme', defaultValue: false));

  void toggleTheme() {
    final newTheme = !state;
    state = newTheme;
    Hive.box('preferences').put('isDarkTheme', newTheme);
  }
}

class UserPreferencesViewModel extends StateNotifier<UserPreferences> {
  final Ref ref;

  UserPreferencesViewModel(this.ref)
      : super(UserPreferences(isDarkMode: false, defaultSortOrder: 'date')) {
    _loadPreferences();
  }

  void _loadPreferences() async {
    final box = await Hive.openBox('userPreferences');
    if (box.isNotEmpty) {
      final preferencesMap = box.get('preferences');
      state = UserPreferences.fromMap(preferencesMap);
    }
  }

  void setSortOrder(String order) async {
    final box = await Hive.openBox('userPreferences');
    final updatedPreferences = state.toMap();
    updatedPreferences['defaultSortOrder'] = order;
    box.put('preferences', updatedPreferences);

    state = UserPreferences.fromMap(updatedPreferences);

    await ref.read(taskProvider.notifier).loadTasks();
  }
}

