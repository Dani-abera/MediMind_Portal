import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/usecases/get_queue_usecase.dart';
import '../../../domain/entities/queue_entry.dart';

part 'queue_event.dart';
part 'queue_state.dart';

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final GetQueueUseCase _getQueue;
  String? _currentCenterId;

  QueueBloc({required GetQueueUseCase getQueue})
      : _getQueue = getQueue,
        super(const QueueInitial()) {
    on<QueueStarted>(_onStarted, transformer: droppable());
    on<QueueRefreshed>(_onRefreshed, transformer: droppable());
    on<QueueCenterChanged>(_onCenterChanged, transformer: droppable());
  }

  Future<void> _onStarted(
    QueueStarted event,
    Emitter<QueueState> emit,
  ) async {
    _currentCenterId = event.centerId;
    if (event.centerId == null) {
      emit(const QueueLoaded([], centerId: null));
      return;
    }
    emit(const QueueLoading());
    final result = await _getQueue(event.centerId!);
    result.fold(
      (f) => emit(QueueError(f.message)),
      (entries) => emit(QueueLoaded(entries, centerId: event.centerId)),
    );
  }

  Future<void> _onRefreshed(
    QueueRefreshed event,
    Emitter<QueueState> emit,
  ) async {
    emit(const QueueLoading());
    final centerId = _currentCenterId;
    if (centerId == null) return;
    final result = await _getQueue(centerId);
    result.fold(
      (f) => emit(QueueError(f.message)),
      (entries) => emit(QueueLoaded(entries, centerId: centerId)),
    );
  }

  Future<void> _onCenterChanged(
    QueueCenterChanged event,
    Emitter<QueueState> emit,
  ) async {
    _currentCenterId = event.centerId;
    emit(const QueueLoading());
    final result = await _getQueue(event.centerId);
    result.fold(
      (f) => emit(QueueError(f.message)),
      (entries) => emit(QueueLoaded(entries, centerId: event.centerId)),
    );
  }
}
