import 'package:flutter/material.dart';

// --- MODEL ---
class SubTaskData {
  String title;
  bool isDone;
  SubTaskData({required this.title, this.isDone = false});
}

class TaskData {
  String title;
  List<SubTaskData> subtasks;
  bool isExpanded;

  TaskData({required this.title, required this.subtasks, this.isExpanded = false});

  int get completedCount => subtasks.where((s) => s.isDone).length;
  bool get isAllDone => subtasks.isNotEmpty && subtasks.every((s) => s.isDone);
}

// --- CONTROLLER ---
class GoalDetailController extends ChangeNotifier {
  // Data (State)
  List<TaskData> tasks = [
    TaskData(
      title: 'Task 1: Membaca Buku',
      isExpanded: true,
      subtasks: [
        SubTaskData(title: 'Sub-task 1: Belajar Abjad', isDone: true),
        SubTaskData(title: 'Sub-task 2: Belajar Pengejaan', isDone: true),
        SubTaskData(title: 'Sub-task 3: Belajar Kosa Kata', isDone: true),
      ],
    ),
    TaskData(
      title: 'Task 2: Memahami Kalimat',
      subtasks: [
        SubTaskData(title: 'Sub-task 1: Kalimat Sederhana'),
        SubTaskData(title: 'Sub-task 2: Tanda Baca'),
      ],
    ),
  ];

  // Getters untuk perhitungan
  double get overallProgress {
    int totalSubtasks = 0;
    int totalDone = 0;
    for (var task in tasks) {
      totalSubtasks += task.subtasks.length;
      totalDone += task.completedCount;
    }
    if (totalSubtasks == 0) return 0.0;
    return totalDone / totalSubtasks;
  }
  
  int get overallPercentage => (overallProgress * 100).toInt();
  int get totalDoneCount => tasks.fold<int>(0, (sum, t) => sum + t.completedCount);
  int get totalTaskCount => tasks.fold<int>(0, (sum, t) => sum + t.subtasks.length);

  // --- ACTIONS / LOGIC ---
  
  void toggleExpand(int index) {
    tasks[index].isExpanded = !tasks[index].isExpanded;
    notifyListeners(); // Memberitahu UI untuk update
  }

  void toggleSubtask(int taskIndex, int subIndex) {
    var subtask = tasks[taskIndex].subtasks[subIndex];
    subtask.isDone = !subtask.isDone;
    notifyListeners(); // Update UI (progress bar berubah)
  }

  void toggleMarkAll(int taskIndex) {
    var task = tasks[taskIndex];
    bool newState = !task.isAllDone;
    for (var s in task.subtasks) {
      s.isDone = newState;
    }
    notifyListeners(); // Update UI
  }
}