import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'daily_boost_player_screen.dart';

class VideoAllListScreen extends StatefulWidget {
  const VideoAllListScreen({super.key});

  @override
  State<VideoAllListScreen> createState() => _VideoAllListScreenState();
}

class _VideoAllListScreenState extends State<VideoAllListScreen> {
  String _selectedCategory = 'Semua';
  final List<String> _categories = [
    'Semua',
    'Motivasi Kerja',
    'Motivasi Pagi',
    'Motivasi Belajar',
    'Motivasi Hidup',
    'Quotes Inspiratif',
    'Sukses Bisnis',
  ];

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> allVideos = _getAllVideos();
    final filteredVideos = _selectedCategory == 'Semua'
        ? allVideos
        : allVideos
              .where((video) => video['category'] == _selectedCategory)
              .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFEFAE0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFAE0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'KOLEKSI VIDEO',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              '${filteredVideos.length} Video Tersedia',
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(category),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFFCCD5AE),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black87 : Colors.black54,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 12,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFFCCD5AE)
                            : Colors.black.withValues(alpha: 0.1),
                        width: 1.5,
                      ),
                    ),
                    checkmarkColor: Colors.black87,
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: filteredVideos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library_outlined,
                    size: 80,
                    color: Colors.black.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada video di kategori ini',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredVideos.length,
              itemBuilder: (context, index) {
                final video = filteredVideos[index];
                return _buildVideoCard(
                  context,
                  index: index,
                  title: video['title'],
                  duration: video['duration'],
                  category: video['category'],
                  categoryColor: video['categoryColor'],
                  videoUrl: video['videoUrl'],
                  description: video['description'],
                  thumbnail: video['thumbnail'],
                );
              },
            ),
    );
  }

  Widget _buildVideoCard(
    BuildContext context, {
    required int index,
    required String title,
    required String duration,
    required String category,
    required Color categoryColor,
    required String videoUrl,
    required String description,
    required String thumbnail,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(
                  videoTitle: title,
                  videoUrl: videoUrl,
                  description: description,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: categoryColor.withValues(alpha: 0.1),
          highlightColor: categoryColor.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail with Enhanced Design
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: thumbnail,
                        width: 140,
                        height: 100,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 140,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                categoryColor.withValues(alpha: 0.3),
                                categoryColor.withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                categoryColor,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 140,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                categoryColor.withValues(alpha: 0.3),
                                categoryColor.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                color: categoryColor,
                                size: 32,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'No Image',
                                style: TextStyle(
                                  color: categoryColor,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Gradient Overlay
                    Container(
                      width: 140,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                    // Play Button
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Duration Badge
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 10,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              duration,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Video Number
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: categoryColor.withValues(alpha: 0.4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          '#${index + 1}',
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
                const SizedBox(width: 12),
                // Content Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: categoryColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(category),
                              size: 10,
                              color: categoryColor,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                category.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: categoryColor,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Description
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black.withValues(alpha: 0.6),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Stats Row
                      Row(
                        children: [
                          Icon(
                            Icons.remove_red_eye_outlined,
                            size: 12,
                            color: categoryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatViews((index + 1) * 1234)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: categoryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: categoryColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Motivasi Kerja':
        return Icons.work_outline_rounded;
      case 'Motivasi Pagi':
        return Icons.wb_sunny_outlined;
      case 'Motivasi Belajar':
        return Icons.school_outlined;
      case 'Motivasi Hidup':
        return Icons.favorite_outline_rounded;
      case 'Quotes Inspiratif':
        return Icons.format_quote_rounded;
      case 'Sukses Bisnis':
        return Icons.trending_up_rounded;
      default:
        return Icons.video_library_outlined;
    }
  }

  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M views';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K views';
    }
    return '$views views';
  }

  List<Map<String, dynamic>> _getAllVideos() {
    return [
      // Motivasi Kerja
      {
        'title': 'Bangkit Kerja Menang',
        'duration': '5:24',
        'category': 'Motivasi Kerja',
        'categoryColor': const Color(0xFF4A9B9B),
        'thumbnail':
            'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=300&fit=crop',
        'videoUrl':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        'description':
            'Video motivasi powerful untuk meningkatkan semangat kerja dan produktivitas Anda dengan mindset positif dan strategi manajemen waktu yang efektif.',
      },
      {
        'title': '5 Cara Meningkatkan Produktivitas Kerja',
        'duration': '7:15',
        'category': 'Motivasi Kerja',
        'categoryColor': const Color(0xFF4A9B9B),
        'thumbnail':
            'https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?w=400&h=300&fit=crop',
        'videoUrl':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        'description':
            'Temukan 5 strategi terbukti untuk meningkatkan produktivitas kerja hingga 200% dengan teknik time blocking dan optimalisasi energi harian.',
      },
      {
        'title': 'Mindset Sukses di Tempat Kerja',
        'duration': '6:30',
        'category': 'Motivasi Kerja',
        'categoryColor': const Color(0xFF4A9B9B),
        'thumbnail':
            'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=400&h=300&fit=crop',
        'videoUrl':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        'description':
            'Bangun mindset growth yang tepat untuk meraih kesuksesan karir jangka panjang dengan mengubah pola pikir dari fixed ke growth mindset.',
      },
      {
        'title': 'Tips Menghadapi Bos yang Sulit',
        'duration': '8:45',
        'category': 'Motivasi Kerja',
        'categoryColor': const Color(0xFF4A9B9B),
        'thumbnail':
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&h=300&fit=crop',
        'videoUrl':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        'description':
            'Panduan lengkap menghadapi atasan yang demanding dengan cara profesional, teknik komunikasi asertif, dan strategi memahami ekspektasi bos.',
      },
      // Motivasi Pagi
      {
        'title': 'Rutinitas Pagi Orang Sukses',
        'duration': '4:30',
        'category': 'Motivasi Pagi',
        'categoryColor': const Color(0xFFE8C547),
        'thumbnail':
            'https://images.unsplash.com/photo-1495195134817-aeb325a55b65?w=400&h=300&fit=crop',
        'videoUrl':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        'description':
            'Kupas tuntas morning routine dari CEO dan entrepreneur sukses dunia seperti Tim Cook, Jeff Bezos, dan Richard Branson untuk produktivitas tinggi.',
      },
      {
        'title': 'Bangun Pagi Penuh Semangat',
        'duration': '5:15',
        'category': 'Motivasi Pagi',
        'categoryColor': const Color(0xFFE8C547),
        'thumbnail':
            'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=400&h=300&fit=crop',
        'videoUrl':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        'description':
            'Mulai hari dengan energi positif maksimal! Dapatkan tips praktis untuk bangun pagi dengan semangat, power breakfast, dan morning stretch routine.',
      },
      {
        'title': 'Afirmasi Positif Setiap Pagi',
        'duration': '3:20',
        'category': 'Motivasi Pagi',
        'categoryColor': const Color(0xFFE8C547),
        'thumbnail':
            'https://images.unsplash.com/photo-1513151233558-d860c5398176?w=400&h=300&fit=crop',
        'videoUrl':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
        'description':
            'Kumpulan afirmasi positif powerful yang terbukti ilmiah meningkatkan mood dan mindset hingga 85% untuk memprogram ulang subconscious mind.',
      },
      // Motivasi Belajar
      {
        'title': 'Cara Belajar Efektif dan Efisien',
        'duration': '9:10',
        'category': 'Motivasi Belajar',
        'categoryColor': const Color(0xFF8B8B8B),
        'thumbnail':
            'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=400&h=300&fit=crop',
        'videoUrl':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
        'description':
            'Master teknik belajar modern yang digunakan mahasiswa top universitas dunia dengan metode active recall, spaced repetition, dan Feynman technique.',
      },
      {
        'title': 'Teknik Pomodoro untuk Belajar',
        'duration': '6:40',
        'category': 'Motivasi Belajar',
        'categoryColor': const Color(0xFF8B8B8B),
        'thumbnail':
            'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=400&h=300&fit=crop',
        'videoUrl':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
        'description':
            'Panduan lengkap mengimplementasikan Pomodoro Technique untuk meningkatkan fokus belajar dengan sesi 25 menit intens dan strategi deep work.',
      },
      {
        'title': 'Motivasi Belajar Tanpa Batas',
        'duration': '7:55',
        'category': 'Motivasi Belajar',
        'categoryColor': const Color(0xFF8B8B8B),
        'thumbnail':
            'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=400&h=300&fit=crop',
        'videoUrl':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
        'description':
            'Kisah inspiratif self-taught learners yang menguasai skill kompleks secara otodidak dengan growth mindset dan habit belajar konsisten.',
      },
      // Motivasi Hidup
      {
        'title': 'Hidup Adalah Pilihan',
        'duration': '10:20',
        'category': 'Motivasi Hidup',
        'categoryColor': const Color(0xFFCCD5AE),
        'thumbnail':
            'https://images.unsplash.com/photo-1500021804447-2ca2eaaaabeb?w=400&h=300&fit=crop',
        'videoUrl':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4',
        'description':
            'Refleksi mendalam tentang kekuatan pilihan dalam hidup. Setiap keputusan membentuk masa depan dengan personal responsibility dan decision making efektif.',
      },
      {
        'title': 'Bangkit dari Kegagalan',
        'duration': '8:30',
        'category': 'Motivasi Hidup',
        'categoryColor': const Color(0xFFCCD5AE),
        'thumbnail':
            'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?w=400&h=300&fit=crop',
        'videoUrl':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
        'description':
            'Kegagalan adalah guru terbaik menuju kesuksesan. Kisah inspiratif tokoh sukses yang pernah gagal besar dan cara reframing failure untuk bangkit lebih kuat.',
      },
      {
        'title': 'Syukuri Hidupmu',
        'duration': '5:45',
        'category': 'Motivasi Hidup',
        'categoryColor': const Color(0xFFCCD5AE),
        'thumbnail':
            'https://images.unsplash.com/photo-1465146633011-14f8e0781093?w=400&h=300&fit=crop',
        'videoUrl':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4',
        'description':
            'Bersyukur adalah kunci kebahagiaan dan abundance. Science of gratitude dan daily gratitude practice yang terbukti meningkatkan life satisfaction hingga 25%.',
      },
      // Quotes Inspiratif
      {
        'title': 'Quotes Motivasi dari Tokoh Dunia',
        'duration': '4:15',
        'category': 'Quotes Inspiratif',
        'categoryColor': const Color(0xFF2C2C2C),
        'thumbnail':
            'https://images.unsplash.com/photo-1455849318743-b2233052fcff?w=400&h=300&fit=crop',
        'videoUrl':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        'description':
            'Koleksi kata-kata bijak powerful dari Nelson Mandela, Albert Einstein, Mother Teresa, dan Steve Jobs tentang kepemimpinan, inovasi, dan compassion.',
      },
      {
        'title': 'Kata-kata Bijak Penuh Makna',
        'duration': '6:00',
        'category': 'Quotes Inspiratif',
        'categoryColor': const Color(0xFF2C2C2C),
        'thumbnail':
            'https://images.unsplash.com/photo-1604480132736-44c188fe4d20?w=400&h=300&fit=crop',
        'videoUrl':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        'description':
            'Quotes inspiratif yang mengubah perspektif hidup dengan wisdom dari stoicism, buddhism, dan modern psychology tentang mental toughness dan happiness.',
      },
      // Sukses Bisnis
      {
        'title': 'Langkah Kecil Raih Bisnis Besar',
        'duration': '12:30',
        'category': 'Sukses Bisnis',
        'categoryColor': const Color(0xFF6B8B6B),
        'thumbnail':
            'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=400&h=300&fit=crop',
        'videoUrl':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        'description':
            'Blueprint lengkap membangun bisnis besar dari langkah kecil dengan lean startup methodology, MVP validation, dan scaling strategy sustainable.',
      },
      {
        'title': 'Mindset Entrepreneur Sukses',
        'duration': '9:45',
        'category': 'Sukses Bisnis',
        'categoryColor': const Color(0xFF6B8B6B),
        'thumbnail':
            'https://images.unsplash.com/photo-1553877522-43269d4ea984?w=400&h=300&fit=crop',
        'videoUrl':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        'description':
            'Cara berpikir entrepreneur sukses dengan abundance mindset, long-term thinking, calculated risk-taking, dan continuous learning mindset yang powerful.',
      },
      {
        'title': 'Cara Memulai Bisnis dari Nol',
        'duration': '11:20',
        'category': 'Sukses Bisnis',
        'categoryColor': const Color(0xFF6B8B6B),
        'thumbnail':
            'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=400&h=300&fit=crop',
        'videoUrl':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
        'description':
            'Panduan step-by-step komprehensif memulai bisnis dari nol dengan modal minimal, dari validasi ide hingga monetization framework, legal setup, dan 50+ tools gratis untuk entrepreneur pemula.',
      },
    ];
  }
}
