import 'package:firebase_auth/firebase_auth.dart';
import 'package:medx/auth/data/auth_repository.dart';

class AuthController {
  final AuthRepository authRepository;

  AuthController(this.authRepository);

  bool isLoading = false;

  // ================= SIGNUP =================
  Future<String?> signup(
    String email,
    String password,
    String username,
  ) async {
    try {
      isLoading = true;

      // Basic validation
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        return "All fields are required";
      }

      if (!email.contains("@")) {
        return "Enter a valid email";
      }

      if (password.length < 6) {
        return "Password must be at least 6 characters";
      }

      await authRepository.signup(email, password, username);
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return "Something went wrong. Try again.";
    } finally {
      isLoading = false;
    }
  }

  // ================= LOGIN =================
  Future<String?> login(
    String email,
    String password,
  ) async {
    try {
      isLoading = true;

      if (email.isEmpty || password.isEmpty) {
        return "Email and Password are required";
      }

      if (password.length < 6) {
        return "Password must be at least 6 characters";
      }

      await authRepository.login(email, password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return "Something went wrong. Try again.";
    } finally {
      isLoading = false;
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await authRepository.logout();
  }

  // ================= ERROR HANDLER =================
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "Email is already registered.";
      case 'invalid-email':
        return "Invalid email format.";
      case 'weak-password':
        return "Password is too weak.";
      case 'user-not-found':
        return "No user found with this email.";
      case 'wrong-password':
        return "Incorrect password.";
      default:
        return "Authentication failed. Please try again.";
    }
  }
}
