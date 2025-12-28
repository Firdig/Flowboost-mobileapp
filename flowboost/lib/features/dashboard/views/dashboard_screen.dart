import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../common/constants/constants.dart';
import '../../../common/widgets/custom_widgets.dart';

// Import fitur-fitur
import '../../goals/views/goals_home_screen.dart';
import '../../goals/views/new_goal_screen.dart';
import '../../goals/services/goal_service.dart';
import '../../goals/models/goal_model.dart';
import '../../daily_boost/screens/daily_boost_screen.dart';
import '../../break_feature/views/break_screen.dart';
import '../../Pomodoro/views/pomodoro_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
    final GoalService goalService = GoalService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Background Beige tema Break
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E4F3C), // Hijau gelap full width
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Flowboost',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Clamping agar tidak ada efek pantulan/scroll berlebih
          physics: const ClampingScrollPhysics(), 
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Column(
                  // Menyesuaikan dengan isi halaman secara pas
                  mainAxisSize: MainAxisSize.min, 
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Section
                    Text(
                      'Hi $userName,',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const Text(
                      'Let\'s make today productive!',
                      style: TextStyle(fontSize: 15, color: Color(0xFF7F8C8D)),
                    ),
                    const SizedBox(height: 24), // Jarak lebih rapat

                    // Goals Section
                    StreamBuilder<List<GoalModel>>(
                      stream: goalService.getGoalsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final activeGoals = (snapshot.data ?? []).where((g) => !g.isFinished).toList();
                        return _buildModernGoalsCard(context, activeGoals);
                      },
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Menu Items (Rapi & Kompak)
                    _buildMenuAction(
                      context: context,
                      title: 'Daily Boost',
                      subtitle: 'Improve your productivity',
                      icon: Icons.rocket_launch_outlined,
                      colors: [const Color(0xFF6C63FF), const Color(0xFF5A52E0)],
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DailyBoostScreen())),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuAction(
                      context: context,
                      title: 'Break Time',
                      subtitle: 'Relax and recharge',
                      icon: Icons.self_improvement_outlined,
                      colors: [const Color(0xFF4CAF50), const Color(0xFF45A049)],
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BreakScreen())),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuAction(
                      context: context,
                      title: 'Pomodoro',
                      subtitle: 'Deep focus sessions',
                      icon: Icons.timer_outlined,
                      colors: [const Color(0xFFFF9800), const Color(0xFFF57C00)],
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PomodoroScreen())),
                    ),
                    // Tidak ada SizedBox besar di bawah agar halaman pas dengan konten
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernGoalsCard(BuildContext context, List<GoalModel> activeGoals) {
    if (activeGoals.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flag_outlined, size: 45, color: Color(0xFF6C63FF)),
            const SizedBox(height: 12),
            const Text(
              'No Active Goals',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2C3E50)),
            ),
            const Text(
              'Start maximizing your potential!',
              style: TextStyle(fontSize: 13, color: Color(0xFF7F8C8D)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NewGoalScreen())),
                    child: const Text('Create New', style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF6C63FF)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GoalsHomeScreen())),
                    child: const Text('View Goals', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 13)),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }

    final primaryGoal = activeGoals.first;
    int completedTasks = primaryGoal.tasks.where((t) => t.isCompleted).length;
    int totalTasks = primaryGoal.tasks.length;
    double percentage = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GoalsHomeScreen())),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Goal in Progress', style: TextStyle(color: Color(0xFF7F8C8D), fontWeight: FontWeight.w600, fontSize: 12)),
                if (activeGoals.length > 1)
                  Text('+${activeGoals.length - 1} more', style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            Text(primaryGoal.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
              color: const Color(0xFF6C63FF),
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$completedTasks/$totalTasks tasks', style: const TextStyle(fontSize: 12, color: Color(0xFF7F8C8D))),
                Text('${(percentage * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6C63FF), fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuAction({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2C3E50))),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF7F8C8D))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFBDC3C7)),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}