import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/doctor_at_center.dart';
import '../../../domain/usecases/get_doctors_at_center_usecase.dart';
import '../../../domain/usecases/add_doctor_to_center_usecase.dart';
import '../../../domain/usecases/remove_doctor_from_center_usecase.dart';
import '../../../domain/usecases/configure_doctor_schedule_usecase.dart';
import '../../../domain/usecases/get_doctor_schedule_usecase.dart';
import '../../../domain/usecases/delete_doctor_schedule_usecase.dart';

part 'doctors_roster_event.dart';
part 'doctors_roster_state.dart';

class DoctorsRosterBloc extends Bloc<DoctorsRosterEvent, DoctorsRosterState> {
  final GetDoctorsAtCenterUseCase _getDoctors;
  final AddDoctorToCenterUseCase _addDoctor;
  final RemoveDoctorFromCenterUseCase _removeDoctor;
  final ConfigureDoctorScheduleUseCase _configureSchedule;
  final GetDoctorScheduleUseCase _getSchedule;
  final DeleteDoctorScheduleUseCase _deleteSchedule;

  String _centerId = '';

  DoctorsRosterBloc({
    required GetDoctorsAtCenterUseCase getDoctors,
    required AddDoctorToCenterUseCase addDoctor,
    required RemoveDoctorFromCenterUseCase removeDoctor,
    required ConfigureDoctorScheduleUseCase configureSchedule,
    required GetDoctorScheduleUseCase getSchedule,
    required DeleteDoctorScheduleUseCase deleteSchedule,
  })  : _getDoctors = getDoctors,
        _addDoctor = addDoctor,
        _removeDoctor = removeDoctor,
        _configureSchedule = configureSchedule,
        _getSchedule = getSchedule,
        _deleteSchedule = deleteSchedule,
        super(const DoctorsRosterInitial()) {
    on<DoctorsRosterStarted>(_onStarted, transformer: droppable());
    on<DoctorsRosterRefreshed>(_onRefreshed, transformer: droppable());
    on<DoctorAddedToCenter>(_onDoctorAdded, transformer: droppable());
    on<DoctorRemovedFromCenter>(_onDoctorRemoved, transformer: droppable());
    on<DoctorScheduleConfigured>(_onScheduleConfigured, transformer: droppable());
    on<DoctorScheduleDeleted>(_onScheduleDeleted, transformer: droppable());
    on<DoctorScheduleRequested>(_onScheduleRequested, transformer: droppable());
  }

  Future<void> _fetch(Emitter<DoctorsRosterState> emit) async {
    final result = await _getDoctors(_centerId);
    result.fold(
      (f) => emit(DoctorsRosterError(f.message)),
      (doctors) => emit(DoctorsRosterLoaded(doctors)),
    );
  }

  Future<void> _onStarted(DoctorsRosterStarted event, Emitter<DoctorsRosterState> emit) async {
    _centerId = event.centerId;
    emit(const DoctorsRosterLoading());
    await _fetch(emit);
  }

  Future<void> _onRefreshed(DoctorsRosterRefreshed _, Emitter<DoctorsRosterState> emit) async {
    await _fetch(emit);
  }

  Future<void> _onDoctorAdded(DoctorAddedToCenter event, Emitter<DoctorsRosterState> emit) async {
    emit(const DoctorsRosterActionInProgress());
    final result = await _addDoctor(_centerId, event.licenseNumber);
    result.fold(
      (f) => emit(DoctorsRosterError(f.message)),
      (_) async {
        emit(const DoctorsRosterActionSuccess('Doctor added successfully'));
        await _fetch(emit);
      },
    );
  }

  Future<void> _onDoctorRemoved(DoctorRemovedFromCenter event, Emitter<DoctorsRosterState> emit) async {
    emit(const DoctorsRosterActionInProgress());
    final result = await _removeDoctor(_centerId, event.doctorId);
    result.fold(
      (f) => emit(DoctorsRosterError(f.message)),
      (_) async {
        emit(const DoctorsRosterActionSuccess('Doctor removed'));
        await _fetch(emit);
      },
    );
  }

  Future<void> _onScheduleConfigured(DoctorScheduleConfigured event, Emitter<DoctorsRosterState> emit) async {
    emit(const DoctorsRosterActionInProgress());
    final result = await _configureSchedule(event.config);
    result.fold(
      (f) => emit(DoctorsRosterError(f.message)),
      (_) => emit(const DoctorsRosterActionSuccess('Schedule saved')),
    );
  }

  Future<void> _onScheduleDeleted(DoctorScheduleDeleted event, Emitter<DoctorsRosterState> emit) async {
    emit(const DoctorsRosterActionInProgress());
    final result = await _deleteSchedule(event.scheduleId);
    result.fold(
      (f) => emit(DoctorsRosterError(f.message)),
      (_) => emit(const DoctorsRosterActionSuccess('Schedule deleted')),
    );
  }

  Future<void> _onScheduleRequested(DoctorScheduleRequested event, Emitter<DoctorsRosterState> emit) async {
    emit(const DoctorScheduleLoading());
    final result = await _getSchedule(event.doctorId, _centerId);
    result.fold(
      (f) => emit(DoctorsRosterError(f.message)),
      (config) => emit(DoctorScheduleLoaded(config)),
    );
  }
}
