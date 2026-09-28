import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'your_username',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add_box_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppTheme.surfaceLight,
                    child: const Text('Y', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatColumn(count: '24', label: 'Posts'),
                        _StatColumn(count: '1.2K', label: 'Followers'),
                        _StatColumn(count: '340', label: 'Following'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bio
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  SizedBox(height: 4),
                  Text('Building cool stuff 🚀\nFlutter • Design • Open Source', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Edit Profile button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.border),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Edit profile', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tabs
            const Divider(height: 0.5, thickness: 0.5, color: AppTheme.border),
            Row(
              children: [
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.grid_on, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.person_pin_outlined, color: AppTheme.textSecondary),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const Divider(height: 0.5, thickness: 0.5, color: AppTheme.border),

            // Grid of posts (placeholder)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 1.5,
                mainAxisSpacing: 1.5,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                return Container(
                  color: AppTheme.surfaceLight,
                  child: Center(
                    child: Icon(Icons.image, color: Colors.white24, size: 32),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String count;
  final String label;

  const _StatColumn({required this.count, required this.label});

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
