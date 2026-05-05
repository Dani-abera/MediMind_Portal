import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/admin_appointment.dart';
import '../../../domain/usecases/get_pending_appointments_usecase.dart';
import '../../../domain/usecases/approve_appointment_usecase.dart';
import '../../../domain/usecases/reject_appointment_usecase.dart';
import '../../../domain/usecases/bulk_approve_usecase.dart';

part 'pending_appointments_event.dart';
part 'pending_appointments_state.dart';

class PendingAppointmentsBloc
    extends Bloc<PendingAppointmentsEvent, PendingAppointmentsState> {
  final GetPendingAppointmentsUseCase _getPending;
  final ApproveAppointmentUseCase _approve;
  final RejectAppointmentUseCase _reject;
  final BulkApproveUseCase _bulkApprove;

  String? _doctorFilter;
  DateTime? _from;
  DateTime? _to;

  PendingAppointmentsBloc({
    required GetPendingAppointmentsUseCase getPending,
    required ApproveAppointmentUseCase approve,
    required RejectAppointmentUseCase reject,
    required BulkApproveUseCase bulkApprove,
  })  : _getPending = getPending,
        _approve = approve,
        _reject = reject,
        _bulkApprove = bulkApprove,
        super(const PendingApptsInitial()) {
    on<PendingApptsStarted>(_onStarted, transformer: droppable());
    on<PendingApptsRefreshed>(_onRefreshed, transformer: droppable());
    on<PendingApptsFiltered>(_onFiltered, transformer: droppable());
    on<PendingSelectionChanged>(_onSelectionChanged);
    on<PendingApptApproved>(_onApproved, transformer: droppable());
    on<PendingApptRejected>(_onRejected, transformer: droppable());
    on<PendingBulkApproved>(_onBulkApproved, transformer: droppable());
    on<PendingBulkRejected>(_onBulkRejected, transformer: droppable());
  }

  Future<void> _fetch(Emitter<PendingAppointmentsState> emit,
      {Set<String> selectedIds = const {}}) async {
    final result = await _getPending(
        doctorId: _doctorFilter, from: _from, to: _to);
    result.fold(
      (f) => emit(PendingApptsError(f.message)),
      (items) => emit(PendingApptsLoaded(
        appointments: items,
        selectedIds: selectedIds,
        doctorFilter: _doctorFilter,
        from: _from,
        to: _to,
      )),
    );
  }

  Future<void> _onStarted(PendingApptsStarted _, Emitter<PendingAppointmentsState> emit) async {
    emit(const PendingApptsLoading());
    await _fetch(emit);
  }

  Future<void> _onRefreshed(PendingApptsRefreshed _, Emitter<PendingAppointmentsState> emit) async {
    await _fetch(emit);
  }

  Future<void> _onFiltered(PendingApptsFiltered event, Emitter<PendingAppointmentsState> emit) async {
    _doctorFilter = event.doctorId;
    _from = event.from;
    _to = event.to;
    emit(const PendingApptsLoading());
    await _fetch(emit);
  }

  void _onSelectionChanged(PendingSelectionChanged event, Emitter<PendingAppointmentsState> emit) {
    if (state is PendingApptsLoaded) {
      final current = state as PendingApptsLoaded;
      emit(current.copyWith(selectedIds: event.selectedIds.toSet()));
    }
  }

  Future<void> _onApproved(PendingApptApproved event, Emitter<PendingAppointmentsState> emit) async {
    emit(const PendingApptsActionInProgress());
    final result = await _approve(event.id);
    await result.fold(
      (f) async => emit(PendingApptsError(f.message)),
      (_) async {
        emit(const PendingApptsActionSuccess('Appointment approved'));
        await _fetch(emit);
      },
    );
  }

  Future<void> _onRejected(PendingApptRejected event, Emitter<PendingAppointmentsState> emit) async {
    emit(const PendingApptsActionInProgress());
    final result = await _reject(event.id, reason: event.reason);
    await result.fold(
      (f) async => emit(PendingApptsError(f.message)),
      (_) async {
        emit(const PendingApptsActionSuccess('Appointment rejected'));
        await _fetch(emit);
      },
    );
  }

  Future<void> _onBulkApproved(PendingBulkApproved _, Emitter<PendingAppointmentsState> emit) async {
    if (state is! PendingApptsLoaded) return;
    final ids = (state as PendingApptsLoaded).selectedIds.toList();
    if (ids.isEmpty) return;
    emit(const PendingApptsActionInProgress());
    final result = await _bulkApprove(ids);
    await result.fold(
      (f) async => emit(PendingApptsError(f.message)),
      (_) async {
        emit(PendingApptsActionSuccess('${ids.length} appointments approved'));
        await _fetch(emit);
      },
    );
  }

  Future<void> _onBulkRejected(PendingBulkRejected event, Emitter<PendingAppointmentsState> emit) async {
    if (state is! PendingApptsLoaded) return;
    final ids = (state as PendingApptsLoaded).selectedIds.toList();
    if (ids.isEmpty) return;
    emit(const PendingApptsActionInProgress());
    for (final id in ids) {
      await _reject(id, reason: event.reason);
    }
    emit(PendingApptsActionSuccess('${ids.length} appointments rejected'));
    await _fetch(emit);
  }
}
