import 'package:flutter/material.dart';

class StretchingController extends ChangeNotifier {
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

  int get currentIndex => _currentIndex;
  List<Map<String, dynamic>> get exercises => _exercises;
  Map<String, dynamic> get currentExercise => _exercises[_currentIndex];
  bool get isLastExercise => _currentIndex == _exercises.length - 1;

  void nextExercise() {
    if (!isLastExercise) {
      _currentIndex++;
      notifyListeners();
    }
  }
}