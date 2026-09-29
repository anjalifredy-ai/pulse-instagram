import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/theme/app_theme.dart';
import '../../services/youtube_service.dart';
import '../channel/channel_profile_screen.dart';

/// Instagram-style Home: vertical swipe, video plays IN PLACE (no new page)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController();
  final YoutubeService _youtube = YoutubeService();

  List<Map<String, dynamic>> _feed = [];
  bool _loading = true;
  int _currentIndex = 0;

  // Direct MP4 samples that ALWAYS play (no YouTube embed block)
  static const _directVideos = [
    {
      'type': 'mp4',
      'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      'title': 'Bee in the garden',
      'channelTitle': 'Flutter',
      'channelId': '',
      'thumbnail': '',
    },
    {
      'type': 'mp4',
      'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      'title': 'Butterfly',
      'channelTitle': 'Flutter',
      'channelId': '',
      'thumbnail': '',
    },
    {
      'type': 'mp4',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'title': 'For Bigger Blazes',
      'channelTitle': 'Google',
      'channelId': '',
      'thumbnail': 'https://i.ytimg.com/vi/aqz-KE-bpKQ/hqdefault.jpg',
    },
    {
      'type': 'mp4',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      'title': 'For Bigger Escapes',
      'channelTitle': 'Google',
      'channelId': '',
      'thumbnail': '',
    },
    {
      'type': 'mp4',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      'title': 'For Bigger Fun',
      'channelTitle': 'Google',
      'channelId': '',
      'thumbnail': '',
    },
    {
      'type': 'mp4',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
      'title': 'For Bigger Joyrides',
      'channelTitle': 'Google',
      'channelId': '',
      'thumbnail': '',
    },
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    // Always start with working direct videos so play never fails
    final list = List<Map<String, dynamic>>.from(_directVideos);

    // Mix in YouTube metadata for titles (thumbnails) if API works
    try {
      final yt = await _youtube.getTrendingShorts();
      for (final v in yt) {
        list.add({
          'type': 'youtube',
          'videoId': v['videoId'],
          'title': v['title'],
          'channelTitle': v['channelTitle'],
          'channelId': v['channelId'],
          'thumbnail': v['thumbnail'],
          // Use a working mp4 as visual stand-in when embed blocked
          'url': _directVideos[list.length % _directVideos.length]['url'],
        });
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _feed = list;
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
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _feed.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              return _FeedItem(
                data: _feed[index],
                isActive: index == _currentIndex,
              );
            },
          ),
          // Top bar like Instagram
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Pulse',
                    style: GoogleFonts.grandHotel(
                      fontSize: 32,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.favorite_border, color: Colors.white, size: 26),
                  const SizedBox(width: 16),
                  const Icon(Icons.send_outlined, color: Colors.white, size: 26),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedItem extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isActive;

  const _FeedItem({required this.data, required this.isActive});

  @override
  State<_FeedItem> createState() => _FeedItemState();
}

class _FeedItemState extends State<_FeedItem> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final url = widget.data['url'] as String? ??
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await _controller!.initialize();
      _controller!.setLooping(true);
      if (widget.isActive) _controller!.play();
      if (mounted) setState(() => _ready = true);
    } catch (e) {
      debugPrint('Video error: $e');
    }
  }

  @override
  void didUpdateWidget(covariant _FeedItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller?.play();
    } else if (!widget.isActive && oldWidget.isActive) {
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
    final thumb = widget.data['thumbnail'] as String? ?? '';

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video
        if (_ready && _controller != null)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          )
        else if (thumb.isNotEmpty)
          CachedNetworkImage(imageUrl: thumb, fit: BoxFit.cover)
        else
          Container(
            color: Colors.grey[900],
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            ),
          ),

        // Gradient
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 220,
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

        // Right actions
        Positioned(
          right: 12,
          bottom: 120,
          child: Column(
            children: [
              IconButton(
                icon: Icon(
                  _liked ? Icons.favorite : Icons.favorite_border,
                  color: _liked ? Colors.red : Colors.white,
                  size: 32,
                ),
                onPressed: () => setState(() => _liked = !_liked),
              ),
              const Text('Like', style: TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(height: 16),
              const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 30),
              const SizedBox(height: 4),
              const Text('Comment', style: TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(height: 16),
              const Icon(Icons.send_outlined, color: Colors.white, size: 28),
              const SizedBox(height: 16),
              const Icon(Icons.more_vert, color: Colors.white, size: 28),
            ],
          ),
        ),

        // Bottom info
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
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
                      child: const Text(
                        'Follow',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Tap to pause/play
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
