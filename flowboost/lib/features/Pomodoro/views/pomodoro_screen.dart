import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/constants/constants.dart';
import '../../goals/models/goal_model.dart';
import '../provider/pomodoro_provider.dart';
import '../models/pomodoro_task_model.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> with SingleTickerProviderStateMixin {
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
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // 1. SETTINGS DIALOG
  // ==========================================================================
  void _showSettingsDialog(BuildContext context) {
    final provider = Provider.of<PomodoroProvider>(context, listen: false);
    
    final pomodoroController = TextEditingController(text: provider.pomodoroMinutes.toString());
    final shortBreakController = TextEditingController(text: provider.shortBreakMinutes.toString());
    final longBreakController = TextEditingController(text: provider.longBreakMinutes.toString());
    
    bool autoStartBreak = provider.autoStartBreak;
    bool autoStartPomodoro = provider.autoStartPomodoro;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('TIMER (minutes)', style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D), fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTimeSettingRow('Pomodoro', pomodoroController),
                    const SizedBox(height: 12),
                    _buildTimeSettingRow('Short Break', shortBreakController),
                    const SizedBox(height: 12),
                    _buildTimeSettingRow('Long Break', longBreakController),

                    const SizedBox(height: 24),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('AUTO START', style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D), fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 10),
                    
                    SwitchListTile(
                      title: const Text('Auto-start Breaks?', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF2C3E50))),
                      value: autoStartBreak,
                      activeColor: const Color(0xFF6C63FF),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => autoStartBreak = val),
                    ),
                    SwitchListTile(
                      title: const Text('Auto-start Pomodoro?', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF2C3E50))),
                      value: autoStartPomodoro,
                      activeColor: const Color(0xFF6C63FF),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => autoStartPomodoro = val),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final pomo = int.tryParse(pomodoroController.text) ?? 25;
                          final short = int.tryParse(shortBreakController.text) ?? 5;
                          final long = int.tryParse(longBreakController.text) ?? 15;

                          provider.updateSettings(
                            pomodoroMinutes: pomo,
                            shortBreakMinutes: short,
                            longBreakMinutes: long,
                            autoStartBreak: autoStartBreak,
                            autoStartPomodoro: autoStartPomodoro,
                          );
                          
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C3E50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimeSettingRow(String label, TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF2C3E50))),
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5DC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // 2. DIALOG USE GOALS FLOW
  // ==========================================================================

  // Step 1: Pilih Goal
  Future<void> _showChooseGoalDialog() async {
    final pomodoroProvider = Provider.of<PomodoroProvider>(context, listen: false);
    String? selectedGoalId;

    final unfinishedGoals = pomodoroProvider.firestoreGoals
        .where((goal) => !goal.isFinished)
        .toList();

    if (unfinishedGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada Goal aktif yang tersedia.'), backgroundColor: Colors.orange),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return ChangeNotifierProvider.value(
          value: pomodoroProvider, 
          child: StatefulBuilder(
            builder: (context, setDialogState) => Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Choose Goal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                      child: SingleChildScrollView(
                        child: Column(
                          children: unfinishedGoals.map((goal) {
                            final isSelected = selectedGoalId == goal.id;
                            final percentage = (goal.progress * 100).toInt();
                            
                            return GestureDetector(
                              onTap: () => setDialogState(() => selectedGoalId = goal.id),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade200,
                                    width: isSelected ? 1.5 : 1
                                  ),
                                  boxShadow: [
                                    if(!isSelected) BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0,2))
                                  ]
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.flag, color: isSelected ? const Color(0xFF4CAF50) : Colors.grey),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(goal.title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
                                          Text('Progress: $percentage%', style: const TextStyle(fontSize: 12, color: Color(0xFF7F8C8D))),
                                        ],
                                      ),
                                    ),
                                    if(isSelected) const Icon(Icons.check_circle, color: Color(0xFF4CAF50))
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedGoalId == null ? null : () {
                          Navigator.pop(context);
                          final selectedGoal = unfinishedGoals.firstWhere((g) => g.id == selectedGoalId);
                          _showChooseTaskDialog(selectedGoal);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C3E50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Step 2: Pilih Task
  Future<void> _showChooseTaskDialog(GoalModel selectedGoal) async {
    final pomodoroProvider = Provider.of<PomodoroProvider>(context, listen: false);

    if (selectedGoal.tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal ini tidak memiliki task.'), backgroundColor: Colors.orange),
      );
      _showChooseGoalDialog();
      return;
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return ChangeNotifierProvider.value(
          value: pomodoroProvider,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Choose Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(dialogContext)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Goal: ${selectedGoal.title}", style: const TextStyle(color: Color(0xFF7F8C8D), fontStyle: FontStyle.italic)),
                  const SizedBox(height: 16),
                  
                  Container(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                    child: SingleChildScrollView(
                      child: Column(
                        children: selectedGoal.tasks.map((taskModel) {
                          final completedSub = taskModel.subtasks.where((s) => s.isCompleted).length;
                          final totalSub = taskModel.subtasks.length;
                          final progress = '$completedSub/$totalSub done';
              
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.assignment_outlined, color: Color(0xFF6C63FF)),
                              title: Text(taskModel.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              trailing: Text(progress, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              onTap: () {
                                Navigator.pop(dialogContext);
                                if (taskModel.subtasks.isNotEmpty) {
                                  _showSubTaskDetailDialog(selectedGoal, taskModel);
                                } else {
                                  _processSingleTaskFromGoal(selectedGoal.title, taskModel.title);
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _showChooseGoalDialog();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFF2C3E50))
                      ),
                      child: const Text('Back', style: TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Step 3: Pilih Subtask (jika ada)
  Future<void> _showSubTaskDetailDialog(GoalModel goal, TaskModel taskModel) async {
    final pomodoroProvider = Provider.of<PomodoroProvider>(context, listen: false);
    Map<int, int> subTaskCycles = {};
    for (int i = 0; i < taskModel.subtasks.length; i++) {
      subTaskCycles[i] = 0; 
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return ChangeNotifierProvider.value(
          value: pomodoroProvider,
          child: StatefulBuilder(
            builder: (context, setDialogState) => Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Set Cycles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    Text("${goal.title} > ${taskModel.title}", style: const TextStyle(color: Color(0xFF7F8C8D), fontSize: 12)),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: List.generate(taskModel.subtasks.length, (index) {
                            final subTask = taskModel.subtasks[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200)
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(subTask.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text("Cycles: ", style: TextStyle(color: Colors.grey)),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF2C3E50)),
                                        onPressed: () {
                                          if ((subTaskCycles[index] ?? 0) > 0) {
                                            setDialogState(() => subTaskCycles[index] = (subTaskCycles[index] ?? 0) - 1);
                                          }
                                        },
                                      ),
                                      Text('${subTaskCycles[index]}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF2C3E50)),
                                        onPressed: () {
                                          setDialogState(() => subTaskCycles[index] = (subTaskCycles[index] ?? 0) + 1);
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showChooseTaskDialog(goal);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: const BorderSide(color: Color(0xFF2C3E50))
                            ),
                            child: const Text('Back', style: TextStyle(color: Color(0xFF2C3E50))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              int totalCycles = 0;
                              subTaskCycles.forEach((_, val) => totalCycles += val);
                              if (totalCycles <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih minimal 1 cycle'), backgroundColor: Colors.red));
                                return;
                              }
                              
                              Navigator.pop(context);

                              // Cek apakah ada task (bukan kosong) di list
                              final hasTasks = pomodoroProvider.tasks.isNotEmpty;
                              
                              final result = await _showStartPomodoroDialog(
                                  totalCycles,
                                  goal.title,
                                  taskModel.title,
                                  hasTasks
                              );

                              if (result != null && result != 'cancel') {
                                _handleMultipleSubTasksWithGoalData(goal, taskModel, subTaskCycles, result);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2C3E50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Start'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // 3. LOGIC HANDLERS (REPLACE & ADD FIX)
  // ==========================================================================

  /// Handler untuk Single Task (Task tanpa subtask dari Goal)
  Future<void> _processSingleTaskFromGoal(String goalTitle, String taskTitle) async {
    const defaultCycles = 4; 
    final provider = Provider.of<PomodoroProvider>(context, listen: false);
    final hasTasks = provider.tasks.isNotEmpty;
    
    final result = await _showStartPomodoroDialog(defaultCycles, goalTitle, taskTitle, hasTasks);
    
    if (result != null && result != 'cancel') {
       if (result == 'replace') {
         // ✅ LOGIC REPLACE: Hapus semua task yang ada
         final allTaskIds = provider.allTasks.map((e) => e.id).toList();
         for (var id in allTaskIds) {
           provider.deleteTask(id);
         }
         // Clear editing state jika ada
         if (provider.editingTaskId != null) provider.cancelEditingTask();
         
         // Tambah task baru
         provider.addNewTask(taskTitle, defaultCycles, 'Goal: $goalTitle');
         
         if(mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('List replaced with new task'), backgroundColor: Colors.green));
         }

       } else if (result == 'add') {
         // ✅ LOGIC ADD: Tambah ke akhir list (default behavior)
         provider.addNewTask(taskTitle, defaultCycles, 'Goal: $goalTitle');
         
         if(mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task added to end of list'), backgroundColor: Colors.blue));
         }
       }
    }
  }

  /// Handler untuk Multiple Subtasks
  void _handleMultipleSubTasksWithGoalData(GoalModel goal, TaskModel taskModel, Map<int, int> cycles, String action) {
    final provider = Provider.of<PomodoroProvider>(context, listen: false);
    
    // ✅ LOGIC REPLACE: Hapus semua task sebelum menambahkan yang baru
    if (action == 'replace') {
      final allTaskIds = provider.allTasks.map((e) => e.id).toList();
      for (var id in allTaskIds) {
        provider.deleteTask(id);
      }
      if (provider.editingTaskId != null) provider.cancelEditingTask();
    }

    // Tambahkan task-task yang dipilih
    cycles.forEach((index, cycleCount) {
      if (cycleCount > 0) {
        final sub = taskModel.subtasks[index];
        provider.addNewTask(sub.title, cycleCount, 'Goal: ${goal.title} > ${taskModel.title}');
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(action == 'replace' ? 'List replaced with selected tasks' : 'Tasks added to list'), 
          backgroundColor: action == 'replace' ? Colors.green : Colors.blue
        ),
      );
    }
  }

  Future<String?> _showStartPomodoroDialog(int totalCycles, String goalTitle, String? subTaskTitle, bool hasTasks) async {
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(hasTasks ? 'Replace or Add?' : 'Start Pomodoro', 
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(color: const Color(0xFFF5F5DC), borderRadius: BorderRadius.circular(10)),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text("Goal: $goalTitle", style: const TextStyle(fontWeight: FontWeight.bold)),
                     if(subTaskTitle != null) Text("Task: $subTaskTitle", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                     const SizedBox(height: 4),
                     Text("$totalCycles Cycles Total", style: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold, fontSize: 12)),
                   ],
                 ),
               ),
               const SizedBox(height: 16),
               Text(hasTasks 
                 ? 'You have existing tasks. Do you want to REPLACE the entire list or ADD these to the end?' 
                 : 'Ready to start focusing on this goal?',
                 style: const TextStyle(color: Colors.grey, fontSize: 13),
               ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context, 'cancel'),
            ),
            if(hasTasks)
              TextButton(
                child: const Text('Replace All', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.pop(context, 'replace'),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(context, 'add'),
              child: Text(hasTasks ? 'Add to List' : 'Start'),
            )
          ],
        );
      },
    );
  }

  // ==========================================================================
  // 4. MAIN UI
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PomodoroProvider>(context);
    final selectedTask = provider.selectedTask;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Background Dashboard Theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E4F3C), // Hijau Gelap Dashboard Theme
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pomodoro Focus",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
           IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // --- TIMER CARD SECTION ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Active Task Label
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          selectedTask?.title ?? 'Select a task to focus',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Mode Toggles
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F2F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            _buildModernModeButton(context, 'Pomodoro', PomodoroMode.pomodoro),
                            _buildModernModeButton(context, 'Short Break', PomodoroMode.shortBreak),
                            _buildModernModeButton(context, 'Long Break', PomodoroMode.longBreak),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),

                      // Timer Display
                      const _TimerDisplayUi(),
                      
                      const SizedBox(height: 40),

                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: ElevatedButton(
                              onPressed: provider.toggleTimer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: provider.isRunning 
                                    ? const Color(0xFFE74C3C) 
                                    : const Color(0xFF6C63FF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 4,
                                shadowColor: (provider.isRunning ? const Color(0xFFE74C3C) : const Color(0xFF6C63FF)).withOpacity(0.4),
                              ),
                              child: Text(
                                provider.isRunning ? 'PAUSE' : 'START FOCUS',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                              ),
                            ),
                          ),
                          
                          if (provider.isRunning) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 58,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: InkWell(
                                  onTap: provider.skipTimer,
                                  borderRadius: BorderRadius.circular(16),
                                  child: const Icon(Icons.skip_next_rounded, color: Color(0xFF2C3E50), size: 30),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- TASKS HEADER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tasks',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.view_list_rounded, color: Color(0xFF7F8C8D)),
                      onPressed: () => provider.showAllParentTasks(),
                      tooltip: 'Show all tasks',
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // --- TASK LIST ---
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.tasks.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final task = provider.tasks[index];
                    if (provider.editingTaskId == task.id) {
                       return _TaskEditForm(
                         task: task,
                         onUseGoals: _showChooseGoalDialog, 
                       ); 
                    }
                    return _TaskItem(task: task);
                  },
                ),

                const SizedBox(height: 20),

                // --- ADD TASK BUTTON ---
                if (provider.editingTaskId == null)
                  InkWell(
                    onTap: provider.startAddingTask,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3), width: 1.5),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          )
                        ]
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_circle_outline, color: Color(0xFF6C63FF)),
                            SizedBox(width: 8),
                            Text(
                              'Add New Task',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernModeButton(BuildContext context, String text, PomodoroMode mode) {
    final provider = Provider.of<PomodoroProvider>(context);
    final isSelected = provider.currentMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected 
              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]
              : [],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFF2C3E50) : const Color(0xFF95A5A6),
            ),
          ),
        ),
      ),
    );
  }
}

