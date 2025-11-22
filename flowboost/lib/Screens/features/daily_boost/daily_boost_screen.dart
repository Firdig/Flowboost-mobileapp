import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'daily_boost_list_screen.dart';
import 'daily_boost_all_list_screen.dart';
import 'daily_boost_share_dialog.dart';

enum SortType { defaultOrder, newest, oldest }

// ✅ DailyBoostScreen - Menu Utama
class DailyBoostScreen extends StatelessWidget {
  const DailyBoostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFAE0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFAE0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'VIDIO MOTIVASI',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMenuItem(
              context,
              icon: Icons.description_outlined,
              title: 'Kategori Vidio',
              subtitle: 'Jelajah Vidio Berdasarkan Kategori',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VideoCategoryScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              context,
              icon: Icons.play_circle_outline,
              title: 'Vidio Motivasi',
              subtitle: 'Semua Vidio Motivasi Tersedia',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VideoAllListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              context,
              icon: Icons.favorite,
              title: 'Vidio Favorit',
              subtitle: 'Vidio Yang Kamu Simpan',
              iconColor: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VideoFavoriteScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE9EDC9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFCCD5AE).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFCCD5AE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 36, color: iconColor ?? Colors.black45),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
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
      ),
    );
  }
}

// ✅ VideoFavoriteScreen - Daftar Video Favorit
class VideoFavoriteScreen extends StatefulWidget {
  const VideoFavoriteScreen({super.key});

  @override
  State<VideoFavoriteScreen> createState() => _VideoFavoriteScreenState();
}

class _VideoFavoriteScreenState extends State<VideoFavoriteScreen> {
  SortType _currentSort = SortType.defaultOrder;

  List<Map<String, dynamic>> get _sortedFavorites {
    final favorites = List<Map<String, dynamic>>.from(
      VideoFavoriteManager.favorites,
    );

    switch (_currentSort) {
      case SortType.newest:
        favorites.sort((a, b) {
          final timeA = a['addedAt'] as int? ?? 0;
          final timeB = b['addedAt'] as int? ?? 0;
          return timeB.compareTo(timeA);
        });
      case SortType.oldest:
        favorites.sort((a, b) {
          final timeA = a['addedAt'] as int? ?? 0;
          final timeB = b['addedAt'] as int? ?? 0;
          return timeA.compareTo(timeB);
        });
      case SortType.defaultOrder:
        break;
    }

    return favorites;
  }

  @override
  Widget build(BuildContext context) {
    final favorites = _sortedFavorites;

    return Scaffold(
      backgroundColor: const Color(0xFFFEFAE0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFAE0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'VIDIO FAVORIT',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          if (favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              onPressed: () {
                _showClearAllDialog();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (favorites.isNotEmpty) _buildSortingFilter(),
          Expanded(
            child: favorites.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final video = favorites[index];
                      return _buildVideoCard(
                        context,
                        index: index,
                        title: video['title']!,
                        videoUrl: video['videoUrl']!,
                        description: video['description'],
                        addedAt: video['addedAt'] as int?,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortingFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EDC9).withValues(alpha: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Urutkan:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortChip(
                    label: 'Default',
                    sortType: SortType.defaultOrder,
                    icon: Icons.format_list_bulleted,
                  ),
                  const SizedBox(width: 8),
                  _buildSortChip(
                    label: 'Terbaru',
                    sortType: SortType.newest,
                    icon: Icons.arrow_downward,
                  ),
                  const SizedBox(width: 8),
                  _buildSortChip(
                    label: 'Terlama',
                    sortType: SortType.oldest,
                    icon: Icons.arrow_upward,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip({
    required String label,
    required SortType sortType,
    required IconData icon,
  }) {
    final isSelected = _currentSort == sortType;

    return InkWell(
      onTap: () {
        setState(() {
          _currentSort = sortType;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFCCD5AE) : const Color(0xFFFAEDCD),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFCCD5AE)
                : const Color(0xFFCCD5AE).withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.black87 : Colors.black54,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.black87 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 100,
            color: const Color(0xFFCCD5AE).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada video favorit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai tambahkan video favoritmu!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(
    BuildContext context, {
    required int index,
    required String title,
    required String videoUrl,
    String? description,
    int? addedAt,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EDC9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to video player
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 120,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCD5AE).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_filled,
                      size: 40,
                      color: Color(0xFF8B9556),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(Icons.favorite, color: Colors.red, size: 20),
                    ),
                  ],
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description ?? 'Video motivasi inspiratif',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (addedAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(addedAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black.withValues(alpha: 0.4),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _showDeleteDialog(videoUrl, title);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hari ini';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showDeleteDialog(String videoUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFEFAE0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus dari Favorit?'),
        content: Text(
          'Apakah kamu yakin ingin menghapus "$title" dari favorit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                VideoFavoriteManager.removeFavorite(videoUrl);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Video dihapus dari favorit'),
                  duration: Duration(seconds: 1),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFEFAE0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Semua?'),
        content: const Text(
          'Apakah kamu yakin ingin menghapus semua video favorit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                VideoFavoriteManager.clearAll();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua video favorit berhasil dihapus'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Hapus Semua',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ VideoCategoryScreen - DENGAN NETWORK IMAGES 🖼️
class VideoCategoryScreen extends StatelessWidget {
  const VideoCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🌐 URL gambar dari Unsplash (GRATIS & LANGSUNG BISA DIPAKAI!)
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'Motivasi Kerja',
        'color': const Color(0xFF4A9B9B),
        'image':
            'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&q=80',
      },
      {
        'name': 'Motivasi Pagi',
        'color': const Color(0xFFE8C547),
        'image':
            'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&q=80',
      },
      {
        'name': 'Motivasi Belajar',
        'color': const Color(0xFF8B8B8B),
        'image':
            'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=800&q=80',
      },
      {
        'name': 'Motivasi Hidup',
        'color': const Color(0xFFCCD5AE),
        'image':
            'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800&q=80',
      },
      {
        'name': 'Quotes Inspiratif',
        'color': const Color(0xFF2C2C2C),
        'image':
            'https://images.unsplash.com/photo-1455849318743-b2233052fcff?w=800&q=80',
      },
      {
        'name': 'Sukses Bisnis',
        'color': const Color(0xFF6B8B6B),
        'image':
            'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&q=80',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFEFAE0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFAE0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'KATEGORI VIDIO',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFE9EDC9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: categories.map((category) {
            return _buildCategoryCard(
              context,
              category['name'],
              category['color'],
              category['image'],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    Color color,
    String imageUrl,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VideoListScreen(categoryName: title, categoryColor: color),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 🖼️ Background Image dengan caching otomatis
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: color.withValues(alpha: 0.3),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: color,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.white54,
                    size: 40,
                  ),
                ),
                memCacheHeight: 400,
                memCacheWidth: 600,
              ),

              // 🎨 Overlay gelap dengan gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),

              // 🌈 Overlay warna kategori
              Container(
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15)),
              ),

              // 📝 Text Label
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black87,
                          blurRadius: 8,
                          offset: Offset(1, 1),
                        ),
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
