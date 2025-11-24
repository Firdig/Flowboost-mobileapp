import 'package:flutter/material.dart';
import 'dart:async';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({Key? key}) : super(key: key);

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  Timer? _timer;
  int _seconds = 300; // 5 minutes = 300 seconds
  bool _isPlaying = false;
  String _selectedMusic = 'Peaceful Nature Sounds';

  void _startTimer() {
    setState(() => _isPlaying = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
      _seconds = 300; // Reset to 5 minutes
    });
  }

  void _showMusicSelector() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFFE8E8D0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Choose Background Music',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildMusicOption('🍃', 'Peaceful Nature Sounds'),
              const SizedBox(height: 8),
              _buildMusicOption('🌊', 'Ocean Waves'),
              const SizedBox(height: 8),
              _buildMusicOption('⛈️', 'Rain & Thunder'),
              const SizedBox(height: 8),
              _buildMusicOption('🦜', 'Forest Birds'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMusicOption(String emoji, String title) {
    bool isSelected = _selectedMusic == title;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedMusic = title);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5DC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, size: 20),
          ],
        ),
      ),
    );
  }

  String _formatTime() {
    int minutes = _seconds ~/ 60;
    int seconds = _seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC8C89F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'BACK',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Title with icon
            Row(
              children: [
                Icon(Icons.self_improvement, size: 24),
                SizedBox(width: 8),
                Text(
                  '5-MINUTE MEDITATION',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Breathing Circle
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black54, width: 2),
                color: const Color(0xFFE8E8D0),
              ),
              child: const Center(
                child: Text(
                  '[Breathing Circle]\nInhale • Exhale',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Instructions
            const Text(
              'Close your eyes and focus on your breath.\nInhale deeply through your nose,\nexhale slowly through your mouth.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Timer
            Text(
              _formatTime(),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              width: double.infinity,
              color: Colors.black,
            ),
            const SizedBox(height: 32),

            // Currently Playing
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8D0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.music_note, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Currently Playing:',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                        Text(
                          _selectedMusic,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5DC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.music_note, size: 20),
                      padding: EdgeInsets.zero,
                      onPressed: _showMusicSelector,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Control Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isPlaying ? null : _startTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8E8D0),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_arrow,
                          size: 20,
                          color: _isPlaying ? Colors.black38 : Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PLAY',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _isPlaying ? Colors.black38 : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isPlaying ? _stopTimer : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8E8D0),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.stop,
                          size: 20,
                          color: !_isPlaying ? Colors.black38 : Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'END',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: !_isPlaying ? Colors.black38 : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}