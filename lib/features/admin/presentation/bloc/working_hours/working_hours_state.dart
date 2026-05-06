part of 'working_hours_bloc.dart';

abstract class WorkingHoursState extends Equatable {
  const WorkingHoursState();
  @override
  List<Object?> get props => [];
}

class WorkingHoursInitial extends WorkingHoursState {
  const WorkingHoursInitial();
}

class WorkingHoursLoading extends WorkingHoursState {
  const WorkingHoursLoading();
}

class WorkingHoursLoaded extends WorkingHoursState {
  final WorkingHours hours;
  const WorkingHoursLoaded(this.hours);
  @override
  List<Object?> get props => [hours];
}

class WorkingHoursSaving extends WorkingHoursState {
  const WorkingHoursSaving();
}

class WorkingHoursSaved extends WorkingHoursState {
  const WorkingHoursSaved();
}

class WorkingHoursError extends WorkingHoursState {
  final String message;
  const WorkingHoursError(this.message);
  @override
  List<Object?> get props => [message];
}
