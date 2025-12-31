import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // ===== EMAIL/PASSWORD =====

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? displayName, // nickname opsional
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (displayName != null && displayName.trim().isNotEmpty) {
      await cred.user?.updateDisplayName(displayName.trim());
      await cred.user?.reload();
    }

    return cred;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ===== GOOGLE =====
  // Native: pakai google_sign_in; Web: pakai signInWithPopup
  // File: lib/services/auth_service.dart

  Future<UserCredential> signInWithGoogle() async {
    // 1. Web Handling
    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();
      return _auth.signInWithPopup(googleProvider);
    }

    try {
      // 2. Trigger flow login (Versi Baru: authenticate)
      // Method ini akan melempar error jika user membatalkan login (klik silang/back)
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

      // 3. Ambil detail otentikasi
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 4. Buat credential Firebase
      // PENTING: Di versi baru, cukup gunakan idToken. accessToken tidak wajib/tidak tersedia.
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: null, 
      );

      // 5. Login ke Firebase
      return _auth.signInWithCredential(credential);
      
    } catch (e) {
      // Tangkap error spesifik pembatalan atau error lainnya
      throw FirebaseAuthException(
        code: 'GOOGLE_SIGN_IN_FAILED',
        message: 'Gagal login Google: $e',
      );
    }
  }

  // ===== FACEBOOK =====
  // Native: pakai flutter_facebook_auth; Web: pakai signInWithPopup
  Future<UserCredential> signInWithFacebook() async {
    if (kIsWeb) {
      final facebookProvider = FacebookAuthProvider();
      return _auth.signInWithPopup(facebookProvider);
    }

    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status != LoginStatus.success) {
      throw FirebaseAuthException(
        code: 'facebook_login_failed',
        message: 'Facebook login gagal / dibatalkan: ${result.status}',
      );
    }

    final accessToken = result.accessToken;
    if (accessToken == null) {
      throw FirebaseAuthException(
        code: 'facebook_no_token',
        message: 'Access token Facebook kosong.',
      );
    }

    // flutter_facebook_auth terbaru pakai tokenString (bukan token)
    final credential = FacebookAuthProvider.credential(accessToken.tokenString);

    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();

    // opsional tapi disarankan untuk “bersih”
    if (!kIsWeb) {
      await GoogleSignIn.instance.signOut();
    }
  }
}
