import 'package:flutter/material.dart';
import '../model/task_model.dart';

class TaskDialog extends StatefulWidget {
  final Task? task; // If editing, this will be the task to edit
  final Function(Task task) onSave;

  const TaskDialog({Key? key, this.task, required this.onSave}) : super(key: key);

  @override
  _TaskDialogState createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late String _priority;
  late DateTime _dueDate;

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _priority = widget.task?.priority ?? 'Medium';
    _dueDate = widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 1));// Default priority
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final task = Task(
        id: widget.task?.id,
        title: _title,
        description: _description,
        priority: _priority,
        dueDate: _dueDate,
        isCompleted: widget.task?.isCompleted ?? false,
      );
      widget.onSave(task);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value!,
              ),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: ['High', 'Medium', 'Low']
                    .map((priority) => DropdownMenuItem(
                  value: priority,
                  child: Text(priority),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _priority = value!),
                onSaved: (value) => _priority = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Due Date'),
                readOnly: true,
                controller: TextEditingController(text: _dueDate.toLocal().toString().split(' ')[0]),
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    setState(() => _dueDate = selectedDate);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveTask,
          child: Text('Save'),
        ),
      ],
    );
  }
}
