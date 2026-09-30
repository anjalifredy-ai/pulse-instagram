import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_theme.dart';

/// Full-screen vertical Reels-style player (Instagram behavior)
class ReelPlayerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> videos;
  final int initialIndex;

  const ReelPlayerScreen({
    super.key,
    required this.videos,
    this.initialIndex = 0,
  });

  @override
  State<ReelPlayerScreen> createState() => _ReelPlayerScreenState();
}

class _ReelPlayerScreenState extends State<ReelPlayerScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  static const _fallbackMp4s = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.videos.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _urlFor(int index) {
    final v = widget.videos[index];
    final url = v['videoUrl'] as String? ?? v['url'] as String?;
    if (url != null && url.isNotEmpty && url.endsWith('.mp4')) return url;
    return _fallbackMp4s[index % _fallbackMp4s.length];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videos.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('No shorts', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.videos.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (context, index) {
          final data = widget.videos[index];
          return _ReelPage(
            key: ValueKey('reel_$index\_${data['videoId']}'),
            videoUrl: _urlFor(index),
            title: data['title'] as String? ?? '',
            channelTitle: data['channelTitle'] as String? ?? '',
            isActive: index == _currentIndex,
            onClose: () => Navigator.pop(context),
          );
        },
      ),
    );
  }
}

class _ReelPage extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String channelTitle;
  final bool isActive;
  final VoidCallback onClose;

  const _ReelPage({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.channelTitle,
    required this.isActive,
    required this.onClose,
  });

  @override
  State<_ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<_ReelPage> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _error = false;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final c = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      _controller = c;
      await c.initialize();
      await c.setLooping(true);
      await c.setVolume(1.0);
      if (widget.isActive) await c.play();
      if (mounted) setState(() => _ready = true);
    } catch (e) {
      debugPrint('Reel play error: $e');
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  void didUpdateWidget(covariant _ReelPage old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _controller?.play();
    } else if (!widget.isActive && old.isActive) {
      _controller?.pause();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggle() {
    final c = _controller;
    if (c == null || !_ready) return;
    if (c.value.isPlaying) {
      c.pause();
    } else {
      c.play();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video layer
        if (_ready && _controller != null && _controller!.value.isInitialized)
          GestureDetector(
            onTap: _toggle,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          )
        else if (_error)
          Container(
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.white54, size: 48),
                  SizedBox(height: 12),
                  Text('Could not play', style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),
          )
        else
          Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          ),

        // Top bar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: widget.onClose,
                ),
                const Text(
                  'Reels',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ],
            ),
          ),
        ),

        // Bottom gradient
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 220,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                ),
              ),
            ),
          ),
        ),

        // Right actions
        Positioned(
          right: 10,
          bottom: 100,
          child: Column(
            children: [
              IconButton(
                onPressed: () => setState(() => _liked = !_liked),
                icon: Icon(
                  _liked ? Icons.favorite : Icons.favorite_border,
                  color: _liked ? Colors.red : Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 28),
              const SizedBox(height: 14),
              const Icon(Icons.send_outlined, color: Colors.white, size: 28),
              const SizedBox(height: 14),
              const Icon(Icons.more_vert, color: Colors.white, size: 28),
            ],
          ),
        ),

        // Caption
        Positioned(
          left: 16,
          right: 70,
          bottom: 36,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.channelTitle,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                widget.title,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
