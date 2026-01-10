import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_helpers.dart';
import '../../models/app_user.dart';
import '../../models/habit.dart';
import '../../models/habit_log.dart';
import '../../routes/app_routes.dart';
import '../../services/habit_service.dart';
import '../../services/user_service.dart';
import 'habit_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitService = context.read<HabitService>();
    final userService = context.read<UserService>();
    final now = DateTime.now();
    void showSaveSnack(Object? result) {
      if (result is! String || result.isEmpty) {
        return;
      }
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text(result)));
    }

    Future<void> openAddHabit() async {
      final result = await Navigator.pushNamed(context, AppRoutes.addHabit);
      if (!context.mounted) {
        return;
      }
      showSaveSnack(result);
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: openAddHabit,
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          const _HomeBackground(),
          SafeArea(
            child: StreamBuilder<List<Habit>>(
              stream: habitService.habitsStream(),
              builder: (context, habitsSnapshot) {
                final habits = habitsSnapshot.data ?? [];
                return StreamBuilder<List<HabitLog>>(
                  stream: habitService.logsForDate(now),
                  builder: (context, logsSnapshot) {
                    final logs = logsSnapshot.data ?? [];
                    final logsByHabitId = {
                      for (final log in logs) log.habitId: log,
                    };
                    final completedCount = habits.where((habit) {
                      return logsByHabitId[habit.id]?.isCompleted ?? false;
                    }).length;
                    final totalCount = habits.length;
                    final progress = totalCount == 0
                        ? 0.0
                        : completedCount / totalCount;

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _Header(userService: userService),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                        SliverToBoxAdapter(
                          child: _ProgressSummary(
                            completedCount: completedCount,
                            totalCount: totalCount,
                            progress: progress,
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                            child: Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                        ),
                        if (habitsSnapshot.connectionState ==
                                ConnectionState.waiting &&
                            habits.isEmpty)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 32),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          )
                        else if (habits.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 24,
                              ),
                              child: _EmptyState(onAddHabit: openAddHabit),
                            ),
                          )
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final habit = habits[index];
                              final log = logsByHabitId[habit.id];
                              final isCompleted = log?.isCompleted ?? false;
                              return Padding(
                                padding: EdgeInsets.fromLTRB(
                                  20,
                                  index == 0 ? 4 : 12,
                                  20,
                                  6,
                                ),
                                child: HabitCard(
                                  habit: habit,
                                  isCompleted: isCompleted,
                                  onToggle: () => habitService.setHabitLog(
                                    habitId: habit.id,
                                    date: now,
                                    isCompleted: !isCompleted,
                                  ),
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.habitDetails,
                                    arguments: habit,
                                  ),
                                ),
                              );
                            }, childCount: habits.length),
                          ),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.userService});

  final UserService userService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: userService.userStream(),
      builder: (context, snapshot) {
        final authUser = FirebaseAuth.instance.currentUser;
        final fallbackName =
            authUser?.displayName ??
            authUser?.email?.split('@').first ??
            'Friend';
        final name = snapshot.data?.displayName ?? fallbackName;
        final dateLabel = DateHelpers.formatMediumDate(DateTime.now());

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            0,
          ), // space above + below
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row with Avatar + Notification Icon
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    radius: 22,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Greeting
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $name',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Today • $dateLabel',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFD9F2FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification Icon
                  IconButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications coming soon.'),
                      ),
                    ),
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16), // spacing between header and progress
            ],
          ),
        );
      },
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({
    required this.completedCount,
    required this.totalCount,
    required this.progress,
  });

  final int completedCount;
  final int totalCount;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$completedCount of $totalCount habits completed',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: const Color(0xFFE9EFF5),
                color: const Color(0xFF1CA7EC),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddHabit});

  final Future<void> Function() onAddHabit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No habits yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap the + button to add your first habit for today.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onAddHabit,
            icon: const Icon(Icons.add),
            label: const Text('Add habit'),
          ),
        ],
      ),
    );
  }
}

class _HomeBackground extends StatelessWidget {
  const _HomeBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: const Color(0xFFF4F8FB))),
        Positioned(
          top: -120,
          left: -40,
          right: -40,
          child: Container(
            height: 260,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF36B9F3), Color(0xFF1B7ED6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(48),
            ),
          ),
        ),
        Positioned(
          top: 60,
          right: 40,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 140,
          left: 24,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
