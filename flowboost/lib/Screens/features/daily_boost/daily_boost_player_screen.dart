import 'package:flutter/material.dart';
import 'daily_boost_share_dialog.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoTitle;
  final String videoUrl;
  final String? description;

  const VideoPlayerScreen({
    super.key,
    required this.videoTitle,
    required this.videoUrl,
    this.description,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with SingleTickerProviderStateMixin {
  bool isPlaying = false;
  bool isFavorite = false;
  bool showControls = true;
  double currentTime = 0;
  double totalTime = 324;
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsAnimation;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controlsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controlsAnimation = CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeInOut,
    );
    _controlsAnimationController.forward();
  }

  @override
  void dispose() {
    _controlsAnimationController.dispose();
    super.dispose();
  }

  void _checkFavoriteStatus() {
    setState(() {
      isFavorite = VideoFavoriteManager.isFavorite(widget.videoUrl);
    });
  }

  void _toggleFavorite() {
    setState(() {
      if (isFavorite) {
        VideoFavoriteManager.removeFavorite(widget.videoUrl);
        isFavorite = false;
        _showCustomSnackBar(
          'Video dihapus dari favorit',
          Icons.heart_broken,
          Colors.red,
        );
      } else {
        VideoFavoriteManager.addFavorite({
          'title': widget.videoTitle,
          'videoUrl': widget.videoUrl,
          'description': widget.description ?? '',
        });
        isFavorite = true;
        _showCustomSnackBar(
          'Video ditambahkan ke favorit',
          Icons.favorite,
          const Color(0xFFCCD5AE),
        );
      }
    });
  }

  void _showCustomSnackBar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              message,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
      showControls = true;
      _controlsAnimationController.forward();
    });

    // Auto hide controls after 3 seconds when playin
    if (isPlaying) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && isPlaying) {
          setState(() {
            showControls = false;
            _controlsAnimationController.reverse();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Video Player Area
            _buildVideoPlayer(),

            // Modern Progress Bar
            _buildProgressBar(),

            // Content Area with Smooth Scroll
            Expanded(child: _buildContentArea()),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Stack(
      children: [
        // Video Container with Gradient Overlay
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Colors.black87,
                Colors.black.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: GestureDetector(
            onTap: _togglePlayPause,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated Play/Pause Button
                AnimatedScale(
                  scale: isPlaying ? 0.8 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedOpacity(
                    opacity: showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFCCD5AE).withValues(alpha: 0.3),
                            const Color(0xFFCCD5AE).withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Modern Back Button with Blur Effect
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),

        // Video Title Overlay
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: FadeTransition(
            opacity: _controlsAnimation,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.videoTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: const Color(0xFFCCD5AE),
              inactiveTrackColor: Colors.white24,
              thumbColor: const Color(0xFFCCD5AE),
              overlayColor: const Color(0xFFCCD5AE).withValues(alpha: 0.3),
            ),
            child: Slider(
              value: currentTime,
              max: totalTime,
              onChanged: (value) {
                setState(() {
                  currentTime = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(currentTime.toInt()),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDuration(totalTime.toInt()),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFEFAE0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Stats
            _buildVideoStats(),

            const SizedBox(height: 24),

            // Action Buttons Row
            _buildActionButtons(),

            const SizedBox(height: 28),

            // About Video Card
            _buildAboutCard(),

            const SizedBox(height: 28),

            // Related Videos Section
            _buildRelatedVideosSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoStats() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFCCD5AE).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.visibility, size: 16, color: Color(0xFF8B9556)),
              const SizedBox(width: 6),
              const Text(
                '12.3K views',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B9556),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE9EDC9).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.black54),
              const SizedBox(width: 6),
              Text(
                '2 hari lalu',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCCD5AE).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildModernActionButton(
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            label: 'Favorit',
            color: isFavorite ? Colors.red : const Color(0xFF8B9556),
            onTap: _toggleFavorite,
          ),
          Container(width: 1, height: 40, color: Colors.black12),
          _buildModernActionButton(
            icon: Icons.share_rounded,
            label: 'Share',
            color: const Color(0xFF8B9556),
            onTap: () {
              VideoShareDialog.showShareDialog(
                context,
                widget.videoTitle,
                widget.videoUrl,
              );
            },
          ),
          Container(width: 1, height: 40, color: Colors.black12),
          _buildModernActionButton(
            icon: Icons.download_rounded,
            label: 'Download',
            color: const Color(0xFF8B9556),
            onTap: () {
              VideoShareDialog.showDownloadDialog(context, widget.videoTitle);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE9EDC9).withValues(alpha: 0.8),
            const Color(0xFFE9EDC9).withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFCCD5AE).withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCCD5AE).withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCD5AE).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Color(0xFF8B9556),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tentang Video Ini',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.description ??
                'Video motivasi ini akan membantumu untuk tetap semangat dan fokus dalam mencapai tujuanmu. Jangan pernah menyerah! Terus berjuang dan raih impianmu dengan tekad yang kuat.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withValues(alpha: 0.75),
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedVideosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFCCD5AE).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.video_library,
                size: 18,
                color: Color(0xFF8B9556),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Video Terkait',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildModernRelatedVideo(
          'Tips Sukses Setiap Hari',
          '6:30',
          '8.2K views',
        ),
        const SizedBox(height: 12),
        _buildModernRelatedVideo('Mindset Pemenang', '5:45', '12.5K views'),
        const SizedBox(height: 12),
        _buildModernRelatedVideo('Raih Impianmu', '7:20', '15.3K views'),
      ],
    );
  }

  Widget _buildModernRelatedVideo(String title, String duration, String views) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCCD5AE).withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle video tap
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 110,
                      height: 65,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFCCD5AE).withValues(alpha: 0.6),
                            const Color(0xFFCCD5AE).withValues(alpha: 0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.play_circle_outline,
                        size: 32,
                        color: Color(0xFF8B9556),
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          duration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.visibility,
                            size: 12,
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            views,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_vert,
                  size: 20,
                  color: Colors.black.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
