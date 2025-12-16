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
  bool _isEditingTimerUi = false;

  final Duration _defaultPomodoro = const Duration(minutes: 25);
  final Duration _defaultShortBreak = const Duration(minutes: 5);
  final Duration _defaultLongBreak = const Duration(minutes: 15);

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

  // ✅ Track task induk yang harus disembunyikan
  final Set<String> _hiddenParentTaskIds = {};

  // Task yang sedang berjalan untuk goals
  PomodoroTask? _currentGoalTask;

  // Antrian task untuk goals
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
  bool get isEditingTimerUi => _isEditingTimerUi;

  // ✅ Getter tasks yang otomatis filter task induk yang disembunyikan
  List<PomodoroTask> get tasks {
    return _tasks.where((task) => !_hiddenParentTaskIds.contains(task.id)).toList();
  }

  // ✅ Getter untuk semua tasks (tanpa filter)
  List<PomodoroTask> get allTasks => _tasks;

  String? get editingTaskId => _editingTaskId;
  PomodoroTask? get currentGoalTask => _currentGoalTask;
  List<PomodoroTask> get taskQueue => _taskQueue;

  PomodoroTask? get selectedTask {
    if (_selectedTaskId == null) return null;
    try {
      return _tasks.firstWhere((task) => task.id == _selectedTaskId);
    } catch (e) {
      return null;
    }
  }

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

    if (_selectedTaskId == id) {
      _selectedTaskId = null;
    }

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