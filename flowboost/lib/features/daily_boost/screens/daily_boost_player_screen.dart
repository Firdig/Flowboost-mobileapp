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
      // Validate URL first
      if (widget.videoUrl.isEmpty) {
        throw Exception('URL video tidak valid');
      }

      // Check internet connection simulation
      await _checkInternetConnection();

      // Initialize video player
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      // Set timeout for initialization
      await _videoController.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
            'Timeout: Gagal memuat video. Periksa koneksi internet Anda.',
          );
        },
      );

      // Check if video is valid
      if (_videoController.value.hasError) {
        throw Exception('Video tidak dapat diputar. Format tidak didukung.');
      }

      // Initialize Chewie controller
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoController.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFCCD5AE),
          handleColor: const Color(0xFFCCD5AE),
          backgroundColor: Colors.grey.withValues(alpha: 0.5),
          bufferedColor: const Color(0xFFE9EDC9),
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFFCCD5AE)),
          ),
        ),
        autoInitialize: true,
        errorBuilder: (context, errorMessage) {
          return _buildVideoError(errorMessage);
        },
      );

      // Listen to video completion
      _videoController.addListener(_videoListener);

      setState(() {
        isPlayerReady = true;
        isLoading = false;
        hasError = false;
        retryCount = 0;
      });

      // Show success message only if widget is still mounted
      if (mounted) {
        _showCustomSnackBar(
          'Video berhasil dimuat! 🎉',
          Icons.check_circle,
          Colors.green,
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

      // Show error snackbar
      _showCustomSnackBar(
        'Gagal memuat video',
        Icons.error_outline,
        Colors.red,
      );
    }
  }

  Future<void> _checkInternetConnection() async {
    // Simulate internet check - in production, use connectivity_plus package
    await Future.delayed(const Duration(milliseconds: 500));
    // Add actual connectivity check here if needed
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
      return 'Video tidak ditemukan. Mungkin sudah dihapus.';
    } else if (errorStr.contains('403') || errorStr.contains('forbidden')) {
      return 'Akses ke video ditolak.';
    } else if (errorStr.contains('invalid')) {
      return 'URL video tidak valid.';
    } else {
      return 'Terjadi kesalahan saat memuat video. Coba lagi nanti.';
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
    // Fade animation
    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );

    // Slide animation
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

    // Scale animation
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

    // Start animations
    _fadeAnimationController.forward();
    _slideAnimationController.forward();
    _scaleAnimationController.forward();
  }

  Future<void> _retryLoadVideo() async {
    if (retryCount >= maxRetries) {
      _showCustomSnackBar(
        'Maksimal percobaan tercapai. Coba lagi nanti.',
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

      // Animate favorite button
      _scaleAnimationController.reset();
      _scaleAnimationController.forward();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      _showCustomSnackBar(
        'Gagal mengubah status favorit',
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
                    fontWeight: FontWeight.w500,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Color(0xFFCCD5AE), size: 28),
            SizedBox(width: 12),
            Text('Video Selesai!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Selamat! Kamu sudah menonton video daily boost hari ini. Tetap semangat! 💪',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE9EDC9).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tips_and_updates, color: Color(0xFF8B9556)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Jangan lupa untuk menonton video lainnya!',
                      style: TextStyle(fontSize: 13, color: Color(0xFF8B9556)),
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
                color: Color(0xFF8B9556),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCCD5AE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Selesai',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
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
      // Simulate download progress
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
          'Video berhasil didownload! 📥',
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
            // Video Player
            _buildVideoPlayer(),

            // Content Area
            Expanded(child: _buildContentArea()),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Stack(
      children: [
        // Video Player Container
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(color: Colors.black, child: _buildVideoContent()),
        ),

        // Back Button with enhanced design
        Positioned(
          top: 16,
          left: 16,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(50),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
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

        // Loading indicator overlay
        if (isLoading && !hasError)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFFCCD5AE),
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
                  const SizedBox(height: 8),
                  const Text(
                    'Harap tunggu sebentar',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
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
      child: CircularProgressIndicator(color: Color(0xFFCCD5AE)),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Oops! Ada Masalah',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: isRetrying ? null : _retryLoadVideo,
                    icon: isRetrying
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(isRetrying ? 'Mencoba...' : 'Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCCD5AE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Kembali'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              if (retryCount > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    'Percobaan ke-$retryCount dari $maxRetries',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
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
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Video Title with animation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Text(
                    widget.videoTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Video Stats
                _buildVideoStats(),

                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(),

                const SizedBox(height: 28),

                // About Video
                _buildAboutCard(),

                const SizedBox(height: 28),

                // Related Videos
                _buildRelatedVideosSection(),

                // Add some bottom padding
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
          color: const Color(0xFF8B9556),
          backgroundColor: const Color(0xFFCCD5AE).withValues(alpha: 0.3),
        ),
        _buildStatChip(
          icon: Icons.visibility,
          label: 'Daily Boost',
          color: Colors.black54,
          backgroundColor: const Color(0xFFE9EDC9).withValues(alpha: 0.5),
        ),
        _buildStatChip(
          icon: Icons.calendar_today,
          label: 'Hari Ini',
          color: const Color(0xFF8B9556),
          backgroundColor: const Color(0xFFCCD5AE).withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
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
              icon: isShareMenuOpen ? Icons.share : Icons.share_rounded,
              label: 'Share',
              color: const Color(0xFF8B9556),
              onTap: _handleShare,
              isLoading: isShareMenuOpen,
            ),
            Container(width: 1, height: 40, color: Colors.black12),
            _buildModernActionButton(
              icon: isDownloading ? Icons.downloading : Icons.download_rounded,
              label: isDownloading
                  ? '${(downloadProgress * 100).toInt()}%'
                  : 'Download',
              color: const Color(0xFF8B9556),
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
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: color,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(icon, size: 24, color: color),
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
    return GestureDetector(
      onTap: () {
        setState(() {
          isDescriptionExpanded = !isDescriptionExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                AnimatedRotation(
                  turns: isDescriptionExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedCrossFade(
              firstChild: Text(
                _truncateText(
                  widget.description ??
                      'Video motivasi ini akan membantumu untuk tetap semangat dan fokus dalam mencapai tujuanmu. Jangan pernah menyerah! Terus berjuang dan raih impianmu dengan tekad yang kuat.',
                  100,
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.75),
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
              ),
              secondChild: Text(
                widget.description ??
                    'Video motivasi ini akan membantumu untuk tetap semangat dan fokus dalam mencapai tujuanmu. Jangan pernah menyerah! Terus berjuang dan raih impianmu dengan tekad yang kuat.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.75),
                  height: 1.6,
                  letterSpacing: 0.2,
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
                  isDescriptionExpanded
                      ? 'Tampilkan Lebih Sedikit'
                      : 'Baca Selengkapnya',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8B9556),
                    fontWeight: FontWeight.w600,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            TextButton(
              onPressed: () {
                _showCustomSnackBar(
                  'Fitur "Lihat Semua" segera hadir!',
                  Icons.info_outline,
                  const Color(0xFF8B9556),
                );
              },
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  color: Color(0xFF8B9556),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Dynamic related videos from data
        ...List.generate(relatedVideos.length, (index) {
          final video = relatedVideos[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < relatedVideos.length - 1 ? 12 : 0,
            ),
            child: _buildModernRelatedVideo(
              video['title']!,
              video['duration']!,
              video['views']!,
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
    int index,
  ) {
    bool isSelected = selectedRelatedVideoIndex == index;

    // Get related video data
    final relatedVideos = _getRelatedVideos();
    if (index >= relatedVideos.length) return const SizedBox.shrink();

    final videoData = relatedVideos[index];

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRelatedVideoIndex = index;
        });

        // Navigate to new video
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFCCD5AE).withValues(alpha: 0.2)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFCCD5AE) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFFCCD5AE,
              ).withValues(alpha: isSelected ? 0.3 : 0.15),
              blurRadius: isSelected ? 8 : 6,
              offset: Offset(0, isSelected ? 3 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                selectedRelatedVideoIndex = index;
              });

              // Navigate to new video
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
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Thumbnail with CachedNetworkImage
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: videoData['thumbnail']!,
                          width: 110,
                          height: 65,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 110,
                            height: 65,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(
                                    0xFFCCD5AE,
                                  ).withValues(alpha: 0.6),
                                  const Color(
                                    0xFFCCD5AE,
                                  ).withValues(alpha: 0.3),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF8B9556),
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 110,
                            height: 65,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(
                                    0xFFCCD5AE,
                                  ).withValues(alpha: 0.6),
                                  const Color(
                                    0xFFCCD5AE,
                                  ).withValues(alpha: 0.3),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 32,
                              color: Color(0xFF8B9556),
                            ),
                          ),
                        ),
                        // Play icon overlay
                        Container(
                          width: 110,
                          height: 65,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              isSelected
                                  ? Icons.play_circle
                                  : Icons.play_circle_outline,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Duration badge
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
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFE9EDC9,
                                ).withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8B9556),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
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

  // Helper function to get related videos
  List<Map<String, String>> _getRelatedVideos() {
    // Return a list of related videos from the same or similar categories
    return [
      {
        'title': 'Tips Sukses Setiap Hari',
        'duration': '6:30',
        'views': '8.2K views',
        'videoUrl':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        'thumbnail':
            'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=300&fit=crop',
        'description':
            'Kiat-kiat praktis untuk meraih kesuksesan setiap hari. Terapkan dalam kehidupan sehari-hari.',
      },
      {
        'title': 'Mindset Pemenang',
        'duration': '5:45',
        'views': '12.5K views',
        'videoUrl':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        'thumbnail':
            'https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?w=400&h=300&fit=crop',
        'description':
            'Bangun pola pikir seorang pemenang. Ubah cara pandangmu terhadap tantangan hidup.',
      },
      {
        'title': 'Raih Impianmu',
        'duration': '7:20',
        'views': '15.3K views',
        'videoUrl':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        'thumbnail':
            'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=400&h=300&fit=crop',
        'description':
            'Jangan biarkan mimpimu hanya menjadi mimpi. Wujudkan dengan kerja keras dan doa.',
      },
    ];
  }
}
