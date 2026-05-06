import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/platform_doctor.dart';
import '../../../domain/usecases/get_platform_doctors_usecase.dart';
import '../../../domain/usecases/verify_doctor_license_usecase.dart';
import '../../../domain/usecases/suspend_platform_doctor_usecase.dart';

part 'platform_doctors_event.dart';
part 'platform_doctors_state.dart';

class PlatformDoctorsBloc extends Bloc<PlatformDoctorsEvent, PlatformDoctorsState> {
  final GetPlatformDoctorsUseCase _getDoctors;
  final VerifyDoctorLicenseUseCase _verify;
  final SuspendPlatformDoctorUseCase _suspend;

  String? _statusFilter;
  int _page = 1;
  static const _pageSize = 20;

  PlatformDoctorsBloc({
    required GetPlatformDoctorsUseCase getDoctors,
    required VerifyDoctorLicenseUseCase verify,
    required SuspendPlatformDoctorUseCase suspend,
  })  : _getDoctors = getDoctors,
        _verify = verify,
        _suspend = suspend,
        super(const PlatformDoctorsInitial()) {
    on<PlatformDoctorsStarted>(_onStarted, transformer: droppable());
    on<PlatformDoctorsFiltered>(_onFiltered, transformer: droppable());
    on<PlatformDoctorsPageChanged>(_onPageChanged, transformer: droppable());
    on<PlatformDoctorsRefreshed>(_onRefreshed, transformer: droppable());
    on<DoctorVerifyLicenseRequested>(_onVerify, transformer: sequential());
    on<DoctorSuspendRequested>(_onSuspend, transformer: sequential());
  }

  Future<void> _fetch(Emitter<PlatformDoctorsState> emit) async {
    emit(const PlatformDoctorsLoading());
    final result = await _getDoctors(status: _statusFilter, page: _page, pageSize: _pageSize);
    result.fold(
      (f) => emit(PlatformDoctorsError(f.message)),
      (r) => emit(PlatformDoctorsLoaded(doctors: r.doctors, total: r.total, page: _page)),
    );
  }

  Future<void> _onStarted(PlatformDoctorsStarted event, Emitter<PlatformDoctorsState> emit) async {
    _statusFilter = event.statusFilter;
    _page = 1;
    await _fetch(emit);
  }

  Future<void> _onFiltered(PlatformDoctorsFiltered event, Emitter<PlatformDoctorsState> emit) async {
    _statusFilter = event.statusFilter;
    _page = 1;
    await _fetch(emit);
  }

  Future<void> _onPageChanged(PlatformDoctorsPageChanged event, Emitter<PlatformDoctorsState> emit) async {
    _page = event.page;
    await _fetch(emit);
  }

  Future<void> _onRefreshed(PlatformDoctorsRefreshed event, Emitter<PlatformDoctorsState> emit) async {
    await _fetch(emit);
  }

  Future<void> _onVerify(DoctorVerifyLicenseRequested event, Emitter<PlatformDoctorsState> emit) async {
    final result = await _verify(event.doctorId, notes: event.notes);
    result.fold(
      (f) => emit(PlatformDoctorsActionError(f.message)),
      (_) {
        emit(const PlatformDoctorsActionSuccess('License verified successfully'));
        add(const PlatformDoctorsRefreshed());
      },
    );
  }

  Future<void> _onSuspend(DoctorSuspendRequested event, Emitter<PlatformDoctorsState> emit) async {
    final result = await _suspend(event.doctorId, reason: event.reason);
    result.fold(
      (f) => emit(PlatformDoctorsActionError(f.message)),
      (_) {
        emit(const PlatformDoctorsActionSuccess('Doctor suspended'));
        add(const PlatformDoctorsRefreshed());
      },
    );
  }
}
