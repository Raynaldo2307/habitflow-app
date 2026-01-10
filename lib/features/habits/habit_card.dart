import 'package:flutter/material.dart';

import '../../models/habit.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.onToggle,
    required this.onTap,
  });

  final Habit habit;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isCompleted ? const Color(0xFF1CA7EC) : const Color(0xFF2A2A2A);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFFDEF4FF)
                    : const Color(0xFFF2F5F8),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                habit.emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _Pill(text: habit.frequency),
                      if (habit.targetPerDay != null)
                        _Pill(text: '${habit.targetPerDay}x'),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 28,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF1CA7EC)
                      : const Color(0xFFE6EDF3),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Align(
                  alignment:
                      isCompleted ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.circle_outlined,
                      size: 16,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4A5568),
        ),
      ),
    );
  }
}
