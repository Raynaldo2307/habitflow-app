import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/app_user.dart';

class UserService {
  UserService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  Stream<AppUser?> userStream() {
    final uid = _uid;
    if (uid == null) {
      return Stream.value(null);
    }
    return _userRef(uid).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      final data = doc.data() ?? {};
      return AppUser.fromMap(uid, data);
    });
  }

  Future<void> ensureUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }
    final docRef = _userRef(user.uid);
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      return;
    }
    final email = user.email ?? '';
    final displayName = user.displayName ?? _nameFromEmail(email);
    await docRef.set({
      'email': email,
      'displayName': displayName,
      'photoUrl': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }
    await _userRef(user.uid).set({
      'displayName': name,
      'email': user.email ?? '',
      'photoUrl': user.photoURL,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await user.updateDisplayName(name);
  }

  String _nameFromEmail(String email) {
    if (email.isEmpty) {
      return 'Friend';
    }
    final handle = email.split('@').first;
    if (handle.isEmpty) {
      return 'Friend';
    }
    return handle[0].toUpperCase() + handle.substring(1);
  }

  Future<void> uploadProfilePicture(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    final ref = FirebaseStorage.instance
        .ref()
        .child('avatars/${user.uid}.jpg');
    await ref.putFile(imageFile);
    final url = await ref.getDownloadURL();

    await user.updatePhotoURL(url);
    await _userRef(user.uid).set({
      'photoUrl': url,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
