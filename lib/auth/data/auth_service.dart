import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ================= EMAIL SIGNUP =================
  Future<void> signup(String email, String password, String username) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(username);
  }

  // ================= EMAIL LOGIN =================
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ================= GOOGLE SIGN IN =================
  Future<void> signInWithGoogle() async {
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();

    try {
      if (kIsWeb) {
        await _auth.signInWithPopup(googleProvider);
      } else {
        await _auth.signInWithProvider(googleProvider);
      }
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  // ================= FORGOT PASSWORD =================
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await _auth.signOut();
  }
}