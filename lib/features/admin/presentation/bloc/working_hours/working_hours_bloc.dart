import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/working_hours.dart';
import '../../../domain/usecases/get_working_hours_usecase.dart';
import '../../../domain/usecases/save_working_hours_usecase.dart';

part 'working_hours_event.dart';
part 'working_hours_state.dart';

class WorkingHoursBloc extends Bloc<WorkingHoursEvent, WorkingHoursState> {
  final GetWorkingHoursUseCase _getWorkingHours;
  final SaveWorkingHoursUseCase _saveWorkingHours;

  String _centerId = '';
  WorkingHours _hours = const WorkingHours();

  WorkingHoursBloc({
    required GetWorkingHoursUseCase getWorkingHours,
    required SaveWorkingHoursUseCase saveWorkingHours,
  })  : _getWorkingHours = getWorkingHours,
        _saveWorkingHours = saveWorkingHours,
        super(const WorkingHoursInitial()) {
    on<WorkingHoursStarted>(_onStarted, transformer: droppable());
    on<WorkingHoursDayToggled>(_onDayToggled);
    on<WorkingHoursTimeChanged>(_onTimeChanged);
    on<WorkingHoursSubmitted>(_onSubmitted, transformer: droppable());
  }

  Future<void> _onStarted(WorkingHoursStarted event, Emitter<WorkingHoursState> emit) async {
    _centerId = event.centerId;
    emit(const WorkingHoursLoading());
    final result = await _getWorkingHours(_centerId);
    result.fold(
      (f) => emit(WorkingHoursError(f.message)),
      (hours) {
        _hours = hours;
        emit(WorkingHoursLoaded(hours));
      },
    );
  }

  void _onDayToggled(WorkingHoursDayToggled event, Emitter<WorkingHoursState> emit) {
    final days = List<DayHours>.from(_hours.days);
    if (event.dayIndex < days.length) {
      days[event.dayIndex] = days[event.dayIndex].copyWith(isClosed: event.isClosed);
    }
    _hours = _hours.copyWith(days: days);
    emit(WorkingHoursLoaded(_hours));
  }

  void _onTimeChanged(WorkingHoursTimeChanged event, Emitter<WorkingHoursState> emit) {
    final days = List<DayHours>.from(_hours.days);
    if (event.dayIndex < days.length) {
      final day = days[event.dayIndex];
      days[event.dayIndex] = switch (event.field) {
        'openTime' => day.copyWith(openTime: event.value),
        'closeTime' => day.copyWith(closeTime: event.value),
        'breakStart' => day.copyWith(breakStart: event.value),
        'breakEnd' => day.copyWith(breakEnd: event.value),
        _ => day,
      };
    }
    _hours = _hours.copyWith(days: days);
    emit(WorkingHoursLoaded(_hours));
  }

  Future<void> _onSubmitted(WorkingHoursSubmitted event, Emitter<WorkingHoursState> emit) async {
    emit(const WorkingHoursSaving());
    final result = await _saveWorkingHours(_centerId, _hours);
    result.fold(
      (f) => emit(WorkingHoursError(f.message)),
      (hours) {
        _hours = hours;
        emit(const WorkingHoursSaved());
        emit(WorkingHoursLoaded(_hours));
      },
    );
  }
}
