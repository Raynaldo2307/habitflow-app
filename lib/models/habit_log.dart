import 'package:cloud_firestore/cloud_firestore.dart';

class HabitLog {
  final String id;
  final String habitId;
  final String dateKey;
  final bool isCompleted;
  final String? notes;
  final Timestamp? updatedAt;

  const HabitLog({
    required this.id,
    required this.habitId,
    required this.dateKey,
    required this.isCompleted,
    this.notes,
    this.updatedAt,
  });

  factory HabitLog.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      return HabitLog(
        id: doc.id,
        habitId: '',
        dateKey: '',
        isCompleted: false,
      );
    }
    return HabitLog(
      id: doc.id,
      habitId: data['habitId'] ?? '',
      dateKey: data['dateKey'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      notes: data['notes'],
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'habitId': habitId,
      'dateKey': dateKey,
      'isCompleted': isCompleted,
      'notes': notes,
    };
  }
}
