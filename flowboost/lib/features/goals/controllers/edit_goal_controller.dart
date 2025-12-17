import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/goal_model.dart';
import '../services/goal_service.dart';

// Class pembantu untuk UI State (Expanded/Collapsed) yang tidak disimpan di DB
class TaskUIState {
  TaskModel data;
  bool isExpanded;

  TaskUIState({required this.data, this.isExpanded = false});
}

class EditGoalController extends ChangeNotifier {
  final GoalService _goalService = GoalService();
  
  // Controller untuk field input
  late TextEditingController goalTitleController;
  late TextEditingController rewardController;

  // List Task dengan wrapper UI State
  List<TaskUIState> tasks = [];
  
  // Data Goal asli untuk referensi update
  GoalModel? _originalGoal;

  EditGoalController() {
    goalTitleController = TextEditingController();
    rewardController = TextEditingController();
  }

  // --- INIT DATA DARI FIREBASE ---
  void loadGoal(GoalModel goal) {
    _originalGoal = goal;
    goalTitleController.text = goal.title;
    rewardController.text = goal.reward;

    // Mapping data model ke UI State
    tasks = goal.tasks.map((t) => TaskUIState(
      data: t, // Menggunakan referensi object yang sama
      isExpanded: false
    )).toList();
    
    notifyListeners();
  }

  @override
  void dispose() {
    goalTitleController.dispose();
    rewardController.dispose();
    super.dispose();
  }

  // --- LOGIC UI ACTIONS ---

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
    tasks[taskIndex].data.subtasks.add(SubTaskModel(title: "", id: ''));
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

  // --- LOGIC SIMPAN KE FIREBASE ---
  Future<void> saveGoal(BuildContext context) async {
    if (_originalGoal == null) return;
    
    // Validasi sederhana
    if (goalTitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul Goal tidak boleh kosong'))
      );
      return;
    }

    try {
      // Update object asli dengan data baru dari form
      _originalGoal!.title = goalTitleController.text;
      _originalGoal!.reward = rewardController.text;
      
      // Ambil list TaskModel dari wrapper TaskUIState
      _originalGoal!.tasks = tasks.map((ui) => ui.data).toList();

      // Panggil Service Update
      await _goalService.updateGoal(_originalGoal!);

      if (context.mounted) {
        Navigator.pop(context); // Kembali ke layar sebelumnya
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal updated successfully!'))
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating goal: $e'))
        );
      }
    }
  }
}