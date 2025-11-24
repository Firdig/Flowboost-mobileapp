import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:intl/intl.dart'; // Tidak diperlukan lagi di sini

import '../../../common/constants/constants.dart';
// KEMBALI MENGGUNAKAN PROVIDER:
import '../provider/pomodoro_provider.dart';
import '../models/pomodoro_task_model.dart';
import '../widgets/pomodoro_widget.dart'; // Pastikan nama file widget Anda benar (pomodoro_widgets.dart atau pomodoro_widget.dart)

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // KEMBALI MENGGUNAKAN PROVIDER DI SINI:
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
      backgroundColor: kAppBarColor, // Menggunakan konstanta yang sudah ada
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
    // MENGGUNAKAN PROVIDER:
    final provider = Provider.of<PomodoroProvider>(context);
    final selectedTask = provider.selectedTask;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // --- Timer Card Section (Gambar 1 & 5) ---
          RetroContainer(
            child: Column(
              children: [
                // Judul Task yang Aktif
                Text(
                  selectedTask?.title ?? 'Pilih Task',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Mode Toggles
                // GUNAKAN EXPANDED UNTUK MENCEGAH OVERFLOW
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

                // Timer Display & Settings Icon
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    // Tampilan Timer atau Edit Timer UI (Gambar 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: provider.isEditingTimerUi
                          ? const _TimerEditUi()
                          : const _TimerDisplayUi(),
                    ),
                    // Icon Settings (Gear)
                    IconButton(
                      icon: const Icon(Icons.settings, size: 28),
                      onPressed: provider.toggleEditTimerUi,
                    ),
                  ],
                ),

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
                const SizedBox(height: 20),
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

          // --- Task List (Gambar 1, 2, 4) ---
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.tasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final task = provider.tasks[index];
              // Cek apakah task ini sedang diedit (Gambar 2)
              if (provider.editingTaskId == task.id) {
                return _TaskEditForm(task: task);
              }
              // Tampilan list biasa (Gambar 1, 4)
              return _TaskItem(task: task);
            },
          ),

          const SizedBox(height: 20),

          // --- Add Task Button (Gambar 3) ---
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

// --- Sub-Widgets untuk Memecah Kompleksitas ---

// Tampilan Timer Normal (e.g., 20:30)
class _TimerDisplayUi extends StatelessWidget {
  const _TimerDisplayUi();

