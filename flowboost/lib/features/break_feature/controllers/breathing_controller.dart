// breathing_controller.dart
import 'package:flutter/material.dart';
import 'dart:async';

class BreathingController extends ChangeNotifier {
  Timer? _timer;
  int _seconds = 4;
  int _cycles = 0;
  bool _isPlaying = false;
  String _currentPhase = 'INHALE';
  int _phaseIndex = 0;

  final List<String> _phases = ['INHALE', 'HOLD', 'EXHALE'];

  int get seconds => _seconds;
  int get cycles => _cycles;
  bool get isPlaying => _isPlaying;
  String get currentPhase => _currentPhase;

  void startExercise() {
    _isPlaying = true;
    _seconds = 4;
    _currentPhase = 'INHALE';
    _phaseIndex = 0;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 1) {
        _seconds--;
        notifyListeners();
      } else {
        _nextPhase();
      }
    });
  }

  void _nextPhase() {
    _phaseIndex = (_phaseIndex + 1) % 3;
    _currentPhase = _phases[_phaseIndex];
    _seconds = 4;

    if (_phaseIndex == 0) {
      _cycles++;
    }
    notifyListeners();
  }

  void stopExercise() {
    _timer?.cancel();
    _isPlaying = false;
    _seconds = 4;
    _cycles = 0;
    _currentPhase = 'INHALE';
    _phaseIndex = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}