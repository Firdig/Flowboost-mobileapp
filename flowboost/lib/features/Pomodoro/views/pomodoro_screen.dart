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

class _PomodoroBody extends StatefulWidget {
  const _PomodoroBody();

  @override
  State<_PomodoroBody> createState() => _PomodoroBodyState();
}

class _PomodoroBodyState extends State<_PomodoroBody> {
  
  // ✅ FUNCTION: Menampilkan Popup Settings
  void _showSettingsDialog(BuildContext context) {
    final provider = Provider.of<PomodoroProvider>(context, listen: false);
    
    // Controllers untuk Input Menit
    final pomodoroController = TextEditingController(text: provider.pomodoroMinutes.toString());
    final shortBreakController = TextEditingController(text: provider.shortBreakMinutes.toString());
    final longBreakController = TextEditingController(text: provider.longBreakMinutes.toString());
    
    // Local State untuk Switch (Auto Start)
    bool autoStartBreak = provider.autoStartBreak;
    bool autoStartPomodoro = provider.autoStartPomodoro;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: kBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),

                    // --- SECTION: TIMER (Minutes) ---
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('TIMER (minutes)', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTimeSettingRow('Pomodoro', pomodoroController),
                    const SizedBox(height: 12),
                    _buildTimeSettingRow('Short Break', shortBreakController),
                    const SizedBox(height: 12),
                    _buildTimeSettingRow('Long Break', longBreakController),

                    const SizedBox(height: 24),

                    // --- SECTION: AUTO START ---
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('AUTO START', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 10),
                    
                    SwitchListTile(
                      title: const Text('Auto-start Breaks?', style: TextStyle(fontWeight: FontWeight.w500)),
                      value: autoStartBreak,
                      activeColor: kPomodoroPrimaryColor,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => autoStartBreak = val),
                    ),
                    SwitchListTile(
                      title: const Text('Auto-start Pomodoro?', style: TextStyle(fontWeight: FontWeight.w500)),
                      value: autoStartPomodoro,
                      activeColor: kPomodoroPrimaryColor,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => autoStartPomodoro = val),
                    ),

                    const SizedBox(height: 24),

                    // Tombol Save
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Validasi sederhana & Save ke Provider
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
                          backgroundColor: Colors.black87,
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

  // Helper Widget untuk Row Input Waktu
  Widget _buildTimeSettingRow(String label, TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
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
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

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
                        // ✅ GANTI: Langsung panggil _TimerDisplayUi (karena edit inline dihapus)
                        const _TimerDisplayUi(),
                        const SizedBox(height: 30),
                        
                        // Tombol Start/Pause & Skip
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Tombol Start/Pause
                              Expanded(
                                flex: 3,
                                child: RetroButtonPomodoro(
                                  text: provider.isRunning ? 'Pause' : 'Start',
                                  onPressed: provider.toggleTimer,
                                ),
                              ),
                              
                              // ✅ PERBAIKAN UI: Tombol Skip hanya muncul jika timer berjalan
                              if (provider.isRunning) ...[
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: provider.skipTimer,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      height: 54,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.grey.shade300, 
                                          width: 1.5
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            offset: const Offset(0, 4),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.skip_next_rounded, 
                                        size: 32, 
                                        color: Colors.black87
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    // ✅ UPDATE: Icon Settings Membuka Popup
                    Positioned(
                      top: -8,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.settings, size: 28, color: Colors.black87),
                        onPressed: () => _showSettingsDialog(context),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // --- Task Section Header & List ---
          // (Bagian ini tidak berubah dari kode sebelumnya)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              // Tambahkan tombol show all jika perlu
            ],
          ),
          const Divider(thickness: 1, color: Colors.black54),
          const SizedBox(height: 10),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.tasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final task = provider.tasks[index];
              // Pastikan class _TaskEditForm dan _TaskItem masih ada di file ini
              // (Kode mereka tidak berubah, hanya pemanggilan di sini)
              if (provider.editingTaskId == task.id) {
                 return _TaskEditForm(task: task); // Pastikan widget ini ada di bawah
              }
              return _TaskItem(task: task); // Pastikan widget ini ada di bawah
            },
          ),

          const SizedBox(height: 20),

          // --- Add Task Button ---
          if (provider.editingTaskId == null)
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
// (Tidak ada perubahan di sini, tapi pastikan ada di file)
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
          if (provider.currentMode != PomodoroMode.pomodoro)
             Text(
              provider.currentMode == PomodoroMode.shortBreak ? 'Short Break' : 'Long Break',
              style: TextStyle(fontSize: 18, color: kPomodoroPrimaryColor, fontWeight: FontWeight.bold),
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

  // Menyimpan data goals yang dipilih
  String? _selectedGoalTitle;
  String? _selectedSubTaskTitle;
  int? _pendingCycles;

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

  // Popup konfirmasi - SELALU muncul saat Start Pomodoro
  Future<String?> _showStartPomodoroDialog(int totalCycles, String goalTitle, String? subTaskTitle, bool hasRunningTask) async {
    // Simpan data sementara
    setState(() {
      _selectedGoalTitle = goalTitle;
      _selectedSubTaskTitle = subTaskTitle;
      _pendingCycles = totalCycles;
    });

    final result = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Start Pomodoro',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return Transform.translate(
          offset: Offset(0, -50 * (1 - curvedAnimation.value)),
          child: Opacity(
            opacity: curvedAnimation.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: hasRunningTask ? const Color(0xFFFFF3E0) : const Color(0xFFE3F2FD),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          hasRunningTask ? Icons.info_outline_rounded : Icons.play_circle_outline_rounded,
                          color: hasRunningTask ? const Color(0xFFF57C00) : const Color(0xFF1976D2),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        hasRunningTask ? 'Task Sedang Berjalan' : 'Start Pomodoro',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Message dengan info goals yang dipilih
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.flag_outlined, size: 16, color: Colors.black54),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        goalTitle,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (subTaskTitle != null) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const SizedBox(width: 24),
                                      const Icon(Icons.chevron_right, size: 14, color: Colors.black38),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          subTaskTitle,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.timer_outlined, size: 14, color: Colors.black54),
                                      const SizedBox(width: 6),
                                      Text(
                                        '$totalCycles siklus Pomodoro',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            hasRunningTask
                                ? 'Pilih tindakan untuk goals yang Anda pilih:'
                                : 'Anda akan memulai Pomodoro dengan goals di atas. Pilih tindakan:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Tombol Cancel
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, 'cancel'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tombol Replace Task (hanya muncul jika ada task berjalan)
                      if (hasRunningTask) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, 'replace'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF424242),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Replace Task',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Tombol Add Task / Start (label berbeda tergantung kondisi)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, 'add'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF424242),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            hasRunningTask ? 'Add Task' : 'Start Pomodoro',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    return result;
  }
