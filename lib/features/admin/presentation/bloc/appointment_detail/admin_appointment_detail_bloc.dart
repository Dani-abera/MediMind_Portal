import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/admin_appointment.dart';
import '../../../domain/usecases/get_admin_appointment_detail_usecase.dart';
import '../../../domain/usecases/approve_appointment_usecase.dart';
import '../../../domain/usecases/reject_appointment_usecase.dart';
import '../../../domain/usecases/cancel_appointment_admin_usecase.dart';

part 'admin_appointment_detail_event.dart';
part 'admin_appointment_detail_state.dart';

class AdminAppointmentDetailBloc
    extends Bloc<AdminApptDetailEvent, AdminApptDetailState> {
  final GetAdminAppointmentDetailUseCase _getDetail;
  final ApproveAppointmentUseCase _approve;
  final RejectAppointmentUseCase _reject;
  final CancelAppointmentAdminUseCase _cancel;

  String _id = '';

  AdminAppointmentDetailBloc({
    required GetAdminAppointmentDetailUseCase getDetail,
    required ApproveAppointmentUseCase approve,
    required RejectAppointmentUseCase reject,
    required CancelAppointmentAdminUseCase cancel,
  })  : _getDetail = getDetail,
        _approve = approve,
        _reject = reject,
        _cancel = cancel,
        super(const AdminApptDetailInitial()) {
    on<AdminApptDetailStarted>(_onStarted, transformer: droppable());
    on<AdminApptApproved>(_onApproved, transformer: droppable());
    on<AdminApptRejected>(_onRejected, transformer: droppable());
    on<AdminApptCancelled>(_onCancelled, transformer: droppable());
  }

  Future<void> _fetch(Emitter<AdminApptDetailState> emit) async {
    final result = await _getDetail(_id);
    result.fold(
      (f) => emit(AdminApptDetailError(f.message)),
      (a) => emit(AdminApptDetailLoaded(a)),
    );
  }

  Future<void> _onStarted(AdminApptDetailStarted event, Emitter<AdminApptDetailState> emit) async {
    _id = event.id;
    emit(const AdminApptDetailLoading());
    await _fetch(emit);
  }

  Future<void> _onApproved(AdminApptApproved _, Emitter<AdminApptDetailState> emit) async {
    emit(const AdminApptDetailActionInProgress());
    final result = await _approve(_id);
    result.fold(
      (f) => emit(AdminApptDetailError(f.message)),
      (_) async { emit(const AdminApptDetailActionSuccess()); await _fetch(emit); },
    );
  }

  Future<void> _onRejected(AdminApptRejected event, Emitter<AdminApptDetailState> emit) async {
    emit(const AdminApptDetailActionInProgress());
    final result = await _reject(_id, reason: event.reason);
    result.fold(
      (f) => emit(AdminApptDetailError(f.message)),
      (_) async { emit(const AdminApptDetailActionSuccess()); await _fetch(emit); },
    );
  }

  Future<void> _onCancelled(AdminApptCancelled event, Emitter<AdminApptDetailState> emit) async {
    emit(const AdminApptDetailActionInProgress());
    final result = await _cancel(_id, reason: event.reason);
    result.fold(
      (f) => emit(AdminApptDetailError(f.message)),
      (_) async { emit(const AdminApptDetailActionSuccess()); await _fetch(emit); },
    );
  }
}
