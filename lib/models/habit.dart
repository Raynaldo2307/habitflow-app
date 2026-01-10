import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String title;
  final String emoji;
  final String frequency;
  final int? targetPerDay;
  final bool isActive;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const Habit({
    required this.id,
    required this.title,
    required this.emoji,
    required this.frequency,
    required this.targetPerDay,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Habit.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      return Habit(
        id: doc.id,
        title: '',
        emoji: '✅',
        frequency: 'daily',
        targetPerDay: null,
        isActive: false,
      );
    }
    final targetRaw = data['targetPerDay'];
    final targetPerDay =
        targetRaw is num ? targetRaw.toInt() : targetRaw as int?;
    return Habit(
      id: doc.id,
      title: data['title'] ?? '',
      emoji: data['emoji'] ?? '✅',
      frequency: data['frequency'] ?? 'daily',
      targetPerDay: targetPerDay,
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'emoji': emoji,
      'frequency': frequency,
      'targetPerDay': targetPerDay,
      'isActive': isActive,
    };
  }
}
