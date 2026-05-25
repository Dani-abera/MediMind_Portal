import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/platform_center.dart';
import '../../../domain/usecases/get_platform_centers_usecase.dart';
import '../../../domain/usecases/approve_center_usecase.dart';
import '../../../domain/usecases/reject_center_usecase.dart';
import '../../../domain/usecases/suspend_center_usecase.dart';
import '../../../domain/usecases/reactivate_center_usecase.dart';
import '../../../domain/usecases/verify_payment_usecase.dart';

part 'centers_event.dart';
part 'centers_state.dart';

class CentersBloc extends Bloc<CentersEvent, CentersState> {
  final GetPlatformCentersUseCase _getCenters;
  final ApproveCenterUseCase _approve;
  final RejectCenterUseCase _reject;
  final SuspendCenterUseCase _suspend;
  final ReactivateCenterUseCase _reactivate;
  final VerifyPaymentUseCase _verifyPayment;

  String? _statusFilter;
  int _page = 1;
  static const _pageSize = 20;

  CentersBloc({
    required GetPlatformCentersUseCase getCenters,
    required ApproveCenterUseCase approve,
    required RejectCenterUseCase reject,
    required SuspendCenterUseCase suspend,
    required ReactivateCenterUseCase reactivate,
    required VerifyPaymentUseCase verifyPayment,
  })  : _getCenters = getCenters,
        _approve = approve,
        _reject = reject,
        _suspend = suspend,
        _reactivate = reactivate,
        _verifyPayment = verifyPayment,
        super(const CentersInitial()) {
    on<CentersStarted>(_onStarted, transformer: droppable());
    on<CentersFiltered>(_onFiltered, transformer: droppable());
    on<CentersPageChanged>(_onPageChanged, transformer: droppable());
    on<CentersRefreshed>(_onRefreshed, transformer: droppable());
    on<CenterApproveRequested>(_onApprove, transformer: sequential());
    on<CenterRejectRequested>(_onReject, transformer: sequential());
    on<CenterSuspendRequested>(_onSuspend, transformer: sequential());
    on<CenterReactivateRequested>(_onReactivate, transformer: sequential());
    on<CenterVerifyPaymentRequested>(_onVerifyPayment, transformer: sequential());
  }

  Future<void> _fetch(Emitter<CentersState> emit) async {
    emit(const CentersLoading());
    final result = await _getCenters(status: _statusFilter, page: _page, pageSize: _pageSize);
    result.fold(
      (f) => emit(CentersError(f.message)),
      (r) => emit(CentersLoaded(centers: r.centers, total: r.total, page: _page)),
    );
  }

  Future<void> _onStarted(CentersStarted event, Emitter<CentersState> emit) async {
    _statusFilter = event.statusFilter;
    _page = 1;
    await _fetch(emit);
  }

  Future<void> _onFiltered(CentersFiltered event, Emitter<CentersState> emit) async {
    _statusFilter = event.statusFilter;
    _page = 1;
    await _fetch(emit);
  }

  Future<void> _onPageChanged(CentersPageChanged event, Emitter<CentersState> emit) async {
    _page = event.page;
    await _fetch(emit);
  }

  Future<void> _onRefreshed(CentersRefreshed event, Emitter<CentersState> emit) async {
    emit(const CentersLoading());
    await _fetch(emit);
  }

  Future<void> _onApprove(CenterApproveRequested event, Emitter<CentersState> emit) async {
    final result = await _approve(event.centerId, trialEndDate: event.trialEndDate, notes: event.notes);
    result.fold(
      (f) => emit(CentersActionError(f.message)),
      (_) {
        emit(const CentersActionSuccess('Center approved successfully'));
        add(const CentersRefreshed());
      },
    );
  }

  Future<void> _onReject(CenterRejectRequested event, Emitter<CentersState> emit) async {
    final result = await _reject(event.centerId, reason: event.reason);
    result.fold(
      (f) => emit(CentersActionError(f.message)),
      (_) {
        emit(const CentersActionSuccess('Center rejected'));
        add(const CentersRefreshed());
      },
    );
  }

  Future<void> _onSuspend(CenterSuspendRequested event, Emitter<CentersState> emit) async {
    final result = await _suspend(event.centerId, reason: event.reason, suspendUntil: event.suspendUntil);
    result.fold(
      (f) => emit(CentersActionError(f.message)),
      (_) {
        emit(const CentersActionSuccess('Center suspended'));
        add(const CentersRefreshed());
      },
    );
  }

  Future<void> _onReactivate(CenterReactivateRequested event, Emitter<CentersState> emit) async {
    final result = await _reactivate(event.centerId);
    result.fold(
      (f) => emit(CentersActionError(f.message)),
      (_) {
        emit(const CentersActionSuccess('Center reactivated'));
        add(const CentersRefreshed());
      },
    );
  }

  Future<void> _onVerifyPayment(CenterVerifyPaymentRequested event, Emitter<CentersState> emit) async {
    final result = await _verifyPayment(event.centerId);
    result.fold(
      (f) => emit(CentersActionError(f.message)),
      (_) {
        emit(const CentersActionSuccess('Payment verified — center is now active'));
        add(const CentersRefreshed());
      },
    );
  }
}
