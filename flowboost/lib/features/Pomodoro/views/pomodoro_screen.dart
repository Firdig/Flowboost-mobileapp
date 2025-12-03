import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/constants/constants.dart';
import '../provider/pomodoro_provider.dart';
import '../models/pomodoro_task_model.dart';
import '../widgets/pomodoro_widget.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PomodoroProvider(),
      child: const Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: _PomodoroAppBar()
        ),
        body: _PomodoroBody(),
      ),
    );
  }
}

class _PomodoroAppBar extends StatelessWidget {
  const _PomodoroAppBar();
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("POMODORO", style: kHeaderStyle),
      backgroundColor: kAppBarColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: kTextColor),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}

class _PomodoroBody extends StatelessWidget {
  const _PomodoroBody();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PomodoroProvider>(context);
    final selectedTask = provider.selectedTask;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // --- Timer Card Section ---
          RetroContainer(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                // Judul Task yang Aktif
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Text(
                    selectedTask?.title ?? 'Pilih Task',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Mode Toggles
                Row(
                  children: [
                    Expanded(
                      child: ModeButton(
                        text: 'Pomodoro',
                        isSelected: provider.currentMode == PomodoroMode.pomodoro,
                        onTap: () => provider.setMode(PomodoroMode.pomodoro),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ModeButton(
                        text: 'Short Break',
                        isSelected: provider.currentMode == PomodoroMode.shortBreak,
                        onTap: () => provider.setMode(PomodoroMode.shortBreak),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ModeButton(
                        text: 'Long Break',
                        isSelected: provider.currentMode == PomodoroMode.longBreak,
                        onTap: () => provider.setMode(PomodoroMode.longBreak),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Timer Section dengan Settings Icon
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    // Timer Display
                    Column(
                      children: [
                        provider.isEditingTimerUi
                            ? const _TimerEditUi()
                            : const _TimerDisplayUi(),
                        const SizedBox(height: 30),
                        // Tombol Start/Pause/Save
                        RetroButtonPomodoro(
                          text: provider.isEditingTimerUi ? 'Save' : (provider.isRunning ? 'Pause' : 'Start'),
                          width: 150,
                          onPressed: () {
                            if (provider.isEditingTimerUi) {
                              provider.saveTimerSetting();
                            } else {
                              provider.toggleTimer();
                            }
                          },
                        ),
                      ],
                    ),
                    // Icon Settings
                    Positioned(
                      top: -8,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.settings, size: 28, color: Colors.black87),
                        onPressed: provider.toggleEditTimerUi,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // --- Task Section Header ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
            ],
          ),
          const Divider(thickness: 1, color: Colors.black54),
          const SizedBox(height: 10),

          // --- Task List ---
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.tasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final task = provider.tasks[index];
              if (provider.editingTaskId == task.id) {
                return _TaskEditForm(task: task);
              }
              return _TaskItem(task: task);
            },
          ),

          const SizedBox(height: 20),

          // --- Add Task Button ---
          InkWell(
            onTap: provider.startAddingTask,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade500, style: BorderStyle.solid, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('Add Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// --- Timer Display UI ---
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

    return Center(
      child: Column(
        children: [
          Text(
            '$minutes : $seconds',
            style: kTimerTextStyle,
          ),
          const SizedBox(height: 10),
          if (provider.currentMode == PomodoroMode.pomodoro)
            Text(
              '#$currentSession',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
            ),
        ],
      ),
    );
  }
}

// --- Timer Edit UI ---
class _TimerEditUi extends StatelessWidget {
  const _TimerEditUi();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PomodoroProvider>(context);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(provider.currentDuration.inMinutes.remainder(60));
    final seconds = twoDigits(provider.currentDuration.inSeconds.remainder(60));

    return Center(
      child: Column(
        children: [
          // Tombol Panah Atas
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black87, width: 1.5),
                ),
                child: IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up, size: 24, color: Colors.black87),
                  onPressed: () => provider.adjustTime(1, 0),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 80),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black87, width: 1.5),
                ),
                child: IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up, size: 24, color: Colors.black87),
                  onPressed: () => provider.adjustTime(0, 10),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tampilan Waktu
          Text(
            '$minutes : $seconds',
            style: kTimerTextStyle,
          ),
          const SizedBox(height: 16),
          // Tombol Panah Bawah
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black87, width: 1.5),
                ),
                child: IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down, size: 24, color: Colors.black87),
                  onPressed: () => provider.adjustTime(-1, 0),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 80),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black87, width: 1.5),
                ),
                child: IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down, size: 24, color: Colors.black87),
                  onPressed: () => provider.adjustTime(0, -10),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Text Instruksi
          Text(
            'Klik angka atau tombol +/- untuk mengatur waktu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Task Item ---
class _TaskItem extends StatelessWidget {
  final PomodoroTask task;
  const _TaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PomodoroProvider>(context, listen: false);
    final isSelected = provider.selectedTask?.id == task.id;

    return GestureDetector(
      onTap: () => provider.selectTask(task.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : kTaskInactiveBgColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? const Border(
            left: BorderSide(
              color: Colors.black,
              width: 5.0,
            ),
          )
              : null,
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ] : [],
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () => provider.toggleTaskDone(task.id),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isDone ? kPomodoroPrimaryColor : kTaskNotDoneColor,
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
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
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  // Tampilkan note di bawah nama task
                  if (task.note != null && task.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        task.note!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              '${task.completedSessions}/${task.targetSessions}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {
                  provider.startEditingTask(task.id);
                } else if (value == 'delete') {
                  provider.deleteTask(task.id);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Task Edit Form ---
class _TaskEditForm extends StatefulWidget {
  final PomodoroTask task;
  const _TaskEditForm({required this.task});

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

  // Fungsi untuk menampilkan popup Choose Goal (Level 1)
  Future<void> _showChooseGoalDialog() async {
    final provider = Provider.of<PomodoroProvider>(context, listen: false);
    String? selectedGoalId;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: kBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Choose Goal',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // List task dengan checkbox
                ...provider.tasks
                    .where((t) => t.id != widget.task.id)
                    .map((task) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Icon(
                      Icons.check,
                      color: selectedGoalId == task.id ? Colors.black : Colors.transparent,
                    ),
                    onTap: () {
                      setDialogState(() {
                        selectedGoalId = task.id;
                      });
                    },
                  ),
                ))
                    .toList(),

                const SizedBox(height: 20),

                // Tombol Next
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedGoalId == null ? null : () {
                      Navigator.pop(context);
                      // Tampilkan popup level 2 (Choose Task)
                      final selectedTask = provider.tasks.firstWhere((t) => t.id == selectedGoalId);
                      _showChooseTaskDialog(selectedTask);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPomodoroDarkButtonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      disabledBackgroundColor: Colors.grey.shade400,
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Popup Level 2: Choose Task (dari sub-tasks)
  Future<void> _showChooseTaskDialog(PomodoroTask selectedGoal) async {
    if (selectedGoal.subTasks == null || selectedGoal.subTasks!.isEmpty) {
      // Jika tidak ada subtask, langsung set target
      setState(() {
        _targetSessions = selectedGoal.targetSessions;
      });
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: kBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Choose Task',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Header dengan nama goal yang dipilih
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedGoal.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Icon(Icons.check),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // List sub-tasks dengan progress
              ...selectedGoal.subTasks!.map((subTask) {
                // Hitung total completed dari sub-sub-tasks
                final progress = '${subTask.completedSessions}/${subTask.targetSessions} done';

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.chevron_right, size: 20),
                    title: Text(
                      subTask.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    trailing: Text(
                      progress,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      // Tampilkan popup level 3
                      _showSubTaskDetailDialog(selectedGoal, subTask);
                    },
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),

              // Tombol Back
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPomodoroDarkButtonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Popup Level 3: Sub-Task Detail dengan pengaturan siklus
  Future<void> _showSubTaskDetailDialog(PomodoroTask mainTask, SubTask subTask) async {
    List<int> subTaskCycles = List.generate(3, (index) => 0);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: const Color(0xFFF5F1E8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Content dengan scroll
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Choose Task',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 24),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Task yang dipilih dengan checkmark
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mainTask.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      subTask.title,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.check, size: 20),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 3 Sub-task items
                        ...List.generate(3, (index) {
                          final subTaskNumber = index + 1;
                          // Variasi nama untuk setiap sub-task
                          final subTaskNames = [
                            'Pengenalan & Konsep Dasar',
                            'Implementasi & Praktik',
                            'Review & Penguatan',
                          ];
                          final taskName = subTaskNames[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Judul sub-task
                                Text(
                                  'Sub - task $subTaskNumber : $taskName',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Act / Siklus Pomodoro',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Row untuk angka dan tombol
                                Row(
                                  children: [
                                    // Display angka siklus (hanya 1 kolom) - LEBIH LEBAR
                                    Container(
                                      width: 120,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8E8E8),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${subTaskCycles[index]}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const Spacer(),

                                    // Tombol Arrow Up
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.keyboard_arrow_up,
                                          size: 24,
                                        ),
                                        onPressed: () {
                                          setDialogState(() {
                                            subTaskCycles[index]++;
                                          });
                                        },
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    // Tombol Arrow Down
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 24,
                                        ),
                                        onPressed: () {
                                          if (subTaskCycles[index] > 0) {
                                            setDialogState(() {
                                              subTaskCycles[index]--;
                                            });
                                          }
                                        },
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

                // Tombol di bawah (tidak ikut scroll)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F1E8),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showChooseTaskDialog(mainTask);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3D3D3D),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final totalCycles = subTaskCycles.reduce((a, b) => a + b);

                            setState(() {
                              _targetSessions = totalCycles;
                            });

                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3D3D3D),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Start Pomodoro',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PomodoroProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(
            color: Colors.black,
            width: 5.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input Title
          TextField(
            controller: _titleController,
            autofocus: widget.task.title.isEmpty,
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.edit, color: Colors.black),
                hintText: 'Nama Tugas (misal: Belajar Flutter)',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12)
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text('Act / Siklus Pomodoro', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          // Kontrol Target Sesi
          Row(
            children: [
              // Sesi Selesai (TIDAK BISA DIUBAH - tanpa tombol)
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8)
                ),
                child: Center(
                  child: Text(
                      '${widget.task.completedSessions}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('/', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              // Target Sesi (BISA DIUBAH)
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8)
                ),
                child: Center(
                  child: Text(
                      '$_targetSessions',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)
                  ),
                ),
              ),
              const Spacer(),
              // Tombol Arrow Up untuk TARGET
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8)
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_drop_up, size: 24),
                  onPressed: () => setState(() => _targetSessions++),
                ),
              ),
              const SizedBox(width: 8),
              // Tombol Arrow Down untuk TARGET
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8)
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_drop_down, size: 24),
                  onPressed: () {
                    // Target tidak boleh kurang dari sesi yang sudah selesai
                    if (_targetSessions > widget.task.completedSessions) {
                      setState(() => _targetSessions--);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Tombol "+ Add Note"
          if (!_showNoteField)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showNoteField = true;
                });
              },
              icon: const Icon(Icons.add, color: Colors.black54, size: 20),
              label: const Text(
                'Add Note',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _noteController,
                maxLines: 3,
                minLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Add Some Note',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),

          const SizedBox(height: 10),

          // Tombol "+ Use Goals"
          TextButton.icon(
            onPressed: _showChooseGoalDialog,
            icon: const Icon(Icons.add, color: Colors.black54, size: 20),
            label: const Text(
              'Use Goals',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),

          const SizedBox(height: 20),
          // Tombol Cancel & Save
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: provider.cancelEditingTask,
                style: TextButton.styleFrom(
                    backgroundColor: kPomodoroDarkButtonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  if (_titleController.text.trim().isNotEmpty) {
                    final noteText = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();
                    provider.saveTask(widget.task.id, _titleController.text, _targetSessions, noteText);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nama tugas tidak boleh kosong'))
                    );
                  }
                },
                style: TextButton.styleFrom(
                    backgroundColor: kPomodoroDarkButtonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          )
        ],
      ),
    );
  }
}