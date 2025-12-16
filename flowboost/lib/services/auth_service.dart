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
  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();
      return _auth.signInWithPopup(googleProvider);
    }

    // Trigger the authentication flow
    final GoogleSignInAccount googleUser =
        await GoogleSignIn.instance.authenticate();

    // Obtain auth details
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    // Create credential (Firebase)
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
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
      await FacebookAuth.instance.logOut();
    }
  }
}
