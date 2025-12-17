import 'package:flutter/material.dart';
import '../../../common/constants/constants.dart';
import '../../../common/widgets/custom_widgets.dart';
import '../controllers/new_goal_controller.dart';

class NewGoalScreen extends StatefulWidget {
  const NewGoalScreen({super.key});

  @override
  State<NewGoalScreen> createState() => _NewGoalScreenState();
}

class _NewGoalScreenState extends State<NewGoalScreen> {
  final NewGoalController _controller = NewGoalController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
        title: const Text('New Goal'),
        actions: [
          TextButton(
            onPressed: () => _controller.createGoal(context),
            child: const Text('Create', style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold, fontSize: 18)),
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
                const Text('Create Your New Goal', style: kHeaderStyle),
                const SizedBox(height: 20),
                
                RetroCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Set Your Goal :', style: kLabelStyle),
                      const SizedBox(height: 10),
                      const Text('What do you want to Achieve?', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _controller.goalTitleController,
                        decoration: const InputDecoration(hintText: 'Contoh: Belajar Javascript'),
                      ),
                      const SizedBox(height: 15),
                      const Text('What the progress :', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),

                      if (_controller.tasks.isEmpty)
                         const Padding(
                           padding: EdgeInsets.symmetric(vertical: 20),
                           child: Center(child: Text("Belum ada task. Tekan tombol di bawah.", style: TextStyle(color: Colors.grey))),
                         ),

                      ..._controller.tasks.asMap().entries.map((entry) {
                        return _buildTaskEditorItem(entry.key, entry.value);
                      }).toList(),

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

                // Bagian Reward
                RetroCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Set Self Reward :', style: kLabelStyle),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _controller.rewardController,
                        maxLines: 2,
                        decoration: const InputDecoration(hintText: 'Contoh: Main game seharian'),
                      ),
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

  Widget _buildTaskEditorItem(int taskIndex, TaskUIState taskState) {
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
          // === HEADER TASK ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: task.title,
                    // Kunci PENTING: Gunakan ID task, bukan index
                    key: ValueKey('task_title_${task.id}'),
                    onChanged: (val) => _controller.updateTaskTitle(taskIndex, val),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Tulis Judul Task...',
                      isDense: true,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                // Toggle Expand
                GestureDetector(
                  onTap: () => _controller.toggleTaskExpansion(taskIndex),
                  child: Row(
                    children: [
                       const Icon(Icons.description_outlined, size: 24, color: Colors.grey),
                       const SizedBox(width: 4),
                       Text('${task.subtasks.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Delete Task
                InkWell(
                  onTap: () => _controller.deleteTask(taskIndex),
                  child: const Icon(Icons.delete_outline, color: Colors.red),
                )
              ],
            ),
          ),
          
          // === BODY SUBTASKS ===
          if (taskState.isExpanded) ...[
            const Divider(height: 1, thickness: 1),
            
            // Loop Subtasks
            if (task.subtasks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text("Belum ada subtask", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),

            ...task.subtasks.asMap().entries.map((entry) {
              int subIndex = entry.key;
              var subtask = entry.value;

              return Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5))
                ),
                child: Row(
                  children: [
                    // CHECKBOX (Boolean)
                    Checkbox(
                      value: subtask.isCompleted, 
                      onChanged: (val) => _controller.toggleSubTaskStatus(taskIndex, subIndex),
                      activeColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    
                    // INPUT SUBTASK
                    Expanded(
                      child: TextFormField(
                        initialValue: subtask.title,
                        // Kunci PENTING: Gunakan ID unik subtask
                        key: ValueKey('sub_${subtask.id}'), 
                        onChanged: (val) => _controller.updateSubTaskTitle(taskIndex, subIndex, val),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Tulis subtask...',
                          isDense: true,
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          // Coret jika selesai
                          decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                          color: subtask.isCompleted ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                    
                    // DELETE SUBTASK
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                      onPressed: () => _controller.deleteSubTask(taskIndex, subIndex),
                    )
                  ],
                ),
              );
            }).toList(),
            
            // Tombol Add Subtask
            InkWell(
              onTap: () => _controller.addSubTask(taskIndex),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: Colors.grey.shade50,
                child: Center(
                   child: Text('+ Tambah Subtask', style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}