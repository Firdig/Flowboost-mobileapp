import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Favorite Manager - Simple in-memory storage dengan timestamp
class VideoFavoriteManager {
  static final List<Map<String, dynamic>> _favorites = [];

  static List<Map<String, dynamic>> get favorites => _favorites;

  static bool isFavorite(String videoUrl) {
    return _favorites.any((video) => video['videoUrl'] == videoUrl);
  }

  static void addFavorite(Map<String, dynamic> video) {
    if (!isFavorite(video['videoUrl']!)) {
      // Tambahkan timestamp saat video ditambahkan ke favorit
      video['addedAt'] = DateTime.now().millisecondsSinceEpoch;
      _favorites.add(video);
    }
  }

  static void removeFavorite(String videoUrl) {
    _favorites.removeWhere((video) => video['videoUrl'] == videoUrl);
  }

  static void clearAll() {
    _favorites.clear();
  }

  static int get count => _favorites.length;
}

class VideoShareDialog {
  static void showShareDialog(
    BuildContext context,
    String videoTitle,
    String videoUrl,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFEFAE0), // Background - Krem sangat terang
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(
                  0xFFCCD5AE,
                ).withValues(alpha: 0.5), // Handle bar - Hijau sage
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Bagikan Video',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  context,
                  icon: Icons.link,
                  label: 'Salin Link',
                  color: const Color(0xFFCCD5AE), // Hijau sage
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: videoUrl));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Link berhasil disalin!'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: const Color(0xFFCCD5AE),
                      ),
                    );
                  },
                ),
                _buildShareOption(
                  context,
                  icon: Icons.chat,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Membuka WhatsApp...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                _buildShareOption(
                  context,
                  icon: Icons.telegram,
                  label: 'Telegram',
                  color: const Color(0xFF0088CC),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Membuka Telegram...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                _buildShareOption(
                  context,
                  icon: Icons.more_horiz,
                  label: 'Lainnya',
                  color: const Color(0xFF8B8B8B),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur share lainnya...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  static void showDownloadDialog(BuildContext context, String videoTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(
          0xFFFEFAE0,
        ), // Dialog background - Krem sangat terang
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.download, color: Color(0xFFCCD5AE)), // Icon - Hijau sage
            SizedBox(width: 12),
            Text('Download Video', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih kualitas video:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            _buildQualityOption(
              context,
              quality: '720p (HD)',
              size: '45 MB',
              icon: Icons.hd,
            ),
            const SizedBox(height: 8),
            _buildQualityOption(
              context,
              quality: '480p',
              size: '25 MB',
              icon: Icons.sd,
            ),
            const SizedBox(height: 8),
            _buildQualityOption(
              context,
              quality: '360p',
              size: '15 MB',
              icon: Icons.phone_android,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  static Widget _buildQualityOption(
    BuildContext context, {
    required String quality,
    required String size,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mengunduh video dengan kualitas $quality...'),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFFCCD5AE), // SnackBar - Hijau sage
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(
            0xFFE9EDC9,
          ).withValues(alpha: 0.7), // Option background - Krem hijau terang
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(
              0xFFCCD5AE,
            ).withValues(alpha: 0.3), // Border - Hijau sage
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF8B9556)), // Icon - Hijau tua
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quality,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    size,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}
