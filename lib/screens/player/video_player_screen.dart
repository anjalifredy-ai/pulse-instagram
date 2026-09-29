import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final String channelTitle;
  final String channelId;

  const VideoPlayerScreen({
    super.key,
    required this.videoId,
    this.title = '',
    this.channelTitle = '',
    this.channelId = '',
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _showFallback = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
        loop: false,
        strictRelatedVideos: true,
        enableCaption: false,
      ),
    );

    // If still not playing after a few seconds, show open-in-YouTube
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showFallback = true);
    });
  }

  Future<void> _openInYoutube() async {
    final url = Uri.parse('https://www.youtube.com/watch?v=${widget.videoId}');
    final yt = Uri.parse('vnd.youtube:${widget.videoId}');
    if (await canLaunchUrl(yt)) {
      await launchUrl(yt, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.channelTitle.isNotEmpty ? widget.channelTitle : 'Video',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: _openInYoutube,
            child: const Text('YouTube', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YoutubePlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
          ),
          if (_showFallback)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openInYoutube,
                  icon: const Icon(Icons.play_circle_outline, color: Colors.redAccent),
                  label: const Text('Play in YouTube app', style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.channelTitle.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.channelTitle,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
