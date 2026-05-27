import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../../core/network/user_context.dart';
import '../../../../../core/services/agora_chat_service.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/video_consultation.dart';
import '../../../domain/repositories/consultation_repository.dart';

part 'video_call_event.dart';
part 'video_call_state.dart';

class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  final ConsultationRepository _repo;
  final UserContext _userContext;
  final AgoraChatService _chat;

  RtcEngine? _engine;
  String? _channelId;          // Agora channel == roomId from backend
  String? _consultationId;     // backend consultation GUID — separate from
                               // _channelId (which is room_<hex>) so REST chat
                               // persistence hits the right endpoint.
  int? _remoteUid;
  StreamSubscription<ChatMessage>? _chatSub;

  RtcEngine? get engine => _engine;
  String? get channelId => _channelId;
  int? get remoteUid => _remoteUid;

  VideoCallBloc({
    required ConsultationRepository repo,
    required UserContext userContext,
    required AgoraChatService chatService,
  })  : _repo = repo,
        _userContext = userContext,
        _chat = chatService,
        super(const VideoCallInitial()) {
    on<VideoCallJoined>(_onJoined, transformer: droppable());
    on<VideoCallEndRequested>(_onEndRequested, transformer: droppable());
    on<VideoCallToggleMic>(_onToggleMic);
    on<VideoCallToggleCamera>(_onToggleCamera);
    on<VideoCallChatToggled>(_onChatToggled);
    on<VideoCallMessageSent>(_onMessageSent);
    on<VideoCallPeerLeft>(_onPeerLeft);
    on<VideoCallChatMessageReceived>(_onChatMessageReceived);
  }

  Future<void> _onJoined(
    VideoCallJoined event,
    Emitter<VideoCallState> emit,
  ) async {
    emit(const VideoCallJoining());

    final result = await _repo.join(event.consultationId);
    if (result.isLeft()) {
      emit(VideoCallError(
          result.fold((f) => f.message, (_) => 'Failed to join')));
      return;
    }
    final consultation = result.fold((_) => null, (c) => c)!;

    // Use the roomId from the backend as the Agora channel (not the consultation UUID).
    _channelId = consultation.signalingRoomId ?? event.consultationId;
    _consultationId = event.consultationId;
    final token = consultation.joinToken ?? '';
    // Prefer the App ID the backend signed the token with; fall back to .env
    // only if the backend hasn't been redeployed yet.
    final appId = consultation.agoraAppId ?? dotenv.env['AGORA_APP_ID'] ?? '';

    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(appId: appId));
      await _engine!.enableVideo();
      await _engine!.enableAudio();

      _engine!.registerEventHandler(RtcEngineEventHandler(
        onUserJoined: (connection, uid, elapsed) {
          _remoteUid = uid;
          final current = state;
          if (current is VideoCallActive) {
            emit(current.copyWith(remoteUid: () => uid));
          }
        },
        onUserOffline: (connection, uid, reason) {
          _remoteUid = null;
          add(const VideoCallPeerLeft());
        },
      ));

      await _engine!.startPreview();
      await _engine!.joinChannel(
        token: token,
        channelId: _channelId!,
        uid: 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );
    } catch (e) {
      emit(VideoCallError('Failed to initialize video call: $e'));
      _cleanup();
      return;
    }

    // RTM userId MUST match what the backend baked into the RTM token, so
    // prefer the backend-issued id; fall back to user context only if missing.
    final rtmUserId = consultation.agoraRtmUserId ??
        _userContext.userId ??
        'd_${event.consultationId.substring(0, 8)}';
    final rtmToken = consultation.agoraRtmToken ?? '';
    try {
      await _chat.connect(
        appId: appId,
        userId: rtmUserId,
        rtmToken: rtmToken,
        consultationId: event.consultationId,
      );
    } catch (_) {
      // RTM unavailable on this platform — video continues without in-call chat.
    }

    _chatSub = _chat.onMessage.listen((msg) {
      final current = state;
      if (current is VideoCallActive) {
        // Replace senderName with the actual patient name from the consultation
        final display = msg.senderType.toLowerCase() == 'patient'
            ? ChatMessage(
                id: msg.id,
                senderId: msg.senderId,
                senderName: current.consultation.patientName,
                senderType: msg.senderType,
                content: msg.content,
                sentAt: msg.sentAt,
              )
            : msg;
        add(VideoCallChatMessageReceived(display));
      }
    });

    emit(VideoCallActive(
      consultation: consultation,
      messages: const [],
    ));
  }

  Future<void> _onEndRequested(
    VideoCallEndRequested event,
    Emitter<VideoCallState> emit,
  ) async {
    final current = state;
    if (current is! VideoCallActive) return;
    emit(const VideoCallEnding());
    await _repo.end(current.consultation.id);
    emit(const VideoCallEndedState());
    _cleanup();
  }

  Future<void> _onToggleMic(
      VideoCallToggleMic event, Emitter<VideoCallState> emit) async {
    final current = state;
    if (current is VideoCallActive) {
      final muted = !current.micEnabled;
      await _engine?.muteLocalAudioStream(muted);
      emit(current.copyWith(micEnabled: !muted));
    }
  }

  Future<void> _onToggleCamera(
      VideoCallToggleCamera event, Emitter<VideoCallState> emit) async {
    final current = state;
    if (current is VideoCallActive) {
      final off = !current.cameraEnabled;
      await _engine?.muteLocalVideoStream(off);
      emit(current.copyWith(cameraEnabled: !off));
    }
  }

  void _onChatToggled(
      VideoCallChatToggled event, Emitter<VideoCallState> emit) {
    final current = state;
    if (current is! VideoCallActive) return;
    final open = !current.isChatOpen;
    emit(current.copyWith(
        isChatOpen: open, unreadCount: open ? 0 : current.unreadCount));
  }

  Future<void> _onMessageSent(
      VideoCallMessageSent event, Emitter<VideoCallState> emit) async {
    final current = state;
    if (current is! VideoCallActive || _channelId == null) return;

    await _chat.sendMessage(
      content: event.content,
      senderName: 'You',
      senderType: 'doctor',
    );

    // Persist via REST. The endpoint expects the consultation GUID, not the
    // Agora channel name (`room_<hex>`) — using _channelId here causes a 404.
    final consultationIdForRest = _consultationId;
    if (consultationIdForRest != null) {
      _repo.sendMessage(consultationIdForRest, event.content).ignore();
    }

    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _userContext.userId ?? '',
      senderName: 'You',
      senderType: 'doctor',
      content: event.content,
      sentAt: DateTime.now(),
    );
    emit(current.copyWith(messages: [...current.messages, msg]));
  }

  void _onPeerLeft(VideoCallPeerLeft event, Emitter<VideoCallState> emit) {
    emit(const VideoCallEndedState());
    _cleanup();
  }

  void _onChatMessageReceived(
      VideoCallChatMessageReceived event, Emitter<VideoCallState> emit) {
    final current = state;
    if (current is VideoCallActive) {
      emit(current.copyWith(
        messages: [...current.messages, event.message],
        unreadCount:
            current.isChatOpen ? 0 : current.unreadCount + 1,
      ));
    }
  }

  void _cleanup() {
    _chatSub?.cancel();
    _chatSub = null;
    if (_channelId != null) {
      _chat.disconnect().ignore();
    }
    _engine?.leaveChannel();
    _engine?.release();
    _engine = null;
    _channelId = null;
    _consultationId = null;
    _remoteUid = null;
  }

  @override
  Future<void> close() async {
    _chatSub?.cancel();
    _chatSub = null;
    if (_channelId != null) {
      await _chat.disconnect();
    }
    _chat.dispose();
    _engine?.leaveChannel();
    _engine?.release();
    _engine = null;
    _channelId = null;
    _consultationId = null;
    _remoteUid = null;
    return super.close();
  }
}
