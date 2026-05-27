part of 'video_call_bloc.dart';

abstract class VideoCallState extends Equatable {
  const VideoCallState();
  @override
  List<Object?> get props => [];
}

class VideoCallInitial extends VideoCallState {
  const VideoCallInitial();
}

class VideoCallJoining extends VideoCallState {
  const VideoCallJoining();
}

class VideoCallActive extends VideoCallState {
  final VideoConsultation consultation;
  final bool micEnabled;
  final bool cameraEnabled;
  final bool isChatOpen;
  final List<ChatMessage> messages;
  final int unreadCount;
  final int? remoteUid;

  const VideoCallActive({
    required this.consultation,
    this.micEnabled = true,
    this.cameraEnabled = true,
    this.isChatOpen = false,
    this.messages = const [],
    this.unreadCount = 0,
    this.remoteUid,
  });

  @override
  List<Object?> get props => [
        consultation,
        micEnabled,
        cameraEnabled,
        isChatOpen,
        messages,
        unreadCount,
        remoteUid,
      ];

  VideoCallActive copyWith({
    VideoConsultation? consultation,
    bool? micEnabled,
    bool? cameraEnabled,
    bool? isChatOpen,
    List<ChatMessage>? messages,
    int? unreadCount,
    int? Function()? remoteUid,
  }) =>
      VideoCallActive(
        consultation: consultation ?? this.consultation,
        micEnabled: micEnabled ?? this.micEnabled,
        cameraEnabled: cameraEnabled ?? this.cameraEnabled,
        isChatOpen: isChatOpen ?? this.isChatOpen,
        messages: messages ?? this.messages,
        unreadCount: unreadCount ?? this.unreadCount,
        remoteUid: remoteUid != null ? remoteUid() : this.remoteUid,
      );
}

class VideoCallEnding extends VideoCallState {
  const VideoCallEnding();
}

class VideoCallEndedState extends VideoCallState {
  const VideoCallEndedState();
}

class VideoCallError extends VideoCallState {
  final String message;
  const VideoCallError(this.message);
  @override
  List<Object?> get props => [message];
}
