import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

import '../core/theme/app_theme.dart';
import '../screens/channel/channel_profile_screen.dart';

/// Instagram-style post card — video plays INSIDE the card (in-feed)
class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  bool isSaved = false;
  VideoPlayerController? _videoController;
  bool _videoReady = false;
  bool _isPlaying = false;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    final url = widget.post['videoUrl'] as String?;
    if (url == null || url.isEmpty) return;

    if (_videoController == null) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      try {
        await _videoController!.initialize();
        _videoController!.setLooping(true);
        if (mounted) setState(() => _videoReady = true);
      } catch (e) {
        debugPrint('Post video error: $e');
        return;
      }
    }

    if (_videoController!.value.isPlaying) {
      await _videoController!.pause();
      setState(() => _isPlaying = false);
    } else {
      await _videoController!.play();
      setState(() => _isPlaying = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final title = post['title'] as String? ?? '';
    final channel = post['channelTitle'] as String? ?? post['username'] as String? ?? 'User';
    final thumb = post['thumbnail'] as String? ?? '';
    final channelId = post['channelId'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
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
                          initialThumbnail: thumb,
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF)],
                    ),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surfaceLight,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        channel.isNotEmpty ? channel.substring(0, 1).toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  channel,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, size: 22),
                onPressed: () {},
              ),
            ],
          ),
        ),

        // Media — plays IN PLACE when tapped
        GestureDetector(
          onTap: _togglePlay,
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_videoReady && _videoController != null && _isPlaying)
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(_videoController!),
                    ),
                  )
                else if (thumb.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: thumb,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppTheme.surfaceLight),
                    errorWidget: (_, __, ___) => Container(
                      color: AppTheme.surfaceLight,
                      child: const Icon(Icons.play_circle_outline, size: 64, color: Colors.white24),
                    ),
                  )
                else
                  Container(
                    color: AppTheme.surfaceLight,
                    child: const Center(
                      child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white24),
                    ),
                  ),
                if (!_isPlaying)
                  const Center(
                    child: Icon(Icons.play_circle_fill, size: 64, color: Colors.white70),
                  ),
              ],
            ),
          ),
        ),

        // Actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? AppTheme.like : Colors.white,
                  size: 28,
                ),
                onPressed: () => setState(() => isLiked = !isLiked),
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, size: 26),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.send_outlined, size: 26),
                onPressed: () {},
              ),
              const Spacer(),
              IconButton(
                icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, size: 26),
                onPressed: () => setState(() => isSaved = !isSaved),
              ),
            ],
          ),
        ),

        // Caption
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white, fontSize: 14),
              children: [
                TextSpan(text: '$channel ', style: const TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: title),
              ],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Text('View comments', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        ),

        const Divider(height: 0.5, thickness: 0.5, color: AppTheme.border),
      ],
    );
  }
}
