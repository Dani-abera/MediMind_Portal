import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/video_consultation.dart';
import '../../../domain/usecases/initiate_consultation_usecase.dart';
import '../../../domain/repositories/consultation_repository.dart';

part 'consultation_event.dart';
part 'consultation_state.dart';

class ConsultationBloc extends Bloc<ConsultationEvent, ConsultationState> {
  final InitiateConsultationUseCase _initiate;
  final ConsultationRepository _repo;

  ConsultationBloc({
    required InitiateConsultationUseCase initiate,
    required ConsultationRepository repo,
  })  : _initiate = initiate,
        _repo = repo,
        super(const ConsultationInitial()) {
    on<ConsultationStarted>(_onStarted, transformer: droppable());
    on<ConsultationTabChanged>(_onTabChanged);
    on<ConsultationNextPage>(_onNextPage, transformer: droppable());
    on<ConsultationInitiated>(_onInitiated, transformer: droppable());
  }

  Future<void> _onStarted(
    ConsultationStarted event,
    Emitter<ConsultationState> emit,
  ) async {
    emit(const ConsultationLoading());
    final activeResult = await _repo.getActive();
    final todayResult = await _repo.getToday();
    final pastResult = await _repo.getPast();

    if (activeResult.isLeft()) {
      emit(ConsultationError(
          activeResult.fold((f) => f.message, (_) => 'Error')));
      return;
    }

    emit(ConsultationLoaded(
      active: activeResult.getOrElse(() => []),
      today: todayResult.getOrElse(() => []),
      past: pastResult.getOrElse(() => []),
      hasMorePast: pastResult.getOrElse(() => []).length == 20,
      tab: 0,
    ));
  }

  void _onTabChanged(
    ConsultationTabChanged event,
    Emitter<ConsultationState> emit,
  ) {
    final current = state;
    if (current is ConsultationLoaded) {
      emit(current.copyWith(tab: event.index));
    }
  }

  Future<void> _onNextPage(
    ConsultationNextPage event,
    Emitter<ConsultationState> emit,
  ) async {
    final current = state;
    if (current is! ConsultationLoaded || !current.hasMorePast) return;
    final nextPage = (current.past.length ~/ 20) + 1;
    final result = await _repo.getPast(page: nextPage);
    result.fold(
      (_) {},
      (more) => emit(current.copyWith(
        past: [...current.past, ...more],
        hasMorePast: more.length == 20,
      )),
    );
  }

  Future<void> _onInitiated(
    ConsultationInitiated event,
    Emitter<ConsultationState> emit,
  ) async {
    emit(const ConsultationInitiateInProgress());
    final result = await _initiate(event.appointmentId);
    result.fold(
      (f) => emit(ConsultationError(f.message)),
      (consultation) => emit(ConsultationInitiateSuccess(consultation)),
    );
  }
}
