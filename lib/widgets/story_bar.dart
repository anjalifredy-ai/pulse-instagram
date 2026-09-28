import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../services/dummy_data.dart';

class StoryBar extends StatelessWidget {
  const StoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    final stories = DummyData.stories;

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: stories.length + 1, // +1 for Your Story
        itemBuilder: (context, index) {
          if (index == 0) {
            return _YourStory();
          }
          final story = stories[index - 1];
          return _StoryItem(
            username: story['username'] as String,
            hasUnseen: story['unseen'] as bool? ?? true,
          );
        },
      ),
    );
  }
}

class _YourStory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surfaceLight,
                  border: Border.all(color: AppTheme.border, width: 1),
                ),
                child: const Icon(Icons.person, size: 36, color: AppTheme.textSecondary),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(Icons.add, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Your story',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _StoryItem extends StatelessWidget {
  final String username;
  final bool hasUnseen;

  const _StoryItem({required this.username, this.hasUnseen = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasUnseen
                  ? const LinearGradient(
                      colors: [Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF)],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    )
                  : null,
              border: hasUnseen ? null : Border.all(color: AppTheme.border, width: 1.5),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceLight,
                border: Border.all(color: Colors.black, width: 2.5),
              ),
              child: Center(
                child: Text(
                  username.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 70,
            child: Text(
              username,
              style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
