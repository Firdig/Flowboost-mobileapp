import 'package:flutter/material.dart';
import '../../../common/constants/constants.dart';
import '../../../common/widgets/custom_widgets.dart';
import 'new_goal_screen.dart';
import 'goal_detail_screen.dart';

class GoalsHomeScreen extends StatelessWidget {
  const GoalsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
        title: const Text('Goals'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current Goals in Progress', style: kHeaderStyle),
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  const Text("There's no Goals in progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  RetroButton(
                    text: 'Create New Goal +',
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NewGoalScreen())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text('Your Finished Goal', style: kHeaderStyle),
            const SizedBox(height: 10),
            RetroCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Belajar Membaca', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const Text('progress'),
                  const SizedBox(height: 5),
                  const CustomProgressBar(percentage: 1.0),
                  const SizedBox(height: 5),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1/1 Task Complete'),
                      Text('(Done)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Self Reward :'),
                  const Text('Vacation to japan', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  RetroButton(
                    text: 'View Goal',
                    isFullWidth: true,
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GoalDetailScreen())),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}