import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../widgets/custom_widgets.dart';
import '../../../Controllers/goal_detail_controller.dart'; // Import Controller
import 'edit_goal_screen.dart';

class GoalDetailScreen extends StatefulWidget {
  const GoalDetailScreen({super.key});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  // Instansiasi Controller
  final GoalDetailController _controller = GoalDetailController();

  @override
  void dispose() {
    _controller.dispose(); // Bersihkan memori saat keluar
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder akan me-rebuild widget di dalamnya setiap kali
    // controller memanggil notifyListeners()
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
            title: const Text('Your Goal'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Complete your Belajar Membaca', style: kHeaderStyle),
                const SizedBox(height: 20),
                
                RetroCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ... Bagian Reward (Static) ...
                      const Text('REWARD :', style: kLabelStyle),
                      const SizedBox(height: 10),
                      _buildRewardBox(), // Saya pisah jadi method kecil biar rapi
                      const SizedBox(height: 20),

                      // ... Bagian Progress (Dynamic dari Controller) ...
                      const Text('PROGRESS', style: kLabelStyle),
                      const SizedBox(height: 5),
                      
                      // AMBIL DATA DARI CONTROLLER
                      CustomProgressBar(percentage: _controller.overallProgress),
                      const SizedBox(height: 5),
                      Text('${_controller.totalDoneCount}/${_controller.totalTaskCount} Tasks Complete'),
                      Text('(${_controller.overallPercentage}% Done)', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

                      // ... List Task (Looping dari Controller) ...
                      ..._controller.tasks.asMap().entries.map((entry) {
                        return _buildTaskItem(entry.key, entry.value);
                      }).toList(),

                      const SizedBox(height: 30),
                      // ... Footer Buttons ...
                      _buildFooterButtons(context), // Saya pisah jadi method kecil biar rapi
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget Helper: Item Task
  Widget _buildTaskItem(int index, TaskData task) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: kButtonColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          // Header Task
          InkWell(
            onTap: () => _controller.toggleExpand(index), // PANGGIL CONTROLLER
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(task.isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.chevron_right_rounded, size: 28),
                  const SizedBox(width: 8),
                  Expanded(child: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                  Text('${task.completedCount}/${task.subtasks.length} done', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),

          // Body Subtasks
          if (task.isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  ...task.subtasks.asMap().entries.map((entry) {
                    return _buildSubTaskRow(index, entry.key, entry.value);
                  }).toList(),
                  const SizedBox(height: 16),
                  
                  // Tombol Aksi
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          text: task.isAllDone ? 'Unmark all' : 'Mark all as done',
                          onTap: () => _controller.toggleMarkAll(index), // PANGGIL CONTROLLER
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionButton(
                          text: 'Start as Pomodoro',
                          onTap: () {}, // Navigasi ke pomodoro nanti
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

  // Widget Helper: Subtask Row
  Widget _buildSubTaskRow(int taskIndex, int subIndex, SubTaskData subtask) {
    return GestureDetector(
      onTap: () => _controller.toggleSubtask(taskIndex, subIndex), // PANGGIL CONTROLLER
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                subtask.title,
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: subtask.isDone ? Colors.grey : Colors.black,
                  decoration: subtask.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: subtask.isDone ? const Color(0xFFD0DDB7) : Colors.transparent,
                border: Border.all(color: subtask.isDone ? const Color(0xFFD0DDB7) : Colors.grey.shade400, width: 2),
              ),
              child: subtask.isDone ? const Icon(Icons.check, size: 16, color: Colors.black54) : null,
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper: Tombol Kecil (Mark All / Pomodoro)
  Widget _buildActionButton({required String text, required VoidCallback onTap}) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF3E0C5),
          foregroundColor: kTextColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.black12)),
        ),
        onPressed: onTap,
        child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Widget Helper: Reward Box (Hanya visual)
  Widget _buildRewardBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: kButtonColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 1, blurRadius: 2, offset: const Offset(0, 2))],
      ),
      child: const Center(child: Text('Vacation to Japan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
    );
  }

  // Widget Helper: Footer Buttons (Edit/Delete)
 Widget _buildFooterButtons(BuildContext context) { // Tambah parameter context jika belum ada
  return Row(
    children: [
      Expanded(
        child: RetroButton(
          text: 'Edit Goal', 
          onPressed: () {
            // --- NAVIGASI KE HALAMAN EDIT BARU ---
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const EditGoalScreen())
            );
          }
        ),
      ),
      const SizedBox(width: 20),
      Expanded(child: RetroButton(text: 'Delete Goal', onPressed: () {})),
    ],
  );
}
}