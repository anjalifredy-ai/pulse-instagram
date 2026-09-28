import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
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
                      (post['username'] as String).substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['username'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    if (post['location'] != null)
                      Text(
                        post['location'] as String,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, size: 22),
                onPressed: () {},
              ),
            ],
          ),
        ),

        // Image / Media
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            color: AppTheme.surfaceLight,
            child: const Center(
              child: Icon(Icons.image, size: 64, color: Colors.white24),
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
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  size: 26,
                ),
                onPressed: () => setState(() => isSaved = !isSaved),
              ),
            ],
          ),
        ),

        // Likes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${post['likes']} likes',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),

        // Caption
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white, fontSize: 14),
              children: [
                TextSpan(
                  text: '${post['username']} ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: post['caption'] as String),
              ],
            ),
          ),
        ),

        // Comments
        if (post['comments'] != null && (post['comments'] as int) > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'View all ${post['comments']} comments',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ),

        // Time
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
          child: Text(
            post['time'] as String,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ),

        const Divider(height: 0.5, thickness: 0.5, color: AppTheme.border),
      ],
    );
  }
}
