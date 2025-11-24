import 'package:flutter/material.dart';
import '../../../common/constants/constants.dart';
import '../../break_feature/views/meditation_screen.dart';
import '../../break_feature/views/Breathing_screen.dart';
import '../../break_feature/views/stretching_screen.dart';

class BreakScreen extends StatelessWidget {
  const BreakScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC8C89F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'TIME FOR A BREAK',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            // Bell Icon
            const Icon(
              Icons.notifications,
              size: 100,
              color: Colors.black,
            ),
            const SizedBox(height: 24),
            
            // Title
            const Text(
              'Time for a Break!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            
            // Description
            const Text(
              'Now it\'s time to rest so\nyour body feels more relaxed\nand healthy.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // Subtitle
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose your break activity:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Activity Cards
            _buildActivityCard(
              icon: Icons.self_improvement,
              title: '5-MIN MEDITATION',
              subtitle: 'Clear your mind',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MeditationScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            
            _buildActivityCard(
              icon: Icons.air,
              title: 'BREATHING EXERCISE',
              subtitle: 'Calm your nerves',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BreathingScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            
            _buildActivityCard(
              icon: Icons.accessibility_new,
              title: 'STRETCHING',
              subtitle: 'Quick desk stretches',
              onTap: () {
                Navigator.push( 
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StretchingScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8D0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.black),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}