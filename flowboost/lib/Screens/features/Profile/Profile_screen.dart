import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../widgets/custom_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Flowboost', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              const Text('PROFILE', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400)),
              const SizedBox(height: 20),
              Row(
                children: [
                  const CircleAvatar(radius: 30, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('John Doe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('OktaIllman@gmail.com', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Logout', style: TextStyle(color: Colors.orange)))
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Your Statistic', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Row(
                    children: [
                      _buildFilterText('Today', true),
                      const SizedBox(width: 10),
                      _buildFilterText('Week', false),
                      const SizedBox(width: 10),
                      _buildFilterText('Month', false),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),
              const StatCard(icon: Icons.golf_course, iconBgColor: Color(0xFFE0BBE4), title: 'Goal Achieved', subtitle: 'Total completed goals', count: '2'),
              const StatCard(icon: Icons.apple, iconBgColor: Color(0xFFF4A6A6), title: 'Pomodoros Used', subtitle: 'Focus sessions', count: '54'),
              const StatCard(icon: Icons.check_box, iconBgColor: Color(0xFFD4A5A5), title: 'Tasks Completed', subtitle: 'Main tasks done', count: '21'),
              const StatCard(icon: Icons.list, iconBgColor: Color(0xFFD0DDB7), title: 'Sub-Task Completed', subtitle: 'Subtasks finished', count: '12'),
              const StatCard(icon: Icons.self_improvement, iconBgColor: Color(0xFFE0BBE4), title: 'Daily Streak Meditation', subtitle: 'Consecutive days', count: '14'),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterText(String text, bool isActive) {
    return Text(
      text,
      style: TextStyle(
        color: isActive ? Colors.orange : Colors.black,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        decoration: isActive ? TextDecoration.underline : TextDecoration.none,
        decorationColor: Colors.orange,
      ),
    );
  }
}