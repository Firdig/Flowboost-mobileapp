import 'auth_service.dart';

class LoginService {
  LoginService({AuthService? auth}) : _auth = auth ?? AuthService();

  final AuthService _auth;

  Future<void> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final e = email.trim();

    if (e.isEmpty || password.isEmpty) {
      throw const LoginInputException('Email dan password wajib diisi');
    }

    await _auth.signInWithEmail(email: e, password: password);
  }

  Future<void> loginWithGoogle() => _auth.signInWithGoogle();

  Future<void> loginWithFacebook() => _auth.signInWithFacebook();
}

class LoginInputException implements Exception {
  final String message;
  const LoginInputException(this.message);

  @override
  String toString() => message;
}
