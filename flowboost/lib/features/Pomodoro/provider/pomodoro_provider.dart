import 'dart:async';
import 'package:flutter/material.dart';
import '../models/pomodoro_task_model.dart';

enum PomodoroMode { pomodoro, shortBreak, longBreak }

class PomodoroProvider with ChangeNotifier {
  // --- TIMER STATE ---
  Timer? _timer;
  Duration _currentDuration = const Duration(minutes: 25);
  PomodoroMode _currentMode = PomodoroMode.pomodoro;
  bool _isRunning = false;
  bool _isEditingTimerUi = false;

  final Duration _defaultPomodoro = const Duration(minutes: 25);
  final Duration _defaultShortBreak = const Duration(minutes: 5);
  final Duration _defaultLongBreak = const Duration(minutes: 15);

  // --- TASK STATE (DATA STATIS) ---
  final List<PomodoroTask> _tasks = [
    PomodoroTask(title: 'Belajar CSS', targetSessions: 4, completedSessions: 4, isDone: true),
    PomodoroTask(title: 'Belajar react', targetSessions: 6, completedSessions: 2, note: 'Fokus pada hooks'),
    // Task baru akan ditambahkan ke list ini secara statis (di memori)
  ];
  String? _selectedTaskId;
  String? _editingTaskId;

  // --- GETTERS ---
  Duration get currentDuration => _currentDuration;
  PomodoroMode get currentMode => _currentMode;
  bool get isRunning => _isRunning;
  bool get isEditingTimerUi => _isEditingTimerUi;
  List<PomodoroTask> get tasks => _tasks;
  String? get editingTaskId => _editingTaskId;

  PomodoroTask? get selectedTask {
    if (_selectedTaskId == null) return null;
    try {
      return _tasks.firstWhere((task) => task.id == _selectedTaskId);
    } catch (e) {
      return null;
    }
  }

  // --- TIMER LOGIC (Sama seperti sebelumnya) ---
  void toggleTimer() {
    if (_isRunning) {
      pauseTimer();
    } else {
      startTimer();
    }
  }

  void startTimer() {
    if (_timer != null) return;
    if (selectedTask == null && _currentMode == PomodoroMode.pomodoro) {
      // Opsional: Mencegah start jika tidak ada task di mode pomodoro
      // return;
    }
    _isRunning = true;
    notifyListeners();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentDuration.inSeconds > 0) {
        _currentDuration = _currentDuration - const Duration(seconds: 1);
        notifyListeners();
      } else {
        completeSession();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    notifyListeners();
  }

  void completeSession() {
    pauseTimer();
    if (_currentMode == PomodoroMode.pomodoro && selectedTask != null) {
      final index = _tasks.indexWhere((t) => t.id == _selectedTaskId);
      if (index != -1) {
        _tasks[index].completedSessions++;
        if (_tasks[index].completedSessions >= _tasks[index].targetSessions) {
          _tasks[index].isDone = true;
        }
      }
    }
    if (_currentMode == PomodoroMode.pomodoro) {
      setMode(PomodoroMode.shortBreak);
    } else {
      setMode(PomodoroMode.pomodoro);
    }
    notifyListeners();
  }

  void setMode(PomodoroMode mode) {
    pauseTimer();
    _currentMode = mode;
    switch (mode) {
      case PomodoroMode.pomodoro:
        _currentDuration = _defaultPomodoro;
        break;
      case PomodoroMode.shortBreak:
        _currentDuration = _defaultShortBreak;
        break;
      case PomodoroMode.longBreak:
        _currentDuration = _defaultLongBreak;
        break;
    }
    notifyListeners();
  }

  void toggleEditTimerUi() {
    _isEditingTimerUi = !_isEditingTimerUi;
    pauseTimer();
    notifyListeners();
  }

  void adjustTime(int minutesDelta, int secondsDelta) {
    final newDuration = _currentDuration + Duration(minutes: minutesDelta, seconds: secondsDelta);
    if (newDuration.inSeconds >= 0) {
      _currentDuration = newDuration;
      notifyListeners();
    }
  }

  void saveTimerSetting() {
    _isEditingTimerUi = false;
    notifyListeners();
  }


  // --- TASK LOGIC ---
  void selectTask(String taskId) {
    _selectedTaskId = taskId;
    setMode(PomodoroMode.pomodoro);
    notifyListeners();
  }

  // Logika untuk memulai proses "Add Task"
  void startAddingTask() {
    // 1. Buat task sementara yang kosong
    final newTask = PomodoroTask(title: '', targetSessions: 1);
    // 2. Tambahkan ke list statis
    _tasks.add(newTask);
    // 3. Masuk ke mode edit untuk task baru ini (UI akan berubah ke Gambar 3)
    _editingTaskId = newTask.id;
    notifyListeners();
  }

  void startEditingTask(String taskId) {
    _editingTaskId = taskId;
    notifyListeners();
  }

  void cancelEditingTask() {
    if (_editingTaskId != null) {
      final task = _tasks.firstWhere((t) => t.id == _editingTaskId);
      // Jika task yang dibatalkan judulnya kosong, berarti itu task baru yang batal dibuat. Hapus.
      if (task.title.isEmpty) {
        _tasks.removeWhere((t) => t.id == _editingTaskId);
      }
    }
    _editingTaskId = null;
    notifyListeners();
  }

  // Logika menyimpan (baik task baru maupun edit task lama)
  void saveTask(String id, String newTitle, int newTarget, String? newNote) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      // Update data statis di memori
      _tasks[index].title = newTitle;
      _tasks[index].targetSessions = newTarget;
      _tasks[index].note = newNote; // Menyimpan note

      if (_tasks[index].completedSessions >= _tasks[index].targetSessions) {
        _tasks[index].isDone = true;
      } else {
        _tasks[index].isDone = false;
      }

      // PERBAIKAN: Jika task yang baru disimpan belum dipilih, otomatis pilih task tersebut.
      // Ini agar sesuai dengan alur Gambar 3 ke Gambar 4.
      if (_selectedTaskId != id) {
        selectTask(id);
      }
    }
    _editingTaskId = null; // Keluar mode edit
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    if (_selectedTaskId == id) {
      _selectedTaskId = null;
    }
    notifyListeners();
  }

  void toggleTaskDone(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].isDone = !_tasks[index].isDone;
      notifyListeners();
    }
  }
}