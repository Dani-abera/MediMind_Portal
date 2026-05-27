import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/foundation.dart';
import '../../features/doctor/domain/entities/chat_message.dart';

// agora_rtm 2.x uses a spawned isolate for native bindings. On macOS desktop
// the RTM native symbol 'CreateIrisRtmEngineWithProcTable' is not bundled with
// agora_rtc_engine 6.x, so the isolate crashes and the RTM future never
// resolves. Guard all RTM calls behind this check.
bool get _rtmSupported =>
    kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isWindows;

class AgoraChatService {
  RtmClient? _client;
  String? _channelName;
  String? _userId;
  final _messageController = StreamController<ChatMessage>.broadcast();

  Stream<ChatMessage> get onMessage => _messageController.stream;

  Future<void> connect({
    required String appId,
    required String userId,
    required String rtmToken,
    required String consultationId,
  }) async {
    _channelName = 'consultation_$consultationId';
    _userId = userId;
    if (!_rtmSupported) return; // macOS: video-only, no real-time RTM chat

    try {
      final (_, client) = await RTM(appId, userId);
      _client = client;

      _client!.addListener(
        message: (MessageEvent event) {
          if (event.channelName != _channelName) return;
          if (event.publisher == _userId) return;
          try {
            final raw = event.message;
            final text = raw != null ? utf8.decode(raw) : '';
            final decoded = jsonDecode(text) as Map<String, dynamic>;
            _messageController.add(ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              senderId: event.publisher ?? '',
              senderName: decoded['senderName'] as String? ?? 'Patient',
              senderType: decoded['senderType'] as String? ?? 'patient',
              content: decoded['content'] as String? ?? '',
              sentAt: DateTime.now(),
            ));
          } catch (_) {}
        },
      );

      final (loginStatus, _) = await _client!.login(rtmToken);
      if (loginStatus.error) {
        debugPrint(
            '[Chat] RTM login rejected: ${loginStatus.errorCode} ${loginStatus.reason}');
        _client = null;
        return;
      }
      await _client!.subscribe(_channelName!, withMessage: true, withPresence: false);
    } catch (e) {
      debugPrint('[Chat] RTM connect failed: $e');
      _client = null;
    }
  }

  Future<void> sendMessage({
    required String content,
    required String senderName,
    required String senderType,
  }) async {
    if (_client == null || _channelName == null) return;
    await _client!.publish(
      _channelName!,
      jsonEncode({
        'content': content,
        'senderName': senderName,
        'senderType': senderType,
      }),
    );
  }

  Future<void> disconnect() async {
    final channel = _channelName;
    _channelName = null;
    if (channel != null) {
      await _client?.unsubscribe(channel);
    }
    await _client?.logout();
    await _client?.release();
    _client = null;
  }

  void dispose() {
    _messageController.close();
  }
}
