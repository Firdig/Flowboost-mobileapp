import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'daily_boost_list_screen.dart';
import 'daily_boost_all_list_screen.dart';
import '../widgets/daily_boost_share_dialog.dart';

enum SortType { defaultOrder, newest, oldest }

// ✅ DailyBoostScreen - Home menu (Redesigned Theme)
class DailyBoostScreen extends StatefulWidget {
  const DailyBoostScreen({super.key});

  @override
  State<DailyBoostScreen> createState() => _DailyBoostScreenState();
}

class _DailyBoostScreenState extends State<DailyBoostScreen> with SingleTickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Background Beige (Tema Dashboard/Break)
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E4F3C), // Hijau Gelap
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'DAILY BOOST',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Boost Your Day',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Temukan inspirasi dan motivasi harianmu di sini.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Menu Items dengan Style Dashboard
                  _buildModernMenuItem(
                    context,
                    icon: Icons.category_outlined,
                    title: 'Kategori Video',
                    subtitle: 'Jelajah video berdasarkan topik',
                    colors: [const Color(0xFF6C63FF), const Color(0xFF5A52E0)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VideoCategoryScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildModernMenuItem(
                    context,
                    icon: Icons.play_circle_outline,
                    title: 'Semua Video',
                    subtitle: 'Lihat koleksi lengkap motivasi',
                    colors: [const Color(0xFFFF9800), const Color(0xFFF57C00)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VideoAllListScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildModernMenuItem(
                    context,
                    icon: Icons.favorite_border,
                    title: 'Video Favorit',
                    subtitle: 'Koleksi inspirasi tersimpanmu',
                    colors: [const Color(0xFFE91E63), const Color(0xFFD81B60)],
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
          ),
        ),
      ),
    );
  }

  Widget _buildModernMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
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
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFBDC3C7)),
          ],
        ),
      ),
    );
  }
}

// ✅ VideoFavoriteScreen - Daftar Video Favorit (Redesigned Theme)
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
      backgroundColor: const Color(0xFFF5F5DC), // Beige Background
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E4F3C), // Hijau Gelap
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'FAVORIT SAYA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        actions: [
          if (favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              tooltip: 'Hapus Semua',
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
                : ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: favorites.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.sort, size: 20, color: Color(0xFF7F8C8D)),
          const SizedBox(width: 12),
          const Text(
            'Urutkan:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
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
                  ),
                  const SizedBox(width: 8),
                  _buildSortChip(
                    label: 'Terbaru',
                    sortType: SortType.newest,
                  ),
                  const SizedBox(width: 8),
                  _buildSortChip(
                    label: 'Terlama',
                    sortType: SortType.oldest,
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
  }) {
    final isSelected = _currentSort == sortType;

    return InkWell(
      onTap: () {
        setState(() {
          _currentSort = sortType;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFFF3EEDD),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF7F8C8D),
          ),
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
            size: 80,
            color: const Color(0xFF6C63FF).withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada video favorit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mulai simpan video inspiratifmu!',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to video player
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3E50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description ?? 'Video motivasi inspiratif',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7F8C8D),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (addedAt != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 10, color: Color(0xFFAAB7B8)),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(addedAt),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFFAAB7B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: Color(0xFFE91E63), size: 22),
                onPressed: () {
                  _showDeleteDialog(videoUrl, title);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Favorit', style: TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold)),
        content: Text(
          'Hapus "$title" dari koleksi favorit?',
          style: const TextStyle(color: Color(0xFF5D6D7E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF7F8C8D))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              setState(() {
                VideoFavoriteManager.removeFavorite(videoUrl);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Video dihapus dari favorit'),
                  backgroundColor: Color(0xFF2C3E50),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Semua', style: TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold)),
        content: const Text(
          'Apakah kamu yakin ingin mengosongkan semua video favorit?',
          style: TextStyle(color: Color(0xFF5D6D7E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF7F8C8D))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              setState(() {
                VideoFavoriteManager.clearAll();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua favorit berhasil dihapus'),
                  backgroundColor: Color(0xFF2C3E50),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Hapus Semua', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ✅ VideoCategoryScreen - Redesigned Theme
class VideoCategoryScreen extends StatelessWidget {
  const VideoCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data Kategori
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'Motivasi Kerja',
        'color': const Color(0xFF4A9B9B),
        'image': 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&q=80',
      },
      {
        'name': 'Motivasi Pagi',
        'color': const Color(0xFFE8C547),
        'image': 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&q=80',
      },
      {
        'name': 'Motivasi Belajar',
        'color': const Color(0xFF8B8B8B),
        'image': 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=800&q=80',
      },
      {
        'name': 'Motivasi Hidup',
        'color': const Color(0xFFCCD5AE),
        'image': 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800&q=80',
      },
      {
        'name': 'Quotes Inspiratif',
        'color': const Color(0xFF2C2C2C),
        'image': 'https://images.unsplash.com/photo-1455849318743-b2233052fcff?w=800&q=80',
      },
      {
        'name': 'Sukses Bisnis',
        'color': const Color(0xFF6B8B6B),
        'image': 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&q=80',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Beige Background
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E4F3C), // Hijau Gelap
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'KATEGORI VIDEO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _buildCategoryCard(
              context,
              categories[index]['name'],
              categories[index]['color'],
              categories[index]['image'],
            );
          },
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 🖼️ Background Image
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: color.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: color,
                  child: const Icon(Icons.image, color: Colors.white54),
                ),
              ),

              // 🎨 Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),

              // 📝 Text Label
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
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