import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/login_service.dart';
import '../../../dashboard/main_scaffold.dart';
import '../../register/views/register.dart';

class FlowboostLoginScreen extends StatefulWidget {
  const FlowboostLoginScreen({super.key});

  static const String logoPath = 'assets/images/flowboost_logo.png';
  static const String googleIconPath = 'assets/images/google.png';
  static const String facebookIconPath = 'assets/images/facebook.png';

  @override
  State<FlowboostLoginScreen> createState() => _FlowboostLoginScreenState();
}

class _FlowboostLoginScreenState extends State<FlowboostLoginScreen> {
  final _loginService = LoginService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      await action();
    } catch (e) {
      if (!mounted) return;

      String message = 'Login gagal';
      if (e is LoginInputException) {
        message = e.message;
      } else if (e is FirebaseAuthException) {
        message = e.message ?? 'Login gagal (${e.code})';
      } else {
        message = 'Login gagal: $e';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goToMain() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScaffold()),
      (route) => false,
    );
  }

  Future<void> _handleLoginEmailPassword() async {
    await _loginService.loginWithEmailPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    _goToMain();
  }

  Future<void> _handleLoginGoogle() async {
    await _loginService.loginWithGoogle();

    if (!mounted) return;
    _goToMain();
  }

  Future<void> _handleLoginFacebook() async {
    await _loginService.loginWithFacebook();

    if (!mounted) return;
    _goToMain();
  }

  @override
  @override
Widget build(BuildContext context) {
  const bg = Color.fromARGB(255, 245, 240, 227);
  const primaryTextColor = Colors.black;
  const hintTextColor = Colors.grey;
  const inputFillColor = Colors.black;

  return Scaffold(
    backgroundColor: bg,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, c) {
          final isShort = c.maxHeight < 720; // layar pendek / keyboard
          final logoH = isShort ? 120.0 : 160.0;
          final titleSize = isShort ? 30.0 : 36.0;
          final padV = isShort ? 16.0 : 22.0;

          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: padV),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(
                          FlowboostLoginScreen.logoPath,
                          height: 300,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.favorite,
                            size: 70,
                            color: Colors.black,
                          ),
                        ),
                      ),

                     

                      const SizedBox(height: 14),

                      _LabeledField(
                        label: 'Email',
                        hintText: 'email@contoh.com',
                        hintTextColor: hintTextColor,
                        fillColor: inputFillColor,
                        controller: _emailController,
                      ),

                      const SizedBox(height: 8),

                      _LabeledField(
                        label: 'Password',
                        hintText: 'Password',
                        hintTextColor: hintTextColor,
                        fillColor: inputFillColor,
                        obscureText: true,
                        controller: _passwordController,
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _loading ? null : () => _run(_handleLoginEmailPassword),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 3),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      // const SizedBox(height: 16),

                      // const Text(
                      //   'Or Login with :',
                      //   textAlign: TextAlign.center,
                      //   style: TextStyle(fontSize: 16, color: primaryTextColor),
                      // ),

                      // const SizedBox(height: 12),

                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     _SocialIconButton(
                      //       assetPath: FlowboostLoginScreen.googleIconPath,
                      //       fallback: 'G',
                      //       onTap: _loading ? null : () => _run(_handleLoginGoogle),
                      //     ),
                      //     const SizedBox(width: 18),
                      //     _SocialIconButton(
                      //       assetPath: FlowboostLoginScreen.facebookIconPath,
                      //       fallback: 'f',
                      //       onTap: _loading ? null : () => _run(_handleLoginFacebook),
                      //     ),
                      //   ],
                      // ),

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Dont have an account? ',
                            style: TextStyle(fontSize: 16, color: primaryTextColor),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FlowboostSignUpScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 0, 160, 210),
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.w600,
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
        },
      ),
    ),
  );
}
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hintText,
    required this.hintTextColor,
    required this.fillColor,
    required this.controller,
    this.obscureText = false,
  });

  final String label;
  final String hintText;
  final Color hintTextColor;
  final Color fillColor;
  final bool obscureText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.black)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: hintTextColor.withOpacity(0.7),
              fontSize: 15,
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}


class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({
    required this.assetPath,
    required this.fallback,
    required this.onTap,
  });

  final String assetPath;
  final String fallback;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: 52,
        height: 52,
        child: Center(
          child: Image.asset(
            assetPath,
            width: 38,
            height: 38,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return CircleAvatar(
                radius: 20,
                backgroundColor: Colors.transparent,
                child: Text(
                  fallback,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

