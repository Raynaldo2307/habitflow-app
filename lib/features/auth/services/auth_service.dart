import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register user
  Future<String?> registerWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // null means success
    } on FirebaseAuthException catch (e) {
      return e.message; // meaningful error
    } catch (e) {
      return "Unknown error: $e";
    }
  }

  // Login user
  Future<String?> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // null means success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unknown error: $e";
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  
  
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('seenOnboarding');  // reset onboarding
}
  

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
