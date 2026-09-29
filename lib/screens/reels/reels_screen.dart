import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_theme.dart';
import '../../services/youtube_service.dart';
import '../channel/channel_profile_screen.dart';

class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  final PageController _pageController = PageController();
  final YoutubeService _youtube = YoutubeService();

  List<Map<String, dynamic>> _shorts = [];
  bool _loading = true;
  int _currentIndex = 0;

  // Unique different videos — no repeat of same one
  static const _mp4s = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = <Map<String, dynamic>>[];

    try {
      final yt = await _youtube.getTrendingShorts();
      for (var i = 0; i < yt.length; i++) {
        list.add({
          'url': _mp4s[i % _mp4s.length],
          'title': yt[i]['title'] ?? 'Short ${i + 1}',
          'channelTitle': yt[i]['channelTitle'] ?? 'Creator',
          'channelId': yt[i]['channelId'] ?? '',
          'thumbnail': yt[i]['thumbnail'] ?? '',
        });
      }
    } catch (_) {}

    if (list.isEmpty) {
      for (var i = 0; i < _mp4s.length; i++) {
        list.add({
          'url': _mp4s[i],
          'title': 'Reel ${i + 1}',
          'channelTitle': 'Pulse',
          'channelId': '',
          'thumbnail': '',
        });
      }
    }

    if (mounted) {
      setState(() {
        _shorts = list;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _shorts.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (context, index) {
          return _ReelItem(
            data: _shorts[index],
            isActive: index == _currentIndex,
          );
        },
      ),
    );
  }
}

class _ReelItem extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isActive;

  const _ReelItem({required this.data, required this.isActive});

  @override
  State<_ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<_ReelItem> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final url = widget.data['url'] as String;
    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await _controller!.initialize();
      _controller!.setLooping(true);
      if (widget.isActive) _controller!.play();
      if (mounted) setState(() => _ready = true);
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant _ReelItem old) {
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

  @override
  Widget build(BuildContext context) {
    final title = widget.data['title'] as String? ?? '';
    final channel = widget.data['channelTitle'] as String? ?? '';
    final channelId = widget.data['channelId'] as String? ?? '';

    return Stack(
      fit: StackFit.expand,
      children: [
        if (_ready && _controller != null)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          )
        else
          Container(
            color: Colors.grey[900],
            child: const Center(child: CircularProgressIndicator(color: Colors.white38)),
          ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 200,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withValues(alpha: 0.75), Colors.transparent],
              ),
            ),
          ),
        ),

        Positioned(
          right: 12,
          bottom: 120,
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
              const SizedBox(height: 16),
              const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 28),
              const SizedBox(height: 16),
              const Icon(Icons.send_outlined, color: Colors.white, size: 28),
              const SizedBox(height: 16),
              const Icon(Icons.more_vert, color: Colors.white, size: 28),
            ],
          ),
        ),

        Positioned(
          left: 16,
          right: 80,
          bottom: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  if (channelId.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChannelProfileScreen(
                          channelId: channelId,
                          initialTitle: channel,
                        ),
                      ),
                    );
                  }
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.primary,
                      child: Text(
                        channel.isNotEmpty ? channel[0].toUpperCase() : 'P',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        channel,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white70),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Follow',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),

        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              if (_controller == null) return;
              if (_controller!.value.isPlaying) {
                _controller!.pause();
              } else {
                _controller!.play();
              }
              setState(() {});
            },
            behavior: HitTestBehavior.translucent,
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}
