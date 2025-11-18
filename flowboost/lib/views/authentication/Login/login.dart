import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flowboost',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                CustomPaint(
                  size: const Size(120, 120),
                  painter: FlowboostLogoPainter(),
                ),
                const SizedBox(height: 16),
                
                // App Name
                const Text(
                  'Flowboost',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '™',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 48),
                
                // Nickname Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nickname',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Username',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.black87,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.black87,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Login Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle login
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Or Login with
                const Text(
                  'Or Login with :',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Social Login Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      icon: Icons.g_mobiledata,
                      color: Colors.red,
                      onTap: () {},
                    ),
                    const SizedBox(width: 20),
                    _buildSocialButton(
                      icon: Icons.facebook,
                      color: const Color(0xFF1877F2),
                      onTap: () {},
                    ),
                    const SizedBox(width: 20),
                    _buildSocialButton(
                      icon: Icons.close,
                      color: Colors.black,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Create Account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Dont have an account?  ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Handle create account
                      },
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF00BCD4),
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
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Icon(
          icon,
          color: color,
          size: 32,
        ),
      ),
    );
  }
}

class FlowboostLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // Moon/Crescent (top)
    final moonPath = Path();
    moonPath.addArc(
      Rect.fromCircle(center: Offset(size.width * 0.6, size.height * 0.2), radius: 15),
      3.14 * 0.3,
      3.14 * 1.4,
    );
    canvas.drawPath(moonPath, paint);

    // Wave 1
    final wave1 = Path();
    wave1.moveTo(size.width * 0.2, size.height * 0.4);
    wave1.quadraticBezierTo(
      size.width * 0.35, size.height * 0.35,
      size.width * 0.5, size.height * 0.4,
    );
    wave1.quadraticBezierTo(
      size.width * 0.65, size.height * 0.45,
      size.width * 0.8, size.height * 0.4,
    );
    canvas.drawPath(wave1, paint);

    // Wave 2
    final wave2 = Path();
    wave2.moveTo(size.width * 0.2, size.height * 0.5);
    wave2.quadraticBezierTo(
      size.width * 0.35, size.height * 0.45,
      size.width * 0.5, size.height * 0.5,
    );
    wave2.quadraticBezierTo(
      size.width * 0.65, size.height * 0.55,
      size.width * 0.8, size.height * 0.5,
    );
    canvas.drawPath(wave2, paint);

    // Heart
    final heartPath = Path();
    // Left curve
    heartPath.moveTo(size.width * 0.5, size.height * 0.65);
    heartPath.cubicTo(
      size.width * 0.5, size.height * 0.6,
      size.width * 0.3, size.height * 0.55,
      size.width * 0.3, size.height * 0.7,
    );
    heartPath.cubicTo(
      size.width * 0.3, size.height * 0.8,
      size.width * 0.5, size.height * 0.9,
      size.width * 0.5, size.height * 0.9,
    );
    // Right curve
    heartPath.cubicTo(
      size.width * 0.5, size.height * 0.9,
      size.width * 0.7, size.height * 0.8,
      size.width * 0.7, size.height * 0.7,
    );
    heartPath.cubicTo(
      size.width * 0.7, size.height * 0.55,
      size.width * 0.5, size.height * 0.6,
      size.width * 0.5, size.height * 0.65,
    );
    canvas.drawPath(heartPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}