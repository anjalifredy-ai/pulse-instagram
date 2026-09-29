import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_theme.dart';

/// Instagram-style Call Screen
/// WebRTC wiring ready — permissions requested properly to avoid crash
class CallScreen extends ConsumerStatefulWidget {
  final String username;
  final bool isVideo;

  const CallScreen({
    super.key,
    required this.username,
    this.isVideo = false,
  });

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _isCameraOn = true;
  bool _isConnected = false;
  bool _permissionGranted = false;
  String _status = 'Requesting permissions...';

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final mic = await Permission.microphone.request();
    PermissionStatus? cam;
    if (widget.isVideo) {
      cam = await Permission.camera.request();
    }

    if (mic.isGranted && (!widget.isVideo || (cam?.isGranted ?? false))) {
      setState(() {
        _permissionGranted = true;
        _status = 'Calling...';
      });
      // Simulate connect (real WebRTC signaling later with Firebase)
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isConnected = true;
            _status = 'Connected';
          });
        }
      });
    } else {
      setState(() {
        _status = 'Permissions denied. Enable mic${widget.isVideo ? ' & camera' : ''} in settings.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (widget.isVideo)
              Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(Icons.person, size: 120, color: Colors.white24),
                ),
              )
            else
              Container(
                color: const Color(0xFF1A1A1A),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: AppTheme.surfaceLight,
                        child: Text(
                          widget.username.isNotEmpty
                              ? widget.username.substring(0, 1).toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        widget.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _status,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            if (widget.isVideo && _isCameraOn && _permissionGranted)
              Positioned(
                top: 20,
                right: 16,
                child: Container(
                  width: 110,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Center(
                    child: Icon(Icons.videocam, color: Colors.white54, size: 32),
                  ),
                ),
              ),

            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  if (widget.isVideo)
                    Text(
                      widget.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const Spacer(),
                  if (_isConnected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('00:42', style: TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                ],
              ),
            ),

            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CallButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: _isMuted ? 'Unmute' : 'Mute',
                    isActive: !_isMuted,
                    onTap: () => setState(() => _isMuted = !_isMuted),
                  ),
                  if (widget.isVideo)
                    _CallButton(
                      icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                      label: _isCameraOn ? 'Camera' : 'Cam Off',
                      isActive: _isCameraOn,
                      onTap: () => setState(() => _isCameraOn = !_isCameraOn),
                    ),
                  _CallButton(
                    icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                    label: 'Speaker',
                    isActive: _isSpeakerOn,
                    onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                  ),
                  _CallButton(
                    icon: Icons.call_end,
                    label: 'End',
                    backgroundColor: Colors.red,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? backgroundColor;
  final VoidCallback onTap;

  const _CallButton({
    required this.icon,
    required this.label,
    this.isActive = true,
    this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: backgroundColor ?? (isActive ? Colors.white24 : Colors.white12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
