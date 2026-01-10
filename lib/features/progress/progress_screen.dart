import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_helpers.dart';
import '../../models/habit.dart';
import '../../models/habit_log.dart';
import '../../services/habit_service.dart';
import 'progress_chart.dart';
import 'stats_card.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitService = context.read<HabitService>();
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 6));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: StreamBuilder<List<Habit>>(
          stream: habitService.habitsStream(),
          builder: (context, habitsSnapshot) {
            final habits = habitsSnapshot.data ?? [];
            return StreamBuilder<List<HabitLog>>(
              stream: habitService.logsForDateRange(start, today),
              builder: (context, logsSnapshot) {
                final logs = logsSnapshot.data ?? [];
                final habitIds = habits.map((habit) => habit.id).toSet();
                final filteredLogs =
                    logs.where((log) => habitIds.contains(log.habitId)).toList();
                final todayKey = DateHelpers.dateKey(today);
                final completedToday = filteredLogs
                    .where((log) =>
                        log.dateKey == todayKey && log.isCompleted)
                    .length;
                final totalHabits = habits.length;
                final weeklyCompleted =
                    filteredLogs.where((log) => log.isCompleted).length;
                final weeklyTotal = totalHabits * 7;
                final weeklyPercent =
                    weeklyTotal == 0 ? 0.0 : (weeklyCompleted / weeklyTotal);

                final last7Days = DateHelpers.lastDays(today, 7);
                final countsByDate = <String, int>{};
                for (final log in filteredLogs) {
                  if (!log.isCompleted) {
                    continue;
                  }
                  countsByDate[log.dateKey] =
                      (countsByDate[log.dateKey] ?? 0) + 1;
                }
                final dailyProgress = last7Days
                    .map((date) {
                      final key = DateHelpers.dateKey(date);
                      final count = countsByDate[key] ?? 0;
                      return totalHabits == 0
                          ? 0.0
                          : count / totalHabits;
                    })
                    .toList();
                final dayLabels =
                    last7Days.map(DateHelpers.weekdayShort).toList();

                return ListView(
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Keep an eye on your weekly momentum',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Completed Today',
                            value: '$completedToday/$totalHabits',
                            subtitle: 'Habits',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            title: 'Weekly Success',
                            value: '${(weeklyPercent * 100).round()}%',
                            subtitle: 'Last 7 days',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ProgressChart(
                      values: dailyProgress,
                      labels: dayLabels,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Weekly completion rate',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 10,
                              value: weeklyPercent,
                              backgroundColor: const Color(0xFFE2E8F0),
                              color: const Color(0xFF1CA7EC),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$weeklyCompleted completions out of $weeklyTotal',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
