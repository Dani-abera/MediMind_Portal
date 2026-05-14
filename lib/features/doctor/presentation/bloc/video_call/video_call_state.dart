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

  const VideoCallActive({
    required this.consultation,
    this.micEnabled = true,
    this.cameraEnabled = true,
    this.isChatOpen = false,
    this.messages = const [],
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props =>
      [consultation, micEnabled, cameraEnabled, isChatOpen, messages, unreadCount];

  VideoCallActive copyWith({
    VideoConsultation? consultation,
    bool? micEnabled,
    bool? cameraEnabled,
    bool? isChatOpen,
    List<ChatMessage>? messages,
    int? unreadCount,
  }) =>
      VideoCallActive(
        consultation: consultation ?? this.consultation,
        micEnabled: micEnabled ?? this.micEnabled,
        cameraEnabled: cameraEnabled ?? this.cameraEnabled,
        isChatOpen: isChatOpen ?? this.isChatOpen,
        messages: messages ?? this.messages,
        unreadCount: unreadCount ?? this.unreadCount,
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
