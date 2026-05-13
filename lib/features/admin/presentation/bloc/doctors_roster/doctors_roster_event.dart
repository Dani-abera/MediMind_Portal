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
class DoctorInvited extends DoctorsRosterEvent {
  final InviteDoctorDto dto;
  const DoctorInvited(this.dto);
  @override List<Object?> get props => [dto];
}
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
class ScheduleExceptionsRequested extends DoctorsRosterEvent {
  final String doctorId;
  const ScheduleExceptionsRequested(this.doctorId);
  @override List<Object?> get props => [doctorId];
}
class ScheduleExceptionAdded extends DoctorsRosterEvent {
  final String doctorId;
  final ScheduleException exception;
  const ScheduleExceptionAdded(this.doctorId, this.exception);
  @override List<Object?> get props => [doctorId, exception];
}
class ScheduleExceptionRemoved extends DoctorsRosterEvent {
  final String doctorId;
  final DateTime date;
  const ScheduleExceptionRemoved(this.doctorId, this.date);
  @override List<Object?> get props => [doctorId, date];
}

class DoctorFeeUpdateRequested extends DoctorsRosterEvent {
  final String doctorId;
  final double newFee;
  const DoctorFeeUpdateRequested(this.doctorId, this.newFee);
  @override List<Object?> get props => [doctorId, newFee];
}
