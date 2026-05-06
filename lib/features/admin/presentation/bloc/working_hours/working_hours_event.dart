part of 'working_hours_bloc.dart';

abstract class WorkingHoursEvent extends Equatable {
  const WorkingHoursEvent();
  @override
  List<Object?> get props => [];
}

class WorkingHoursStarted extends WorkingHoursEvent {
  final String centerId;
  const WorkingHoursStarted(this.centerId);
  @override
  List<Object?> get props => [centerId];
}

class WorkingHoursDayToggled extends WorkingHoursEvent {
  final int dayIndex;
  final bool isClosed;
  const WorkingHoursDayToggled(this.dayIndex, this.isClosed);
  @override
  List<Object?> get props => [dayIndex, isClosed];
}

class WorkingHoursTimeChanged extends WorkingHoursEvent {
  final int dayIndex;
  final String field;
  final String? value;
  const WorkingHoursTimeChanged(this.dayIndex, this.field, this.value);
  @override
  List<Object?> get props => [dayIndex, field, value];
}

class WorkingHoursSubmitted extends WorkingHoursEvent {
  const WorkingHoursSubmitted();
}
