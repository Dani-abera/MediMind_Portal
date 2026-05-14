import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../../../../../core/network/user_context.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/video_consultation.dart';
import '../../../domain/repositories/consultation_repository.dart';

part 'video_call_event.dart';
part 'video_call_state.dart';

class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  final ConsultationRepository _repo;
  final UserContext _userContext;

  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  RTCVideoRenderer? _localRenderer;
  RTCVideoRenderer? _remoteRenderer;
  HubConnection? _hub;
  String? _consultationId;
  String? _peerConnectionId;
  bool _offerSent = false;

  RTCVideoRenderer? get localRenderer => _localRenderer;
  RTCVideoRenderer? get remoteRenderer => _remoteRenderer;

  VideoCallBloc({
    required ConsultationRepository repo,
    required UserContext userContext,
  })  : _repo = repo,
        _userContext = userContext,
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
    _consultationId = event.consultationId;
    emit(const VideoCallJoining());

    // REST join — registers participant and returns peer list + chat history
    final result = await _repo.join(event.consultationId);
    if (result.isLeft()) {
      emit(VideoCallError(result.fold((f) => f.message, (_) => 'Failed to join')));
      return;
    }
    final consultation = result.fold((_) => null, (c) => c)!;

    // Init WebRTC renderers
    _localRenderer = RTCVideoRenderer();
    _remoteRenderer = RTCVideoRenderer();
    await _localRenderer!.initialize();
    await _remoteRenderer!.initialize();

    // Get local camera/mic stream
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {'facingMode': 'user'},
      });
      _localRenderer!.srcObject = _localStream;
    } catch (_) {
      // Proceed without local stream (permission denied in browser)
    }

    // Create peer connection
    _pc = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    });

    _localStream?.getTracks().forEach((track) {
      _pc!.addTrack(track, _localStream!);
    });

    _pc!.onIceCandidate = (candidate) {
      if (candidate.candidate != null && _peerConnectionId != null) {
        _hubSend('SendIceCandidate', [
          _consultationId!,
          _peerConnectionId!,
          jsonEncode(candidate.toMap()),
        ]);
      }
    };

    _pc!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer!.srcObject = event.streams[0];
      }
    };

    // Connect to video SignalR hub
    await _connectSignalR(event.consultationId);

    emit(VideoCallActive(
      consultation: consultation,
      messages: const [],
    ));
  }

  Future<void> _connectSignalR(String consultationId) async {
    final base =
        dotenv.env['SIGNALR_BASE_URL'] ?? 'https://api.medimind.et';
    final url = '$base/hubs/video';

    _hub = HubConnectionBuilder()
        .withUrl(url,
            options: HttpConnectionOptions(
              accessTokenFactory: () async => _userContext.accessToken ?? '',
            ))
        .withAutomaticReconnect()
        .build();

    _hub!.on('ReceiveOffer', (args) async {
      if (args == null || args.length < 2) return;
      final senderConnectionId = args[0] as String? ?? '';
      _peerConnectionId ??= senderConnectionId;
      final rawSdp = args[1];
      Map<String, dynamic> sdpMap;
      if (rawSdp is Map<String, dynamic>) {
        sdpMap = rawSdp;
      } else if (rawSdp is String) {
        sdpMap = jsonDecode(rawSdp) as Map<String, dynamic>? ?? {};
      } else {
        return;
      }
      await _pc?.setRemoteDescription(
          RTCSessionDescription(sdpMap['sdp'] as String?, sdpMap['type'] as String?));
      final answer = await _pc?.createAnswer();
      if (answer != null) {
        await _pc?.setLocalDescription(answer);
        _hubSend('SendAnswer', [
          consultationId,
          senderConnectionId,
          jsonEncode({'sdp': answer.sdp, 'type': answer.type}),
        ]);
      }
    });

    _hub!.on('ReceiveAnswer', (args) async {
      if (args == null || args.length < 2) return;
      final rawSdp = args[1];
      Map<String, dynamic> sdpMap;
      if (rawSdp is Map<String, dynamic>) {
        sdpMap = rawSdp;
      } else if (rawSdp is String) {
        sdpMap = jsonDecode(rawSdp) as Map<String, dynamic>? ?? {};
      } else {
        return;
      }
      await _pc?.setRemoteDescription(
          RTCSessionDescription(sdpMap['sdp'] as String?, sdpMap['type'] as String?));
    });

    _hub!.on('ReceiveIceCandidate', (args) async {
      if (args == null || args.length < 2) return;
      final raw = args[1];
      Map<String, dynamic> candidateMap;
      if (raw is Map<String, dynamic>) {
        candidateMap = raw;
      } else if (raw is String) {
        candidateMap = jsonDecode(raw) as Map<String, dynamic>? ?? {};
      } else {
        return;
      }
      await _pc?.addCandidate(RTCIceCandidate(
        candidateMap['candidate'] as String?,
        candidateMap['sdpMid'] as String?,
        candidateMap['sdpMLineIndex'] as int?,
      ));
    });

    _hub!.on('UserJoined', (args) async {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>? ?? {};
      final connectionId = data['connectionId'] as String? ?? '';
      if (connectionId.isNotEmpty && !_offerSent) {
        _peerConnectionId = connectionId;
        _offerSent = true;
        final offer = await _pc?.createOffer();
        if (offer != null) {
          await _pc?.setLocalDescription(offer);
          _hubSend('SendOffer', [
            consultationId,
            connectionId,
            jsonEncode({'sdp': offer.sdp, 'type': offer.type}),
          ]);
        }
      }
    });

    _hub!.on('UserLeft', (_) => add(const VideoCallPeerLeft()));
    _hub!.on('ConsultationEnded', (_) => add(const VideoCallPeerLeft()));

    _hub!.on('ReceiveChatMessage', (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>? ?? {};
      final msg = ChatMessage(
        id: data['messageId'] as String? ?? '',
        senderId: data['senderId'] as String? ?? '',
        senderName: data['senderName'] as String? ?? '',
        senderType: data['senderType'] as String? ?? '',
        content: data['content'] as String? ?? '',
        sentAt: data['sentAt'] != null
            ? DateTime.tryParse(data['sentAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
      add(VideoCallChatMessageReceived(msg));
    });

    await _hub!.start();
    await _hub!.invoke('JoinConsultationRoom', args: [consultationId]);
  }

  void _hubSend(String method, List<Object?> args) {
    _hub?.invoke(method, args: args).catchError((_) {});
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

  void _onToggleMic(VideoCallToggleMic event, Emitter<VideoCallState> emit) {
    final current = state;
    if (current is VideoCallActive) {
      final muted = !current.micEnabled;
      _localStream?.getAudioTracks().forEach((t) => t.enabled = !muted);
      emit(current.copyWith(micEnabled: !muted));
    }
  }

  void _onToggleCamera(
      VideoCallToggleCamera event, Emitter<VideoCallState> emit) {
    final current = state;
    if (current is VideoCallActive) {
      final off = !current.cameraEnabled;
      _localStream?.getVideoTracks().forEach((t) => t.enabled = !off);
      emit(current.copyWith(cameraEnabled: !off));
    }
  }

  void _onChatToggled(VideoCallChatToggled event, Emitter<VideoCallState> emit) {
    final current = state;
    if (current is! VideoCallActive) return;
    final open = !current.isChatOpen;
    emit(current.copyWith(isChatOpen: open, unreadCount: open ? 0 : current.unreadCount));
  }

  Future<void> _onMessageSent(
      VideoCallMessageSent event, Emitter<VideoCallState> emit) async {
    final current = state;
    if (current is! VideoCallActive || _consultationId == null) return;
    _hubSend('SendChatMessage', [_consultationId!, event.content]);
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
    _localStream?.dispose();
    _pc?.close();
    _localRenderer?.dispose();
    _remoteRenderer?.dispose();
    _hub?.stop();
    _offerSent = false;
    _peerConnectionId = null;
  }

  @override
  Future<void> close() {
    _cleanup();
    return super.close();
  }
}
