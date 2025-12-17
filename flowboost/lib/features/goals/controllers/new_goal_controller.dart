import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/goal_model.dart';
import '../services/goal_service.dart';

class TaskUIState {
  TaskModel data;
  bool isExpanded;
  TaskUIState({required this.data, this.isExpanded = true});
}

class NewGoalController extends ChangeNotifier {
  final GoalService _goalService = GoalService();
  
  final TextEditingController goalTitleController = TextEditingController();
  final TextEditingController rewardController = TextEditingController();

  List<TaskUIState> tasks = [];

  @override
  void dispose() {
    goalTitleController.dispose();
    rewardController.dispose();
    super.dispose();
  }

  // --- ACTIONS ---

  void addNewTask() {
    tasks.add(TaskUIState(
      data: TaskModel(
        id: const Uuid().v4(),
        title: "", 
        subtasks: []
      ),
      isExpanded: true,
    ));
    notifyListeners();
  }

  void deleteTask(int index) {
    tasks.removeAt(index);
    notifyListeners();
  }

  void addSubTask(int taskIndex) {
    // Generate ID unik untuk Subtask
    tasks[taskIndex].data.subtasks.add(
      SubTaskModel(
        id: const Uuid().v4(), 
        title: "",
        isCompleted: false // Default belum selesai
      )
    );
    notifyListeners();
  }

  void deleteSubTask(int taskIndex, int subIndex) {
    tasks[taskIndex].data.subtasks.removeAt(subIndex);
    notifyListeners();
  }

  void toggleTaskExpansion(int index) {
    tasks[index].isExpanded = !tasks[index].isExpanded;
    notifyListeners();
  }
  
  void updateTaskTitle(int index, String val) {
    tasks[index].data.title = val;
  }

  void updateSubTaskTitle(int taskIndex, int subIndex, String val) {
    tasks[taskIndex].data.subtasks[subIndex].title = val;
  }

  // Action untuk toggle checkbox subtask (Done/Undone)
  void toggleSubTaskStatus(int taskIndex, int subIndex) {
    bool current = tasks[taskIndex].data.subtasks[subIndex].isCompleted;
    tasks[taskIndex].data.subtasks[subIndex].isCompleted = !current;
    notifyListeners();
  }

  Future<void> createGoal(BuildContext context) async {
    if (goalTitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul Goal harus diisi!')));
      return;
    }
    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Minimal harus ada 1 task!')));
      return;
    }

    try {
      String userId = _goalService.currentUserId; 
      if (userId.isEmpty) return;

      GoalModel newGoal = GoalModel(
        userId: userId,
        title: goalTitleController.text,
        reward: rewardController.text,
        createdAt: Timestamp.now() as dynamic,
        tasks: tasks.map((ui) => ui.data).toList(),
      );

      await _goalService.addGoal(newGoal);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Goal berhasil dibuat!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}