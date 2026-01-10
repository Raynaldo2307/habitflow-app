import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_helpers.dart';
import '../../models/habit.dart';
import '../../models/habit_log.dart';
import '../../routes/app_routes.dart';
import '../../services/habit_service.dart';

class HabitDetailsScreen extends StatefulWidget {
  const HabitDetailsScreen({super.key});

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  final TextEditingController _notesController = TextEditingController();
  Habit? _initialHabit;
  String? _habitId;
  bool _initialized = false;
  bool _noteDirty = false;
  bool? _localCompleted;
  String? _todayKey;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Habit) {
      _initialHabit = args;
      _habitId = args.id;
    } else if (args is String) {
      _habitId = args;
    }

    _initialized = true;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_habitId == null) {
      return const Scaffold(body: Center(child: Text('Habit not found')));
    }

    final habitService = context.read<HabitService>();
    final today = DateTime.now();
    final recentDays = DateHelpers.lastDays(today, 7);
    _todayKey = DateHelpers.dateKey(today);

    return Scaffold(
      body: StreamBuilder<Habit?>(
        stream: habitService.habitStream(_habitId!),
        builder: (context, habitSnapshot) {
          if (habitSnapshot.hasError) {
            return const Center(child: Text('Error loading habit data.'));
          }

          final habit = habitSnapshot.data ?? _initialHabit;
          if (habit == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<List<HabitLog>>(
            stream: habitService.logsForHabit(habit.id, limit: 30),
            builder: (context, logsSnapshot) {
              if (logsSnapshot.hasError) {
                return const Center(
                  child: Text('Failed to load logs. Try again later.'),
                );
              }

              final logs = logsSnapshot.data ?? [];
              final logsByDate = {for (final log in logs) log.dateKey: log};
              final todayLog = logsByDate[_todayKey];
              final firestoreCompleted = todayLog?.isCompleted ?? false;
              final isCompleted = _localCompleted ?? firestoreCompleted;

              // Reset _localCompleted on day change
              if (_localCompleted != null && !_habitId!.contains(_todayKey!)) {
                _localCompleted = null;
              }

              final streak = _calculateStreak(logsByDate, today);

              if (!_noteDirty) {
                _notesController.text = todayLog?.notes ?? '';
              }

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _DetailsHeader(
                      habit: habit,
                      streak: streak,
                      onEdit: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          AppRoutes.addHabit,
                          arguments: habit,
                        );
                        if (!mounted) {
                          return;
                        }
                        _showSaveSnack(result);
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Text(
                        'Last 7 days',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: recentDays.map((date) {
                          final key = DateHelpers.dateKey(date);
                          final done = logsByDate[key]?.isCompleted ?? false;
                          return _DayChip(date: date, done: done);
                        }).toList(),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                      child: Text(
                        'Today',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Completed',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const Spacer(),
                                Switch(
                                  value: isCompleted,
                                  onChanged: (value) async {
                                    setState(() => _localCompleted = value);
                                    try {
                                      await habitService.setHabitLog(
                                        habitId: habit.id,
                                        date: today,
                                        isCompleted: value,
                                        notes:
                                            _notesController.text.trim().isEmpty
                                            ? null
                                            : _notesController.text.trim(),
                                      );
                                      if (!mounted) {
                                        return;
                                      }
                                      _showSnackMessage(
                                        value
                                            ? 'Marked as completed 🎉'
                                            : 'Marked as incomplete',
                                      );
                                    } catch (e) {
                                      if (!mounted) {
                                        return;
                                      }
                                      _showSnackMessage(
                                        'Failed to update. Try again.',
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _notesController,
                              maxLines: 3,
                              onChanged: (_) => _noteDirty = true,
                              decoration: const InputDecoration(
                                labelText: 'Notes for today (optional)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: _isSaving
                                    ? null
                                    : () async {
                                        setState(() => _isSaving = true);
                                        try {
                                          await habitService.setHabitLog(
                                            habitId: habit.id,
                                            date: today,
                                            isCompleted: isCompleted,
                                            notes:
                                                _notesController.text
                                                    .trim()
                                                    .isEmpty
                                                ? null
                                                : _notesController.text.trim(),
                                          );
                                          if (!mounted) {
                                            return;
                                          }
                                          setState(() => _noteDirty = false);
                                          _showSnackMessage(
                                            'Note saved for today 📝',
                                          );
                                        } catch (e) {
                                          if (!mounted) {
                                            return;
                                          }
                                          _showSnackMessage(
                                            'Failed to save note. Please try again.',
                                          );
                                        } finally {
                                          if (mounted) {
                                            setState(() => _isSaving = false);
                                          }
                                        }
                                      },
                                icon: const Icon(Icons.save_outlined),
                                label: const Text('Save note'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                      child: Text(
                        'Recent activity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (logsSnapshot.connectionState == ConnectionState.waiting &&
                      logs.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else if (logs.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'No logs yet. Toggle today to start your streak.',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final log = logs[index];
                        final date = _parseDateKey(log.dateKey);
                        return ListTile(
                          leading: Icon(
                            log.isCompleted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: log.isCompleted
                                ? const Color(0xFF1CA7EC)
                                : const Color(0xFFCBD5E1),
                          ),
                          title: Text(DateHelpers.formatMediumDate(date)),
                          subtitle: log.notes == null || log.notes!.isEmpty
                              ? null
                              : Text(log.notes!),
                        );
                      }, childCount: logs.length),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showSnackMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSaveSnack(Object? result) {
    if (result is! String || result.isEmpty) {
      return;
    }
    _showSnackMessage(result);
  }

  int _calculateStreak(Map<String, HabitLog> logsByDate, DateTime today) {
    var streak = 0;
    for (var i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: i));
      final key = DateHelpers.dateKey(date);
      final log = logsByDate[key];
      if (log != null && log.isCompleted) {
        streak += 1;
      } else {
        break;
      }
    }
    return streak;
  }

  DateTime _parseDateKey(String dateKey) {
    try {
      return DateTime.parse(dateKey);
    } catch (_) {
      return DateTime.now();
    }
  }
}

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader({
    required this.habit,
    required this.streak,
    required this.onEdit,
  });

  final Habit habit;
  final int streak;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 220,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2BB3F3), Color(0xFF1A6FD1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: -30,
          right: -10,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.white,
                ),
                const Spacer(),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(habit.emoji, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(height: 10),
              Text(
                habit.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                streak == 1 ? '1-day streak' : '$streak-day streak',
                style: const TextStyle(color: Color(0xFFD9F2FF)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.date, required this.done});

  final DateTime date;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final background = done ? const Color(0xFF1CA7EC) : const Color(0xFFF1F5F9);
    final textColor = done ? Colors.white : const Color(0xFF475569);
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            DateHelpers.weekdayShort(date),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