// --- TIMER DISPLAY UI ---
class _TimerDisplayUi extends StatelessWidget {
  const _TimerDisplayUi();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PomodoroProvider>(context);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(provider.currentDuration.inMinutes.remainder(60));
    final seconds = twoDigits(provider.currentDuration.inSeconds.remainder(60));

    int currentSession = 1;
    if (provider.selectedTask != null) {
      currentSession = provider.selectedTask!.completedSessions + 1;
    }

    return Column(
      children: [
        Text(
          '$minutes:$seconds',
          style: const TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.w200, 
            color: Color(0xFF2C3E50),
            letterSpacing: -2.0,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: provider.currentMode == PomodoroMode.pomodoro 
                ? const Color(0xFFE8F5E9) 
                : const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            provider.currentMode == PomodoroMode.pomodoro
                ? 'Session #$currentSession'
                : (provider.currentMode == PomodoroMode.shortBreak ? 'Short Break' : 'Long Break'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: provider.currentMode == PomodoroMode.pomodoro
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFF1565C0),
            ),
          ),
        ),
      ],
    );
  }
}

// --- TASK ITEM ---
class _TaskItem extends StatelessWidget {
  final PomodoroTask task;
  const _TaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PomodoroProvider>(context, listen: false);
    final isSelected = provider.selectedTask?.id == task.id;

