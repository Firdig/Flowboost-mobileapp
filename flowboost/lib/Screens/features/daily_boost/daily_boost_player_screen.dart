import 'package:flutter/material.dart';
import 'daily_boost_share_dialog.dart'; // VideoFavoriteManager sudah di dalam file ini

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

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool isPlaying = false;
  bool isFavorite = false;
  double currentTime = 0;
  double totalTime = 324;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video dihapus dari favorit'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        VideoFavoriteManager.addFavorite({
          'title': widget.videoTitle,
          'videoUrl': widget.videoUrl,
          'description': widget.description ?? '',
        });
        isFavorite = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Video ditambahkan ke favorit'),
            duration: const Duration(seconds: 1),
            backgroundColor: const Color(0xFFCCD5AE), // Hijau sage
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Video Player Area
            Stack(
              children: [
                // Video Container
                Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.black87,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Placeholder untuk video
                      Icon(
                        isPlaying ? Icons.pause_circle : Icons.play_circle,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      // Tap untuk play/pause
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isPlaying = !isPlaying;
                            });
                          },
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                    ],
                  ),
                ),
                // Back Button
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),

            // Progress Bar
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                    ),
                    child: Slider(
                      value: currentTime,
                      max: totalTime,
                      activeColor: const Color(
                        0xFFCCD5AE,
                      ), // Progress - Hijau sage
                      inactiveColor: Colors.white30,
                      onChanged: (value) {
                        setState(() {
                          currentTime = value;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(currentTime.toInt()),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatDuration(totalTime.toInt()),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Video Info & Actions
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEFAE0), // Background - Krem sangat terang
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video Title
                      Text(
                        widget.videoTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Views & Date
                      Text(
                        '12,345 views • 2 hari yang lalu',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionButton(
                            icon: isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            label: 'Favorit',
                            color: isFavorite ? Colors.red : Colors.black87,
                            onTap: _toggleFavorite,
                          ),
                          _buildActionButton(
                            icon: Icons.share,
                            label: 'Share',
                            onTap: () {
                              VideoShareDialog.showShareDialog(
                                context,
                                widget.videoTitle,
                                widget.videoUrl,
                              );
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.download,
                            label: 'Download',
                            onTap: () {
                              VideoShareDialog.showDownloadDialog(
                                context,
                                widget.videoTitle,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Tentang Video
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFE9EDC9,
                          ).withValues(alpha: 0.7), // Card - Krem hijau terang
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFFCCD5AE,
                            ).withValues(alpha: 0.3), // Border - Hijau sage
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tentang Vidio Ini',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.description ??
                                  'Video motivasi ini akan membantumu untuk tetap semangat dan fokus dalam mencapai tujuanmu. Jangan pernah menyerah!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black.withValues(alpha: 0.7),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Related Videos
                      const Text(
                        'Vidio Terkait',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildRelatedVideo('Tips Sukses Setiap Hari', '6:30'),
                      _buildRelatedVideo('Mindset Pemenang', '5:45'),
                      _buildRelatedVideo('Raih Impianmu', '7:20'),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color ?? Colors.black87),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color ?? Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedVideo(String title, String duration) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(
          0xFFE9EDC9,
        ).withValues(alpha: 0.7), // Card - Krem hijau terang
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(
            0xFFCCD5AE,
          ).withValues(alpha: 0.3), // Border - Hijau sage
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(
                0xFFCCD5AE,
              ).withValues(alpha: 0.5), // Thumbnail - Hijau sage
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.play_circle_outline,
              size: 30,
              color: Color(0xFF8B9556), // Icon - Hijau tua
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
