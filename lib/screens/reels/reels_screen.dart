import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

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
  bool _loadingMore = false;
  String? _nextPageToken;

  final Map<int, YoutubePlayerController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() => _loading = true);
    final list = await _youtube.getTrendingShorts();
    if (mounted) {
      setState(() {
        _shorts = list;
        _nextPageToken = list.isNotEmpty ? list.last['nextPageToken'] : null;
        _loading = false;
      });
      if (_shorts.isNotEmpty) _initController(0);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _nextPageToken == null) return;
    setState(() => _loadingMore = true);
    final more = await _youtube.getTrendingShorts(pageToken: _nextPageToken);
    if (mounted) {
      setState(() {
        _shorts.addAll(more);
        _nextPageToken = more.isNotEmpty ? more.last['nextPageToken'] : null;
        _loadingMore = false;
      });
    }
  }

  void _initController(int index) {
    if (index < 0 || index >= _shorts.length) return;
    if (_controllers.containsKey(index)) return;

    final videoId = _shorts[index]['videoId'] as String? ?? '';
    if (videoId.isEmpty) return;

    final controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        mute: false,
        loop: true,
        strictRelatedVideos: true,
      ),
    );
    _controllers[index] = controller;
  }

  void _disposeController(int index) {
    _controllers[index]?.close();
    _controllers.remove(index);
  }

  void _onPageChanged(int index) {
    for (final i in [index - 1, index, index + 1]) {
      _initController(i);
    }
    final keys = _controllers.keys.toList();
    for (final k in keys) {
      if ((k - index).abs() > 2) _disposeController(k);
    }

    _controllers.forEach((i, c) {
      if (i == index) {
        c.playVideo();
      } else {
        c.pauseVideo();
      }
    });

    if (index >= _shorts.length - 3) {
      _loadMore();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _controllers.values) {
      c.close();
    }
    _controllers.clear();
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

    if (_shorts.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off, size: 64, color: Colors.white38),
              const SizedBox(height: 16),
              const Text('No Shorts available', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loadInitial,
                child: const Text('Retry', style: TextStyle(color: AppTheme.primary)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _shorts.length + (_loadingMore ? 1 : 0),
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          if (index >= _shorts.length) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          final reel = _shorts[index];
          final controller = _controllers[index];

          return Stack(
            fit: StackFit.expand,
            children: [
              if (controller != null)
                YoutubePlayer(
                  controller: controller,
                  aspectRatio: 9 / 16,
                )
              else
                Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: Icon(Icons.play_circle_outline, size: 80, color: Colors.white38),
                  ),
                ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 180,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                    ),
                  ),
                ),
              ),

              Positioned(
                right: 12,
                bottom: 120,
                child: Column(
                  children: [
                    _ActionButton(icon: Icons.favorite_border, label: 'Like', onTap: () {}),
                    const SizedBox(height: 18),
                    _ActionButton(icon: Icons.chat_bubble_outline, label: 'Comment', onTap: () {}),
                    const SizedBox(height: 18),
                    _ActionButton(icon: Icons.send_outlined, label: '', onTap: () {}),
                    const SizedBox(height: 18),
                    _ActionButton(icon: Icons.more_vert, label: '', onTap: () {}),
                  ],
                ),
              ),

              Positioned(
                left: 16,
                right: 80,
                bottom: 50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        final chId = reel['channelId'] as String? ?? '';
                        if (chId.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChannelProfileScreen(
                                channelId: chId,
                                initialTitle: reel['channelTitle'] ?? '',
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
                              ((reel['channelTitle'] as String?) ?? 'Y').isNotEmpty
                                  ? (reel['channelTitle'] as String).substring(0, 1).toUpperCase()
                                  : 'Y',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              reel['channelTitle'] ?? '',
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
                      reel['title'] ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ],
      ),
    );
  }
}
