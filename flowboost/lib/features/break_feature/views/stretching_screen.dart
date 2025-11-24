import 'package:flutter/material.dart';

class StretchingScreen extends StatefulWidget {
  const StretchingScreen({Key? key}) : super(key: key);

  @override
  State<StretchingScreen> createState() => _StretchingScreenState();
}

class _StretchingScreenState extends State<StretchingScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _exercises = [
    {
      'number': '1',
      'name': 'Neck Rolls',
      'icon': '🧑',
      'description': 'Slowly roll your head in circular motions.\n10 times clockwise, 10 times counter-clockwise.',
      'duration': '30 seconds',
    },
    {
      'number': '2',
      'name': 'Shoulder Shrugs',
      'icon': '🤷',
      'description': 'Lift your shoulders towards your ears, hold\nfor 2 seconds, then relax. Repeat 15 times.',
      'duration': '30 seconds',
    },
    {
      'number': '3',
      'name': 'Arm Circles',
      'icon': '💪',
      'description': 'Extend your arms and make small circles.\n10 forward, 10 backward on each side.',
      'duration': '30 seconds',
    },
    {
      'number': '4',
      'name': 'Spinal Twist',
      'icon': '🌀',
      'description': 'Sit upright and gently twist your torso to\neach side. Hold each side for 15 seconds.',
      'duration': '30 seconds',
    },
    {
      'number': '5',
      'name': 'Wrist Stretch',
      'icon': '✋',
      'description': 'Extend one arm and use the other hand to\ngently pull fingers back. Hold 10 seconds each side.',
      'duration': '30 seconds',
    },
    {
      'number': '6',
      'name': 'Toe Touches',
      'icon': '🦵',
      'description': 'Slowly bend forward to touch your toes.\nHold for 30 seconds and breathe deeply.',
      'duration': '30 seconds',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final exercise = _exercises[_currentIndex];

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
          'BACK',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Title with icon
              Row(
                children: [
                  Icon(Icons.accessibility_new, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'STRETCHING',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Exercise Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8E5D0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      exercise['number'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      exercise['icon'],
                      style: const TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      exercise['description'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          exercise['duration'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Progress Indicator
              Text(
                '${_currentIndex + 1}/${_exercises.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _exercises.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentIndex
                          ? Colors.black
                          : Colors.black26,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Done Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentIndex < _exercises.length - 1) {
                      setState(() => _currentIndex++);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8E8D0),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'DONE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Stretching Tips
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Stretching Tips:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '●  Move slowly and steadily',
                      style: TextStyle(fontSize: 12, height: 1.6),
                    ),
                    Text(
                      '●  Don\'t bounce while stretching',
                      style: TextStyle(fontSize: 12, height: 1.6),
                    ),
                    Text(
                      '●  Breathe deeply throughout',
                      style: TextStyle(fontSize: 12, height: 1.6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}