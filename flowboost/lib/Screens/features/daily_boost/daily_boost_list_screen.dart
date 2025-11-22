import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'daily_boost_player_screen.dart';

class VideoListScreen extends StatelessWidget {
  final String categoryName;
  final Color categoryColor;

  const VideoListScreen({
    super.key,
    required this.categoryName,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    // Daftar video dummy berdasarkan kategori
    final List<Map<String, String>> videos = _getVideosByCategory(categoryName);

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
        title: Text(
          categoryName.toUpperCase(),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return _buildVideoCard(
            context,
            index: index,
            title: video['title']!,
            duration: video['duration']!,
            thumbnail: video['thumbnail']!,
            videoUrl: video['videoUrl']!,
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
    required String thumbnail,
    required String videoUrl,
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
              builder: (context) =>
                  VideoPlayerScreen(videoTitle: title, videoUrl: videoUrl),
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

  List<Map<String, String>> _getVideosByCategory(String category) {
    // Data dummy video dengan thumbnail URL yang sesuai
    switch (category) {
      case 'Motivasi Kerja':
        return [
          {
            'title': 'Bangkit Kerja Menang',
            'duration': '5:24',
            'thumbnail':
                'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=300&fit=crop', // Team meeting
            'videoUrl': 'https://www.example.com/video1.mp4',
          },
          {
            'title': '5 Cara Meningkatkan Produktivitas Kerja',
            'duration': '7:15',
            'thumbnail':
                'https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?w=400&h=300&fit=crop', // Laptop work
            'videoUrl': 'https://www.example.com/video2.mp4',
          },
          {
            'title': 'Mindset Sukses di Tempat Kerja',
            'duration': '6:30',
            'thumbnail':
                'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=400&h=300&fit=crop', // Office collaboration
            'videoUrl': 'https://www.example.com/video3.mp4',
          },
          {
            'title': 'Tips Menghadapi Bos yang Sulit',
            'duration': '8:45',
            'thumbnail':
                'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&h=300&fit=crop', // Professional discussion
            'videoUrl': 'https://www.example.com/video4.mp4',
          },
        ];
      case 'Motivasi Pagi':
        return [
          {
            'title': 'Rutinitas Pagi Orang Sukses',
            'duration': '4:30',
            'thumbnail':
                'https://images.unsplash.com/photo-1495195134817-aeb325a55b65?w=400&h=300&fit=crop', // Morning coffee
            'videoUrl': 'https://www.example.com/video5.mp4',
          },
          {
            'title': 'Bangun Pagi Penuh Semangat',
            'duration': '5:15',
            'thumbnail':
                'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=400&h=300&fit=crop', // Sunrise
            'videoUrl': 'https://www.example.com/video6.mp4',
          },
          {
            'title': 'Afirmasi Positif Setiap Pagi',
            'duration': '3:20',
            'thumbnail':
                'https://images.unsplash.com/photo-1513151233558-d860c5398176?w=400&h=300&fit=crop', // Morning meditation
            'videoUrl': 'https://www.example.com/video7.mp4',
          },
        ];
      case 'Motivasi Belajar':
        return [
          {
            'title': 'Cara Belajar Efektif dan Efisien',
            'duration': '9:10',
            'thumbnail':
                'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=400&h=300&fit=crop', // Study desk
            'videoUrl': 'https://www.example.com/video8.mp4',
          },
          {
            'title': 'Teknik Pomodoro untuk Belajar',
            'duration': '6:40',
            'thumbnail':
                'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=400&h=300&fit=crop', // Books and notes
            'videoUrl': 'https://www.example.com/video9.mp4',
          },
          {
            'title': 'Motivasi Belajar Tanpa Batas',
            'duration': '7:55',
            'thumbnail':
                'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=400&h=300&fit=crop', // Student learning
            'videoUrl': 'https://www.example.com/video10.mp4',
          },
        ];
      case 'Motivasi Hidup':
        return [
          {
            'title': 'Hidup Adalah Pilihan',
            'duration': '10:20',
            'thumbnail':
                'https://images.unsplash.com/photo-1500021804447-2ca2eaaaabeb?w=400&h=300&fit=crop', // Mountain peak
            'videoUrl': 'https://www.example.com/video11.mp4',
          },
          {
            'title': 'Bangkit dari Kegagalan',
            'duration': '8:30',
            'thumbnail':
                'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?w=400&h=300&fit=crop', // Person standing strong
            'videoUrl': 'https://www.example.com/video12.mp4',
          },
          {
            'title': 'Syukuri Hidupmu',
            'duration': '5:45',
            'thumbnail':
                'https://images.unsplash.com/photo-1465146633011-14f8e0781093?w=400&h=300&fit=crop', // Nature peaceful
            'videoUrl': 'https://www.example.com/video13.mp4',
          },
        ];
      case 'Quotes Inspiratif':
        return [
          {
            'title': 'Quotes Motivasi dari Tokoh Dunia',
            'duration': '4:15',
            'thumbnail':
                'https://images.unsplash.com/photo-1455849318743-b2233052fcff?w=400&h=300&fit=crop', // Motivational quote
            'videoUrl': 'https://www.example.com/video14.mp4',
          },
          {
            'title': 'Kata-kata Bijak Penuh Makna',
            'duration': '6:00',
            'thumbnail':
                'https://images.unsplash.com/photo-1604480132736-44c188fe4d20?w=400&h=300&fit=crop', // Wisdom quotes
            'videoUrl': 'https://www.example.com/video15.mp4',
          },
        ];
      case 'Sukses Bisnis':
        return [
          {
            'title': 'Langkah Kecil Raih Bisnis Besar',
            'duration': '12:30',
            'thumbnail':
                'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=400&h=300&fit=crop', // Business planning
            'videoUrl': 'https://www.example.com/video16.mp4',
          },
          {
            'title': 'Mindset Entrepreneur Sukses',
            'duration': '9:45',
            'thumbnail':
                'https://images.unsplash.com/photo-1553877522-43269d4ea984?w=400&h=300&fit=crop', // Business success
            'videoUrl': 'https://www.example.com/video17.mp4',
          },
          {
            'title': 'Cara Memulai Bisnis dari Nol',
            'duration': '11:20',
            'thumbnail':
                'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=400&h=300&fit=crop', // Startup business
            'videoUrl': 'https://www.example.com/video18.mp4',
          },
        ];
      default:
        return [];
    }
  }
}
