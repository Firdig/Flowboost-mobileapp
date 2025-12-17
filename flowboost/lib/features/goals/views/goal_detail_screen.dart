import 'package:flutter/material.dart';
import '../../../common/constants/constants.dart';
import '../../../common/widgets/custom_widgets.dart';
import '../models/goal_model.dart';
import '../controllers/goal_detail_controller.dart';
import '../../Pomodoro/views/pomodoro_screen.dart'; // Import Pomodoro Screen
import 'edit_goal_screen.dart';

class GoalDetailScreen extends StatefulWidget {
  final GoalModel goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final GoalDetailController _controller = GoalDetailController();

  @override
  void initState() {
    super.initState();
    _controller.init(widget.goal);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Navigasi ke Edit Screen
  void _navigateToEdit() async {
    await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => EditGoalScreen(goal: _controller.currentGoal))
    );
    // Refresh data setelah kembali dari edit
    setState(() {
      _controller.init(_controller.currentGoal);
    });
  }

  // Delete Confirm
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal?'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await _controller.deleteGoal(context);
              if (mounted) {
                Navigator.pop(context); // Tutup dialog
                Navigator.pop(context); // Kembali ke Home
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Your Goal'),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Complete your ${_controller.currentGoal.title}', style: kHeaderStyle),
                const SizedBox(height: 20),
                
                RetroCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- REWARD SECTION ---
                      const Text('REWARD :', style: kLabelStyle),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: kButtonColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 2))],
                        ),
                        child: Center(
                          child: Text(_controller.currentGoal.reward, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.center,
                          )
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- PROGRESS SECTION ---
                      const Text('PROGRESS', style: kLabelStyle),
                      const SizedBox(height: 5),
                      CustomProgressBar(percentage: _controller.overallProgress),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${_controller.progressPercentage}% Completed'),
                          if (_controller.overallProgress >= 1.0)
                            const Text('(Done)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // --- TASKS LIST ---
                      ..._controller.taskStates.asMap().entries.map((entry) {
                        return _buildTaskItem(entry.key, entry.value);
                      }).toList(),

                      const SizedBox(height: 30),
                      
                      // --- FOOTER BUTTONS ---
                      Row(
                        children: [
                          Expanded(
                            child: RetroButton(
                              text: 'Edit Goal', 
                              onPressed: _navigateToEdit
                            )
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: RetroButton(
                              text: 'Delete Goal', 
                              onPressed: _confirmDelete
                            )
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET: ITEM TASK (ACCORDION) ---
  Widget _buildTaskItem(int index, TaskDetailState taskState) {
    TaskModel task = taskState.data;
    bool isAllDone = task.subtasks.isNotEmpty && task.subtasks.every((s) => s.isCompleted);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: Column(
        children: [
          // 1. HEADER TASK (Klik untuk expand/collapse)
          InkWell(
            onTap: () => _controller.toggleExpand(index),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    taskState.isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.chevron_right_rounded, 
                    size: 28, color: Colors.grey[700]
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                    )
                  ),
                  // Indikator jumlah subtask selesai
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAllDone ? Colors.green[50] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${task.subtasks.where((s) => s.isCompleted).length}/${task.subtasks.length}',
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold,
                        color: isAllDone ? Colors.green : Colors.grey[600]
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. BODY SUBTASKS (Expanded)
          if (taskState.isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  
                  // List Subtasks
                  if (task.subtasks.isEmpty)
                     const Text("No subtasks", style: TextStyle(color: Colors.grey, fontSize: 12)),

                  ...task.subtasks.asMap().entries.map((entry) {
                    return _buildSubTaskRow(index, entry.key, entry.value);
                  }).toList(),
                  
                  const SizedBox(height: 16),
                  
                  // 3. TOMBOL AKSI (Mark All & Pomodoro)
                  Row(
                    children: [
                      // Tombol Mark All
                      Expanded(
                        child: _buildActionButton(
                          text: isAllDone ? 'Unmark all' : 'Mark all as done',
                          icon: isAllDone ? Icons.remove_done : Icons.done_all,
                          color: isAllDone ? Colors.orange.shade100 : const Color(0xFFD0DDB7),
                          onTap: () => _controller.markAllDone(index),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Tombol Start Pomodoro
                      Expanded(
                        child: _buildActionButton(
                          text: 'Start Pomodoro',
                          icon: Icons.timer_outlined,
                          color: const Color(0xFFF3E0C5),
                          onTap: () {
                            // Navigasi ke Pomodoro Screen
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => const PomodoroScreen())
                            );
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Widget Row Subtask dengan Checkbox
  Widget _buildSubTaskRow(int taskIndex, int subIndex, SubTaskModel subtask) {
    return InkWell(
      onTap: () => _controller.toggleSubtask(taskIndex, subIndex),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 24, height: 24,
              child: Checkbox(
                value: subtask.isCompleted,
                onChanged: (val) => _controller.toggleSubtask(taskIndex, subIndex),
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                subtask.title,
                style: TextStyle(
                  fontSize: 14,
                  color: subtask.isCompleted ? Colors.grey : Colors.black87,
                  decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper Tombol Kecil
  Widget _buildActionButton({
    required String text, 
    required IconData icon, 
    required Color color, 
    required VoidCallback onTap
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.black87),
              const SizedBox(width: 6),
              Text(
                text, 
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)
              ),
            ],
          ),
        ),
      ),
    );
  }
}