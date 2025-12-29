import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart'; 
import 'package:intl/intl.dart'; 

import '../../../common/widgets/custom_widgets.dart';
import '../../../services/auth_service.dart';
import '../../Pomodoro/provider/pomodoro_provider.dart';
import '../../goals/services/goal_service.dart';
import '../../goals/models/goal_model.dart';
import '../../Pomodoro/models/pomodoro_task_model.dart';
import '../../authentication/login/views/login.dart';
import '../../break_feature/services/break_services.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  final AuthService _authService = AuthService();
  final GoalService _goalService = GoalService();
  final BreakService _breakService = BreakService();

  // --- Animation Controller ---
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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // --- Logic Helpers (TIDAK DIUBAH) ---
  Map<DateTime, int> _prepareHeatMapDataset(List<BreakLogModel> logs) {
    Map<DateTime, int> dataset = {};
    for (var log in logs) {
      DateTime normalizedDate = DateTime(log.date.year, log.date.month, log.date.day);
      if (dataset.containsKey(normalizedDate)) {
        dataset[normalizedDate] = dataset[normalizedDate]! + 1;
      } else {
        dataset[normalizedDate] = 1;
      }
    }
    return dataset;
  }

  int _calculateStreak(List<BreakLogModel> logs) {
    if (logs.isEmpty) return 0;
    Set<String> uniqueDates = logs.map((e) => DateFormat('yyyy-MM-dd').format(e.date)).toSet();
    List<DateTime> sortedDates = uniqueDates.map((e) => DateTime.parse(e)).toList();
    sortedDates.sort((a, b) => b.compareTo(a));

    int realStreak = 0;
    DateTime current = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (!sortedDates.contains(current)) {
      current = current.subtract(const Duration(days: 1));
    }

    for (var date in sortedDates) {
      if (date.year == current.year && date.month == current.month && date.day == current.day) {
        realStreak++;
        current = current.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return realStreak;
  }

  void _showEditProfileDialog() {
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

  // --- UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroProvider>(
      builder: (context, pomodoroProvider, child) {
        final int pomodorosUsed = pomodoroProvider.tasks.fold(0, (sum, item) => sum + item.completedSessions);

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5DC), // Beige Background (Sesuai Dashboard/Break)
          appBar: AppBar(
            backgroundColor: const Color(0xFF3E4F3C), // Hijau Gelap (Sesuai Dashboard)
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            actions: [
               IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: _showEditProfileDialog,
              ),
            ],
          ),
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- PROFILE HEADER CARD ---
                      _buildProfileHeader(),

                      const SizedBox(height: 30),
                      
                      // --- STATISTIK ---
                      const Text(
                        'Your Progress',
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: Color(0xFF2C3E50)
                        ),
                      ),
                      const SizedBox(height: 15),

                      // StreamBuilders logic kept exactly same
                      StreamBuilder<List<GoalModel>>(
                        stream: _goalService.getGoalsStream(),
                        builder: (context, snapshotGoals) {
                          return StreamBuilder<List<BreakLogModel>>(
                            stream: _breakService.getBreakLogsStream(),
                            builder: (context, snapshotBreaks) {
                              
                              // DATA CALCULATION
                              String goalCountStr = '0';
                              String tasksCompletedStr = '0';
                              int meditationStreak = 0;
                              Map<DateTime, int> heatMapData = {};

                              if (snapshotGoals.hasData) {
                                final goals = snapshotGoals.data!;
                                goalCountStr = goals.where((g) => g.isFinished).length.toString();
                                int t = 0; 
                                for (var g in goals) {
                                  t += g.tasks.where((x) => x.isCompleted).length;
                                }
                                tasksCompletedStr = t.toString();
                              }

                              if (snapshotBreaks.hasData) {
                                final breaks = snapshotBreaks.data!;
                                meditationStreak = _calculateStreak(breaks);
                                heatMapData = _prepareHeatMapDataset(breaks);
                              }

                              return Column(
                                children: [
                                  // Grid Statistik Modern
                                  GridView.count(
                                    crossAxisCount: 2,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    childAspectRatio: 1.4,
                                    crossAxisSpacing: 15,
                                    mainAxisSpacing: 15,
                                    children: [
                                      _buildStatCard('Goals Done', goalCountStr, Icons.emoji_events_outlined, const [Color(0xFFE0BBE4), Color(0xFF957DAD)]),
                                      _buildStatCard('Focus Time', '$pomodorosUsed x', Icons.timer_outlined, const [Color(0xFFF4A6A6), Color(0xFFD4A5A5)]),
                                      _buildStatCard('Tasks', tasksCompletedStr, Icons.check_circle_outline, const [Color(0xFFA8E6CF), Color(0xFF1DE9B6)]),
                                      _buildStatCard('Streak', '$meditationStreak days', Icons.local_fire_department_outlined, const [Color(0xFFFFCC80), Color(0xFFFF9800)]),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 30),
                                  
                                  // --- HEATMAP CARD ---
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: _commonDecoration(),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Consistency',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C3E50)),
                                            ),
                                            Icon(Icons.calendar_month, color: Colors.grey[400], size: 20)
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Text('Track your daily break habits.', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                        const SizedBox(height: 20),
                                        HeatMapCalendar(
                                          defaultColor: Colors.grey[100],
                                          flexible: true,
                                          colorMode: ColorMode.color,
                                          datasets: heatMapData,
                                          colorsets: const {
                                            1: Color(0xFFD4A5A5), 
                                            3: Color(0xFFE0BBE4), 
                                            5: Colors.orange,     
                                          },
                                          onClick: (value) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Activity on: ${DateFormat('dd MMM yyyy').format(value)}')),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // --- LOGOUT BUTTON ---
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _handleLogout,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: Colors.white
                          ),
                          icon: const Icon(Icons.logout, color: Colors.redAccent),
                          label: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _commonDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFFE0BBE4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              backgroundImage: (user?.photoURL != null && user!.photoURL!.isNotEmpty)
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: (user?.photoURL == null) 
                  ? const Icon(Icons.person, size: 35, color: Colors.grey) 
                  : null,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Hello, User!',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 18,
                    color: Color(0xFF2C3E50)
                  )
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '', 
                  style: const TextStyle(
                    color: Color(0xFF7F8C8D), 
                    fontSize: 13
                  )
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _showEditProfileDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 11, 
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, List<Color> gradient) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _commonDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count, 
                style: const TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50)
                )
              ),
              Text(
                title, 
                style: const TextStyle(
                  fontSize: 12, 
                  color: Color(0xFF95A5A6)
                )
              ),
            ],
          )
        ],
      ),
    );
  }

  // Dekorasi standar untuk Card (Shadow lembut + Rounded White)
  BoxDecoration _commonDecoration() {
    return BoxDecoration(
      color: Colors.white,
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