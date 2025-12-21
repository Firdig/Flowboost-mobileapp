// FILE: lib/features/Pomodoro/provider/pomodoro_provider.dart
// ✅ VERSI FINAL - TANPA DUPLIKAT

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart';
import '../../goals/models/goal_model.dart'; // Import GoalModel
import '../../goals/services/goal_service.dart'; // Import GoalService
import '../models/pomodoro_task_model.dart';

enum PomodoroMode { pomodoro, shortBreak, longBreak }

class PomodoroProvider with ChangeNotifier {
  //Service Goals
  final GoalService _goalService = GoalService();
  StreamSubscription<List<GoalModel>>? _goalsSubscription;

  // Stream untuk Task Pomodoro
  StreamSubscription<QuerySnapshot>? _pomodoroTasksSubscription;

  List<GoalModel> _firestoreGoals = [];
  
  // --- FIRESTORE REFERENCE ---
  // Mengambil koleksi berdasarkan User ID agar data private per user
  CollectionReference? get _pomodoroCollection {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pomodoro_tasks');
  }

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
  List<PomodoroTask> _tasks = []; // Data akan diisi dari Firestore
  String? _selectedTaskId;
  String? _editingTaskId;
  final Set<String> _hiddenParentTaskIds = {};

  // Constructor
  PomodoroProvider() {
    _initGoalsListener();
    _initPomodoroTasksListener(); // Jalankan listener task
  }

  // Listener Goals (Kode sebelumnya)
  void _initGoalsListener() {
    _goalsSubscription = _goalService.getGoalsStream().listen((goals) {
      _firestoreGoals = goals;
      notifyListeners();
    });
  }

  // ✅ BARU: Listener untuk Pomodoro Tasks agar Realtime & Persisten
  void _initPomodoroTasksListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _pomodoroTasksSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pomodoro_tasks')
          .snapshots()
          .listen((snapshot) {
        
        _tasks = snapshot.docs.map((doc) {
          return PomodoroTask.fromMap(doc.data());
        }).toList();
        
        // Auto select task pertama jika belum ada yang dipilih dan list tidak kosong
        if (_selectedTaskId == null && _tasks.isNotEmpty) {
           _selectedTaskId = _tasks.first.id;
        }

        notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    _goalsSubscription?.cancel();
    _pomodoroTasksSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }
  // --- GETTERS ---
  List<PomodoroTask> get tasks => _tasks; // Tampilkan semua task (filter hidden jika perlu)
  List<GoalModel> get firestoreGoals => _firestoreGoals;
  
  Duration get currentDuration => _currentDuration;
  PomodoroMode get currentMode => _currentMode;
  bool get isRunning => _isRunning;
  int get pomodoroMinutes => _pomodoroDuration.inMinutes;
  int get shortBreakMinutes => _shortBreakDuration.inMinutes;
  int get longBreakMinutes => _longBreakDuration.inMinutes;
  bool get autoStartBreak => _autoStartBreak;
  bool get autoStartPomodoro => _autoStartPomodoro;

  PomodoroTask? get selectedTask {
    if (_selectedTaskId == null) return null;
    try {
      return _tasks.firstWhere((task) => task.id == _selectedTaskId);
    } catch (e) {
      return null;
    }
  }
  
  String? get editingTaskId => _editingTaskId;
  bool get hasRunningTask => selectedTask != null; // Simplifikasi

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

  // ✅ UPDATE: Save progress ke Firestore saat sesi selesai
  void completeSession() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;

    if (_currentMode == PomodoroMode.pomodoro && selectedTask != null) {
      final task = selectedTask!;
      task.completedSessions++;
      if (task.completedSessions >= task.targetSessions) {
        task.isDone = true;
      }
      // Update ke Firestore
      _updateTaskInFirestore(task);
    }

    _handleModeSwitch();
  }
  
  // ✅ UPDATE: Save progress ke Firestore saat skip
  void skipTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;

    if (_currentMode == PomodoroMode.pomodoro && selectedTask != null) {
      final task = selectedTask!;
      task.completedSessions++;
      if (task.completedSessions >= task.targetSessions) {
        task.isDone = true;
      }
      _updateTaskInFirestore(task); // Simpan
    }
    
