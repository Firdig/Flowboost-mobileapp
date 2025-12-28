import 'package:flutter/material.dart';
import '../../../common/constants/constants.dart';
import '../controllers/new_goal_controller.dart';

class NewGoalScreen extends StatefulWidget {
  const NewGoalScreen({super.key});

  @override
  State<NewGoalScreen> createState() => _NewGoalScreenState();
}

class _NewGoalScreenState extends State<NewGoalScreen> with SingleTickerProviderStateMixin {
  final NewGoalController _controller = NewGoalController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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
      backgroundColor: const Color(0xFFF5F5DC), // Beige background konsisten
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E4F3C), // Hijau gelap
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        ),
        title: const Text(
          'Create New Goal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: () => _controller.createGoal(context),
              child: const Text(
                'CREATE',
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
                      'Start something great!',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Define your ambition and break it down into small, manageable steps.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D), height: 1.4),
                    ),
                    const SizedBox(height: 32),

                    // --- SECTION 1: GOAL TITLE ---
                    _buildSectionHeader('YOUR BIG AMBITION', Icons.rocket_launch_rounded),
                    const Text(
                      'Give your goal a clear and inspiring name.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF95A5A6), fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 12),
                    _buildInputCard(
                      child: TextFormField(
                        controller: _controller.goalTitleController,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        decoration: _inputDecoration('e.g., Run a 5K Marathon'),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- SECTION 2: TASKS ---
                    _buildSectionHeader('ACTIONABLE STEPS', Icons.format_list_bulleted_rounded),
                    const Text(
                      'Success is a series of small wins. Add your tasks here.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF95A5A6), fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 12),
                    
                    if (_controller.tasks.isEmpty)
                      _buildEmptyState()
                    else
                      ..._controller.tasks.asMap().entries.map((entry) {
                        return _buildTaskEditorItem(entry.key, entry.value);
                      }).toList(),
                    
                    const SizedBox(height: 8),
                    Center(
                      child: _buildAddButton(
                        text: 'Add New Task',
                        onTap: () => _controller.addNewTask(),
                        icon: Icons.add_circle_outline_rounded,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- SECTION 3: REWARD ---
                    _buildSectionHeader('SELF REWARD', Icons.card_giftcard_rounded),
                    const Text(
                      'Treat yourself! What will you get when this goal is done?',
                      style: TextStyle(fontSize: 12, color: Color(0xFF95A5A6), fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 12),
                    _buildInputCard(
                      child: TextFormField(
                        controller: _controller.rewardController,
                        maxLines: 2,
                        decoration: _inputDecoration('e.g., A relaxing spa day or a new book'),
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
        Icon(icon, size: 18, color: const Color(0xFF3E4F3C)),
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05), style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_add, size: 40, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 8),
          const Text("No tasks added yet.", style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
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
                    key: ValueKey('task_title_${task.id}'),
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
                        key: ValueKey('sub_${entry.value.id}'),
                        onChanged: (val) => _controller.updateSubTaskTitle(taskIndex, entry.key, val),
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(border: InputBorder.none, hintText: 'Add a detail...'),
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
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.05),
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, size: 14, color: Color(0xFF6C63FF)),
                    const SizedBox(width: 6),
                    Text(
                      'Add sub-task', 
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
        backgroundColor: const Color(0xFF6C63FF),
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