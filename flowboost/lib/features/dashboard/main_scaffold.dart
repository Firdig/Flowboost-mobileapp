import 'package:flowboost/features/Profile/views/Profile_screen.dart';
import 'package:flutter/material.dart';
import '../../common/constants/constants.dart';
import 'views/dashboard_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bungkus body dengan SafeArea agar konten atas tidak tertutup status bar/notch
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      // Gunakan SafeArea di Bottom Navigation Bar agar tidak tertutup tombol sistem
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: kAppBarColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), 
            topRight: Radius.circular(20)
          ),
        ),
        child: SafeArea(
          child: Container(
            height: 70, // Tinggi dikurangi sedikit karena sudah ada padding dari SafeArea
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_filled, 0),
                _buildNavItem(Icons.person, 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isSelected 
              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))] 
              : [],
        ),
        child: Icon(icon, size: 28, color: Colors.black),
      ),
    );
  }
}