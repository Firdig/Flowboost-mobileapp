import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// Favorite Manager - Simple in-memory storage dengan timestamp
class VideoFavoriteManager {
  static final List<Map<String, dynamic>> _favorites = [];

  // Enhanced: Add listeners for favorite changes
  static final StreamController<List<Map<String, dynamic>>>
  _favoritesController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  static Stream<List<Map<String, dynamic>>> get favoritesStream =>
      _favoritesController.stream;

  static List<Map<String, dynamic>> get favorites => _favorites;

  static bool isFavorite(String videoUrl) {
    try {
      return _favorites.any((video) => video['videoUrl'] == videoUrl);
    } catch (e) {
      debugPrint('Error checking favorite: $e');
      return false;
    }
  }

  static void addFavorite(Map<String, dynamic> video) {
    try {
      if (!isFavorite(video['videoUrl']!)) {
        // Tambahkan timestamp saat video ditambahkan ke favorit
        video['addedAt'] = DateTime.now().millisecondsSinceEpoch;

        // Enhanced: Add more metadata
        video['favoriteId'] = DateTime.now().millisecondsSinceEpoch.toString();
        video['platform'] = 'FlowBoost';
        video['category'] = 'Daily Boost';

        _favorites.add(video);
        _notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding favorite: $e');
    }
  }

  static void removeFavorite(String videoUrl) {
    try {
      _favorites.removeWhere((video) => video['videoUrl'] == videoUrl);
      _notifyListeners();
    } catch (e) {
      debugPrint('Error removing favorite: $e');
    }
  }

  static void clearAll() {
    try {
      _favorites.clear();
      _notifyListeners();
    } catch (e) {
      debugPrint('Error clearing favorites: $e');
    }
  }

  static int get count => _favorites.length;

  // Enhanced: Get favorites sorted by date
  static List<Map<String, dynamic>> getFavoritesSortedByDate({
    bool ascending = false,
  }) {
    try {
      final sortedList = List<Map<String, dynamic>>.from(_favorites);
      sortedList.sort((a, b) {
        final aTime = a['addedAt'] as int? ?? 0;
        final bTime = b['addedAt'] as int? ?? 0;
        return ascending ? aTime.compareTo(bTime) : bTime.compareTo(aTime);
      });
      return sortedList;
    } catch (e) {
      debugPrint('Error sorting favorites: $e');
      return _favorites;
    }
  }

  // Enhanced: Search favorites
  static List<Map<String, dynamic>> searchFavorites(String query) {
    try {
      if (query.isEmpty) return _favorites;

      return _favorites.where((video) {
        final title = (video['title'] as String? ?? '').toLowerCase();
        final description = (video['description'] as String? ?? '')
            .toLowerCase();
        final searchQuery = query.toLowerCase();

        return title.contains(searchQuery) || description.contains(searchQuery);
      }).toList();
    } catch (e) {
      debugPrint('Error searching favorites: $e');
      return _favorites;
    }
  }

  // Enhanced: Get favorite by URL
  static Map<String, dynamic>? getFavoriteByUrl(String videoUrl) {
    try {
      return _favorites.firstWhere(
        (video) => video['videoUrl'] == videoUrl,
        orElse: () => {},
      );
    } catch (e) {
      debugPrint('Error getting favorite by URL: $e');
      return null;
    }
  }

  static void _notifyListeners() {
    _favoritesController.add(_favorites);
  }

  // Enhanced: Dispose resources
  static void dispose() {
    _favoritesController.close();
  }
}

class VideoShareDialog {
  // Enhanced: Make it return Future for better async handling
  static Future<void> showShareDialog(
    BuildContext context,
    String videoTitle,
    String videoUrl,
  ) async {
    if (!context.mounted) return;

    try {
      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        enableDrag: true,
        isDismissible: true,
        builder: (context) =>
            _ShareBottomSheet(videoTitle: videoTitle, videoUrl: videoUrl),
      );
    } catch (e) {
      debugPrint('Error showing share dialog: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(child: Text('Gagal membuka menu share')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
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

  // Enhanced: Make it return Future for better async handling
  static Future<void> showDownloadDialog(
    BuildContext context,
    String videoTitle,
  ) async {
    if (!context.mounted) return;

    try {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => _DownloadDialog(videoTitle: videoTitle),
      );
    } catch (e) {
      debugPrint('Error showing download dialog: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(child: Text('Gagal membuka menu download')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
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

// Enhanced: Separate widget for Share Bottom Sheet with animations
class _ShareBottomSheet extends StatefulWidget {
  final String videoTitle;
  final String videoUrl;

  const _ShareBottomSheet({required this.videoTitle, required this.videoUrl});

  @override
  State<_ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<_ShareBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isCopying = false;
  int _selectedShareOption = -1;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleCopyLink() async {
    if (_isCopying) return;

    setState(() {
      _isCopying = true;
      _selectedShareOption = 0;
    });

    try {
      await Clipboard.setData(ClipboardData(text: widget.videoUrl));

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Link berhasil disalin!',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFFCCD5AE),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error copying link: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(child: Text('Gagal menyalin link')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCopying = false;
          _selectedShareOption = -1;
        });
      }
    }
  }

  void _handleShareOption(int index, String platform) {
    setState(() {
      _selectedShareOption = index;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.open_in_new, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text('Membuka $platform...')),
              ],
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFEFAE0), // Background - Krem sangat terang
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: SafeArea(
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

                // Title with icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCD5AE).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.share_rounded,
                        size: 20,
                        color: Color(0xFF8B9556),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Bagikan Video',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Video title
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9EDC9).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFCCD5AE).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.video_library,
                        size: 16,
                        color: Color(0xFF8B9556),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.videoTitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Share options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildEnhancedShareOption(
                      context,
                      icon: _isCopying ? Icons.hourglass_empty : Icons.link,
                      label: 'Salin Link',
                      color: const Color(0xFFCCD5AE),
                      onTap: _isCopying ? null : _handleCopyLink,
                      isSelected: _selectedShareOption == 0,
                      isLoading: _isCopying,
                    ),
                    _buildEnhancedShareOption(
                      context,
                      icon: Icons.chat,
                      label: 'WhatsApp',
                      color: const Color(0xFF25D366),
                      onTap: () => _handleShareOption(1, 'WhatsApp'),
                      isSelected: _selectedShareOption == 1,
                    ),
                    _buildEnhancedShareOption(
                      context,
                      icon: Icons.telegram,
                      label: 'Telegram',
                      color: const Color(0xFF0088CC),
                      onTap: () => _handleShareOption(2, 'Telegram'),
                      isSelected: _selectedShareOption == 2,
                    ),
                    _buildEnhancedShareOption(
                      context,
                      icon: Icons.more_horiz,
                      label: 'Lainnya',
                      color: const Color(0xFF8B8B8B),
                      onTap: () => _handleShareOption(3, 'aplikasi lainnya'),
                      isSelected: _selectedShareOption == 3,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Additional options
                _buildAdditionalOptions(context),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
    bool isSelected = false,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(18),
                      child: CircularProgressIndicator(
                        color: color,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalOptions(BuildContext context) {
    return Column(
      children: [
        _buildAdditionalOptionItem(
          icon: Icons.qr_code,
          label: 'Bagikan via QR Code',
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Expanded(child: Text('Fitur QR Code segera hadir!')),
                  ],
                ),
                backgroundColor: const Color(0xFF8B9556),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        _buildAdditionalOptionItem(
          icon: Icons.email_outlined,
          label: 'Bagikan via Email',
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.email, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Expanded(child: Text('Membuka aplikasi email...')),
                  ],
                ),
                backgroundColor: const Color(0xFF8B9556),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalOptionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFCCD5AE).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCD5AE).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF8B9556)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced: Separate widget for Download Dialog with animations
class _DownloadDialog extends StatefulWidget {
  final String videoTitle;

  const _DownloadDialog({required this.videoTitle});

  @override
  State<_DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<_DownloadDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  int _selectedQuality = -1;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleDownload(String quality, int index) async {
    if (_isDownloading) return;

    setState(() {
      _selectedQuality = index;
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      // Simulate download progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 150));
        if (!mounted) return;

        setState(() {
          _downloadProgress = i / 100;
        });
      }

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.download_done, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text('Video berhasil diunduh ($quality)!')),
              ],
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'Buka',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Membuka file...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error downloading: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(child: Text('Gagal mengunduh video')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _selectedQuality = -1;
          _downloadProgress = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        backgroundColor: const Color(
          0xFFFEFAE0,
        ), // Dialog background - Krem sangat terang
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFCCD5AE).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.download,
                color: Color(0xFFCCD5AE),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Download Video',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video title
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE9EDC9).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.video_library,
                    size: 16,
                    color: Color(0xFF8B9556),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.videoTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Pilih kualitas video:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),

