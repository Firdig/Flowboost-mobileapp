import 'package:flutter/material.dart';
import 'dart:async';

class MeditationController extends ChangeNotifier {
  static const int _totalSeconds = 300; // 5 minutes
  
  Timer? _timer;
  int _seconds = _totalSeconds;
  bool _isPlaying = false;
  String _selectedMusic = 'Peaceful Nature Sounds';

  int get seconds => _seconds;
  bool get isPlaying => _isPlaying;
  String get selectedMusic => _selectedMusic;

  String formatTime() {
    int minutes = _seconds ~/ 60;
    int seconds = _seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void startTimer() {
    _isPlaying = true;
    notifyListeners();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        _seconds--;
        notifyListeners();
      } else {
        stopTimer();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _isPlaying = false;
    _seconds = _totalSeconds;
    notifyListeners();
  }

  void selectMusic(String music) {
    _selectedMusic = music;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}