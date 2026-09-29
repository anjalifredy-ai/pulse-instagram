import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/story_bar.dart';
import '../../widgets/post_card.dart';
import '../../services/youtube_service.dart';

/// Classic Instagram Home: Stories bar + scrollable post feed
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final YoutubeService _youtube = YoutubeService();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _posts = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _nextPageToken;

  // Unique direct playable URLs for in-feed video
  static const _mp4Pool = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    setState(() => _loading = true);
    final list = await _youtube.getTrendingShorts();
    final posts = <Map<String, dynamic>>[];

    for (var i = 0; i < list.length; i++) {
      posts.add({
        ...list[i],
        'videoUrl': _mp4Pool[i % _mp4Pool.length],
      });
    }

    // Ensure something shows even if API empty
    if (posts.isEmpty) {
      for (var i = 0; i < _mp4Pool.length; i++) {
        posts.add({
          'videoId': 'local_$i',
          'title': 'Post ${i + 1}',
          'channelTitle': 'Pulse Creator',
          'channelId': '',
          'thumbnail': '',
          'videoUrl': _mp4Pool[i],
        });
      }
    }

    if (mounted) {
      setState(() {
        _posts = posts;
        _nextPageToken = list.isNotEmpty ? list.last['nextPageToken'] : null;
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _nextPageToken == null) return;
    setState(() => _loadingMore = true);
    final more = await _youtube.getTrendingShorts(pageToken: _nextPageToken);
    if (mounted) {
      setState(() {
        for (var i = 0; i < more.length; i++) {
          _posts.add({
            ...more[i],
            'videoUrl': _mp4Pool[(_posts.length + i) % _mp4Pool.length],
          });
        }
        _nextPageToken = more.isNotEmpty ? more.last['nextPageToken'] : null;
        _loadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Pulse',
          style: GoogleFonts.grandHotel(
            fontSize: 32,
            fontWeight: FontWeight.w400,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, size: 26),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.send_outlined, size: 26),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: _loadInitial,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Stories — classic Instagram top bar
                  const SliverToBoxAdapter(child: StoryBar()),
                  const SliverToBoxAdapter(
                    child: Divider(height: 0.5, thickness: 0.5, color: AppTheme.border),
                  ),
                  // Feed posts
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= _posts.length) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: CircularProgressIndicator(color: AppTheme.primary),
                            ),
                          );
                        }
                        return PostCard(post: _posts[index]);
                      },
                      childCount: _posts.length + (_loadingMore ? 1 : 0),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
