import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/user_context.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/services/agora_chat_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/consultation_repository.dart';

class AppointmentChatPage extends StatefulWidget {
  final String consultationId;
  const AppointmentChatPage({super.key, required this.consultationId});

  @override
  State<AppointmentChatPage> createState() => _AppointmentChatPageState();
}

class _AppointmentChatPageState extends State<AppointmentChatPage> {
  late final AgoraChatService _chatService;
  final List<ChatMessage> _messages = [];
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  StreamSubscription<ChatMessage>? _sub;
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    _chatService = AgoraChatService();
    _connect();
  }

  Future<void> _connect() async {
    // Backend-issued RTM credentials are required (the Agora project has
    // App Certificate enabled — empty tokens get rejected).
    final joinResult = await sl<ConsultationRepository>().join(widget.consultationId);
    final fallbackAppId = dotenv.env['AGORA_APP_ID'] ?? '';
    final fallbackUserId = sl<UserContext>().userId ??
        'd_${widget.consultationId.substring(0, 8)}';

    final (appId, rtmToken, userId) = joinResult.fold(
      (_) => (fallbackAppId, '', fallbackUserId),
      (c) => (
        c.agoraAppId?.isNotEmpty == true ? c.agoraAppId! : fallbackAppId,
        c.agoraRtmToken ?? '',
        c.agoraRtmUserId?.isNotEmpty == true ? c.agoraRtmUserId! : fallbackUserId,
      ),
    );

    await _chatService.connect(
      appId: appId,
      userId: userId,
      rtmToken: rtmToken,
      consultationId: widget.consultationId,
    );

    _sub = _chatService.onMessage.listen((msg) {
      if (mounted) {
        setState(() => _messages.add(msg));
        _scrollToBottom();
      }
    });

    if (mounted) setState(() => _connected = true);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _chatService.disconnect().ignore();
    _chatService.dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty || !_connected) return;
    _input.clear();

    _chatService.sendMessage(
      content: text,
      senderName: 'You',
      senderType: 'doctor',
    );

    sl<ConsultationRepository>()
        .sendMessage(widget.consultationId, text)
        .ignore();

    if (mounted) {
      final userCtx = sl<UserContext>();
      setState(() => _messages.add(ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: userCtx.userId ?? '',
            senderName: 'You',
            senderType: 'doctor',
            content: text,
            sentAt: DateTime.now(),
          )));
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Chat'),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 16),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(RouteNames.doctorConsultations),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color:
                      _connected ? AppColors.success : AppColors.neutral400,
                ),
                const SizedBox(width: 6),
                Text(
                  _connected ? 'Connected' : 'Connecting…',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      _connected
                          ? 'No messages yet. Say hello!'
                          : 'Connecting to chat…',
                      style:
                          const TextStyle(color: AppColors.neutral500),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) =>
                        _MessageBubble(msg: _messages[i]),
                  ),
          ),
          _ChatInput(
            controller: _input,
            enabled: _connected,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isDoctor = msg.isFromDoctor;
    return Align(
      alignment: isDoctor ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.65),
        decoration: BoxDecoration(
          color: isDoctor ? AppColors.primary : AppColors.neutral200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isDoctor ? 12 : 2),
            bottomRight: Radius.circular(isDoctor ? 2 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment: isDoctor
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              msg.senderName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDoctor
                    ? Colors.white.withAlpha(180)
                    : AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              msg.content,
              style: TextStyle(
                color: isDoctor ? Colors.white : AppColors.neutral900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  const _ChatInput({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.neutral200)),
        color: AppColors.surface,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: enabled ? 'Type a message…' : 'Connecting…',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.neutral100,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: enabled ? onSend : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
            child: const FaIcon(FontAwesomeIcons.paperPlane,
                size: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
