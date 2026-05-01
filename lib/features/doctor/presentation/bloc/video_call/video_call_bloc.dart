import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/video_consultation.dart';
import '../../../domain/repositories/consultation_repository.dart';

part 'video_call_event.dart';
part 'video_call_state.dart';

class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  final ConsultationRepository _repo;

  VideoCallBloc({required ConsultationRepository repo})
      : _repo = repo,
        super(const VideoCallInitial()) {
    on<VideoCallJoined>(_onJoined, transformer: droppable());
    on<VideoCallEndRequested>(_onEndRequested, transformer: droppable());
    on<VideoCallToggleMic>(_onToggleMic);
    on<VideoCallToggleCamera>(_onToggleCamera);
  }

  Future<void> _onJoined(
    VideoCallJoined event,
    Emitter<VideoCallState> emit,
  ) async {
    emit(const VideoCallJoining());
    final result = await _repo.join(event.consultationId);
    result.fold(
      (f) => emit(VideoCallError(f.message)),
      (consultation) => emit(VideoCallActive(consultation: consultation)),
    );
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
  }

  void _onToggleMic(VideoCallToggleMic event, Emitter<VideoCallState> emit) {
    final current = state;
    if (current is VideoCallActive) {
      emit(current.copyWith(micEnabled: !current.micEnabled));
    }
  }

  void _onToggleCamera(
      VideoCallToggleCamera event, Emitter<VideoCallState> emit) {
    final current = state;
    if (current is VideoCallActive) {
      emit(current.copyWith(cameraEnabled: !current.cameraEnabled));
    }
  }
}
