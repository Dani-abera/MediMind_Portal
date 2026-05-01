import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/video_call/video_call_bloc.dart';

class VideoCallPage extends StatelessWidget {
  final String consultationId;
  const VideoCallPage({super.key, required this.consultationId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<VideoCallBloc>()..add(VideoCallJoined(consultationId)),
      child: BlocListener<VideoCallBloc, VideoCallState>(
        listener: (ctx, state) {
          if (state is VideoCallEndedState) {
            Navigator.of(context).pop();
          }
        },
        child: const _VideoCallView(),
      ),
    );
  }
}

class _VideoCallView extends StatefulWidget {
  const _VideoCallView();

  @override
  State<_VideoCallView> createState() => _VideoCallViewState();
}

class _VideoCallViewState extends State<_VideoCallView> {
  Timer? _durationTimer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }

  String get _durationText {
    final h = _elapsed.inHours;
    final m = _elapsed.inMinutes % 60;
    final s = _elapsed.inSeconds % 60;
    if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<VideoCallBloc, VideoCallState>(
        builder: (ctx, state) {
          if (state is VideoCallJoining) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text('Connecting...', style: TextStyle(color: Colors.white)),
                ],
              ),
            );
          }
          if (state is VideoCallError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 56, color: AppColors.danger),
                  const SizedBox(height: 16),
                  Text(state.message,
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white)),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Leave'),
                  ),
                ],
              ),
            );
          }

          final micEnabled =
              state is VideoCallActive ? state.micEnabled : true;
          final cameraEnabled =
              state is VideoCallActive ? state.cameraEnabled : true;
          final patientName = state is VideoCallActive
              ? state.consultation.patientName
              : 'Patient';

          return Stack(
            children: [
              // Remote video (large)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF1A1A2E),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.primary.withAlpha(60),
                          child: Text(
                            patientName.isNotEmpty ? patientName[0] : '?',
                            style: const TextStyle(
                              fontSize: 48,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(patientName,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20)),
                        const SizedBox(height: 8),
                        if (!cameraEnabled)
                          const Text('Camera off',
                              style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                  ),
                ),
              ),

              // Local video (PiP top-right)
              Positioned(
                top: 24,
                right: 24,
                child: Container(
                  width: 140,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D44),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: cameraEnabled
                      ? const Center(
                          child: Icon(Icons.person, size: 36, color: Colors.white38))
                      : const Center(
                          child: Icon(Icons.videocam_off,
                              size: 28, color: Colors.white38)),
                ),
              ),

              // Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black54, Colors.transparent],
                    ),
                  ),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.video,
                          size: 16, color: Colors.white54),
                      const SizedBox(width: 8),
                      Text(
                        'Video Consultation',
                        style: AppTypography.body.copyWith(color: Colors.white),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          _durationText,
                          style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'RobotoMono',
                              fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Controls bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ControlButton(
                        icon: micEnabled
                            ? FontAwesomeIcons.microphone
                            : FontAwesomeIcons.microphoneSlash,
                        label: micEnabled ? 'Mute' : 'Unmute',
                        active: micEnabled,
                        onTap: () => ctx
                            .read<VideoCallBloc>()
                            .add(const VideoCallToggleMic()),
                      ),
                      const SizedBox(width: 24),
                      _ControlButton(
                        icon: cameraEnabled
                            ? FontAwesomeIcons.video
                            : FontAwesomeIcons.videoSlash,
                        label: cameraEnabled ? 'Stop Video' : 'Start Video',
                        active: cameraEnabled,
                        onTap: () => ctx
                            .read<VideoCallBloc>()
                            .add(const VideoCallToggleCamera()),
                      ),
                      const SizedBox(width: 48),
                      _EndCallButton(
                        onTap: () => ctx
                            .read<VideoCallBloc>()
                            .add(const VideoCallEndRequested()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: active ? Colors.white24 : Colors.white10,
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? Colors.white38 : Colors.white24,
              ),
            ),
            child: Center(
              child: FaIcon(icon,
                  size: 18, color: active ? Colors.white : Colors.white54),
            ),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}

class _EndCallButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EndCallButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: AppColors.danger,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.phoneSlash,
                  size: 22, color: Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          const Text('End Call',
              style: TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}
