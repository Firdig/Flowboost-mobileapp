import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/auth_service.dart';

const String logoPath = 'assets/images/Backlogtable.png';

class FlowboostSignUpScreen extends StatefulWidget {
  const FlowboostSignUpScreen({super.key});

  @override
  State<FlowboostSignUpScreen> createState() => _FlowboostSignUpScreenState();
}

class _FlowboostSignUpScreenState extends State<FlowboostSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _nicknameC = TextEditingController();
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  final _passwordC = TextEditingController();
  final _confirmPasswordC = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nicknameC.dispose();
    _emailC.dispose();
    _phoneC.dispose();
    _passwordC.dispose();
    _confirmPasswordC.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_passwordC.text != _confirmPasswordC.text) {
      _showSnack('Password dan konfirmasi password tidak sama.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.registerWithEmail(
        email: _emailC.text.trim(),
        password: _passwordC.text,
        displayName: _nicknameC.text.trim(),
      );

      if (!mounted) return;
      _showSnack('Registrasi berhasil. Kamu sudah login.');

      // TODO: pindah ke halaman home / login sesuai flow kamu
      // Navigator.pushReplacement(...);

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showSnack(_mapAuthError(e));
    } catch (e) {
      if (!mounted) return;
      _showSnack('Terjadi error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter).';
      case 'operation-not-allowed':
        return 'Email/Password belum di-enable di Firebase Console.';
      default:
        return 'Gagal registrasi (${e.code}).';
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTextColor = Colors.black;
    const Color hintTextColor = Colors.grey;
    const Color inputFillColor = Colors.black;
    const Color buttonColor = Color.fromARGB(255, 108, 150, 180);
    const TextStyle labelStyle =
        TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: primaryTextColor);

    const double screenPadding = 24.0;
    const double fieldSpacing = 16.0;
    const double borderRadius = 8.0;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 240, 227),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, toolbarHeight: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: screenPadding, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Image.asset(
                    logoPath,
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 80, color: Colors.black);
                    },
                  ),
                ),
                const SizedBox(height: 40),

                _buildInputField(
                  controller: _nicknameC,
                  label: 'Nickname',
                  hintText: 'Username',
                  labelStyle: labelStyle,
                  fillColor: inputFillColor,
                  hintTextColor: hintTextColor,
                  borderRadius: borderRadius,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nickname wajib diisi' : null,
                ),
                SizedBox(height: fieldSpacing),

                _buildInputField(
                  controller: _emailC,
                  label: 'Email',
                  hintText: 'Email',
                  labelStyle: labelStyle,
                  fillColor: inputFillColor,
                  hintTextColor: hintTextColor,
                  borderRadius: borderRadius,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'Email wajib diisi';
                    if (!s.contains('@')) return 'Email tidak valid';
                    return null;
                  },
                ),
                SizedBox(height: fieldSpacing),

                _buildInputField(
                  controller: _phoneC,
                  label: 'Phone number',
                  hintText: 'Phone number',
                  keyboardType: TextInputType.phone,
                  labelStyle: labelStyle,
                  fillColor: inputFillColor,
                  hintTextColor: hintTextColor,
                  borderRadius: borderRadius,
                  // Ini profil saja (bukan metode login), jadi boleh opsional:
                  validator: (_) => null,
                ),
                SizedBox(height: fieldSpacing),

                _buildInputField(
                  controller: _passwordC,
                  label: 'Password',
                  hintText: 'Password',
                  isPassword: true,
                  labelStyle: labelStyle,
                  fillColor: inputFillColor,
                  hintTextColor: hintTextColor,
                  borderRadius: borderRadius,
                  validator: (v) {
                    final s = v ?? '';
                    if (s.isEmpty) return 'Password wajib diisi';
                    if (s.length < 6) return 'Minimal 6 karakter';
                    return null;
                  },
                ),
                SizedBox(height: fieldSpacing),

                _buildInputField(
                  controller: _confirmPasswordC,
                  label: 'Confirmation Password',
                  hintText: 'Confirm Password',
                  isPassword: true,
                  labelStyle: labelStyle,
                  fillColor: inputFillColor,
                  hintTextColor: hintTextColor,
                  borderRadius: borderRadius,
                  validator: (v) => (v == null || v.isEmpty) ? 'Konfirmasi password wajib diisi' : null,
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _isLoading ? null : _onRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Already have an Account? ',
                        style: TextStyle(color: primaryTextColor, fontSize: 16)),
                    GestureDetector(
                      onTap: () {
                        // TODO: navigasi ke login screen
                      },
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          color: buttonColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          decorationColor: buttonColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required TextStyle labelStyle,
    required Color fillColor,
    required Color hintTextColor,
    required double borderRadius,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: hintTextColor.withOpacity(0.7)),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
