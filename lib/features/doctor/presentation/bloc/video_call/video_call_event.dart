part of 'video_call_bloc.dart';

abstract class VideoCallEvent extends Equatable {
  const VideoCallEvent();
  @override
  List<Object?> get props => [];
}

class VideoCallJoined extends VideoCallEvent {
  final String consultationId;
  const VideoCallJoined(this.consultationId);
  @override
  List<Object?> get props => [consultationId];
}

class VideoCallEndRequested extends VideoCallEvent {
  const VideoCallEndRequested();
}

class VideoCallToggleMic extends VideoCallEvent {
  const VideoCallToggleMic();
}

class VideoCallToggleCamera extends VideoCallEvent {
  const VideoCallToggleCamera();
}

class VideoCallChatToggled extends VideoCallEvent {
  const VideoCallChatToggled();
}

class VideoCallMessageSent extends VideoCallEvent {
  final String content;
  const VideoCallMessageSent(this.content);
  @override
  List<Object?> get props => [content];
}

class VideoCallPeerJoined extends VideoCallEvent {
  final int uid;
  const VideoCallPeerJoined(this.uid);
  @override
  List<Object?> get props => [uid];
}

class VideoCallPeerLeft extends VideoCallEvent {
  const VideoCallPeerLeft();
}

class VideoCallChatMessageReceived extends VideoCallEvent {
  final ChatMessage message;
  const VideoCallChatMessageReceived(this.message);
  @override
  List<Object?> get props => [message];
}