  @override
  Widget build(BuildContext context) {
    // MENGGUNAKAN PROVIDER:
    final provider = Provider.of<PomodoroProvider>(context);
    // Format durasi menjadi MM:SS
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(provider.currentDuration.inMinutes.remainder(60));
    final seconds = twoDigits(provider.currentDuration.inSeconds.remainder(60));

    // Hitung sesi saat ini untuk task yang dipilih
    int currentSession = 1;
    if (provider.selectedTask != null) {
      currentSession = provider.selectedTask!.completedSessions + 1;
    }

    return Center(
      child: Column(
        children: [
          Text(
            '$minutes : $seconds',
            // GUNAKAN STYLE BARU
            style: kTimerTextStyle,
          ),
          const SizedBox(height: 10),
          // Menampilkan sesi ke berapa jika dalam mode pomodoro
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

// Tampilan Edit Timer (Gambar 5 - dengan panah atas bawah)
class _TimerEditUi extends StatelessWidget {
  const _TimerEditUi();

  @override
  Widget build(BuildContext context) {
    // MENGGUNAKAN PROVIDER:
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
              IconButton(icon: const Icon(Icons.keyboard_arrow_up, size: 30), onPressed: () => provider.adjustTime(1, 0)),
              const SizedBox(width: 30),
              IconButton(icon: const Icon(Icons.keyboard_arrow_up, size: 30), onPressed: () => provider.adjustTime(0, 10)),
            ],
          ),
          // Tampilan Waktu
          Text(
            '$minutes : $seconds',
            // GUNAKAN STYLE BARU
            style: kTimerTextStyle,
          ),
          // Tombol Panah Bawah
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.keyboard_arrow_down, size: 30), onPressed: () => provider.adjustTime(-1, 0)),
              const SizedBox(width: 30),
              IconButton(icon: const Icon(Icons.keyboard_arrow_down, size: 30), onPressed: () => provider.adjustTime(0, -10)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Klik angka atau tombol +/- untuk mengatur waktu',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}


// Item Task Normal dalam List (Gambar 1 & 4)
class _TaskItem extends StatelessWidget {
  final PomodoroTask task;
  const _TaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    // MENGGUNAKAN PROVIDER:
    final provider = Provider.of<PomodoroProvider>(context, listen: false);
    final isSelected = provider.selectedTask?.id == task.id;

    return GestureDetector(
      onTap: () => provider.selectTask(task.id),
      child: RetroContainer(
        // GUNAKAN KONSTANTA BARU: Background putih jika dipilih, kTaskInactiveBgColor jika tidak
        backgroundColor: isSelected ? Colors.white : kTaskInactiveBgColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        borderRadius: 16,
        hasShadow: isSelected, // Shadow hanya jika dipilih
        child: Row(
          children: [
            // Custom Checkbox
            InkWell(
              onTap: () => provider.toggleTaskDone(task.id),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // GUNAKAN KONSTANTA BARU: Warna Checkbox
                  color: task.isDone ? kPomodoroPrimaryColor : kTaskNotDoneColor,
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            Text(
              '${task.completedSessions}/${task.targetSessions}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            // Popup Menu untuk Edit/Delete (Gambar 2 - menu kecil)
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


// Form Edit Task Inline (Gambar 2 & 3)
class _TaskEditForm extends StatefulWidget {
  final PomodoroTask task;
  const _TaskEditForm({required this.task});

  @override
  State<_TaskEditForm> createState() => _TaskEditFormState();
}

class _TaskEditFormState extends State<_TaskEditForm> {
  late TextEditingController _titleController;
  late int _targetSessions;
  String? _currentNote; // State lokal untuk menyimpan note sementara saat mengedit

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _targetSessions = widget.task.targetSessions;
    // Inisialisasi note dari data task yang ada
    _currentNote = widget.task.note;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // Fungsi untuk menampilkan Dialog Input Note
  Future<void> _showNoteDialog() async {
    final noteController = TextEditingController(text: _currentNote);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add / Edit Note', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: noteController,
          maxLines: 5, // Membuat area teks lebih besar
          minLines: 3,
          decoration: InputDecoration(
            hintText: 'Masukkan catatan untuk tugas ini...',
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Tutup dialog tanpa menyimpan
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // Simpan note ke state lokal _currentNote
              setState(() {
                _currentNote = noteController.text;
              });
              Navigator.pop(context); // Tutup dialog
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A4A4A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // MENGGUNAKAN PROVIDER:
    final provider = Provider.of<PomodoroProvider>(context, listen: false);

    return RetroContainer(
        backgroundColor: Colors.white,
        borderRadius: 12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Title dengan Icon Pensil
            TextField(
              controller: _titleController,
              // Autofocus agar keyboard langsung muncul saat Add Task
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
            // Kontrol Target Sesi (+/-)
            Row(
              children: [
                // ... (Bagian tampilan sesi selesai tetap sama) ...
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
                  child: Text('${widget.task.completedSessions}', style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 10),
                const Text('/', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
                  child: Text('$_targetSessions', style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 20),
                // Tombol Up/Down untuk target
                Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_drop_up),
                    onPressed: () => setState(() => _targetSessions++),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: () {
                      if (_targetSessions > 1) setState(() => _targetSessions--);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // --- Tombol Add/Edit Note (Diimplementasikan) ---
            TextButton.icon(
              onPressed: _showNoteDialog, // Memanggil dialog saat ditekan
              icon: Icon(
                // Ubah ikon jika sudah ada note
                  _currentNote != null && _currentNote!.isNotEmpty ? Icons.note : Icons.add,
                  color: Colors.black54
              ),
              label: Text(
                // Ubah teks jika sudah ada note
                _currentNote != null && _currentNote!.isNotEmpty ? 'Edit Note' : 'Add Note',
                style: const TextStyle(color: Colors.black54, decoration: TextDecoration.underline),
              ),
            ),
            // Opsional: Menampilkan preview note kecil di bawah tombol
            if (_currentNote != null && _currentNote!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                child: Text(
                  _currentNote!,
                  style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                    // GUNAKAN KONSTANTA BARU: kPomodoroDarkButtonColor
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
                    // Validasi sederhana: Judul tidak boleh kosong
                    if (_titleController.text.trim().isNotEmpty) {
                      // Memanggil provider untuk menyimpan data statis, termasuk _currentNote
                      provider.saveTask(widget.task.id, _titleController.text, _targetSessions, _currentNote);
                    } else {
                      // Opsional: Tampilkan snackbar jika judul kosong
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama tugas tidak boleh kosong')));
                    }
                  },
                  style: TextButton.styleFrom(
                    // GUNAKAN KONSTANTA BARU: kPomodoroDarkButtonColor
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
        )
    );
  }
}