    return GestureDetector(
      onTap: () => provider.selectTask(task.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F4C3).withOpacity(0.5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFF3E4F3C).withOpacity(0.3), width: 1.5)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () => provider.toggleTaskDone(task.id),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isDone ? const Color(0xFF4CAF50) : Colors.transparent,
                  border: Border.all(
                    color: task.isDone ? const Color(0xFF4CAF50) : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: task.isDone ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C3E50),
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                      decorationColor: Colors.grey,
                    ),
                  ),
                  if (task.note != null && task.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        task.note!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7F8C8D),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${task.completedSessions}/${task.targetSessions}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF546E7A)),
              ),
            ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFF90A4AE)),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'edit') {
                  provider.startEditingTask(task.id);
                } else if (value == 'delete') {
                  provider.deleteTask(task.id);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                const PopupMenuItem<String>(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- TASK EDIT FORM ---
class _TaskEditForm extends StatefulWidget {
  final PomodoroTask task;
  final VoidCallback onUseGoals;

  const _TaskEditForm({
    required this.task,
    required this.onUseGoals,
  });

  @override
  State<_TaskEditForm> createState() => _TaskEditFormState();
}

class _TaskEditFormState extends State<_TaskEditForm> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late int _targetSessions;
  bool _showNoteField = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _noteController = TextEditingController(text: widget.task.note ?? '');
    _targetSessions = widget.task.targetSessions;
    _showNoteField = widget.task.note != null && widget.task.note!.isNotEmpty;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PomodoroProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            autofocus: widget.task.title.isEmpty,
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.edit, color: Color(0xFF6C63FF)),
                hintText: 'What are you working on?',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12)
            ),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
          ),
          const Divider(),
          const SizedBox(height: 10),
          const Text('Est Pomodoros', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7F8C8D), fontSize: 13)),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${widget.task.completedSessions} / $_targetSessions', 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5DC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18, color: Color(0xFF2C3E50)),
                      onPressed: () {
                         if (_targetSessions > widget.task.completedSessions) {
                          setState(() => _targetSessions--);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18, color: Color(0xFF2C3E50)),
                      onPressed: () => setState(() => _targetSessions++),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 15),

          Row(
            children: [
               if (!_showNoteField)
                TextButton.icon(
                  onPressed: () => setState(() => _showNoteField = true),
                  icon: const Icon(Icons.notes, color: Color(0xFF95A5A6), size: 20),
                  label: const Text('Add Note', style: TextStyle(color: Color(0xFF95A5A6), fontSize: 14)),
                ),
               
               if (widget.task.title.isEmpty) ...[
                 const SizedBox(width: 8),
                 TextButton.icon(
                    onPressed: widget.onUseGoals,
                    icon: const Icon(Icons.flag_outlined, color: Color(0xFF6C63FF), size: 20),
                    label: const Text('Use Goals', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 14, fontWeight: FontWeight.w600)),
                 ),
               ]
            ],
          ),

          if (_showNoteField)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _noteController,
                maxLines: 3,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Add notes here...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: provider.cancelEditingTask,
                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.trim().isNotEmpty) {
                    final noteText = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();
                    provider.saveTask(widget.task.id, _titleController.text, _targetSessions, noteText);

                    if (widget.task.completedSessions == 0 && widget.task.title.isEmpty) {
                      provider.startAddingTask(); 
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                child: const Text('Save'),
              ),
            ],
          )
        ],
      ),
    );
  }
}