// UI
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management/screen/task_detail_screen.dart';
import 'package:task_management/screen/task_dialogue_screen.dart';

import '../model/task_model.dart';
import '../provider/preference_provider.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              ref.read(userPreferencesProvider.notifier).setSortOrder(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'date', child: Text('Sort by Date')),
              const PopupMenuItem(value: 'priority', child: Text('Sort by Priority')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: themeNotifier.toggleTheme,
          ),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('No tasks yet.'))
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            child: ListTile(
              title: Text(task.title),
              subtitle: Text('${task.description} - ${task.priority} - ${task.dueDate}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () async {
                      _showTaskDialog(
                        context,
                        ref,
                        task: task,
                      );

                      // final updatedTask = await showDialog<Task>(
                      //   context: context,
                      //   builder: (_) => TaskDialog(task: task),
                      // );
                      //
                      // if (updatedTask != null) {
                      //   ref.read(taskProvider.notifier).updateTask(updatedTask);
                      // }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => ref.read(taskProvider.notifier).deleteTask(task.id!),
                  ),
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) {
                      ref.read(taskProvider.notifier).updateTask(
                        Task(
                          id: task.id,
                          title: task.title,
                          description: task.description,
                          isCompleted: value ?? false, priority: task.priority,dueDate: task.dueDate
                        ),
                      );
                    },
                  ),
                ],
              ),
              onTap: () {
                // Navigate to Task Details
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskDetailsScreen(task: task),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showTaskDialog(context, ref),
      ),
    );
  }

  void _showTaskDialog(BuildContext context, WidgetRef ref, {Task? task}) {
    showDialog(
      context: context,
      builder: (context) {
        return TaskDialog(
          task: task,
          onSave: (updatedTask) {
            if (task == null) {
              ref.read(taskProvider.notifier).addTask(updatedTask);
            } else {
              ref.read(taskProvider.notifier).updateTask(updatedTask);
            }
          },
        );
      },
    );
  }
}

