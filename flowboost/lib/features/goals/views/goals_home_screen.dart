import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../common/constants/constants.dart';
import '../../../common/widgets/custom_widgets.dart';
import '../models/goal_model.dart';
import '../services/goal_service.dart';
import 'new_goal_screen.dart';
import 'goal_detail_screen.dart';

class GoalsHomeScreen extends StatelessWidget {
  const GoalsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan user sudah login sebelum mengambil data
    final user = FirebaseAuth.instance.currentUser;
    final GoalService goalService = GoalService();

    // Jika user belum login, tampilkan pesan (Opsional: bisa redirect ke login)
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Goals')),
        body: const Center(child: Text("Please login to view your goals")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Goals'),
      ),
      body: StreamBuilder<List<GoalModel>>(
        // Menggunakan stream dari service
        stream: goalService.getGoalsStream(),
        builder: (context, snapshot) {
          // 1. Cek Status Koneksi
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Cek Jika Ada Error (PENTING untuk debugging)
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Error: ${snapshot.error}", 
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // 3. Cek Jika Data Kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(context);
          }

          // 4. Olah Data
          final allGoals = snapshot.data!;
          final inProgressGoals = allGoals.where((g) => !g.isFinished).toList();
          final finishedGoals = allGoals.where((g) => g.isFinished).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === SECTION: IN PROGRESS ===
                const Text('Current Goals in Progress', style: kHeaderStyle),
                const SizedBox(height: 20),
                
                if (inProgressGoals.isEmpty)
                  _buildSectionEmptyState("No goals in progress"),

                // Loop data In Progress
                ...inProgressGoals.map((goal) => _buildGoalCard(context, goal)),

                const SizedBox(height: 20),
                Center(
                  child: RetroButton(
                    text: 'Create New Goal +',
                    onPressed: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const NewGoalScreen())
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // === SECTION: FINISHED ===
                const Text('Your Finished Goal', style: kHeaderStyle),
                const SizedBox(height: 10),
                
                if (finishedGoals.isEmpty)
                  _buildSectionEmptyState("No finished goals yet"),

                // Loop data Finished
                ...finishedGoals.map((goal) => _buildGoalCard(context, goal)),
                
                // Tambahan ruang di bawah agar tidak mentok
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget Tampilan Saat Data Benar-Benar Kosong
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.flag_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 10),
          const Text(
            "There's no Goals created", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)
          ),
          const SizedBox(height: 20),
          RetroButton(
            text: 'Create New Goal +',
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const NewGoalScreen())
            ),
          ),
        ],
      ),
    );
  }

  // Widget Tampilan Kosong per Section (Progress/Finished)
  Widget _buildSectionEmptyState(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
      ),
    );
  }

  // Widget Kartu Goal
  Widget _buildGoalCard(BuildContext context, GoalModel goal) {
    // Hitung ulang progress agar akurat
    // (Misal: Task dianggap selesai jika ditandai selesai)
    int completedTasks = goal.tasks.where((t) => t.isCompleted).length;
    int totalTasks = goal.tasks.length;
    
    // Cegah pembagian dengan nol
    double percentage = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: RetroCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text('progress'),
            const SizedBox(height: 5),
            
            // Progress Bar
            CustomProgressBar(percentage: percentage),
            
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$completedTasks/$totalTasks Task Complete'),
                if (percentage >= 1.0)
                  const Text('(Done)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 10),
            
            const Text('Self Reward :', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(goal.reward, style: const TextStyle(fontWeight: FontWeight.bold)),
            
            const SizedBox(height: 20),
            RetroButton(
              text: 'View Goal',
              isFullWidth: true,
              onPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => GoalDetailScreen(goal: goal)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}