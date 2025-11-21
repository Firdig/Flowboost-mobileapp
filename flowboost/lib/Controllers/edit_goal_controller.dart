import 'package:flutter/material.dart';

// --- DATA MODELS (Bisa dipindah ke file models terpisah jika mau) ---
class SubTaskData {
  String title;
  bool isDone;
  SubTaskData({required this.title, this.isDone = false});
}

class TaskData {
  String title;
  List<SubTaskData> subtasks;
  bool isExpanded; // Agar saat diedit bisa dibuka/tutup

  TaskData({
    required this.title,
    required this.subtasks,
    this.isExpanded = false,
  });
}

// --- CONTROLLER ---
class EditGoalController extends ChangeNotifier {
  // Text Controllers untuk Input
  final TextEditingController goalTitleController = TextEditingController(text: "Belajar Membaca");
  final TextEditingController rewardController = TextEditingController(text: "Vacation to Japan");

  // Data Tasks (Init dengan data dummy seperti sebelumnya)
  List<TaskData> tasks = [
    TaskData(
      title: 'Membaca Buku',
      isExpanded: true, // Default terbuka agar terlihat seperti Image 2
      subtasks: [
        SubTaskData(title: 'Belajar Abjad'),
        SubTaskData(title: 'Belajar Pengejaan'),
        SubTaskData(title: 'Belajar Kosa Kata'),
      ],
    ),
  ];

  @override
  void dispose() {
    goalTitleController.dispose();
    rewardController.dispose();
    super.dispose();
  }

  // --- LOGIC ACTIONS ---

  // 1. Tambah Task Baru (Parent)
  void addNewTask() {
    tasks.add(TaskData(title: "", subtasks: [], isExpanded: true));
    notifyListeners();
  }

  // 2. Hapus Task
  void deleteTask(int index) {
    tasks.removeAt(index);
    notifyListeners();
  }

  // 3. Tambah Subtask ke dalam Task tertentu
  void addSubTask(int taskIndex) {
    tasks[taskIndex].subtasks.add(SubTaskData(title: ""));
    notifyListeners();
  }

  // 4. Hapus Subtask
  void deleteSubTask(int taskIndex, int subIndex) {
    tasks[taskIndex].subtasks.removeAt(subIndex);
    notifyListeners();
  }

  // 5. Expand/Collapse Task (Opsional, tapi bagus untuk UI)
  void toggleTaskExpansion(int index) {
    tasks[index].isExpanded = !tasks[index].isExpanded;
    notifyListeners();
  }
  
  // 6. Update Judul Task (Saat diketik)
  void updateTaskTitle(int index, String val) {
    tasks[index].title = val;
  }

  // 7. Update Judul Subtask
  void updateSubTaskTitle(int taskIndex, int subIndex, String val) {
    tasks[taskIndex].subtasks[subIndex].title = val;
  }
}