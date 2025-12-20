// FILE: lib/features/Pomodoro/provider/pomodoro_provider.dart
// ✅ VERSI FINAL - TANPA DUPLIKAT

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

  // Settings Duration (Default)
  Duration _pomodoroDuration = const Duration(minutes: 25);
  Duration _shortBreakDuration = const Duration(minutes: 5);
  Duration _longBreakDuration = const Duration(minutes: 15);

  // ✅ NEW: Auto Start Settings
  bool _autoStartBreak = false;
  bool _autoStartPomodoro = false;

  int _cycleCount = 0;

  // --- TASK STATE ---
  final List<PomodoroTask> _tasks = [
    PomodoroTask(
      title: 'Belajar Javascript',
      targetSessions: 4,
      completedSessions: 0,
      subTasks: [
        SubTask(title: 'Task 1 : Introduction to JavaScript', targetSessions: 3, completedSessions: 0),
        SubTask(title: 'Task 2 : Variables and Data Types', targetSessions: 3, completedSessions: 0),
        SubTask(title: 'Task 3 : Functions and Scope', targetSessions: 3, completedSessions: 0),
        SubTask(title: 'Task 4 : ES6 Features', targetSessions: 3, completedSessions: 0),
      ],
    ),
    PomodoroTask(
      title: 'Belajar CSS',
      targetSessions: 4,
      completedSessions: 4,
      isDone: true,
      subTasks: [
        SubTask(title: 'Task 1 : Introduction to CSS', targetSessions: 3, completedSessions: 3, isDone: true),
        SubTask(title: 'Task 2 : CSS Selectors', targetSessions: 3, completedSessions: 3, isDone: true),
        SubTask(title: 'Task 3 : CSS Flexbox', targetSessions: 3, completedSessions: 3, isDone: true),
        SubTask(title: 'Task 4 : CSS Grid', targetSessions: 3, completedSessions: 3, isDone: true),
      ],
    ),
    PomodoroTask(
      title: 'Belajar React',
      targetSessions: 6,
      completedSessions: 2,
      note: 'Fokus pada hooks',
      subTasks: [
        SubTask(title: 'Task 1 : React Basics', targetSessions: 3, completedSessions: 3, isDone: true),
        SubTask(title: 'Task 2 : Components and Props', targetSessions: 3, completedSessions: 2),
        SubTask(title: 'Task 3 : State and Lifecycle', targetSessions: 3, completedSessions: 0),
        SubTask(title: 'Task 4 : Hooks (useState, useEffect)', targetSessions: 3, completedSessions: 0),
      ],
    ),
  ];

  String? _selectedTaskId;
  String? _editingTaskId;
  final Set<String> _hiddenParentTaskIds = {};
  PomodoroTask? _currentGoalTask;
  final List<PomodoroTask> _taskQueue = [];

  // Constructor
  PomodoroProvider() {
    if (_tasks.isNotEmpty) {
      _selectedTaskId = _tasks.first.id;
    }
  }

  // --- GETTERS ---
  Duration get currentDuration => _currentDuration;
  PomodoroMode get currentMode => _currentMode;
  bool get isRunning => _isRunning;
  
  // Getters for Settings
  int get pomodoroMinutes => _pomodoroDuration.inMinutes;
  int get shortBreakMinutes => _shortBreakDuration.inMinutes;
  int get longBreakMinutes => _longBreakDuration.inMinutes;
  bool get autoStartBreak => _autoStartBreak;
  bool get autoStartPomodoro => _autoStartPomodoro;

  // (Getters Task tetap sama)
  List<PomodoroTask> get tasks => _tasks.where((task) => !_hiddenParentTaskIds.contains(task.id)).toList();
  List<PomodoroTask> get allTasks => _tasks;
  PomodoroTask? get selectedTask {
    if (_selectedTaskId == null) return null;
    try {
      return _tasks.firstWhere((task) => task.id == _selectedTaskId);
    } catch (e) {
      return null;
    }
  }
  String? get editingTaskId => _editingTaskId;
  bool get hasRunningTask => _currentGoalTask != null;


  // --- TIMER LOGIC ---
  void toggleTimer() {
    if (_isRunning) {
      pauseTimer();
    } else {
      startTimer();
    }
  }

  void startTimer() {
    if (_timer != null) return;
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

  // ✅ LOGIKA TRANSISI DENGAN AUTO START
  void completeSession() {
    // 1. Stop timer dulu
    _timer?.cancel();
    _timer = null;
    _isRunning = false;

    // 2. Update Progress Task
    if (_currentMode == PomodoroMode.pomodoro && selectedTask != null) {
      final index = _tasks.indexWhere((t) => t.id == _selectedTaskId);
      if (index != -1) {
        _tasks[index].completedSessions++;
        if (_tasks[index].completedSessions >= _tasks[index].targetSessions) {
          _tasks[index].isDone = true;
        }
      }
    }

    // 3. Tentukan Mode Berikutnya & Cek Auto Start
    if (_currentMode == PomodoroMode.pomodoro) {
      // Selesai Kerja -> Masuk Istirahat
      _cycleCount++;
      
      if (_cycleCount >= 4) {
        setMode(PomodoroMode.longBreak);
        _cycleCount = 0;
      } else {
        setMode(PomodoroMode.shortBreak);
      }

      // Cek Auto Start Break
      if (_autoStartBreak) {
        startTimer();
      } else {
        notifyListeners(); // Update UI status jadi Pause
      }

    } else {
      // Selesai Istirahat -> Masuk Kerja
      setMode(PomodoroMode.pomodoro);

      // Cek Auto Start Pomodoro
      if (_autoStartPomodoro) {
        startTimer();
      } else {
        notifyListeners(); // Update UI status jadi Pause
      }
    }
  }
  
  // ✅ LOGIKA SKIP DENGAN AUTO START
  void skipTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;

    if (_currentMode == PomodoroMode.pomodoro) {
      // 1. Update Progress Task & Indikator UI (#1 -> #2)
      if (_selectedTaskId != null) {
        final index = _tasks.indexWhere((t) => t.id == _selectedTaskId);
        if (index != -1) {
          _tasks[index].completedSessions++;
          // Cek jika task sudah selesai targetnya
          if (_tasks[index].completedSessions >= _tasks[index].targetSessions) {
            _tasks[index].isDone = true;
          }
        }
      }

      // 2. Tambah Global Cycle Count (untuk memicu Long Break)
      _cycleCount++;
      
      // 3. Tentukan Break (Short/Long)
      if (_cycleCount >= 4) {
        setMode(PomodoroMode.longBreak);
        _cycleCount = 0; 
      } else {
        setMode(PomodoroMode.shortBreak);
      }
      
      // Auto Start Break jika aktif
      if (_autoStartBreak) startTimer();

    } else {
      // Jika sedang Break, kembali ke Pomodoro
      setMode(PomodoroMode.pomodoro);
      
      // Auto Start Pomodoro jika aktif
      if (_autoStartPomodoro) startTimer();
    }
    
    notifyListeners();
  }

  void setMode(PomodoroMode mode) {
    // Jangan pause di sini jika dipanggil dari completeSession/skipTimer yang mau auto-start
    // Tapi kita butuh update duration
    
    _currentMode = mode;
    switch (mode) {
      case PomodoroMode.pomodoro:
        _currentDuration = _pomodoroDuration;
        break;
      case PomodoroMode.shortBreak:
        _currentDuration = _shortBreakDuration;
        break;
      case PomodoroMode.longBreak:
        _currentDuration = _longBreakDuration;
        break;
    }
    // notifyListeners() dipanggil oleh pemanggil (completeSession/skipTimer/UI)
  }

  // ✅ UPDATE SETTINGS DARI POPUP
  void updateSettings({
    required int pomodoroMinutes,
    required int shortBreakMinutes,
    required int longBreakMinutes,
    required bool autoStartBreak,
    required bool autoStartPomodoro,
  }) {
    _pomodoroDuration = Duration(minutes: pomodoroMinutes);
    _shortBreakDuration = Duration(minutes: shortBreakMinutes);
    _longBreakDuration = Duration(minutes: longBreakMinutes);
    _autoStartBreak = autoStartBreak;
    _autoStartPomodoro = autoStartPomodoro;

    // Reset timer saat ini ke settingan baru jika tidak sedang berjalan
    if (!_isRunning) {
      setMode(_currentMode); 
    }
    
    notifyListeners();
  }

  // void toggleEditTimerUi() {
  //   _isEditingTimerUi = !_isEditingTimerUi;
  //   pauseTimer();
  //   notifyListeners();
  // }

  void adjustTime(int minutesDelta, int secondsDelta) {
    final newDuration = _currentDuration + Duration(minutes: minutesDelta, seconds: secondsDelta);
    if (newDuration.inSeconds >= 0) {
      _currentDuration = newDuration;
      notifyListeners();
    }
  }

  void saveTimerSetting() {
    // _isEditingTimerUi = false;
    
    // Simpan durasi saat ini ke variabel setting mode yang sedang aktif
    switch (_currentMode) {
      case PomodoroMode.pomodoro:
        _pomodoroDuration = _currentDuration;
        break;
      case PomodoroMode.shortBreak:
        _shortBreakDuration = _currentDuration;
        break;
      case PomodoroMode.longBreak:
        _longBreakDuration = _currentDuration;
        break;
    }
    notifyListeners();
  }

  
  // --- TASK LOGIC ---
  void selectTask(String taskId) {
    _selectedTaskId = taskId;

    // if (_currentMode == PomodoroMode.pomodoro) {
    //   // KONDISI 1: Sudah di mode Pomodoro (Pindah antar Task)
    //   // - Jangan panggil setMode() agar durasi TIDAK reset (tetap mengikuti timer sebelumnya)
    //   // - Panggil pauseTimer() agar otomatis berhenti (Auto Pause)
    //   pauseTimer();
    // } else {
    //   // KONDISI 2: Dari mode Break pindah ke Task
    //   // - Masuk mode Pomodoro (Waktu reset ke settingan awal, misal 25 menit)
    //   // - Pause timer juga agar user siap-siap
    //   setMode(PomodoroMode.pomodoro);
      pauseTimer();
    // }
    
    notifyListeners();
  }

  void startAddingTask() {
    final newTask = PomodoroTask(title: '', targetSessions: 1);
    _tasks.add(newTask);
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
      if (task.title.isEmpty) {
        _tasks.removeWhere((t) => t.id == _editingTaskId);
      }
    }
    _editingTaskId = null;
    notifyListeners();
  }

  void saveTask(String id, String newTitle, int newTarget, String? newNote) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].title = newTitle;
      _tasks[index].targetSessions = newTarget;
      _tasks[index].note = newNote;
      if (_tasks[index].completedSessions >= _tasks[index].targetSessions) {
        _tasks[index].isDone = true;
      } else {
        _tasks[index].isDone = false;
      }
      if (_selectedTaskId != id) {
        _selectedTaskId = id;
      }
    }
    _editingTaskId = null;
    notifyListeners();
  }

  // ✅ Tambah task baru dan sembunyikan semua task induk
  String addNewTask(String title, int targetSessions, String? note) {
    print('🆕 addNewTask called - Title: $title');

    // Sembunyikan semua task induk (yang punya subtasks)
    for (var task in _tasks) {
      if (task.subTasks != null && task.subTasks!.isNotEmpty) {
        _hiddenParentTaskIds.add(task.id);
        print('🙈 Hiding parent task: ${task.title} (ID: ${task.id})');
      }
    }

    final newTask = PomodoroTask(
      title: title,
      targetSessions: targetSessions,
      completedSessions: 0,
      note: note,
    );

    _tasks.add(newTask);
    _selectedTaskId = newTask.id;
    _editingTaskId = null;

    print('✅ New task added: $title');
    print('📋 Visible tasks: ${tasks.length}');
    print('🔒 Hidden parent tasks: ${_hiddenParentTaskIds.length}');

    notifyListeners();
    return newTask.id;
  }

  // ✅ Tampilkan kembali semua task induk
  void showAllParentTasks() {
    _hiddenParentTaskIds.clear();
    print('👁️ All parent tasks are now visible');
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    if (_selectedTaskId == id) _selectedTaskId = null;
    _hiddenParentTaskIds.remove(id);
    notifyListeners();
  }

  void toggleTaskDone(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].isDone = !_tasks[index].isDone;
      notifyListeners();
    }
  }

  // --- GOAL TASK LOGIC ---
  void setGoalTaskAsCurrent(PomodoroTask goalTask) {
    _currentGoalTask = goalTask;
    _selectedTaskId = goalTask.id;
    setMode(PomodoroMode.pomodoro);
    notifyListeners();
  }

  void replaceCurrentTask(PomodoroTask newGoalTask) {
    pauseTimer();
    _currentGoalTask = newGoalTask;
    _selectedTaskId = newGoalTask.id;
    setMode(PomodoroMode.pomodoro);
    notifyListeners();
  }

  void addTaskToQueue(PomodoroTask goalTask) {
    _taskQueue.add(goalTask);
    notifyListeners();
  }

  void startNextTaskFromQueue() {
    if (_taskQueue.isNotEmpty) {
      final nextTask = _taskQueue.removeAt(0);
      setGoalTaskAsCurrent(nextTask);
    } else {
      _currentGoalTask = null;
      notifyListeners();
    }
  }
}