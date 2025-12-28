import 'package:flutter/material.dart';
import '../../../common/constants/constants.dart';
import '../models/goal_model.dart';
import '../controllers/goal_detail_controller.dart';
import '../../Pomodoro/views/pomodoro_screen.dart';
import 'edit_goal_screen.dart';

class GoalDetailScreen extends StatefulWidget {
  final GoalModel goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> with SingleTickerProviderStateMixin {
  final GoalDetailController _controller = GoalDetailController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller.init(widget.goal);
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

  void _navigateToEdit() async {
    await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => EditGoalScreen(goal: _controller.currentGoal))
    );
    setState(() {
      _controller.init(_controller.currentGoal);
    });
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Goal?'),
        content: const Text('Are you sure you want to delete this goal? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              await _controller.deleteGoal(context);
              if (mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Beige background
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E4F3C), // Hijau gelap
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        ),
        title: const Text(
          'Goal Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Text(
                      'Target: ${_controller.currentGoal.title}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Track your progress and stay focused!',
                      style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
                    ),
                    const SizedBox(height: 24),

                    // Reward Card
                    _buildSectionHeader('YOUR REWARD', Icons.emoji_events_outlined),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: _cardDecoration(color: Colors.white),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9800).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.card_giftcard, color: Color(0xFFFF9800)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _controller.currentGoal.reward,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C3E50)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Progress Section
                    _buildSectionHeader('OVERALL PROGRESS', Icons.analytics_outlined),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: _cardDecoration(color: Colors.white),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${_controller.progressPercentage}% Completed', 
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6C63FF))),
                              if (_controller.overallProgress >= 1.0)
                                const Text('Status: Done ✨', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: _controller.overallProgress,
                            backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                            color: const Color(0xFF6C63FF),
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tasks Section
                    _buildSectionHeader('TASKS & MILESTONES', Icons.checklist_rtl_outlined),
                    const SizedBox(height: 12),
                    ..._controller.taskStates.asMap().entries.map((entry) {
                      return _buildTaskItem(entry.key, entry.value);
                    }).toList(),

                    const SizedBox(height: 30),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildMainActionButton(
                            text: 'Edit Goal',
                            icon: Icons.edit_outlined,
                            color: const Color(0xFF6C63FF),
                            onTap: _navigateToEdit,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildMainActionButton(
                            text: 'Delete',
                            icon: Icons.delete_outline,
                            color: Colors.redAccent,
                            onTap: _confirmDelete,
                            isOutlined: true,
                          ),
                        ),
                      ],
                    ),
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
        Icon(icon, size: 18, color: const Color(0xFF7F8C8D)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF7F8C8D), letterSpacing: 1.1),
        ),
      ],
    );
  }

  Widget _buildTaskItem(int index, TaskDetailState taskState) {
    TaskModel task = taskState.data;
    bool isAllDone = task.subtasks.isNotEmpty && task.subtasks.every((s) => s.isCompleted);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: _cardDecoration(color: Colors.white),
      child: Column(
        children: [
          InkWell(
            onTap: () => _controller.toggleExpand(index),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    taskState.isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.chevron_right_rounded, 
                    color: const Color(0xFF6C63FF)
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C3E50))
                    )
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAllDone ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${task.subtasks.where((s) => s.isCompleted).length}/${task.subtasks.length}',
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold,
                        color: isAllDone ? const Color(0xFF4CAF50) : Colors.grey[600]
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (taskState.isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  if (task.subtasks.isEmpty)
                     const Text("No subtasks available", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ...task.subtasks.asMap().entries.map((entry) {
                    return _buildSubTaskRow(index, entry.key, entry.value);
                  }).toList(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallActionButton(
                          text: isAllDone ? 'Unmark All' : 'Mark Done',
                          icon: isAllDone ? Icons.remove_done : Icons.done_all,
                          color: const Color(0xFF4CAF50),
                          onTap: () => _controller.markAllDone(index),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSmallActionButton(
                          text: 'Pomodoro',
                          icon: Icons.timer_outlined,
                          color: const Color(0xFFFF9800),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const PomodoroScreen()));
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

  Widget _buildSubTaskRow(int taskIndex, int subIndex, SubTaskModel subtask) {
    return InkWell(
      onTap: () => _controller.toggleSubtask(taskIndex, subIndex),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Transform.scale(
              scale: 0.9,
              child: Checkbox(
                value: subtask.isCompleted,
                onChanged: (val) => _controller.toggleSubtask(taskIndex, subIndex),
                activeColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            Expanded(
              child: Text(
                subtask.title,
                style: TextStyle(
                  fontSize: 14,
                  color: subtask.isCompleted ? Colors.grey : const Color(0xFF2C3E50),
                  decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainActionButton({required String text, required IconData icon, required Color color, required VoidCallback onTap, bool isOutlined = false}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: isOutlined ? color : Colors.white),
      label: Text(text, style: TextStyle(color: isOutlined ? color : Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.transparent : color,
        elevation: 0,
        side: isOutlined ? BorderSide(color: color) : null,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSmallActionButton({required String text, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration({required Color color}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}