import 'package:medx/auth/data/auth_service.dart';

class AuthRepository {
  final AuthService _service;

  AuthRepository(this._service);

  Future<void> signup(
      String email, String password, String username) async {
    await _service.signup(email, password, username);
  }

  Future<void> login(String email, String password) async {
    await _service.login(email, password);
  }

  Future<void> signInWithGoogle() async {
    await _service.signInWithGoogle();
  }

  Future<void> sendPasswordReset(String email) async {
    await _service.sendPasswordReset(email);
  }

  Future<void> logout() async {
    await _service.logout();
  }
}