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
// import '../../Profile/views/Profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil data User saat ini
    final user = FirebaseAuth.instance.currentUser;
    // Gunakan displayName, jika kosong gunakan bagian depan email, atau default 'User'
    final String userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
    
    // Service untuk mengambil data goals
    final GoalService goalService = GoalService();

    return Scaffold(
      // 2. Menggunakan AppBar agar judul "Flowboost" warnanya SAMA dengan fitur Goals
      appBar: AppBar(
        title: const Text('Flowboost'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Menghilangkan tombol back di dashboard
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sapaan User
              Text(
                'Hi $userName,\nHave a nice day',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              
              // 3. Goals Card (Logic Perbaikan)
              StreamBuilder<List<GoalModel>>(
                stream: goalService.getGoalsStream(),
                builder: (context, snapshot) {
                  // Loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const RetroCard(
                      child: SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  // Error state
                  if (snapshot.hasError) {
                    return RetroCard(child: Text("Error: ${snapshot.error}"));
                  }

                  // Data processing
                  final allGoals = snapshot.data ?? [];
                  // Filter hanya goal yang belum selesai (in progress)
                  final activeGoals = allGoals.where((g) => !g.isFinished).toList();

                  return _buildDynamicGoalsCard(context, activeGoals);
                },
              ),

              const SizedBox(height: 20),
              
              // Menu Lainnya
              MenuCard(
                title: 'Daily boost',
                subtitle: 'Meningkatkan produktivitas',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DailyBoostScreen(),
                  ),
                ),
              ),
              MenuCard(
                title: 'Break',
                subtitle: 'Don’t Overworked your body, Take a break',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BreakScreen()),
                ),
              ),
              MenuCard(
                title: 'Pomodoro',
                subtitle: 'Make your focus increase',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PomodoroScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicGoalsCard(BuildContext context, List<GoalModel> activeGoals) {
    // KONDISI 1: TIDAK ADA GOAL AKTIF
    if (activeGoals.isEmpty) {
      return RetroCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'No Active Goals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "You don't have any goals running. Start maximizing your potential now!",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: RetroButton(
                    text: 'Create Goal +',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NewGoalScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RetroButton(
                    text: 'View All',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GoalsHomeScreen()),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }

    // KONDISI 2: ADA GOAL AKTIF
    // Ambil goal pertama untuk ditampilkan detailnya
    final primaryGoal = activeGoals.first;
    final int extraCount = activeGoals.length - 1;
    
    // Hitung progress untuk goal utama
    int completedTasks = primaryGoal.tasks.where((t) => t.isCompleted).length;
    int totalTasks = primaryGoal.tasks.length;
    double percentage = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    return RetroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Goal in Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Penjelasan ringkas jika ada lebih dari 1 goal
              if (extraCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kButtonColor, // Menggunakan warna tema beige/tombol
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12)
                  ),
                  child: Text(
                    '+$extraCount others',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Judul Goal Utama
          Text(
            primaryGoal.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 5),
          CustomProgressBar(
            percentage: percentage,
          ),
          const SizedBox(height: 5),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedTasks/$totalTasks Task Complete',
                style: const TextStyle(fontSize: 12),
              ),
              Text('(${(percentage * 100).toInt()}% Done)', style: const TextStyle(fontSize: 12)),
            ],
          ),
          
          const SizedBox(height: 15),
          RetroButton(
            text: 'Go to Goals',
            isFullWidth: true,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GoalsHomeScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}