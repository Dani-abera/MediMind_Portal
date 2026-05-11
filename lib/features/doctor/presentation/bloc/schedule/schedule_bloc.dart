import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/doctor_schedule.dart';
import '../../../domain/usecases/get_doctor_schedules_usecase.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final GetDoctorSchedulesUseCase _getSchedules;

  ScheduleBloc({required GetDoctorSchedulesUseCase getSchedules})
      : _getSchedules = getSchedules,
        super(const ScheduleInitial()) {
    on<ScheduleStarted>(_onStarted, transformer: droppable());
    on<ScheduleRefreshed>(_onRefreshed, transformer: droppable());
  }

  Future<void> _onStarted(
    ScheduleStarted event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleLoading());
    final result = await _getSchedules();
    result.fold(
      (f) => emit(ScheduleError(f.message)),
      (schedules) => emit(ScheduleLoaded(schedules)),
    );
  }

  Future<void> _onRefreshed(
    ScheduleRefreshed event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleLoading());
    final result = await _getSchedules();
    result.fold(
      (f) => emit(ScheduleError(f.message)),
      (schedules) => emit(ScheduleLoaded(schedules)),
    );
  }
}
