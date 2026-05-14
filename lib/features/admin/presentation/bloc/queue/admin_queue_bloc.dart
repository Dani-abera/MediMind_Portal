import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/queue_item.dart';
import '../../../domain/usecases/get_admin_queue_usecase.dart';
import '../../../domain/usecases/call_next_usecase.dart';
import '../../../domain/usecases/mark_arrived_usecase.dart';
import '../../../domain/usecases/mark_complete_usecase.dart';
import '../../../domain/usecases/mark_no_show_usecase.dart';
import '../../../domain/usecases/skip_queue_usecase.dart';
import '../../../domain/usecases/insert_emergency_usecase.dart';
import '../../../../../core/network/realtime_service.dart';
import '../../../../../core/network/realtime_event.dart';

part 'admin_queue_event.dart';
part 'admin_queue_state.dart';

class AdminQueueBloc extends Bloc<AdminQueueEvent, AdminQueueState> {
  final GetAdminQueueUseCase _getQueue;
  final CallNextUseCase _callNext;
  final MarkArrivedUseCase _markArrived;
  final MarkCompleteUseCase _markComplete;
  final MarkNoShowUseCase _markNoShow;
  final SkipQueueUseCase _skip;
  final InsertEmergencyUseCase _insertEmergency;
  final RealtimeService _realtime;
  StreamSubscription<RealtimeEvent>? _realtimeSub;

  String _centerId = '';

  AdminQueueBloc({
    required GetAdminQueueUseCase getQueue,
    required CallNextUseCase callNext,
    required MarkArrivedUseCase markArrived,
    required MarkCompleteUseCase markComplete,
    required MarkNoShowUseCase markNoShow,
    required SkipQueueUseCase skip,
    required InsertEmergencyUseCase insertEmergency,
    required RealtimeService realtime,
  })  : _getQueue = getQueue,
        _callNext = callNext,
        _markArrived = markArrived,
        _markComplete = markComplete,
        _markNoShow = markNoShow,
        _skip = skip,
        _insertEmergency = insertEmergency,
        _realtime = realtime,
        super(const AdminQueueInitial()) {
    on<AdminQueueOpened>(_onOpened, transformer: droppable());
    on<AdminQueueRefreshed>(_onRefreshed, transformer: droppable());
    on<AdminQueueNextCalled>(_onNextCalled, transformer: droppable());
    on<AdminQueueMarkArrived>(_onMarkArrived, transformer: droppable());
    on<AdminQueueMarkComplete>(_onMarkComplete, transformer: droppable());
    on<AdminQueueMarkNoShow>(_onMarkNoShow, transformer: droppable());
    on<AdminQueueSkipped>(_onSkipped, transformer: droppable());
    on<AdminQueueEmergencyInserted>(_onEmergencyInserted, transformer: droppable());
    on<AdminQueueSignalRUpdate>(_onSignalRUpdate);
  }

  Future<void> _fetch(Emitter<AdminQueueState> emit) async {
    final result = await _getQueue(_centerId);
    result.fold(
      (f) => emit(AdminQueueError(f.message)),
      (items) {
        final sorted = [...items]..sort((a, b) => a.queueNumber.compareTo(b.queueNumber));
        final nowServing = sorted.where((i) => i.status == QueueStatus.inProgress).firstOrNull;
        final stats = _computeStats(sorted);
        emit(AdminQueueLoaded(
          items: sorted,
          nowServing: nowServing,
          stats: stats,
          centerId: _centerId,
          updatedAt: DateTime.now(),
        ));
      },
    );
  }

