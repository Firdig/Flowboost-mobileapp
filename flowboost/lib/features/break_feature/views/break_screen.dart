import 'package:flutter/material.dart';
import '../../break_feature/views/meditation_screen.dart';
import '../../break_feature/views/Breathing_screen.dart';
import '../../break_feature/views/stretching_screen.dart';

class BreakScreen extends StatefulWidget {
  const BreakScreen({Key? key}) : super(key: key);

  @override
  State<BreakScreen> createState() => _BreakScreenState();
}

class _BreakScreenState extends State<BreakScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _selectedCardIndex = -1;

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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      _buildHeaderSection(screenHeight, screenWidth),
                      _buildDivider(),
                      _buildActivitiesSection(context, screenWidth),
                      _buildBottomSpacing(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    return const Color(0xFFF5F5DC); // Beige sesuai gambar
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: _buildBackButton(context),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: _buildAppBarTitle(),
        centerTitle: false,
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Color(0xFF2C3E50),
          size: 18,
        ),
        onPressed: () => _handleBackNavigation(context),
      ),
    );
  }

  void _handleBackNavigation(BuildContext context) {
    Navigator.pop(context);
  }

  Widget _buildAppBarTitle() {
    return const Text(
      'Take a Break',
      style: TextStyle(
        color: Color(0xFF2C3E50),
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildHeaderSection(double screenHeight, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: screenHeight * 0.03,
      ),
      child: Column(
        children: [
          _buildNotificationIcon(),
          SizedBox(height: screenHeight * 0.025),
          _buildMainTitle(),
          SizedBox(height: screenHeight * 0.015),
          _buildSubtitle(),
          SizedBox(height: screenHeight * 0.02),
          _buildTimeIndicator(),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF).withOpacity(0.1),
            const Color(0xFF4CAF50).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.notifications_active_outlined,
        size: 56,
        color: Color(0xFF6C63FF),
      ),
    );
  }

  Widget _buildMainTitle() {
    return const Text(
      'Time for a Break!',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2C3E50),
        letterSpacing: -0.5,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      'Take a moment to relax and recharge.\nYour well-being matters.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15,
        color: Color(0xFF7F8C8D),
        height: 1.6,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildTimeIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time,
            size: 16,
            color: Color(0xFF6C63FF),
          ),
          const SizedBox(width: 8),
          Text(
            '5-10 minutes recommended',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF6C63FF).withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.grey.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesSection(BuildContext context, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: 20),
          _buildActivityCards(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return const Row(
      children: [
        Icon(
          Icons.format_list_bulleted,
          color: Color(0xFF2C3E50),
          size: 20,
        ),
        SizedBox(width: 8),
        Text(
          'Choose Your Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C3E50),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCards(BuildContext context) {
    return Column(
      children: [
        _buildActivityCard(
          context: context,
          index: 0,
          icon: Icons.self_improvement_outlined,
          gradientColors: const [Color(0xFF6C63FF), Color(0xFF5A52E0)],
          title: 'Meditation',
          subtitle: 'Clear your mind with guided meditation',
          duration: '5 min',
          onTap: () => _navigateToScreen(
            context,
            const MeditationScreen(),
          ),
        ),
        const SizedBox(height: 16),
        _buildActivityCard(
          context: context,
          index: 1,
          icon: Icons.air,
          gradientColors: const [Color(0xFF4CAF50), Color(0xFF45A049)],
          title: 'Breathing Exercise',
          subtitle: 'Calm your nerves with deep breathing',
          duration: '3 min',
          onTap: () => _navigateToScreen(
            context,
            const BreathingScreen(),
          ),
        ),
        const SizedBox(height: 16),
        _buildActivityCard(
          context: context,
          index: 2,
          icon: Icons.accessibility_new_outlined,
          gradientColors: const [Color(0xFFFF9800), Color(0xFFF57C00)],
          title: 'Stretching',
          subtitle: 'Quick desk stretches to relieve tension',
          duration: '7 min',
          onTap: () => _navigateToScreen(
            context,
            const StretchingScreen(),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard({
    required BuildContext context,
    required int index,
    required IconData icon,
    required List<Color> gradientColors,
    required String title,
    required String subtitle,
    required String duration,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedCardIndex == index;
    
    return GestureDetector(
      onTapDown: (_) => _handleCardTapDown(index),
      onTapUp: (_) => _handleCardTapUp(),
      onTapCancel: () => _handleCardTapCancel(),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()
          ..scale(isSelected ? 0.97 : 1.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: _buildCardDecoration(gradientColors, isSelected),
          child: Row(
            children: [
              _buildCardIcon(icon, gradientColors),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCardContent(title, subtitle),
              ),
              _buildCardTrailing(duration, gradientColors),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCardTapDown(int index) {
    setState(() {
      _selectedCardIndex = index;
    });
  }

  void _handleCardTapUp() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _selectedCardIndex = -1;
        });
      }
    });
  }

  void _handleCardTapCancel() {
    setState(() {
      _selectedCardIndex = -1;
    });
  }

  BoxDecoration _buildCardDecoration(List<Color> colors, bool isSelected) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: colors[0].withOpacity(isSelected ? 0.3 : 0.15),
          blurRadius: isSelected ? 20 : 12,
          offset: Offset(0, isSelected ? 6 : 4),
        ),
      ],
      border: Border.all(
        color: colors[0].withOpacity(0.1),
        width: 1,
      ),
    );
  }

  Widget _buildCardIcon(IconData icon, List<Color> gradientColors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 28,
        color: Colors.white,
      ),
    );
  }

  Widget _buildCardContent(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: const Color(0xFF7F8C8D).withOpacity(0.9),
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCardTrailing(String duration, List<Color> gradientColors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: gradientColors[0].withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            duration,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: gradientColors[0],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Icon(
          Icons.arrow_forward_ios,
          color: gradientColors[0],
          size: 16,
        ),
      ],
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Widget _buildBottomSpacing() {
    return const SizedBox(height: 32);
  }
}