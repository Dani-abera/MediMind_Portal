part of 'schedule_bloc.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();
  @override
  List<Object?> get props => [];
}

class ScheduleStarted extends ScheduleEvent {
  const ScheduleStarted();
}

class ScheduleRefreshed extends ScheduleEvent {
  const ScheduleRefreshed();
}
