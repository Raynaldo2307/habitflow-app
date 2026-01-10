import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/utils/date_helpers.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';

class HabitService {
  HabitService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _requiredUid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated.');
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _habitsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('habits');
  }

  CollectionReference<Map<String, dynamic>> _logsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('habit_logs');
  }

  Stream<List<Habit>> habitsStream({bool activeOnly = true}) {
    try {
      final uid = _requiredUid;
      Query<Map<String, dynamic>> query = _habitsRef(uid);
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }
      return query.snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => Habit.fromDoc(doc)).toList(),
      );
    } catch (e) {
      debugPrint('habitsStream error: $e');
      return Stream.value([]);
    }
  }

  Stream<Habit?> habitStream(String habitId) {
    try {
      final uid = _requiredUid;
      return _habitsRef(uid).doc(habitId).snapshots().map((doc) {
        if (!doc.exists) return null;
        return Habit.fromDoc(doc);
      });
    } catch (e) {
      debugPrint('habitStream error: $e');
      return Stream.value(null);
    }
  }

  Future<String> saveHabit({
    String? habitId,
    required String title,
    required String emoji,
    required String frequency,
    int? targetPerDay,
    required bool isActive,
  }) async {
    try {
      final uid = _requiredUid;
      final data = {
        'title': title,
        'emoji': emoji,
        'frequency': frequency,
        'targetPerDay': targetPerDay,
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (habitId == null) {
        final doc = await _habitsRef(uid).add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return doc.id;
      }

      await _habitsRef(uid).doc(habitId).update(data);
      return habitId;
    } catch (e, stack) {
      debugPrint('saveHabit error: $e\n$stack');
      rethrow;
    }
  }

  Future<void> setHabitActive(String habitId, bool isActive) async {
    try {
      final uid = _requiredUid;
      await _habitsRef(uid).doc(habitId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('setHabitActive error: $e');
      rethrow;
    }
  }

  Stream<List<HabitLog>> logsForDate(DateTime date) {
    try {
      final uid = _requiredUid;
      final key = DateHelpers.dateKey(date);
      return _logsRef(uid)
          .where('dateKey', isEqualTo: key)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => HabitLog.fromDoc(doc)).toList());
    } catch (e) {
      debugPrint('logsForDate error: $e');
      return Stream.value([]);
    }
  }

  Stream<List<HabitLog>> logsForDateRange(DateTime start, DateTime end) {
    try {
      final uid = _requiredUid;
      final startKey = DateHelpers.dateKey(start);
      final endKey = DateHelpers.dateKey(end);
      return _logsRef(uid)
          .where('dateKey', isGreaterThanOrEqualTo: startKey)
          .where('dateKey', isLessThanOrEqualTo: endKey)
          .orderBy('dateKey')
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => HabitLog.fromDoc(doc)).toList());
    } catch (e) {
      debugPrint('logsForDateRange error: $e');
      return Stream.value([]);
    }
  }

  Stream<List<HabitLog>> logsForHabit(String habitId, {int limit = 30}) {
    try {
      final uid = _requiredUid;
      return _logsRef(uid)
          .where('habitId', isEqualTo: habitId)
          .orderBy('dateKey', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => HabitLog.fromDoc(doc)).toList());
    } catch (e) {
      debugPrint('logsForHabit error: $e');
      return Stream.value([]);
    }
  }

  Future<void> setHabitLog({
    required String habitId,
    required DateTime date,
    required bool isCompleted,
    String? notes,
  }) async {
    try {
      final uid = _requiredUid;
      final key = DateHelpers.dateKey(date);
      final docId = '${habitId}_$key';
      final data = <String, dynamic>{
        'habitId': habitId,
        'dateKey': key,
        'isCompleted': isCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (notes != null) {
        data['notes'] = notes;
      }
      await _logsRef(uid).doc(docId).set(data, SetOptions(merge: true));
    } catch (e, stack) {
      debugPrint('setHabitLog error: $e\n$stack');
      rethrow;
    }
  }
}
