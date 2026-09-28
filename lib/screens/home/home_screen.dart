import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/story_bar.dart';
import '../../widgets/post_card.dart';
import '../../services/dummy_data.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = DummyData.posts;

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
      body: CustomScrollView(
        slivers: [
          // Stories
          const SliverToBoxAdapter(
            child: StoryBar(),
          ),
          const SliverToBoxAdapter(
            child: Divider(height: 0.5, thickness: 0.5, color: AppTheme.border),
          ),

          // Posts
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return PostCard(post: posts[index]);
              },
              childCount: posts.length,
            ),
          ),
        ],
      ),
    );
  }
}
