import 'package:flutter/material.dart';
import '../../../common/constants/constants.dart';
import '../controllers/edit_goal_controller.dart';
import '../models/goal_model.dart';

class EditGoalScreen extends StatefulWidget {
  final GoalModel goal;

  const EditGoalScreen({super.key, required this.goal});

  @override
  State<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends State<EditGoalScreen> with SingleTickerProviderStateMixin {
  final EditGoalController _controller = EditGoalController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller.loadGoal(widget.goal);
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Beige background konsisten dengan dashboard
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E4F3C), // Hijau gelap
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        ),
        title: const Text(
          'Refine Your Goal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: () => _controller.saveGoal(context),
              child: const Text(
                'SAVE',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC4CE8F), fontSize: 14),
              ),
            ),
          )
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER GREETING ---
                    const Text(
                      'Sharpen your vision!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Adjust your plan and milestones to ensure you stay on the path to success.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D), height: 1.4),
                    ),
                    const SizedBox(height: 32),

                    // --- SECTION 1: GOAL TITLE ---
                    _buildSectionHeader('DEFINE YOUR DESTINATION', Icons.flag_rounded),
                    const Text(
                      'What is the big achievement you are aiming for today?',
                      style: TextStyle(fontSize: 12, color: Color(0xFF95A5A6), fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 12),
                    _buildInputCard(
                      child: TextFormField(
                        controller: _controller.goalTitleController,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        decoration: _inputDecoration('e.g., Master Flutter Framework'),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- SECTION 2: TASKS ---
                    _buildSectionHeader('ROADMAP TO SUCCESS', Icons.map_rounded),
                    const Text(
                      'Break your goal into smaller, actionable steps.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF95A5A6), fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 12),
                    ..._controller.tasks.asMap().entries.map((entry) {
                      return _buildTaskEditorItem(entry.key, entry.value);
                    }).toList(),
                    
                    const SizedBox(height: 8),
                    Center(
                      child: _buildAddButton(
                        text: 'Add New Milestone',
                        onTap: () => _controller.addNewTask(),
                        icon: Icons.add_circle_outline_rounded,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- SECTION 3: REWARD ---
                    _buildSectionHeader('THE GRAND PRIZE', Icons.emoji_events_rounded),
                    const Text(
                      'How will you celebrate once you reach the finish line?',
                      style: TextStyle(fontSize: 12, color: Color(0xFF95A5A6), fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 12),
                    _buildInputCard(
                      child: TextFormField(
                        controller: _controller.rewardController,
                        decoration: _inputDecoration('e.g., Weekend getaway or a fancy dinner'),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF3E4F3C)), // Menggunakan warna primer app
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13, 
            fontWeight: FontWeight.w800, 
            color: Color(0xFF3E4F3C), 
            letterSpacing: 1.1
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: _cardDecoration(),
      child: child,
    );
  }

  Widget _buildTaskEditorItem(int taskIndex, TaskUIState taskState) {
    var task = taskState.data;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: task.title,
                    key: Key('task_${task.id}'),
                    onChanged: (val) => _controller.updateTaskTitle(taskIndex, val),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                    decoration: const InputDecoration(
                      border: InputBorder.none, 
                      hintText: 'Enter task name...',
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _controller.toggleTaskExpansion(taskIndex),
                  icon: Icon(
                    taskState.isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF6C63FF),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                  onPressed: () => _controller.deleteTask(taskIndex),
                ),
              ],
            ),
          ),
          if (taskState.isExpanded) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            ...task.subtasks.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(left: 32, right: 12),
                child: Row(
                  children: [
                    const Icon(Icons.subdirectory_arrow_right_rounded, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.value.title,
                        key: ValueKey('sub_${task.id}_${entry.key}'),
                        onChanged: (val) => _controller.updateSubTaskTitle(taskIndex, entry.key, val),
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(border: InputBorder.none, hintText: 'Add a small detail...'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                      onPressed: () => _controller.deleteSubTask(taskIndex, entry.key),
                    )
                  ],
                ),
              );
            }).toList(),
            InkWell(
              onTap: () => _controller.addSubTask(taskIndex),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, size: 14, color: Color(0xFF6C63FF)),
                    const SizedBox(width: 6),
                    Text(
                      'Add sub-milestone', 
                      style: TextStyle(color: const Color(0xFF6C63FF), fontWeight: FontWeight.bold, fontSize: 13)
                    ),
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildAddButton({required String text, required VoidCallback onTap, required IconData icon}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6C63FF), // Ungu produktivitas
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFBDC3C7), fontSize: 14, fontWeight: FontWeight.normal),
      border: InputBorder.none,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}