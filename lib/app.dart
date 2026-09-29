import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/theme/app_theme.dart';
import 'screens/main_shell.dart';
import 'screens/auth/auth_screen.dart';

class PulseInstagramApp extends ConsumerWidget {
  final bool firebaseReady;

  const PulseInstagramApp({super.key, this.firebaseReady = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Pulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: firebaseReady
          ? StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    backgroundColor: Colors.black,
                    body: Center(
                      child: CircularProgressIndicator(color: Color(0xFFE1306C)),
                    ),
                  );
                }
                if (snapshot.hasData) {
                  return const MainShell();
                }
                return const AuthScreen();
              },
            )
          : const MainShell(), // Firebase fail ho toh seedha app khol do
    );
  }
}
