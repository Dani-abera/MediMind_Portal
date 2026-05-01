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
