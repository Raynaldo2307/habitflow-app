import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

import 'package:firebase_auth/firebase_auth.dart';
class AuthService {
  final FirebaseAuth _auth =FirebaseAuth.instance;

  Future<User?> registerWithEmail (String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e){
      printToConsole('Registration Error: $e');
       return null;
    }

  }

Future<User?> loginWithEmail(String email, String password) async{
  try {
    UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return result.user;
  }catch(e){
    printToConsole('Login Error: $e');
    return null;
  }
}
Future<void> signOut() async{
  try{
    await _auth.signOut();
  }catch (e){
    printToConsole('Sign Out Error: $e');
  }
}
Stream<User?> get authStateChanges => _auth.authStateChanges();
}
