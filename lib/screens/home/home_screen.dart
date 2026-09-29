import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/story_bar.dart';
import '../../widgets/post_card.dart';
import '../../services/youtube_service.dart';

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
    if (mounted) {
      setState(() {
        _posts = list;
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
        _posts.addAll(more);
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
                  const SliverToBoxAdapter(child: StoryBar()),
                  const SliverToBoxAdapter(
                    child: Divider(height: 0.5, thickness: 0.5, color: AppTheme.border),
                  ),
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
