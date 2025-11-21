import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../widgets/custom_widgets.dart';
// Import semua fitur lain di sini
import '../goals/goals_home_screen.dart';
import '../daily_boost/daily_boost_screen.dart';
import '../break_feature/break_screen.dart';
import '../pomodoro/pomodoro_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
              const SizedBox(height: 20),
              const Text('Hi John Doe,Have a nice day', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              RetroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('You have goal in progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    const Text('Project website', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    const CustomProgressBar(percentage: 0.0, fillColor: Colors.transparent),
                    const SizedBox(height: 5),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text('0/2 Task Complete', style: TextStyle(fontSize: 12)),
                         Text('(0% Done)', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    RetroButton(
                      text: 'Go to Goals',
                      isFullWidth: true,
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GoalsHomeScreen())),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              MenuCard(title: 'Daily boost', subtitle: 'Meningkatkan produktivitas', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DailyBoostScreen()))),
              MenuCard(title: 'Break', subtitle: 'Don’t Overworked your body, Take a break', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BreakScreen()))),
              MenuCard(title: 'Pomodoro', subtitle: 'Make your focus increase', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PomodoroScreen()))),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}