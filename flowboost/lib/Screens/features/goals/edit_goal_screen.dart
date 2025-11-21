import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../Widgets/custom_widgets.dart';
import '../../../Controllers/edit_goal_controller.dart';

class EditGoalScreen extends StatefulWidget {
  const EditGoalScreen({super.key});

  @override
  State<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends State<EditGoalScreen> {
  final EditGoalController _controller = EditGoalController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Edit Goal'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Logic Simpan Data ke Database/API
              Navigator.pop(context); 
            },
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
          )
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit Your New Goal', style: kHeaderStyle),
                const SizedBox(height: 15),

                // --- 1. WARNING BANNER ---
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black54),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.black),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Unfinished the task first if you want to edit or delete",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- 2. SET YOUR GOAL SECTION ---
                RetroCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Set Your Goal :', style: kLabelStyle),
                      const SizedBox(height: 15),
                      
                      // Input Goal Title
                      const Text('What do you want to Achieve?', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _controller.goalTitleController,
                        decoration: const InputDecoration(hintText: 'Ex: Belajar coding'),
                      ),
                      const SizedBox(height: 20),

                      // Task List Label
                      const Text('What the progress :', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),

                      // --- DYNAMIC TASK LIST ---
                      ..._controller.tasks.asMap().entries.map((entry) {
                        int index = entry.key;
                        TaskData task = entry.value;
                        return _buildTaskEditorItem(index, task);
                      }).toList(),

                      const SizedBox(height: 15),
                      
                      // Button Add New Task
                      Center(
                        child: RetroButton(
                          text: 'add new task +',
                          onPressed: () => _controller.addNewTask(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- 3. SET SELF REWARD SECTION ---
                RetroCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Set Self Reward :', style: kLabelStyle),
                      const SizedBox(height: 15),
                      
                      const Text('What reward after complete the goal?', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _controller.rewardController,
                        decoration: const InputDecoration(hintText: 'Ex: Buy a coffee'),
                      ),
                      const SizedBox(height: 20),

                      const Text('Reward Suggestion :', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.only(left: 10, bottom: 8),
                        child: Text('Watch Movie on Cinema'),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 10, bottom: 20),
                        child: Text('Buy your Wishlist Book'),
                      ),

                      Center(
                        child: RetroButton(
                          text: 'generate new suggestion',
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                // Extra space for scrolling
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET HELPER: TASK EDITOR ITEM (Kotak Putih berisi Task & Subtask) ---
  Widget _buildTaskEditorItem(int taskIndex, TaskData task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          // 1. HEADER (PARENT TASK)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: task.title,
                    onChanged: (val) => _controller.updateTaskTitle(taskIndex, val),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: 'Task Title',
                      fillColor: Colors.transparent, // Transparan agar menyatu dgn kotak putih
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                // Custom Icon: Dokumen dengan angka subtask (badge)
                GestureDetector(
                  onTap: () => _controller.toggleTaskExpansion(taskIndex),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.description_outlined, size: 28, color: Colors.black87),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Text(
                          '${task.subtasks.length}', // Jumlah subtask
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Tombol Hapus Task
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.black),
                  onPressed: () => _controller.deleteTask(taskIndex),
                ),
              ],
            ),
          ),

          // 2. SUBTASKS LIST (Hanya muncul jika isExpanded = true)
          if (task.isExpanded) ...[
            const Divider(height: 1, thickness: 1),
            
            // Loop Subtasks
            ...task.subtasks.asMap().entries.map((entry) {
              int subIndex = entry.key;
              SubTaskData subtask = entry.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 12, top: 0, bottom: 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: subtask.title,
                            onChanged: (val) => _controller.updateSubTaskTitle(taskIndex, subIndex, val),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: 'Subtask title',
                              fillColor: Colors.transparent,
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.black87),
                          onPressed: () => _controller.deleteSubTask(taskIndex, subIndex),
                        )
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1), // Garis pemisah antar subtask
                ],
              );
            }).toList(),

            // 3. TOMBOL ADD SUBTASK
            GestureDetector(
              onTap: () => _controller.addSubTask(taskIndex),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E0C5), // Warna beige tombol
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'add subtask +',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}