            // Quality options
            _buildEnhancedQualityOption(
              quality: '1080p (Full HD)',
              size: '85 MB',
              icon: Icons.hd,
              recommended: true,
              index: 0,
            ),
            const SizedBox(height: 8),
            _buildEnhancedQualityOption(
              quality: '720p (HD)',
              size: '45 MB',
              icon: Icons.hd,
              index: 1,
            ),
            const SizedBox(height: 8),
            _buildEnhancedQualityOption(
              quality: '480p',
              size: '25 MB',
              icon: Icons.sd,
              index: 2,
            ),
            const SizedBox(height: 8),
            _buildEnhancedQualityOption(
              quality: '360p',
              size: '15 MB',
              icon: Icons.phone_android,
              index: 3,
            ),

            // Download progress
            if (_isDownloading) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9EDC9).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mengunduh...',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B9556),
                          ),
                        ),
                        Text(
                          '${(_downloadProgress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B9556),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _downloadProgress,
                        backgroundColor: Colors.black.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFCCD5AE),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isDownloading ? null : () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(
                color: _isDownloading ? Colors.black26 : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedQualityOption({
    required String quality,
    required String size,
    required IconData icon,
    required int index,
    bool recommended = false,
  }) {
    final isSelected = _selectedQuality == index;
    final isDisabled = _isDownloading && !isSelected;

    return InkWell(
      onTap: isDisabled ? null : () => _handleDownload(quality, index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFCCD5AE).withValues(alpha: 0.3)
              : const Color(
                  0xFFE9EDC9,
                ).withValues(alpha: isDisabled ? 0.3 : 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFCCD5AE)
                : const Color(0xFFCCD5AE).withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDisabled ? Colors.black26 : const Color(0xFF8B9556),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        quality,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDisabled ? Colors.black26 : Colors.black87,
                        ),
                      ),
                      if (recommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCD5AE),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Rekomendasi',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    size,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDisabled
                          ? Colors.black26
                          : Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected && _isDownloading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Color(0xFF8B9556),
                  strokeWidth: 2,
                ),
              )
            else
              Icon(
                isSelected ? Icons.download : Icons.arrow_forward_ios,
                size: 16,
                color: isDisabled ? Colors.black12 : Colors.black26,
              ),
          ],
        ),
      ),
    );
  }
}
