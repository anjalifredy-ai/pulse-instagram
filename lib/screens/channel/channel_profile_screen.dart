import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../services/youtube_service.dart';
import '../player/reel_player_screen.dart';

class ChannelProfileScreen extends ConsumerStatefulWidget {
  final String channelId;
  final String initialTitle;
  final String initialThumbnail;

  const ChannelProfileScreen({
    super.key,
    required this.channelId,
    this.initialTitle = '',
    this.initialThumbnail = '',
  });

  @override
  ConsumerState<ChannelProfileScreen> createState() => _ChannelProfileScreenState();
}

class _ChannelProfileScreenState extends ConsumerState<ChannelProfileScreen> {
  final _youtube = YoutubeService();
  Map<String, dynamic>? _channel;
  List<Map<String, dynamic>> _shorts = [];
  bool _loading = true;
  bool _isFollowing = false;

  static const _mp4Pool = [
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
    _load();
  }

  Future<void> _load() async {
    final details = await _youtube.getChannelDetails(widget.channelId);
    final shorts = await _youtube.getChannelShorts(widget.channelId);

    // Attach playable URLs so Reels player always works
    final withUrls = <Map<String, dynamic>>[];
    for (var i = 0; i < shorts.length; i++) {
      withUrls.add({
        ...shorts[i],
        'videoUrl': _mp4Pool[i % _mp4Pool.length],
      });
    }

    if (mounted) {
      setState(() {
        _channel = details;
        _shorts = withUrls;
        _loading = false;
      });
    }
  }

  void _openInReels(int index) {
    if (_shorts.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReelPlayerScreen(
          videos: _shorts,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _channel?['title'] ?? widget.initialTitle;
    final thumb = _channel?['thumbnail'] ?? widget.initialThumbnail;
    final subs = _channel?['subscriberCount'] ?? '—';
    final videos = _channel?['videoCount'] ?? '—';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: AppTheme.surfaceLight,
                              backgroundImage: thumb.isNotEmpty ? CachedNetworkImageProvider(thumb) : null,
                              child: thumb.isEmpty
                                  ? Text(
                                      title.isNotEmpty ? title.substring(0, 1).toUpperCase() : '?',
                                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _Stat(count: videos, label: 'Videos'),
                                  _Stat(count: subs, label: 'Followers'),
                                  const _Stat(count: '—', label: 'Following'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        if ((_channel?['description'] as String?)?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            _channel!['description'],
                            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => setState(() => _isFollowing = !_isFollowing),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isFollowing ? AppTheme.surfaceLight : AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              _isFollowing ? 'Following' : 'Follow',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Divider(height: 0.5, thickness: 0.5, color: AppTheme.border),
                ),
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: IconButton(
                          icon: const Icon(Icons.grid_on, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: const Icon(Icons.play_circle_outline, color: AppTheme.textSecondary),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Divider(height: 0.5, thickness: 0.5, color: AppTheme.border),
                ),
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 1.5,
                    mainAxisSpacing: 1.5,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= _shorts.length) {
                        return Container(color: AppTheme.surfaceLight);
                      }
                      final s = _shorts[index];
                      return GestureDetector(
                        onTap: () => _openInReels(index), // → Reels player
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if ((s['thumbnail'] as String?)?.isNotEmpty == true)
                              CachedNetworkImage(
                                imageUrl: s['thumbnail'],
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(color: AppTheme.surfaceLight),
                                errorWidget: (_, __, ___) => Container(
                                  color: AppTheme.surfaceLight,
                                  child: const Icon(Icons.play_circle_outline, color: Colors.white24),
                                ),
                              )
                            else
                              Container(
                                color: AppTheme.surfaceLight,
                                child: const Icon(Icons.play_circle_outline, color: Colors.white24),
                              ),
                            const Positioned(
                              bottom: 6,
                              right: 6,
                              child: Icon(Icons.play_arrow, color: Colors.white, size: 18),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: _shorts.isEmpty ? 9 : _shorts.length,
                  ),
                ),
              ],
            ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String count;
  final String label;
  const _Stat({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      ],
    );
  }
}
