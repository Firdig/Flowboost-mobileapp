import 'package:flutter/material.dart';
import 'dart:async';
// Import BreakService yang sudah dibuat sebelumnya
import '../services/break_services.dart'; 

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

  // ✅ UPDATE: Tambahkan logika simpan ke Firebase di sini
  void stopExercise() {
    // 1. Cek apakah user sudah melakukan minimal 1 siklus
    if (_cycles > 0) {
      // Hitung durasi: 1 siklus = 4+4+4 = 12 detik
      // Kita konversi ke menit (pembulatan ke atas), minimal 1 menit
      int totalSeconds = _cycles * 12;
      int durationMinutes = (totalSeconds / 60).ceil();
      if (durationMinutes < 1) durationMinutes = 1;

      // Panggil Service (Fire & Forget)
      BreakService().logBreakActivity(
        type: 'breathing',
        durationMinutes: durationMinutes,
      ).then((_) {
        print("✅ Breathing activity logged: $durationMinutes mins");
      });
    }

    // 2. Reset state (Kode lama)
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