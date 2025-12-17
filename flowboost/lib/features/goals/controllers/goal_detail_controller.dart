import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../services/goal_service.dart';

// Class pembantu untuk UI State (Expanded/Collapsed)
class TaskDetailState {
  TaskModel data;
  bool isExpanded;

  TaskDetailState({required this.data, this.isExpanded = false});
}

class GoalDetailController extends ChangeNotifier {
  final GoalService _goalService = GoalService();
  
  // Data Goal Utama
  late GoalModel currentGoal;
  
  // List Wrapper untuk menangani state UI (seperti expand/collapse)
  List<TaskDetailState> taskStates = [];

  // Init Data
  void init(GoalModel goal) {
    currentGoal = goal;
    // Map data task asli ke TaskDetailState agar punya properti isExpanded
    taskStates = goal.tasks.map((t) => TaskDetailState(
      data: t,
      isExpanded: true // Default terbuka agar user langsung lihat subtask
    )).toList();
    notifyListeners();
  }

  // --- GETTERS (Untuk UI) ---
  
  // Hitung total progress (berdasarkan task atau subtask sesuai preferensi)
  // Di sini saya hitung berdasarkan persentase subtask yang selesai dari total semua subtask
  double get overallProgress {
    int totalSubtasks = 0;
    int completedSubtasks = 0;

    for (var t in currentGoal.tasks) {
      // Jika task tidak punya subtask, kita anggap task itu sendiri sebagai 1 unit
      if (t.subtasks.isEmpty) {
        totalSubtasks++;
        if (t.isCompleted) completedSubtasks++;
      } else {
        totalSubtasks += t.subtasks.length;
        completedSubtasks += t.subtasks.where((s) => s.isCompleted).length;
      }
    }

    if (totalSubtasks == 0) return 0.0;
    return completedSubtasks / totalSubtasks;
  }
  
  String get progressPercentage => (overallProgress * 100).toStringAsFixed(0);

  // --- ACTIONS ---

  void toggleExpand(int index) {
    taskStates[index].isExpanded = !taskStates[index].isExpanded;
    notifyListeners();
  }

  // 1. Toggle Subtask (Check/Uncheck)
  Future<void> toggleSubtask(int taskIndex, int subIndex) async {
    var subtask = currentGoal.tasks[taskIndex].subtasks[subIndex];
    subtask.isCompleted = !subtask.isCompleted;
    
    // Cek apakah semua subtask di task ini selesai? Jika ya, tandai parent task selesai
    bool allDone = currentGoal.tasks[taskIndex].subtasks.every((s) => s.isCompleted);
    currentGoal.tasks[taskIndex].isCompleted = allDone;

    notifyListeners();
    await _saveChanges();
  }

  // 2. Mark All as Done (untuk satu Task)
  Future<void> markAllDone(int taskIndex) async {
    var task = currentGoal.tasks[taskIndex];
    
    // Cek logika: Jika sudah semua done, maka unmark semua. Jika belum, mark semua.
    bool isAllCurrentlyDone = task.subtasks.every((s) => s.isCompleted);
    bool newState = !isAllCurrentlyDone;

    for (var sub in task.subtasks) {
      sub.isCompleted = newState;
    }
    task.isCompleted = newState;

    notifyListeners();
    await _saveChanges();
  }

  // Simpan ke Firebase
  Future<void> _saveChanges() async {
    await _goalService.updateGoal(currentGoal);
  }

  Future<void> deleteGoal(BuildContext context) async {
    if (currentGoal.id == null) return;
    await _goalService.deleteGoal(currentGoal.id!);
  }
}