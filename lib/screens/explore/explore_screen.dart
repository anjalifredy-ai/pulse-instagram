import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/theme/app_theme.dart';
import '../../services/youtube_service.dart';
import '../channel/channel_profile_screen.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  final _youtube = YoutubeService();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() {
        _results = [];
        _query = '';
      });
      return;
    }
    setState(() {
      _loading = true;
      _query = q.trim();
    });
    final results = await _youtube.searchChannels(q.trim());
    if (mounted) {
      setState(() {
        _results = results;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Search channels...',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                    prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary, size: 22),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 11),
                  ),
                  onSubmitted: _search,
                  textInputAction: TextInputAction.search,
                ),
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppTheme.primary),
              )
            else if (_query.isNotEmpty && _results.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Text('No channels found', style: TextStyle(color: AppTheme.textSecondary)),
              )
            else if (_results.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final ch = _results[index];
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChannelProfileScreen(
                              channelId: ch['channelId'] ?? '',
                              initialTitle: ch['title'] ?? '',
                              initialThumbnail: ch['thumbnail'] ?? '',
                            ),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.surfaceLight,
                        backgroundImage: (ch['thumbnail'] as String?)?.isNotEmpty == true
                            ? CachedNetworkImageProvider(ch['thumbnail'])
                            : null,
                        child: (ch['thumbnail'] as String?)?.isEmpty != false
                            ? Text(
                                (ch['title'] as String? ?? '?').isNotEmpty
                                    ? (ch['title'] as String).substring(0, 1).toUpperCase()
                                    : '?',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      title: Text(
                        ch['title'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        ch['description'] ?? '',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(1.5),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 1.5,
                    mainAxisSpacing: 1.5,
                  ),
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    return Container(
                      color: AppTheme.surfaceLight,
                      child: Center(
                        child: Icon(
                          index % 5 == 0 ? Icons.play_circle_outline : Icons.image,
                          color: Colors.white24,
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
