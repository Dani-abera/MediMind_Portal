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
  const VideoCallActive({
    required this.consultation,
    this.micEnabled = true,
    this.cameraEnabled = true,
  });
  @override
  List<Object?> get props => [consultation, micEnabled, cameraEnabled];

  VideoCallActive copyWith({
    VideoConsultation? consultation,
    bool? micEnabled,
    bool? cameraEnabled,
  }) =>
      VideoCallActive(
        consultation: consultation ?? this.consultation,
        micEnabled: micEnabled ?? this.micEnabled,
        cameraEnabled: cameraEnabled ?? this.cameraEnabled,
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
