import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart'; // Import Package
import 'package:intl/intl.dart'; // Untuk format tanggal

import '../../../common/widgets/custom_widgets.dart';
import '../../../services/auth_service.dart';
import '../../Pomodoro/provider/pomodoro_provider.dart';
import '../../goals/services/goal_service.dart';
import '../../goals/models/goal_model.dart';
import '../../Pomodoro/models/pomodoro_task_model.dart';
import '../../authentication/login/views/login.dart';
// Import Service Break yang baru dibuat
import '../../break_feature/services/break_services.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final AuthService _authService = AuthService();
  final GoalService _goalService = GoalService();
  final BreakService _breakService = BreakService(); // Inisialisasi Service

  // --- Helpers untuk Heatmap ---
  
  // Mengubah List log menjadi Map untuk Heatmap {DateTime: Value}
  Map<DateTime, int> _prepareHeatMapDataset(List<BreakLogModel> logs) {
    Map<DateTime, int> dataset = {};
    for (var log in logs) {
      // Normalisasi tanggal (hapus jam/menit/detik) agar warnanya akurat per hari
      DateTime normalizedDate = DateTime(log.date.year, log.date.month, log.date.day);
      
      // Value bisa berupa frekuensi (jumlah sesi) atau durasi. 
      // Di sini kita pakai jumlah sesi per hari.
      if (dataset.containsKey(normalizedDate)) {
        dataset[normalizedDate] = dataset[normalizedDate]! + 1;
      } else {
        dataset[normalizedDate] = 1;
      }
    }
    return dataset;
  }

  // Menghitung Current Streak (Hari berturut-turut sampai hari ini/kemarin)
  int _calculateStreak(List<BreakLogModel> logs) {
    if (logs.isEmpty) return 0;

    // Ambil tanggal unik saja
    Set<String> uniqueDates = logs.map((e) => DateFormat('yyyy-MM-dd').format(e.date)).toSet();
    List<DateTime> sortedDates = uniqueDates.map((e) => DateTime.parse(e)).toList();
    
    // Urutkan dari yang paling baru
    sortedDates.sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime checkDate = DateTime.now();
    // Normalisasi hari ini
    DateTime today = DateTime(checkDate.year, checkDate.month, checkDate.day);
    
    // Cek apakah hari ini ada activity?
    if (sortedDates.contains(today)) {
      streak++;
      checkDate = today.subtract(const Duration(days: 1));
    } else {
      // Jika hari ini belum, cek apakah kemarin ada? (Streak belum putus kalau kemarin ada)
      DateTime yesterday = today.subtract(const Duration(days: 1));
      if (sortedDates.contains(yesterday)) {
        checkDate = yesterday;
      } else {
        return 0; // Tidak ada hari ini atau kemarin, streak putus.
      }
    }

    // Loop mundur ke belakang
    while (true) {
      if (sortedDates.contains(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        // Cek double count untuk hari pertama loop (karena logic di atas sudah nambah 1)
        // Kita sesuaikan logic simple:
        // Sebenarnya loop sederhana pada sortedDates lebih mudah:
        break;
      }
    }
    
    // Logic alternatif yang lebih robust untuk menghitung consecutive days dari sorted list
    int realStreak = 0;
    DateTime current = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    
    // Jika user belum meditasi hari ini, kita mulai cek dari kemarin agar streak tidak 0
    if (!sortedDates.contains(current)) {
      current = current.subtract(const Duration(days: 1));
    }

    for (var date in sortedDates) {
      if (date.year == current.year && date.month == current.month && date.day == current.day) {
        realStreak++;
        current = current.subtract(const Duration(days: 1));
      } else {
        // Jika tanggal tidak sama dengan (current - 1 hari), berarti putus
        break;
      }
    }

    return realStreak;
  }

  // ... (Fungsi _showEditProfileDialog dan _handleLogout sama seperti sebelumnya) ...
  void _showEditProfileDialog() {
    // Gunakan kode dialog yang sama seperti respons sebelumnya
    final TextEditingController nameController = TextEditingController(text: user?.displayName ?? '');
    final TextEditingController photoUrlController = TextEditingController(text: user?.photoURL ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama')),
              TextField(controller: photoUrlController, decoration: const InputDecoration(labelText: 'URL Foto')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(onPressed: () async {
                if (user != null) {
                  if (nameController.text.isNotEmpty) await user!.updateDisplayName(nameController.text.trim());
                  if (photoUrlController.text.isNotEmpty) await user!.updatePhotoURL(photoUrlController.text.trim());
                  await user!.reload();
                  setState(() {});
                  if (context.mounted) Navigator.pop(context);
                }
            }, child: const Text('Simpan')),
          ],
        );
      },
    );
  }

  void _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const FlowboostLoginScreen()), (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroProvider>(
      builder: (context, pomodoroProvider, child) {
        final int pomodorosUsed = pomodoroProvider.tasks.fold(0, (sum, item) => sum + item.completedSessions);

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Flowboost', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  const Text('PROFILE', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400)),
                  const SizedBox(height: 20),
                  
                  // --- INFO USER ---
                  _buildUserInfoSection(),
                  
                  const SizedBox(height: 30),
                  
                  // --- BAGIAN STATISTIK UTAMA ---
                  const Text('Activity Statistics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 15),
                  
                  // Menggunakan StreamBuilder Ganda (Goals & Breaks)
                  StreamBuilder<List<GoalModel>>(
                    stream: _goalService.getGoalsStream(),
                    builder: (context, snapshotGoals) {
                      return StreamBuilder<List<BreakLogModel>>(
                        stream: _breakService.getBreakLogsStream(),
                        builder: (context, snapshotBreaks) {
                          
                          // DATA CALCULATION
                          String goalCountStr = '0';
                          String tasksCompletedStr = '0';
                          String subTasksCompletedStr = '0';
                          int meditationStreak = 0;
                          Map<DateTime, int> heatMapData = {};

                          if (snapshotGoals.hasData) {
                            final goals = snapshotGoals.data!;
                            goalCountStr = goals.where((g) => g.isFinished).length.toString();
                            int t = 0; int s = 0;
                            for (var g in goals) {
                              t += g.tasks.where((x) => x.isCompleted).length;
                              for (var task in g.tasks) {
                                s += task.subtasks.where((x) => x.isCompleted).length;
                              }
                            }
                            tasksCompletedStr = t.toString();
                            subTasksCompletedStr = s.toString();
                          }

                          if (snapshotBreaks.hasData) {
                            final breaks = snapshotBreaks.data!;
                            meditationStreak = _calculateStreak(breaks);
                            heatMapData = _prepareHeatMapDataset(breaks);
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Grid Statistik Angka
                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: 1.5,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                children: [
                                  _buildMiniStatCard('Goals Achieved', goalCountStr, Icons.golf_course, const Color(0xFFE0BBE4)),
                                  _buildMiniStatCard('Pomodoros', pomodorosUsed.toString(), Icons.timer, const Color(0xFFF4A6A6)),
                                  _buildMiniStatCard('Tasks Done', tasksCompletedStr, Icons.check_circle, const Color(0xFFD4A5A5)),
                                  _buildMiniStatCard('Streak Days', '$meditationStreak', Icons.local_fire_department, Colors.orangeAccent),
                                ],
                              ),
                              
                              const SizedBox(height: 30),
                              
                              // --- WELLNESS CALENDAR (Heatmap) ---
                              const Text('Wellness Consistency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const Text('Track your meditation & break habits.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 15),
                              
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: HeatMapCalendar(
                                  defaultColor: Colors.grey[200],
                                  flexible: true,
                                  colorMode: ColorMode.color,
                                  datasets: heatMapData,
                                  colorsets: const {
                                    1: Color(0xFFD4A5A5), // 1x activity (Soft Red)
                                    3: Color(0xFFE0BBE4), // 3x activity (Soft Purple)
                                    5: Colors.orange,     // 5x activity (High intensity)
                                  },
                                  onClick: (value) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Activity on: ${DateFormat('dd MMM yyyy').format(value)}')),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 80),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfoSection() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[300],
          backgroundImage: (user?.photoURL != null && user!.photoURL!.isNotEmpty)
              ? NetworkImage(user!.photoURL!)
              : null,
          child: (user?.photoURL == null) ? const Icon(Icons.person, color: Colors.white) : null,
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(user?.displayName ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 16, color: Colors.grey),
                    onPressed: _showEditProfileDialog,
                  )
                ],
              ),
              Text(user?.email ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
        IconButton(onPressed: _handleLogout, icon: const Icon(Icons.logout, color: Colors.orange)),
      ],
    );
  }

  Widget _buildMiniStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}