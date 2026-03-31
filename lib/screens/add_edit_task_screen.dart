import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:todo_flutter/models/task.dart';
import 'package:todo_flutter/providers/task_provider.dart';
import '../app_localizations.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  const AddEditTaskScreen({Key? key, this.task}) : super(key: key);

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  String? _description;
  DateTime? _dueDate;
  int _priority = 2;
  String _tagsText = '';

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    if (t != null) {
      _title = t.title;
      _description = t.description;
      _dueDate = t.dueDate;
      _priority = t.priority;
      _tagsText = t.tags.join(', ');
    } else {
      _title = '';
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _dueDate != null
          ? TimeOfDay.fromDateTime(_dueDate!)
          : TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() {
      _dueDate =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final tags = _tagsText
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (widget.task != null) {
      final t = widget.task!;
      t.title = _title;
      t.description = _description;
      t.dueDate = _dueDate;
      t.priority = _priority;
      t.tags = tags;
      provider.updateTask(t);
    } else {
      final newTask = Task(
        id: '',
        title: _title,
        description: _description,
        dueDate: _dueDate,
        priority: _priority,
        tags: tags,
      );
      provider.addTask(newTask);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(isEditing ? loc.t('saveChanges') : loc.t('addButton'))),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: loc.t('titleLabel')),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? loc.t('enterTitle') : null,
                onSaved: (v) => _title = v!.trim(),
              ),
              TextFormField(
                initialValue: _description,
                decoration:
                    InputDecoration(labelText: loc.t('descriptionLabel')),
                maxLines: 3,
                onSaved: (v) => _description = v?.trim(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickDateTime,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_dueDate == null
                        ? loc.t('chooseDate')
                        : DateFormat.yMd(loc.locale.languageCode)
                            .add_jm()
                            .format(_dueDate!.toLocal())),
                  ),
                  if (_dueDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _dueDate = null),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _priority,
                items: [
                  DropdownMenuItem(
                      child: Text(loc.t('priorityHigh')), value: 1),
                  DropdownMenuItem(
                      child: Text(loc.t('priorityNormal')), value: 2),
                  DropdownMenuItem(child: Text(loc.t('priorityLow')), value: 3),
                ],
                onChanged: (v) => setState(() => _priority = v ?? 2),
                decoration: InputDecoration(labelText: loc.t('priorityLabel')),
              ),
              TextFormField(
                initialValue: _tagsText,
                decoration: InputDecoration(labelText: loc.t('tagsLabel')),
                onSaved: (v) => _tagsText = v ?? '',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child:
                    Text(isEditing ? loc.t('saveChanges') : loc.t('addButton')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