// ✅ FIXED: Handler yang benar untuk replace task dan hide parent tasks
  void _handleStartPomodoroAction(String action, int totalCycles, String newTaskTitle, String? newNote) {
    final provider = Provider.of<PomodoroProvider>(context, listen: false);

    if (action == 'replace') {
      // ✅ Hapus task parent
      provider.deleteTask(widget.task.id);

      // ✅ Tambah task baru
      provider.addNewTask(newTaskTitle, totalCycles, newNote);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.refresh_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Task berhasil diganti', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('$newTaskTitle - $totalCycles siklus', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }

    } else if (action == 'add') {
      final hasRunningTask = _targetSessions > widget.task.completedSessions;

      if (hasRunningTask) {
        // Jika ada task berjalan, tambahkan ke target sessions yang ada
        final newTotal = _targetSessions + totalCycles;
        setState(() {
          _targetSessions = newTotal;
        });

        final noteText = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();
        provider.saveTask(widget.task.id, _titleController.text.trim(), _targetSessions, noteText);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.add_circle_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Task ditambahkan ke queue', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('Total: $newTotal siklus', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.blue,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } else {
        // ✅ Tidak ada task berjalan: hapus task lama dan buat task baru
        provider.deleteTask(widget.task.id);
        provider.addNewTask(newTaskTitle, totalCycles, newNote);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.play_circle_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Pomodoro dimulai', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('$newTaskTitle - $totalCycles siklus', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

// ============================================================================
// 2️⃣ HANDLER UNTUK MULTIPLE SUB-TASKS
// ✅ SELALU HAPUS PARENT untuk action 'add' dan 'replace'
// ============================================================================
  void _handleMultipleSubTasks(Map<int, int> selectedSubTaskCycles, String action) {
    final provider = Provider.of<PomodoroProvider>(context, listen: false);

    // Validasi: pastikan ada sub-tasks
    if (widget.task.subTasks == null || widget.task.subTasks!.isEmpty) {
      return;
    }

    // Konversi map ke list task info
    List<Map<String, dynamic>> selectedTasks = [];
    selectedSubTaskCycles.forEach((index, cycles) {
      if (cycles > 0 && index < widget.task.subTasks!.length) {
        final subTask = widget.task.subTasks![index];
        selectedTasks.add({
          'title': subTask.title,
          'cycles': cycles,
          'note': null,
        });
      }
    });

    // Validasi: pastikan ada yang dipilih
    if (selectedTasks.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih minimal 1 sub-task'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // ✅ LOGIC UTAMA: Hapus parent → Tambah sub-tasks
    if (action == 'replace' || action == 'add') {
      // Step 1: HAPUS task parent
      provider.deleteTask(widget.task.id);

      // Step 2: Tambahkan semua sub-tasks sebagai task terpisah
      for (var task in selectedTasks) {
        provider.addNewTask(
          task['title'] as String,
          task['cycles'] as int,
          task['note'] as String?,
        );
      }

      // Step 3: Tampilkan notifikasi
      if (mounted) {
        final isReplace = action == 'replace';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isReplace ? Icons.refresh_rounded : Icons.add_circle_rounded,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isReplace ? 'Task berhasil diganti' : 'Sub-task ditambahkan ke queue',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${selectedTasks.length} task baru ditambahkan',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: isReplace ? Colors.green : Colors.blue,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

// ============================================================================
// 3️⃣ METHOD HELPER
// ============================================================================
  void _showAllParentTasks() {
    final provider = Provider.of<PomodoroProvider>(context, listen: false);
    provider.showAllParentTasks();
  }

  Widget _buildShowAllTasksButton() {
    return Consumer<PomodoroProvider>(
      builder: (context, provider, _) {
        return IconButton(
          icon: const Icon(Icons.view_list),
          onPressed: () {
            provider.showAllParentTasks();
          },
          tooltip: 'Show all parent tasks',
        );
      },
    );
  }
// Fungsi untuk menampilkan popup Choose Goal (Level 1)
// Hanya menampilkan task GOALS (task dengan subTasks)
  Future<void> _showChooseGoalDialog() async {
    final provider = Provider.of<PomodoroProvider>(context, listen: false);
    String? selectedGoalId;

    // ✅ PERBAIKAN: Gunakan allTasks untuk akses semua task termasuk yang hidden
    final goalTasks = provider.allTasks.where((t) {
      return t.subTasks != null && t.subTasks!.isNotEmpty;
    }).toList();

    // Jika tidak ada goal yang tersedia
    if (goalTasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada goal yang tersedia.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

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

                // List HANYA task goals (yang punya subTasks)
                ...goalTasks.map((task) => Container(
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
                    subtitle: Text(
                      '${task.subTasks?.length ?? 0} subtasks',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
                )).toList(),

                const SizedBox(height: 20),

                // Tombol Next
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedGoalId == null ? null : () {
                      Navigator.pop(context);
                      final selectedTask = goalTasks.firstWhere((t) => t.id == selectedGoalId);
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
      // Jika tidak ada subtask, langsung tampilkan dialog konfirmasi
      final hasRunningTask = _targetSessions > widget.task.completedSessions;
      final result = await _showStartPomodoroDialog(
          selectedGoal.targetSessions,
          selectedGoal.title,
          null,
          hasRunningTask
      );

      // Handle hasil pilihan
      if (result == null || result == 'cancel') {
        return;
      }

      // Handle Replace atau Add - Update task yang dipilih
      _handleStartPomodoroAction(
          result,
          selectedGoal.targetSessions,
          selectedGoal.title,
          selectedGoal.note
      );
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
                  onPressed: () {
                    Navigator.pop(context);
                    _showChooseGoalDialog(); // Kembali ke Level 1
                  },
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
    // State untuk menyimpan cycles tiap sub-task (maksimal 3 sub-task)
    Map<int, int> subTaskCycles = {
      0: 0, // Pengenalan & Konsep Dasar
      1: 0, // Implementasi & Praktik
      2: 0, // Review & Penguatan
    };

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
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Selected Goal & SubTask
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

                        // 3 Sub-Task Cards
                        ...List.generate(3, (index) {
                          final subTaskNumber = index + 1;
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
                                Row(
                                  children: [
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
                                            subTaskCycles[index] = subTaskCycles[index]! + 1;
                                          });
                                        },
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
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
                                          if (subTaskCycles[index]! > 0) {
                                            setDialogState(() {
                                              subTaskCycles[index] = subTaskCycles[index]! - 1;
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

                // Bottom Buttons
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
                            Navigator.pop(context);              // Tutup Level 3
                            _showChooseTaskDialog(mainTask);     // Buka Level 2
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
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            // ✅ Hitung total cycles
                            final totalCycles = subTaskCycles.values.reduce((a, b) => a + b);

                            if (totalCycles <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Harap pilih minimal 1 siklus Pomodoro'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // ✅ Cek apakah ada task yang sedang berjalan
                            final hasRunningTask = _targetSessions > widget.task.completedSessions;

                            Navigator.pop(context);

                            // ✅ Tampilkan dialog konfirmasi
                            final result = await _showStartPomodoroDialog(
                                totalCycles,
                                mainTask.title,
                                subTask.title,
                                hasRunningTask
                            );

                            if (result == null || result == 'cancel') {
                              return;
                            }

                            // ✅ Handle berdasarkan hasil pilihan user
                            _handleMultipleSubTasksWithGoalData(
                              mainTask,
                              subTask,
                              subTaskCycles,
                              result,
                            );
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
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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

// ============================================================================
// 2️⃣ METHOD: Handle Multiple Sub-Tasks dengan Goal Data (NEW)
// ============================================================================
  void _handleMultipleSubTasksWithGoalData(
      PomodoroTask mainTask,
      SubTask selectedSubTask,
      Map<int, int> selectedSubTaskCycles,
      String action
      ) {
    final provider = Provider.of<PomodoroProvider>(context, listen: false);

    // Nama sub-task yang FIXED (sesuai gambar)
    final fixedSubTaskNames = [
      'Pengenalan & Konsep Dasar',
      'Implementasi & Praktik',
      'Review & Penguatan',
    ];

    // ✅ Konversi map ke list task info (HANYA yang memiliki cycles > 0)
    List<Map<String, dynamic>> selectedTasks = [];
    selectedSubTaskCycles.forEach((index, cycles) {
      if (cycles > 0 && index < fixedSubTaskNames.length) {
        // ✅ PERBAIKAN FORMAT:
        // Title: "Pengenalan & Konsep Dasar" (hanya nama sub-task)
        // Note: "From: Task 1 : Introduction to JavaScript" (lengkap dengan Task number)

        selectedTasks.add({
          'title': fixedSubTaskNames[index],  // ✅ Hanya nama sub-task
          'cycles': cycles,
          'note': 'From: ${selectedSubTask.title}',  // ✅ Format: "From: Task 1 : Introduction to JavaScript"
        });
      }
    });

    // ✅ Validasi: pastikan ada yang dipilih
    if (selectedTasks.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih minimal 1 sub-task'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // ✅ LOGIC UTAMA: Hapus parent → Tambah sub-tasks
    if (action == 'replace' || action == 'add') {
      // Step 1: HAPUS task parent
      provider.deleteTask(widget.task.id);

      // Step 2: Tambahkan semua sub-tasks sebagai task terpisah
      for (var task in selectedTasks) {
        provider.addNewTask(
          task['title'] as String,
          task['cycles'] as int,
          task['note'] as String?,
        );
      }

      // Step 3: Tampilkan notifikasi
      if (mounted) {
        final isReplace = action == 'replace';
        final taskCount = selectedTasks.length;
        final totalCycles = selectedTasks.fold<int>(0, (sum, task) => sum + (task['cycles'] as int));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isReplace ? Icons.refresh_rounded : Icons.add_circle_rounded,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isReplace ? 'Task berhasil diganti' : 'Sub-task ditambahkan',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '$taskCount task baru • $totalCycles total siklus',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: isReplace ? Colors.green : Colors.blue,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PomodoroProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Colors.black, width: 5.0),
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
          Row(
            children: [
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
                    if (_targetSessions > widget.task.completedSessions) {
                      setState(() => _targetSessions--);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          if (!_showNoteField)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showNoteField = true;
                });
              },
              icon: const Icon(Icons.add, color: Colors.black54, size: 20),
              label: const Text('Add Note', style: TextStyle(color: Colors.black54, fontSize: 14)),
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

          // ✅ SEKARANG (selalu tampil saat editing)
          if (widget.task.title.isEmpty)
            TextButton.icon(
              onPressed: _showChooseGoalDialog,
              icon: const Icon(Icons.add, color: Colors.black54, size: 20),
              label: const Text('Use Goals', style: TextStyle(color: Colors.black54, fontSize: 14)),
            ),
            
          const SizedBox(height: 20),
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

                    if (widget.task.completedSessions == 0 && widget.task.title.isEmpty) {
                      provider.startAddingTask();
                    }
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