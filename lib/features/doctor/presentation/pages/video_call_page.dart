import 'dart:async';
import 'dart:io';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/video_call/video_call_bloc.dart';
import '../../domain/entities/chat_message.dart';

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
            context.go(RouteNames.doctorConsultations);
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
  final _chatController = TextEditingController();
  final _chatScrollController = ScrollController();

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
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  String get _durationText {
    final h = _elapsed.inHours;
    final m = _elapsed.inMinutes % 60;
    final s = _elapsed.inSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _scrollChatToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
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
                  Text('Connecting...',
                      style: TextStyle(color: Colors.white)),
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
                    onPressed: () =>
                        context.go(RouteNames.doctorConsultations),
                    child: const Text('Leave'),
                  ),
                ],
              ),
            );
          }

          final bloc = ctx.read<VideoCallBloc>();
          final micEnabled =
              state is VideoCallActive ? state.micEnabled : true;
          final cameraEnabled =
              state is VideoCallActive ? state.cameraEnabled : true;
          final isChatOpen =
              state is VideoCallActive ? state.isChatOpen : false;
          final messages =
              state is VideoCallActive ? state.messages : const <ChatMessage>[];
          final unreadCount =
              state is VideoCallActive ? state.unreadCount : 0;
          final patientName = state is VideoCallActive
              ? state.consultation.patientName
              : 'Patient';

          if (state is VideoCallActive) {
            _scrollChatToBottom();
          }

          return Row(
            children: [
              // ── Video area ──────────────────────────────────────────────
              Expanded(
                child: Stack(
                  children: [
                    // Remote video (full screen)
                    Positioned.fill(
                      child: bloc.engine != null &&
                              state is VideoCallActive &&
                              state.remoteUid != null
                          ? AgoraVideoView(
                              controller: VideoViewController.remote(
                                rtcEngine: bloc.engine!,
                                canvas:
                                    VideoCanvas(uid: state.remoteUid!),
                                connection: RtcConnection(channelId: bloc.channelId!),
                                useFlutterTexture: kIsWeb ? false : (Platform.isMacOS || Platform.isWindows),
                              ),
                            )
                          : Container(
                              color: const Color(0xFF1A1A2E),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 60,
                                      backgroundColor:
                                          AppColors.primary.withAlpha(60),
                                      child: Text(
                                        patientName.isNotEmpty
                                            ? patientName[0]
                                            : '?',
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
                                            color: Colors.white,
                                            fontSize: 20)),
                                  ],
                                ),
                              ),
                            ),
                    ),

                    // Local video PiP (top-right)
                    Positioned(
                      top: 24,
                      right: 24,
                      child: Container(
                        width: 160,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2D44),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: bloc.engine != null && cameraEnabled
                              ? AgoraVideoView(
                                  controller: VideoViewController(
                                    rtcEngine: bloc.engine!,
                                    canvas: const VideoCanvas(uid: 0),
                                    useFlutterTexture: kIsWeb ? false : (Platform.isMacOS || Platform.isWindows),
                                  ),
                                )
                              : const Center(
                                  child: Icon(Icons.videocam_off,
                                      size: 28,
                                      color: Colors.white38)),
                        ),
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
                              style: AppTypography.body
                                  .copyWith(color: Colors.white),
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
                              label: cameraEnabled
                                  ? 'Stop Video'
                                  : 'Start Video',
                              active: cameraEnabled,
                              onTap: () => ctx
                                  .read<VideoCallBloc>()
                                  .add(const VideoCallToggleCamera()),
                            ),
                            const SizedBox(width: 24),
                            // Chat toggle with badge
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                _ControlButton(
                                  icon: FontAwesomeIcons.commentDots,
                                  label: 'Chat',
                                  active: isChatOpen,
                                  onTap: () => ctx
                                      .read<VideoCallBloc>()
                                      .add(const VideoCallChatToggled()),
                                ),
                                if (unreadCount > 0)
                                  Positioned(
                                    top: -4,
                                    right: -4,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.danger,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '$unreadCount',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                              ],
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
                ),
              ),

              // ── Chat drawer (slides in from right) ─────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: isChatOpen ? 320 : 0,
                color: const Color(0xFF1A1A2E),
                clipBehavior: Clip.hardEdge,
                child: isChatOpen
                    ? OverflowBox(
                        minWidth: 320,
                        maxWidth: 320,
                        alignment: Alignment.topLeft,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              color: Colors.black38,
                              child: Row(
                                children: [
                                  const Text('Chat',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.white54, size: 20),
                                    onPressed: () => ctx
                                        .read<VideoCallBloc>()
                                        .add(const VideoCallChatToggled()),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                controller: _chatScrollController,
                                padding: const EdgeInsets.all(12),
                                itemCount: messages.length,
                                itemBuilder: (_, i) {
                                  final msg = messages[i];
                                  final isDoctor = msg.isFromDoctor;
                                  return Align(
                                    alignment: isDoctor
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          bottom: 8),
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                      constraints: const BoxConstraints(
                                          maxWidth: 220),
                                      decoration: BoxDecoration(
                                        color: isDoctor
                                            ? AppColors.primary
                                            : Colors.white12,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (!isDoctor)
                                            Text(
                                              msg.senderName,
                                              style: const TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 11),
                                            ),
                                          Text(
                                            msg.content,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              color: Colors.black26,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _chatController,
                                      style: const TextStyle(
                                          color: Colors.white),
                                      decoration: InputDecoration(
                                        hintText: 'Type a message...',
                                        hintStyle: const TextStyle(
                                            color: Colors.white38),
                                        filled: true,
                                        fillColor: Colors.white10,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 10),
                                      ),
                                      onSubmitted: (text) {
                                        if (text.trim().isNotEmpty) {
                                          ctx.read<VideoCallBloc>().add(
                                              VideoCallMessageSent(
                                                  text.trim()));
                                          _chatController.clear();
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.send,
                                        color: AppColors.primary),
                                    onPressed: () {
                                      final text =
                                          _chatController.text.trim();
                                      if (text.isNotEmpty) {
                                        ctx.read<VideoCallBloc>().add(
                                            VideoCallMessageSent(text));
                                        _chatController.clear();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
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
                  size: 18,
                  color: active ? Colors.white : Colors.white54),
            ),
          ),
          const SizedBox(height: 6),
          Text(label,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 11)),
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