  QueueStats _computeStats(List<QueueItem> items) {
    final served = items.where((i) => i.status == QueueStatus.done).length;
    final noShows = items.where((i) => i.status == QueueStatus.noShow).length;
    final doctorMap = <String, Map<String, dynamic>>{};
    for (final item in items) {
      doctorMap.putIfAbsent(item.doctorId, () => {
            'name': item.doctorName, 'inConsultation': false, 'served': 0, 'remaining': 0,
          });
      if (item.status == QueueStatus.inProgress) doctorMap[item.doctorId]!['inConsultation'] = true;
      if (item.status == QueueStatus.done) doctorMap[item.doctorId]!['served'] = (doctorMap[item.doctorId]!['served'] as int) + 1;
      if (item.status == QueueStatus.waiting || item.status == QueueStatus.inProgress) {
        doctorMap[item.doctorId]!['remaining'] = (doctorMap[item.doctorId]!['remaining'] as int) + 1;
      }
    }
    return QueueStats(
      totalServed: served,
      noShowCount: noShows,
      doctorStats: doctorMap.entries
          .map((e) => DoctorQueueStat(
                doctorId: e.key,
                doctorName: e.value['name'] as String,
                inConsultation: e.value['inConsultation'] as bool,
                served: e.value['served'] as int,
                remaining: e.value['remaining'] as int,
              ))
          .toList(),
    );
  }

  Future<void> _onOpened(AdminQueueOpened event, Emitter<AdminQueueState> emit) async {
    _centerId = event.centerId;
    emit(const AdminQueueLoading());
    await _realtime.joinCenterGroup(_centerId);
    _realtimeSub?.cancel();
    _realtimeSub = _realtime.events
        .where((e) => e.type == RealtimeEventType.queueUpdate)
        .listen((e) => add(AdminQueueSignalRUpdate(e.data ?? {})));
    await _fetch(emit);
  }

  Future<void> _onRefreshed(AdminQueueRefreshed event, Emitter<AdminQueueState> emit) async {
    emit(const AdminQueueLoading());
    await _fetch(emit);
  }

  Future<void> _onNextCalled(AdminQueueNextCalled event, Emitter<AdminQueueState> emit) async {
    emit(const AdminQueueActionInProgress(''));
    final result = await _callNext();
    await result.fold(
      (f) async => emit(AdminQueueActionError(f.message)),
      (_) async => await _fetch(emit),
    );
  }

  Future<void> _onMarkArrived(AdminQueueMarkArrived event, Emitter<AdminQueueState> emit) async {
    emit(AdminQueueActionInProgress(event.queueId));
    final result = await _markArrived(event.queueId);
    await result.fold(
      (f) async => emit(AdminQueueActionError(f.message)),
      (_) async => await _fetch(emit),
    );
  }

  Future<void> _onMarkComplete(AdminQueueMarkComplete event, Emitter<AdminQueueState> emit) async {
    emit(AdminQueueActionInProgress(event.queueId));
    final result = await _markComplete(event.queueId);
    await result.fold(
      (f) async => emit(AdminQueueActionError(f.message)),
      (_) async => await _fetch(emit),
    );
  }

  Future<void> _onMarkNoShow(AdminQueueMarkNoShow event, Emitter<AdminQueueState> emit) async {
    emit(AdminQueueActionInProgress(event.queueId));
    final result = await _markNoShow(event.queueId);
    await result.fold(
      (f) async => emit(AdminQueueActionError(f.message)),
      (_) async => await _fetch(emit),
    );
  }

  Future<void> _onSkipped(AdminQueueSkipped event, Emitter<AdminQueueState> emit) async {
    emit(AdminQueueActionInProgress(event.queueId));
    final result = await _skip(event.queueId);
    await result.fold(
      (f) async => emit(AdminQueueActionError(f.message)),
      (_) async => await _fetch(emit),
    );
  }

  Future<void> _onEmergencyInserted(AdminQueueEmergencyInserted event, Emitter<AdminQueueState> emit) async {
    emit(const AdminQueueActionInProgress(''));
    final result = await _insertEmergency(event.appointmentId);
    await result.fold(
      (f) async => emit(AdminQueueActionError(f.message)),
      (item) async {
        await _fetch(emit);
        emit(AdminQueueActionSuccess('Emergency: ${item.patientName} inserted at position 1'));
      },
    );
  }

  void _onSignalRUpdate(AdminQueueSignalRUpdate event, Emitter<AdminQueueState> emit) {
    if (state is AdminQueueLoaded) add(const AdminQueueRefreshed());
  }

  @override
  Future<void> close() {
    _realtimeSub?.cancel();
    return super.close();
  }
}
