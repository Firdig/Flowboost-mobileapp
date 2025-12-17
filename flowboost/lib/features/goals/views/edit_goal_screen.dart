import 'package:flutter/material.dart';
import '../../../common/constants/constants.dart';
import '../../../common/widgets/custom_widgets.dart';
import '../controllers/edit_goal_controller.dart';
import '../models/goal_model.dart'; // Import Model

class EditGoalScreen extends StatefulWidget {
  final GoalModel goal; // Tambah parameter ini

  const EditGoalScreen({super.key, required this.goal});

  @override
  State<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends State<EditGoalScreen> {
  final EditGoalController _controller = EditGoalController();

  @override
  void initState() {
    super.initState();
    // Load data dari widget.goal ke controller
    _controller.loadGoal(widget.goal);
  }

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
            onPressed: () => _controller.saveGoal(context), // Panggil Fungsi Save
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

                // ... WARNING BANNER ...
                // (Kode Banner sama seperti sebelumnya, tidak diubah)
                
                const SizedBox(height: 20),

                // --- 2. SET YOUR GOAL SECTION ---
                RetroCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Set Your Goal :', style: kLabelStyle),
                      const SizedBox(height: 15),
                      
                      const Text('What do you want to Achieve?', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _controller.goalTitleController,
                        decoration: const InputDecoration(hintText: 'Ex: Belajar coding'),
                      ),
                      const SizedBox(height: 20),

                      const Text('What the progress :', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),

                      // --- DYNAMIC TASK LIST ---
                      // Loop dari data tasks di controller
                      ..._controller.tasks.asMap().entries.map((entry) {
                        return _buildTaskEditorItem(entry.key, entry.value);
                      }).toList(), // Hapus .toList() jika error iterable, tapi biasanya aman.

                      const SizedBox(height: 15),
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

                      // ... Suggestion UI ... (Sama seperti sebelumnya)
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- HELPER WIDGET ---
  Widget _buildTaskEditorItem(int taskIndex, TaskUIState taskState) {
    // Perhatikan: parameter sekarang TaskUIState
    var task = taskState.data; 

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: task.title,
                    // Gunakan unique key agar field tidak error saat list berubah
                    key: Key('task_${task.id}'), 
                    onChanged: (val) => _controller.updateTaskTitle(taskIndex, val),
                    decoration: const InputDecoration(
                      border: InputBorder.none, hintText: 'Task Title', isDense: true
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                GestureDetector(
                  onTap: () => _controller.toggleTaskExpansion(taskIndex),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.description_outlined, size: 28, color: Colors.black87),
                      Positioned(
                        right: 0, top: 0,
                        child: Text('${task.subtasks.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.black),
                  onPressed: () => _controller.deleteTask(taskIndex),
                ),
              ],
            ),
          ),
          
          if (taskState.isExpanded) ...[
            const Divider(height: 1),
            ...task.subtasks.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(left: 20, right: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.value.title,
                        key: ValueKey('sub_${task.id}_${entry.key}'), // Key unik
                        onChanged: (val) => _controller.updateSubTaskTitle(taskIndex, entry.key, val),
                        decoration: const InputDecoration(border: InputBorder.none, hintText: 'Subtask title'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                      onPressed: () => _controller.deleteSubTask(taskIndex, entry.key),
                    )
                  ],
                ),
              );
            }).toList(),
            
            GestureDetector(
              onTap: () => _controller.addSubTask(taskIndex),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                   child: Text('add subtask +', style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}