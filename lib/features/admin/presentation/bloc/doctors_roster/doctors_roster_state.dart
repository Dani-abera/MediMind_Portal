part of 'doctors_roster_bloc.dart';

abstract class DoctorsRosterState extends Equatable {
  const DoctorsRosterState();
  @override List<Object?> get props => [];
}
class DoctorsRosterInitial extends DoctorsRosterState { const DoctorsRosterInitial(); }
class DoctorsRosterLoading extends DoctorsRosterState { const DoctorsRosterLoading(); }
class DoctorsRosterLoaded extends DoctorsRosterState {
  final List<DoctorAtCenter> doctors;
  const DoctorsRosterLoaded(this.doctors);
  @override List<Object?> get props => [doctors];
}
class DoctorsRosterActionInProgress extends DoctorsRosterState { const DoctorsRosterActionInProgress(); }
class DoctorsRosterActionSuccess extends DoctorsRosterState {
  final String message;
  const DoctorsRosterActionSuccess(this.message);
  @override List<Object?> get props => [message];
}
class DoctorsRosterError extends DoctorsRosterState {
  final String message;
  const DoctorsRosterError(this.message);
  @override List<Object?> get props => [message];
}
class DoctorScheduleLoading extends DoctorsRosterState { const DoctorScheduleLoading(); }
class DoctorScheduleLoaded extends DoctorsRosterState {
  final DoctorScheduleConfig? config;
  const DoctorScheduleLoaded(this.config);
  @override List<Object?> get props => [config];
}
class DoctorInvitationSent extends DoctorsRosterState {
  final String message;
  const DoctorInvitationSent(this.message);
  @override List<Object?> get props => [message];
}
class ScheduleExceptionsLoaded extends DoctorsRosterState {
  final String doctorId;
  final List<ScheduleException> exceptions;
  const ScheduleExceptionsLoaded(this.doctorId, this.exceptions);
  @override List<Object?> get props => [doctorId, exceptions];
}
