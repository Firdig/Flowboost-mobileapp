import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'daily_boost_player_screen.dart';

class VideoAllListScreen extends StatelessWidget {
  const VideoAllListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Gabungkan semua video dari semua kategori
    final List<Map<String, dynamic>> allVideos = _getAllVideos();

    return Scaffold(
      backgroundColor: const Color(
        0xFFFEFAE0,
      ), // Background - Krem sangat terang
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFAE0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SEMUA VIDIO MOTIVASI',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allVideos.length,
        itemBuilder: (context, index) {
          final video = allVideos[index];
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
        color: const Color(0xFFE9EDC9), // Card - Krem hijau terang
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(
            0xFFCCD5AE,
          ).withValues(alpha: 0.3), // Border - Hijau sage
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail dengan CachedNetworkImage
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    // Gambar Thumbnail
                    CachedNetworkImage(
                      imageUrl: thumbnail,
                      width: 120,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 120,
                        height: 80,
                        color: categoryColor.withValues(alpha: 0.3),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              categoryColor,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 120,
                        height: 80,
                        color: categoryColor.withValues(alpha: 0.3),
                        child: Icon(
                          Icons.image_not_supported,
                          color: categoryColor,
                          size: 30,
                        ),
                      ),
                    ),

                    // Play Button Overlay
                    Container(
                      width: 120,
                      height: 80,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.play_circle_filled,
                        size: 40,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),

                    // Duration Badge
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
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
              ),
              const SizedBox(width: 12),
              // Title & Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.remove_red_eye,
                          size: 14,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(index + 1) * 1234} views',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: const Color(0xFFCCD5AE), // Chevron - Hijau sage
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getAllVideos() {
    // Gabungkan semua video dari semua kategori dengan thumbnail
    return [
      // Motivasi Kerja
      {
        'title': 'Bangkit Kerja Menang',
        'duration': '5:24',
        'category': 'Motivasi Kerja',
        'categoryColor': const Color(0xFF4A9B9B),
        'thumbnail':
            'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=300&fit=crop',
        'videoUrl': 'https://www.example.com/video1.mp4',
        'description':
            'Video ini akan membantumu bangkit dan tetap semangat di tempat kerja.',
      },
      {
        'title': '5 Cara Meningkatkan Produktivitas Kerja',
        'duration': '7:15',
        'category': 'Motivasi Kerja',
        'categoryColor': const Color(0xFF4A9B9B),
        'thumbnail':
            'https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?w=400&h=300&fit=crop',
        'videoUrl': 'https://www.example.com/video2.mp4',
        'description':
            'Tingkatkan produktivitasmu dengan 5 cara efektif yang mudah diterapkan.',
      },
      {
        'title': 'Mindset Sukses di Tempat Kerja',
        'duration': '6:30',
        'category': 'Motivasi Kerja',
        'categoryColor': const Color(0xFF4A9B9B),
        'thumbnail':
            'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=400&h=300&fit=crop',
        'videoUrl': 'https://www.example.com/video3.mp4',
        'description':
            'Pelajari mindset yang tepat untuk sukses di dunia kerja.',
      },
      // Motivasi Pagi
      {
        'title': 'Rutinitas Pagi Orang Sukses',
        'duration': '4:30',
        'category': 'Motivasi Pagi',
        'categoryColor': const Color(0xFFE8C547),
        'thumbnail':
            'https://images.unsplash.com/photo-1495195134817-aeb325a55b65?w=400&h=300&fit=crop',
        'videoUrl': 'https://www.example.com/video5.mp4',
        'description':
            'Mulai hari dengan rutinitas pagi yang akan mengubah hidupmu.',
      },
      {
        'title': 'Bangun Pagi Penuh Semangat',
        'duration': '5:15',
        'category': 'Motivasi Pagi',
        'categoryColor': const Color(0xFFE8C547),
        'thumbnail':
            'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=400&h=300&fit=crop',
        'videoUrl': 'https://www.example.com/video6.mp4',
        'description': 'Tips bangun pagi dengan penuh energi dan semangat.',
      },
      {
        'title': 'Afirmasi Positif Setiap Pagi',
        'duration': '3:20',
        'category': 'Motivasi Pagi',
        'categoryColor': const Color(0xFFE8C547),
        'thumbnail':
            'https://images.unsplash.com/photo-1513151233558-d860c5398176?w=400&h=300&fit=crop',
        'videoUrl': 'https://www.example.com/video7.mp4',
        'description':
            'Mulai hari dengan afirmasi positif untuk energi maksimal.',
      },
      // Motivasi Belajar
      {
        'title': 'Cara Belajar Efektif dan Efisien',
        'duration': '9:10',
        'category': 'Motivasi Belajar',
        'categoryColor': const Color(0xFF8B8B8B),
        'thumbnail':
            'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=400&h=300&fit=crop',
        'videoUrl': 'https://www.example.com/video8.mp4',
        'description': 'Teknik belajar yang efektif untuk hasil maksimal.',
      },
      {
        'title': 'Teknik Pomodoro untuk Belajar',
        'duration': '6:40',
        'category': 'Motivasi Belajar',
        'categoryColor': const Color(0xFF8B8B8B),
        'thumbnail':
            'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=400&h=300&fit=crop',
        'videoUrl': 'https://www.example.com/video9.mp4',
        'description': 'Tingkatkan fokus belajar dengan teknik Pomodoro.',
      },
      {
        'title': 'Motivasi Belajar Tanpa Batas',
        'duration': '7:55',
        'category': 'Motivasi Belajar',
        'categoryColor': const Color(0xFF8B8B8B),
        'thumbnail':
            'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=400&h=300&fit=crop',
        'videoUrl': 'https://www.example.com/video10.mp4',
        'description':
            'Jangan pernah berhenti belajar untuk masa depan lebih baik.',
      },
      // Motivasi Hidup
      {
        'title': 'Hidup Adalah Pilihan',
        'duration': '10:20',
        'category': 'Motivasi Hidup',
        'categoryColor': const Color(0xFFCCD5AE),
        'thumbnail':
            'https://images.unsplash.com/photo-1500021804447-2ca2eaaaabeb?w=400&h=300&fit=crop',
        'videoUrl': 'https://www.example.com/video11.mp4',
        'description':
            'Setiap keputusan yang kamu ambil akan menentukan masa depanmu.',
      },
      {
        'title': 'Bangkit dari Kegagalan',
        'duration': '8:30',
        'category': 'Motivasi Hidup',
        'categoryColor': const Color(0xFFCCD5AE),
        'thumbnail':
            'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?w=400&h=300&fit=crop',
        'videoUrl': 'https://www.example.com/video12.mp4',
        'description': 'Kegagalan adalah awal dari kesuksesan yang nyata.',
      },
      {
        'title': 'Syukuri Hidupmu',
        'duration': '5:45',
        'category': 'Motivasi Hidup',
        'categoryColor': const Color(0xFFCCD5AE),
        'thumbnail':
            'https://images.unsplash.com/photo-1465146633011-14f8e0781093?w=400&h=300&fit=crop',
        'videoUrl': 'https://www.example.com/video13.mp4',
        'description': 'Bersyukur adalah kunci kebahagiaan dalam hidup.',
      },
      // Quotes Inspiratif
      {
        'title': 'Quotes Motivasi dari Tokoh Dunia',
        'duration': '4:15',
        'category': 'Quotes Inspiratif',
        'categoryColor': const Color(0xFF2C2C2C),
        'thumbnail':
            'https://images.unsplash.com/photo-1455849318743-b2233052fcff?w=400&h=300&fit=crop',
        'videoUrl': 'https://www.example.com/video14.mp4',
        'description': 'Kata-kata bijak dari tokoh dunia yang menginspirasi.',
      },
      {
        'title': 'Kata-kata Bijak Penuh Makna',
        'duration': '6:00',
        'category': 'Quotes Inspiratif',
        'categoryColor': const Color(0xFF2C2C2C),
        'thumbnail':
            'https://images.unsplash.com/photo-1604480132736-44c188fe4d20?w=400&h=300&fit=crop',
        'videoUrl': 'https://www.example.com/video15.mp4',
        'description': 'Quotes penuh makna untuk inspirasi harian.',
      },
      // Sukses Bisnis
      {
        'title': 'Langkah Kecil Raih Bisnis Besar',
        'duration': '12:30',
        'category': 'Sukses Bisnis',
        'categoryColor': const Color(0xFF6B8B6B),
        'thumbnail':
            'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=400&h=300&fit=crop',
        'videoUrl': 'https://www.example.com/video16.mp4',
        'description':
            'Mulai bisnis dari langkah kecil untuk hasil yang besar.',
      },
      {
        'title': 'Mindset Entrepreneur Sukses',
        'duration': '9:45',
        'category': 'Sukses Bisnis',
        'categoryColor': const Color(0xFF6B8B6B),
        'thumbnail':
            'https://images.unsplash.com/photo-1553877522-43269d4ea984?w=400&h=300&fit=crop',
        'videoUrl': 'https://www.example.com/video17.mp4',
        'description': 'Pola pikir yang harus dimiliki setiap entrepreneur.',
      },
      {
        'title': 'Cara Memulai Bisnis dari Nol',
        'duration': '11:20',
        'category': 'Sukses Bisnis',
        'categoryColor': const Color(0xFF6B8B6B),
        'thumbnail':
            'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=400&h=300&fit=crop',
        'videoUrl': 'https://www.example.com/video18.mp4',
        'description': 'Panduan lengkap memulai bisnis dari nol hingga sukses.',
      },
    ];
  }
}
