import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/daily_boost_share_dialog.dart';

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
    with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool isPlayerReady = false;
  bool isFavorite = false;
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsAnimation;

  // Enhanced error handling states
  bool hasError = false;
  String errorMessage = '';
  bool isLoading = true;
  bool isRetrying = false;
  int retryCount = 0;
  final int maxRetries = 3;

  // Animation controllers for enhanced UI
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;

  // Interactive states
  bool isDescriptionExpanded = false;
  bool showFullDescription = false;
  int selectedRelatedVideoIndex = -1;
  bool isShareMenuOpen = false;
  bool isDownloading = false;
  double downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _checkFavoriteStatus();
    _setupAnimations();
    _setupEnhancedAnimations();
  }

  Future<void> _initializePlayer() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      if (widget.videoUrl.isEmpty) {
        throw Exception('URL video tidak valid');
      }

      await _checkInternetConnection();

      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _videoController.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
            'Timeout: Gagal memuat video. Periksa koneksi internet Anda.',
          );
        },
      );

      if (_videoController.value.hasError) {
        throw Exception('Video tidak dapat diputar. Format tidak didukung.');
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoController.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF6C63FF), // Updated Theme Color
          handleColor: const Color(0xFF6C63FF),
          backgroundColor: Colors.grey.withOpacity(0.5),
          bufferedColor: const Color(0xFF6C63FF).withOpacity(0.3),
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
          ),
        ),
        autoInitialize: true,
        errorBuilder: (context, errorMessage) {
          return _buildVideoError(errorMessage);
        },
      );

      _videoController.addListener(_videoListener);

      setState(() {
        isPlayerReady = true;
        isLoading = false;
        hasError = false;
        retryCount = 0;
      });

      if (mounted) {
        _showCustomSnackBar(
          'Video berhasil dimuat!',
          Icons.check_circle,
          const Color(0xFF4CAF50),
        );
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      setState(() {
        hasError = true;
        errorMessage = _getErrorMessage(e);
        isLoading = false;
        isPlayerReady = false;
      });

      _showCustomSnackBar(
        'Gagal memuat video',
        Icons.error_outline,
        Colors.red,
      );
    }
  }

  Future<void> _checkInternetConnection() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  String _getErrorMessage(dynamic error) {
    String errorStr = error.toString().toLowerCase();

    if (errorStr.contains('timeout')) {
      return 'Koneksi terlalu lambat. Periksa internet Anda.';
    } else if (errorStr.contains('network') || errorStr.contains('socket')) {
      return 'Tidak ada koneksi internet. Periksa WiFi atau data seluler Anda.';
    } else if (errorStr.contains('format') || errorStr.contains('codec')) {
      return 'Format video tidak didukung.';
    } else if (errorStr.contains('404') || errorStr.contains('not found')) {
      return 'Video tidak ditemukan.';
    } else if (errorStr.contains('invalid')) {
      return 'URL video tidak valid.';
    } else {
      return 'Terjadi kesalahan saat memuat video.';
    }
  }

  void _videoListener() {
    if (!mounted) return;

    try {
      if (_videoController.value.hasError) {
        setState(() {
          hasError = true;
          errorMessage = 'Terjadi kesalahan saat memutar video';
        });
        return;
      }

      if (_videoController.value.position == _videoController.value.duration &&
          _videoController.value.duration.inSeconds > 0) {
        _showCompletionDialog();
      }
    } catch (e) {
      debugPrint('Error in video listener: $e');
    }
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

  void _setupEnhancedAnimations() {
    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );

    _slideAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideAnimationController,
            curve: Curves.easeOut,
          ),
        );

    _scaleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimationController.forward();
    _slideAnimationController.forward();
    _scaleAnimationController.forward();
  }

  Future<void> _retryLoadVideo() async {
    if (retryCount >= maxRetries) {
      _showCustomSnackBar(
        'Maksimal percobaan tercapai.',
        Icons.warning,
        Colors.orange,
      );
      return;
    }

    setState(() {
      isRetrying = true;
      retryCount++;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      await _videoController.dispose();
      _chewieController?.dispose();
    } catch (e) {
      debugPrint('Error disposing controllers: $e');
    }

    await _initializePlayer();

    setState(() {
      isRetrying = false;
    });
  }

  @override
  void dispose() {
    try {
      _videoController.removeListener(_videoListener);
      _videoController.dispose();
      _chewieController?.dispose();
      _controlsAnimationController.dispose();
      _fadeAnimationController.dispose();
      _slideAnimationController.dispose();
      _scaleAnimationController.dispose();
    } catch (e) {
      debugPrint('Error disposing resources: $e');
    }
    super.dispose();
  }

  void _checkFavoriteStatus() {
    try {
      setState(() {
        isFavorite = VideoFavoriteManager.isFavorite(widget.videoUrl);
      });
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
      setState(() {
        isFavorite = false;
      });
    }
  }

  void _toggleFavorite() {
    try {
      setState(() {
        if (isFavorite) {
          VideoFavoriteManager.removeFavorite(widget.videoUrl);
          isFavorite = false;
          _showCustomSnackBar(
            'Dihapus dari favorit',
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
            'Ditambahkan ke favorit',
            Icons.favorite,
            const Color(0xFF6C63FF),
          );
        }
      });

      _scaleAnimationController.reset();
      _scaleAnimationController.forward();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      _showCustomSnackBar(
        'Gagal mengubah status',
        Icons.error_outline,
        Colors.red,
      );
    }
  }

  void _showCustomSnackBar(String message, IconData icon, Color color) {
    if (!mounted) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error showing snackbar: $e');
    }
  }

  void _showCompletionDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Color(0xFF6C63FF), size: 28),
            SizedBox(width: 12),
            Text('Video Selesai!', style: TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Selamat! Kamu sudah menonton video daily boost hari ini. Tetap semangat!',
              style: TextStyle(fontSize: 15, color: Color(0xFF5D6D7E), height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EEDD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tips_and_updates, color: Color(0xFF6C63FF), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tonton video lainnya untuk inspirasi!',
                      style: TextStyle(fontSize: 12, color: Color(0xFF2C3E50)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Tonton Lagi',
              style: TextStyle(
                color: Color(0xFF7F8C8D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Selesai',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleShare() async {
    setState(() {
      isShareMenuOpen = true;
    });

    try {
      await VideoShareDialog.showShareDialog(
        context,
        widget.videoTitle,
        widget.videoUrl,
      );
    } catch (e) {
      debugPrint('Error sharing video: $e');
      if (mounted) {
        _showCustomSnackBar(
          'Gagal membagikan video',
          Icons.error_outline,
          Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isShareMenuOpen = false;
        });
      }
    }
  }

  Future<void> _handleDownload() async {
    setState(() {
      isDownloading = true;
      downloadProgress = 0.0;
    });

    try {
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
        setState(() {
          downloadProgress = i / 100;
        });
      }

      await VideoShareDialog.showDownloadDialog(context, widget.videoTitle);

      if (mounted) {
        _showCustomSnackBar(
          'Video berhasil didownload!',
          Icons.download_done,
          Colors.green,
        );
      }
    } catch (e) {
      debugPrint('Error downloading video: $e');
      if (mounted) {
        _showCustomSnackBar(
          'Gagal mendownload video',
          Icons.error_outline,
          Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isDownloading = false;
          downloadProgress = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildVideoPlayer(),
            Expanded(child: _buildContentArea()),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(color: Colors.black, child: _buildVideoContent()),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(50),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (isLoading && !hasError)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFF6C63FF),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isRetrying
                        ? 'Mencoba lagi... ($retryCount/$maxRetries)'
                        : 'Memuat video...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoContent() {
    if (hasError) {
      return _buildVideoError(errorMessage);
    }

    if (isPlayerReady && _chewieController != null) {
      return Chewie(controller: _chewieController!);
    }

    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
    );
  }

  Widget _buildVideoError(String message) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.white54,
              ),
              const SizedBox(height: 20),
              const Text(
                'Gagal Memutar Video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: isRetrying ? null : _retryLoadVideo,
                icon: isRetrying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: Text(isRetrying ? 'Mencoba...' : 'Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentArea() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5DC), // Beige Background
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Text(
                    widget.videoTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50), // Dark Blue-Grey
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildVideoStats(),
                const SizedBox(height: 24),
                _buildActionButtons(),
                const SizedBox(height: 24),
                _buildAboutCard(),
                const SizedBox(height: 24),
                _buildRelatedVideosSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoStats() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildStatChip(
          icon: Icons.play_circle,
          label: isPlayerReady
              ? _formatDuration(_videoController.value.duration)
              : '0:00',
          color: const Color(0xFF2C3E50),
        ),
        _buildStatChip(
          icon: Icons.visibility,
          label: 'Daily Boost',
          color: const Color(0xFF7F8C8D),
        ),
        _buildStatChip(
          icon: Icons.calendar_today,
          label: 'Hari Ini',
          color: const Color(0xFF2C3E50),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
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
    );
  }

  Widget _buildActionButtons() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
              color: isFavorite ? Colors.red : const Color(0xFF2C3E50),
              onTap: _toggleFavorite,
            ),
            Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.2)),
            _buildModernActionButton(
              icon: isShareMenuOpen ? Icons.share : Icons.share_rounded,
              label: 'Share',
              color: const Color(0xFF2C3E50),
              onTap: _handleShare,
              isLoading: isShareMenuOpen,
            ),
            Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.2)),
            _buildModernActionButton(
              icon: isDownloading ? Icons.downloading : Icons.download_rounded,
              label: isDownloading
                  ? '${(downloadProgress * 100).toInt()}%'
                  : 'Unduh',
              color: const Color(0xFF2C3E50),
              onTap: isDownloading ? null : _handleDownload,
              isLoading: isDownloading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: color,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(icon, size: 24, color: color),
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
    return GestureDetector(
      onTap: () {
        setState(() {
          isDescriptionExpanded = !isDescriptionExpanded;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tentang Video Ini',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                AnimatedRotation(
                  turns: isDescriptionExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedCrossFade(
              firstChild: Text(
                _truncateText(
                  widget.description ?? 'Deskripsi tidak tersedia.',
                  100,
                ),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7F8C8D),
                  height: 1.5,
                ),
              ),
              secondChild: Text(
                widget.description ?? 'Deskripsi tidak tersedia.',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7F8C8D),
                  height: 1.5,
                ),
              ),
              crossFadeState: isDescriptionExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
            if ((widget.description?.length ?? 0) > 100)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  isDescriptionExpanded ? 'Lebih Sedikit' : 'Selengkapnya',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Widget _buildRelatedVideosSection() {
    final relatedVideos = _getRelatedVideos();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Video Terkait',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(relatedVideos.length, (index) {
          final video = relatedVideos[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < relatedVideos.length - 1 ? 16 : 0,
            ),
            child: _buildModernRelatedVideo(
              video['title']!,
              video['duration']!,
              video['views']!,
              video['thumbnail']!,
              index,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildModernRelatedVideo(
    String title,
    String duration,
    String views,
    String thumbnail,
    int index,
  ) {
    final relatedVideos = _getRelatedVideos();
    if (index >= relatedVideos.length) return const SizedBox.shrink();
    final videoData = relatedVideos[index];

    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              videoTitle: videoData['title']!,
              videoUrl: videoData['videoUrl']!,
              description: videoData['description']!,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: thumbnail,
                    width: 100,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: const Color(0xFFF3EEDD),
                      child: const Center(
                        child: Icon(Icons.image, size: 20, color: Colors.grey),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 20),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        duration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    views,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_circle_outline, color: Color(0xFF6C63FF)),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    }
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  List<Map<String, String>> _getRelatedVideos() {
    return [
      {
        'title': 'Tips Sukses Setiap Hari',
        'duration': '6:30',
        'views': '8.2K views',
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=300&fit=crop',
        'description': 'Kiat-kiat praktis untuk meraih kesuksesan setiap hari. Terapkan dalam kehidupan sehari-hari.',
      },
      {
        'title': 'Mindset Pemenang',
        'duration': '5:45',
        'views': '12.5K views',
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?w=400&h=300&fit=crop',
        'description': 'Bangun pola pikir seorang pemenang. Ubah cara pandangmu terhadap tantangan hidup.',
      },
      {
        'title': 'Raih Impianmu',
        'duration': '7:20',
        'views': '15.3K views',
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=400&h=300&fit=crop',
        'description': 'Jangan biarkan mimpimu hanya menjadi mimpi. Wujudkan dengan kerja keras dan doa.',
      },
    ];
  }
}