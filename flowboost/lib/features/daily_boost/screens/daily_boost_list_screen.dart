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
    final List<Map<String, String>> videos = _getVideosByCategory(categoryName);

    return Scaffold(
      backgroundColor: const Color(0xFFFEFAE0),
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
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: videos.isEmpty
          ? Center(
              child: Text(
                'Belum ada video tersedia',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
            )
          : ListView.builder(
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
                  description: video['description']!,
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
    required String description,
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
            color: categoryColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail Section with Enhanced Styling
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: thumbnail,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              categoryColor.withValues(alpha: 0.3),
                              categoryColor.withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              categoryColor,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              categoryColor.withValues(alpha: 0.3),
                              categoryColor.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              color: categoryColor,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Thumbnail tidak tersedia',
                              style: TextStyle(
                                color: categoryColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                  // Play Button
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Duration Badge
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            duration,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Video Number Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(8),
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
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Content Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Description
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withValues(alpha: 0.65),
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Stats and Action
                    Row(
                      children: [
                        // Views Count
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEFAE0),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: categoryColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.remove_red_eye_outlined,
                                size: 14,
                                color: categoryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${_formatViews((index + 1) * 1234)} views',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: categoryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Watch Now Button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: categoryColor.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Tonton',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
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
    );
  }

  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    }
    return views.toString();
  }

  List<Map<String, String>> _getVideosByCategory(String category) {
    switch (category) {
      case 'Motivasi Kerja':
        return [
          {
            'title': 'Bangkit Kerja Menang',
            'duration': '5:24',
            'thumbnail':
                'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=300&fit=crop',
            'videoUrl':
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
            'description':
                'Video motivasi powerful untuk meningkatkan semangat kerja dan produktivitas Anda. Pelajari cara menghadapi tantangan di tempat kerja dengan mindset positif, strategi manajemen waktu yang efektif, dan tips membangun relasi profesional yang baik dengan rekan kerja dan atasan.',
          },
          {
            'title': '5 Cara Meningkatkan Produktivitas Kerja',
            'duration': '7:15',
            'thumbnail':
                'https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?w=400&h=300&fit=crop',
            'videoUrl':
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
            'description':
                'Temukan 5 strategi terbukti untuk meningkatkan produktivitas kerja Anda hingga 200%. Dari teknik time blocking, menghilangkan distraksi, optimalisasi energi harian, hingga cara mengatur prioritas dengan metode Eisenhower Matrix. Cocok untuk professional di semua level karir.',
          },
          {
            'title': 'Mindset Sukses di Tempat Kerja',
            'duration': '6:30',
            'thumbnail':
                'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=400&h=300&fit=crop',
            'videoUrl':
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
            'description':
                'Bangun mindset growth yang tepat untuk meraih kesuksesan karir jangka panjang. Video ini membahas cara mengubah pola pikir dari fixed mindset ke growth mindset, menghadapi kegagalan sebagai pembelajaran, dan membangun resiliensi mental di lingkungan kerja yang kompetitif.',
          },
          {
            'title': 'Tips Menghadapi Bos yang Sulit',
            'duration': '8:45',
            'thumbnail':
                'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&h=300&fit=crop',
            'videoUrl':
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
            'description':
                'Panduan lengkap menghadapi atasan yang demanding dengan cara profesional dan efektif. Pelajari teknik komunikasi asertif, cara menetapkan boundaries yang sehat, strategi memahami ekspektasi bos, dan tips menjaga keseimbangan mental di tengah tekanan kerja yang tinggi.',
          },
        ];
      case 'Motivasi Pagi':
        return [
          {
            'title': 'Rutinitas Pagi Orang Sukses',
            'duration': '4:30',
            'thumbnail':
                'https://images.unsplash.com/photo-1495195134817-aeb325a55b65?w=400&h=300&fit=crop',
            'videoUrl':
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
            'description':
                'Kupas tuntas morning routine dari CEO dan entrepreneur sukses dunia seperti Tim Cook, Jeff Bezos, dan Richard Branson. Video ini mengungkap rahasia produktivitas tinggi mereka melalui kebiasaan pagi yang konsisten: bangun lebih awal, meditasi, olahraga, journaling, dan perencanaan hari yang strategis.',
          },
          {
            'title': 'Bangun Pagi Penuh Semangat',
            'duration': '5:15',
            'thumbnail':
                'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=400&h=300&fit=crop',
            'videoUrl':
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
            'description':
                'Mulai hari dengan energi positif maksimal! Dapatkan tips praktis untuk bangun pagi dengan semangat: teknik sleep hygiene yang benar, cara mengatur alarm yang efektif, power breakfast untuk energi sepanjang hari, morning stretch routine 10 menit, dan mindfulness practice untuk mental clarity.',
          },
          {
            'title': 'Afirmasi Positif Setiap Pagi',
            'duration': '3:20',
            'thumbnail':
                'https://images.unsplash.com/photo-1513151233558-d860c5398176?w=400&h=300&fit=crop',
            'videoUrl':
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
            'description':
                'Kumpulan afirmasi positif powerful yang sudah terbukti secara ilmiah dapat meningkatkan mood dan mindset Anda hingga 85%. Ikuti guided morning affirmation ini setiap hari untuk memprogram ulang subconscious mind Anda, meningkatkan self-confidence, dan menciptakan hari yang produktif dan penuh berkah.',
          },
        ];
      case 'Motivasi Belajar':
        return [
          {
            'title': 'Cara Belajar Efektif dan Efisien',
            'duration': '9:10',
            'thumbnail':
                'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=400&h=300&fit=crop',
            'videoUrl':
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
            'description':
                'Master teknik belajar modern yang digunakan oleh mahasiswa top universitas dunia. Video ini mengajarkan metode active recall, spaced repetition, Feynman technique untuk pemahaman mendalam, mind mapping untuk visualisasi konsep kompleks, dan cara mengoptimalkan retensi informasi jangka panjang hingga 400%.',
          },
          {
            'title': 'Teknik Pomodoro untuk Belajar',
            'duration': '6:40',
            'thumbnail':
                'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=400&h=300&fit=crop',
            'videoUrl':
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
            'description':
                'Panduan lengkap mengimplementasikan Pomodoro Technique untuk meningkatkan fokus dan produktivitas belajar. Pelajari cara mengatur sesi belajar 25 menit yang intens, optimalisasi break time 5 menit, strategi deep work untuk materi sulit, dan tips menghilangkan prokrastinasi saat belajar.',
          },
          {
            'title': 'Motivasi Belajar Tanpa Batas',
            'duration': '7:55',
            'thumbnail':
                'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=400&h=300&fit=crop',
            'videoUrl':
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
            'description':
                'Kisah inspiratif dari self-taught learners yang berhasil menguasai skill kompleks secara otodidak. Video ini membahas growth mindset dalam pembelajaran, cara membangun habit belajar yang konsisten, mengatasi learning plateau, menghadapi materi yang sulit dengan growth mindset, dan tips mempertahankan motivasi belajar jangka panjang.',
          },
        ];
      case 'Motivasi Hidup':
        return [
          {
            'title': 'Hidup Adalah Pilihan',
            'duration': '10:20',
            'thumbnail':
                'https://images.unsplash.com/photo-1500021804447-2ca2eaaaabeb?w=400&h=300&fit=crop',
            'videoUrl':
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4',
            'description':
                'Refleksi mendalam tentang kekuatan pilihan dalam hidup. Setiap keputusan yang kamu buat, sekecil apapun, membentuk masa depanmu. Video ini membahas konsep personal responsibility, cara mengambil keputusan yang aligned dengan nilai hidup, teknik decision making yang efektif, dan bagaimana pilihan hari ini menciptakan realitas masa depan.',
          },
          {
            'title': 'Bangkit dari Kegagalan',
            'duration': '8:30',
            'thumbnail':
                'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?w=400&h=300&fit=crop',
            'videoUrl':
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
            'description':
                'Kegagalan adalah guru terbaik menuju kesuksesan sejati. Dengarkan kisah inspiratif tokoh-tokoh sukses dunia yang pernah mengalami kegagalan besar: Steve Jobs yang dipecat dari Apple, J.K. Rowling yang ditolak 12 penerbit, dan Walt Disney yang bangkrut berkali-kali. Pelajari cara reframing failure, membangun resiliensi, dan bangkit lebih kuat.',
          },
          {
            'title': 'Syukuri Hidupmu',
            'duration': '5:45',
            'thumbnail':
                'https://images.unsplash.com/photo-1465146633011-14f8e0781093?w=400&h=300&fit=crop',
            'videoUrl':
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4',
            'description':
                'Bersyukur adalah kunci kebahagiaan dan abundance dalam hidup. Video ini membahas science of gratitude, bagaimana rasa syukur mengubah brain chemistry untuk kebahagiaan, teknik daily gratitude practice yang terbukti meningkatkan life satisfaction hingga 25%, dan cara mengembangkan mindset abundance di tengah tantangan hidup.',
          },
        ];
      case 'Quotes Inspiratif':
        return [
          {
            'title': 'Quotes Motivasi dari Tokoh Dunia',
            'duration': '4:15',
            'thumbnail':
                'https://images.unsplash.com/photo-1455849318743-b2233052fcff?w=400&h=300&fit=crop',
            'videoUrl':
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
            'description':
                'Koleksi kata-kata bijak powerful dari tokoh-tokoh paling berpengaruh di dunia: Nelson Mandela tentang kepemimpinan dan keberanian, Albert Einstein tentang kreativitas dan inovasi, Mother Teresa tentang compassion dan service, Steve Jobs tentang innovation dan following your heart. Setiap quote dilengkapi dengan story dan context yang mendalam.',
          },
          {
            'title': 'Kata-kata Bijak Penuh Makna',
            'duration': '6:00',
            'thumbnail':
                'https://images.unsplash.com/photo-1604480132736-44c188fe4d20?w=400&h=300&fit=crop',
            'videoUrl':
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
            'description':
                'Quotes inspiratif yang akan mengubah perspektif hidupmu secara fundamental. Video ini menyajikan wisdom dari berbagai tradisi dan filsafat: stoicism tentang mental toughness, buddhism tentang mindfulness dan inner peace, modern psychology tentang growth dan happiness, dilengkapi analisis mendalam dan aplikasi praktis di kehidupan sehari-hari.',
          },
        ];
      case 'Sukses Bisnis':
        return [
          {
            'title': 'Langkah Kecil Raih Bisnis Besar',
            'duration': '12:30',
            'thumbnail':
                'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=400&h=300&fit=crop',
            'videoUrl':
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
            'description':
                'Blueprint lengkap membangun bisnis besar dari langkah kecil. Video ini membahas lean startup methodology, cara validasi ide bisnis dengan MVP, strategi bootstrap untuk growth tanpa investor, customer development process, product-market fit, dan scaling strategy yang sustainable. Real case study dari startup unicorn yang memulai dari garasi.',
          },
          {
            'title': 'Mindset Entrepreneur Sukses',
            'duration': '9:45',
            'thumbnail':
                'https://images.unsplash.com/photo-1553877522-43269d4ea984?w=400&h=300&fit=crop',
            'videoUrl':
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
            'description':
                'Cara berpikir entrepreneur sukses yang membedakan mereka dari yang lain. Pelajari abundance mindset vs scarcity mindset, long-term thinking dalam business strategy, calculated risk-taking, dealing with uncertainty, continuous learning mindset, dan cara membangun network yang powerful. Interview eksklusif dengan founder successful startups.',
          },
          {
            'title': 'Cara Memulai Bisnis dari Nol',
            'duration': '11:20',
            'thumbnail':
                'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=400&h=300&fit=crop',
            'videoUrl':
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
            'description':
                'Panduan step-by-step komprehensif memulai bisnis dari nol dengan modal minimal. Mulai dari ide bisnis validation, market research yang efektif, creating business model canvas, building minimum viable product, customer acquisition strategy, monetization framework, hingga legal dan financial setup. Bonus: 50+ tools gratis untuk entrepreneur pemula.',
          },
        ];
      default:
        return [];
    }
  }
}
