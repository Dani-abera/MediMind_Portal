part of 'doctors_roster_bloc.dart';

abstract class DoctorsRosterEvent extends Equatable {
  const DoctorsRosterEvent();
  @override List<Object?> get props => [];
}
class DoctorsRosterStarted extends DoctorsRosterEvent {
  final String centerId;
  const DoctorsRosterStarted(this.centerId);
  @override List<Object?> get props => [centerId];
}
class DoctorsRosterRefreshed extends DoctorsRosterEvent { const DoctorsRosterRefreshed(); }
class DoctorAddedToCenter extends DoctorsRosterEvent {
  final String licenseNumber;
  const DoctorAddedToCenter(this.licenseNumber);
  @override List<Object?> get props => [licenseNumber];
}
class DoctorRemovedFromCenter extends DoctorsRosterEvent {
  final String doctorId;
  const DoctorRemovedFromCenter(this.doctorId);
  @override List<Object?> get props => [doctorId];
}
class DoctorScheduleConfigured extends DoctorsRosterEvent {
  final DoctorScheduleConfig config;
  const DoctorScheduleConfigured(this.config);
  @override List<Object?> get props => [config];
}
class DoctorScheduleDeleted extends DoctorsRosterEvent {
  final String scheduleId;
  const DoctorScheduleDeleted(this.scheduleId);
  @override List<Object?> get props => [scheduleId];
}
class DoctorScheduleRequested extends DoctorsRosterEvent {
  final String doctorId;
  const DoctorScheduleRequested(this.doctorId);
  @override List<Object?> get props => [doctorId];
}
