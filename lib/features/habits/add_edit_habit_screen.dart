import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/habit.dart';
import '../../services/habit_service.dart';

class AddEditHabitScreen extends StatefulWidget {
  const AddEditHabitScreen({super.key});

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();

  Habit? _habit;
  String _emoji = _emojiOptions.first;
  String _frequency = 'daily';
  bool _isActive = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Habit) {
      _habit = arguments;
      _titleController.text = arguments.title;
      _emoji = arguments.emoji;
      _frequency = arguments.frequency;
      _isActive = arguments.isActive;
      if (arguments.targetPerDay != null) {
        _targetController.text = '${arguments.targetPerDay}';
      }
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final habitService = context.read<HabitService>();
    final target = _targetController.text.isEmpty
        ? null
        : int.tryParse(_targetController.text);
    final isEditing = _habit != null;

    await habitService.saveHabit(
      habitId: _habit?.id,
      title: _titleController.text.trim(),
      emoji: _emoji,
      frequency: _frequency,
      targetPerDay: target,
      isActive: _isActive,
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(
      context,
      isEditing ? 'Habit updated.' : 'Habit saved.',
    );
  }

  Future<void> _deleteHabit() async {
    if (_habit == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive habit?'),
        content: const Text(
          'This will hide the habit without deleting its history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final habitService = context.read<HabitService>();
    await habitService.setHabitActive(_habit!.id, false);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _habit != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: Text(isEditing ? 'Edit Habit' : 'Add Habit')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Please enter a habit title'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _emoji,
                    decoration: const InputDecoration(
                      labelText: 'Icon / Emoji',
                      border: OutlineInputBorder(),
                    ),
                    items: _emojiOptions
                        .map(
                          (emoji) => DropdownMenuItem(
                            value: emoji,
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _emoji = value ?? _emoji),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _frequency,
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    ],
                    onChanged: (value) =>
                        setState(() => _frequency = value ?? _frequency),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Target per day (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Active'),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveHabit,
                    child: const Text('Save'),
                  ),
                  if (isEditing) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _deleteHabit,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                      ),
                      child: const Text('Archive Habit'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const List<String> _emojiOptions = [
  '💧',
  '🏃',
  '📖',
  '🧘',
  '🍎',
  '💤',
  '📝',
  '🎯',
  '🦋',
  '✅',
];