    _handleModeSwitch();
  }

  void _handleModeSwitch() {
    if (_currentMode == PomodoroMode.pomodoro) {
      _cycleCount++;
      if (_cycleCount >= 4) {
        setMode(PomodoroMode.longBreak);
        _cycleCount = 0;
      } else {
        setMode(PomodoroMode.shortBreak);
      }
      if (_autoStartBreak) startTimer();
      else notifyListeners();
    } else {
      setMode(PomodoroMode.pomodoro);
      if (_autoStartPomodoro) startTimer();
      else notifyListeners();
    }
  }

  void setMode(PomodoroMode mode) {
    _currentMode = mode;
    switch (mode) {
      case PomodoroMode.pomodoro: _currentDuration = _pomodoroDuration; break;
      case PomodoroMode.shortBreak: _currentDuration = _shortBreakDuration; break;
      case PomodoroMode.longBreak: _currentDuration = _longBreakDuration; break;
    }
    // notifyListeners() dipanggil oleh parent
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

  // void saveTimerSetting() {
  //   // _isEditingTimerUi = false;
    
  //   // Simpan durasi saat ini ke variabel setting mode yang sedang aktif
  //   switch (_currentMode) {
  //     case PomodoroMode.pomodoro:
  //       _pomodoroDuration = _currentDuration;
  //       break;
  //     case PomodoroMode.shortBreak:
  //       _shortBreakDuration = _currentDuration;
  //       break;
  //     case PomodoroMode.longBreak:
  //       _longBreakDuration = _currentDuration;
  //       break;
  //   }
  //   notifyListeners();
  // }

  
  // --- TASK LOGIC ---
  void selectTask(String taskId) {
    _selectedTaskId = taskId;
    pauseTimer();
    setMode(PomodoroMode.pomodoro); // Reset ke mode kerja saat ganti task
    notifyListeners();
  }

  void startAddingTask() {
    // Kita buat task lokal sementara untuk UI editing
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
      // Hapus dari list lokal jika belum disimpan (belum ada di DB)
      // Cek apakah task ini ada di Firestore? Kalau task baru (title kosong), hapus.
      final task = _tasks.firstWhere((t) => t.id == _editingTaskId);
      if (task.title.isEmpty) {
        _tasks.removeWhere((t) => t.id == _editingTaskId);
      }
    }
    _editingTaskId = null;
    notifyListeners();
  }

  Future<void> saveTask(String id, String newTitle, int newTarget, String? newNote) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      task.title = newTitle;
      task.targetSessions = newTarget;
      task.note = newNote;
      task.isDone = (task.completedSessions >= task.targetSessions);

      // Simpan ke Firestore
      if (_pomodoroCollection != null) {
        await _pomodoroCollection!.doc(id).set(task.toMap());
      }
      
      if (_selectedTaskId != id) _selectedTaskId = id;
    }
    _editingTaskId = null;
    notifyListeners();
  }

  // ✅ Tambah task baru dan sembunyikan semua task induk
  Future<String> addNewTask(String title, int targetSessions, String? note) async {
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

    // Simpan ke Firestore
    if (_pomodoroCollection != null) {
      await _pomodoroCollection!.doc(newTask.id).set(newTask.toMap());
    }
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

  Future<void> deleteTask(String id) async {
    if (_pomodoroCollection != null) {
      await _pomodoroCollection!.doc(id).delete();
    }
    if (_selectedTaskId == id) _selectedTaskId = null;
  }

  Future<void> toggleTaskDone(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      task.isDone = !task.isDone;
      _updateTaskInFirestore(task); // Simpan perubahan
    }
  }
Future<void> _updateTaskInFirestore(PomodoroTask task) async {
    if (_pomodoroCollection != null) {
      await _pomodoroCollection!.doc(task.id).update(task.toMap());
    }
  }
  // --- GOAL TASK LOGIC ---
  // void setGoalTaskAsCurrent(PomodoroTask goalTask) {
  //   _currentGoalTask = goalTask;
  //   _selectedTaskId = goalTask.id;
  //   setMode(PomodoroMode.pomodoro);
  //   notifyListeners();
  // }

  // void replaceCurrentTask(PomodoroTask newGoalTask) {
  //   pauseTimer();
  //   _currentGoalTask = newGoalTask;
  //   _selectedTaskId = newGoalTask.id;
  //   setMode(PomodoroMode.pomodoro);
  //   notifyListeners();
  // }

  // void addTaskToQueue(PomodoroTask goalTask) {
  //   _taskQueue.add(goalTask);
  //   notifyListeners();
  // }

  // void startNextTaskFromQueue() {
  //   if (_taskQueue.isNotEmpty) {
  //     final nextTask = _taskQueue.removeAt(0);
  //     setGoalTaskAsCurrent(nextTask);
  //   } else {
  //     _currentGoalTask = null;
  //     notifyListeners();
  //   }
  // }
}