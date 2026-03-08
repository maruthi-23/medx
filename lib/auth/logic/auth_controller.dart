import 'package:firebase_auth/firebase_auth.dart';
import 'package:medx/auth/data/auth_repository.dart';

class AuthController {
  final AuthRepository authRepository;

  AuthController(this.authRepository);

  // ================= SIGNUP =================
  Future<String?> signup(
      String email, String password, String username) async {
    try {
      if (email.isEmpty ||
          password.isEmpty ||
          username.isEmpty) {
        return "All fields are required";
      }

      if (password.length < 6) {
        return "Password must be at least 6 characters";
      }

      await authRepository.signup(email, password, username);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // ================= LOGIN =================
  Future<String?> login(
      String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return "Email and Password required";
      }

      await authRepository.login(email, password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      await authRepository.signInWithGoogle();
      return null;
    } catch (e) {
      return "Google sign in failed";
    }
  }

  Future<String?> sendPasswordReset(String email) async {
    try {
      await authRepository.sendPasswordReset(email);
      return null;
    } catch (e) {
      return "Failed to send reset email";
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
  }
}