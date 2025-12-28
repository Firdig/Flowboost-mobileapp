import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../services/goal_service.dart';
import 'new_goal_screen.dart';
import 'goal_detail_screen.dart';

class GoalsHomeScreen extends StatefulWidget {
  const GoalsHomeScreen({super.key});

  @override
  State<GoalsHomeScreen> createState() => _GoalsHomeScreenState();
}

class _GoalsHomeScreenState extends State<GoalsHomeScreen> with SingleTickerProviderStateMixin {
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
    final GoalService goalService = GoalService();

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5DC),
        body: const Center(child: Text("Please login to view your goals")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Background Beige (Tema Break/Dashboard)
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E4F3C), // Hijau Gelap identik dengan Dashboard
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Goals',
          style: TextStyle(
            color: Colors.white, // Teks Putih agar kontras
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.1,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: StreamBuilder<List<GoalModel>>(
            stream: goalService.getGoalsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState(context);
              }

              final allGoals = snapshot.data!;
              final inProgressGoals = allGoals.where((g) => !g.isFinished).toList();
              final finishedGoals = allGoals.where((g) => g.isFinished).toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                children: [
                  _buildSectionHeader('In Progress', Icons.trending_up),
                  const SizedBox(height: 16),
                  if (inProgressGoals.isEmpty) _buildSectionEmptyState("No active goals"),
                  ...inProgressGoals.map((goal) => _buildModernGoalCard(context, goal)),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader('Completed', Icons.task_alt),
                  const SizedBox(height: 16),
                  if (finishedGoals.isEmpty) _buildSectionEmptyState("No finished goals yet"),
                  ...finishedGoals.map((goal) => _buildModernGoalCard(context, goal)),
                  
                  const SizedBox(height: 100), // Ruang ekstra untuk FAB
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6C63FF),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NewGoalScreen())),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Goal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2C3E50)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
        ),
      ],
    );
  }

  Widget _buildModernGoalCard(BuildContext context, GoalModel goal) {
    int completedTasks = goal.tasks.where((t) => t.isCompleted).length;
    int totalTasks = goal.tasks.length;
    double percentage = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GoalDetailScreen(goal: goal))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                  ),
                ),
                if (percentage >= 1.0)
                  const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Reward: ${goal.reward}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF7F8C8D)),
            ),
            const SizedBox(height: 16),
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flag_outlined, size: 80, color: const Color(0xFF6C63FF).withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            "No goals created yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
          ),
          const Text("Start your journey today!", style: TextStyle(color: Color(0xFF7F8C8D))),
        ],
      ),
    );
  }

  Widget _buildSectionEmptyState(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(text, style: const TextStyle(color: Color(0xFF7F8C8D), fontStyle: FontStyle.italic)),
      ),
    );
  }
}