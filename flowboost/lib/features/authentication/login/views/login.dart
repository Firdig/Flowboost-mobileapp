import 'package:flutter/material.dart';
import '/services/auth_service.dart';
import '../../../dashboard/main_scaffold.dart';

class FlowboostLoginScreen extends StatefulWidget {
  const FlowboostLoginScreen({super.key});

  static const String logoPath = 'assets/images/flowboost_logo.png';
  static const String googleIconPath = 'assets/images/google.png';
  static const String facebookIconPath = 'assets/images/facebook.png';

  @override
  State<FlowboostLoginScreen> createState() => _FlowboostLoginScreenState();
}

class _FlowboostLoginScreenState extends State<FlowboostLoginScreen> {
  final _auth = AuthService();

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login gagal: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

 Future<void> _loginEmailPassword() async {
  final email = _emailController.text.trim();
  final pass = _passwordController.text;

  final auth = AuthService();
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password wajib diisi')),
      );
      return;
    }

     await auth.signInWithEmail(email: email, password: pass);

  if (!mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const MainScaffold()),
    (route) => false,
  );

    // TODO: arahkan ke halaman home kamu
    // Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> _loginGoogle() async {
  await AuthService().signInWithGoogle();

  if (!mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const MainScaffold()),
    (route) => false,
  );
}


  Future<void> _loginFacebook() async {
  await AuthService().signInWithFacebook();

  if (!mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const MainScaffold()),
    (route) => false,
  );
}


  @override
  Widget build(BuildContext context) {
    const bg = Color.fromARGB(255, 245, 240, 227);
    const primaryTextColor = Colors.black;
    const hintTextColor = Colors.grey;
    const inputFillColor = Colors.black;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              Center(
                child: Image.asset(
                  FlowboostLoginScreen.logoPath,
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.favorite, size: 120, color: Colors.black),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: primaryTextColor,
                    ),
                    children: [
                      TextSpan(text: 'Flowboost'),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.top,
                        child: Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Text(
                            '™',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: primaryTextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              _LabeledField(
                label: 'Email', // sebelumnya "Nickname"
                hintText: 'email@contoh.com',
                hintTextColor: hintTextColor,
                fillColor: inputFillColor,
                controller: _emailController,
              ),

              const SizedBox(height: 18),

              _LabeledField(
                label: 'Password',
                hintText: 'Password',
                hintTextColor: hintTextColor,
                fillColor: inputFillColor,
                obscureText: true,
                controller: _passwordController,
              ),

              const SizedBox(height: 22),

              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 180,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : () => _run(_loginEmailPassword),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Or Login with :',
                style: TextStyle(fontSize: 20, color: primaryTextColor),
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialIconButton(
                    assetPath: FlowboostLoginScreen.googleIconPath,
                    fallback: 'G',
                    onTap: _loading ? null : () => _run(_loginGoogle),
                  ),
                  const SizedBox(width: 36),
                  _SocialIconButton(
                    assetPath: FlowboostLoginScreen.facebookIconPath,
                    fallback: 'f',
                    onTap: _loading ? null : () => _run(_loginFacebook),
                  ),
                ],
              ),

              const SizedBox(height: 80),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Dont have an account? ',
                    style: TextStyle(fontSize: 20, color: primaryTextColor),
                  ),
                  GestureDetector(
                    onTap: () {
                      debugPrint('Create Account tapped');
                      // TODO: navigate to register
                    },
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 0, 160, 210),
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
        Text(label, style: const TextStyle(fontSize: 22, color: Colors.black)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white, fontSize: 20),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: hintTextColor.withOpacity(0.7), fontSize: 22),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
        width: 70,
        height: 70,
        child: Center(
          child: Image.asset(
            assetPath,
            width: 56,
            height: 56,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return CircleAvatar(
                radius: 28,
                backgroundColor: Colors.transparent,
                child: Text(
                  fallback,
                  style: const TextStyle(
                    fontSize: 38,
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
