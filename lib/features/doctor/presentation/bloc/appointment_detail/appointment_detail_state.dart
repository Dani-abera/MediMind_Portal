part of 'appointment_detail_bloc.dart';

abstract class AppointmentDetailState extends Equatable {
  const AppointmentDetailState();
  @override
  List<Object?> get props => [];
}

class AppointmentDetailInitial extends AppointmentDetailState {
  const AppointmentDetailInitial();
}

class AppointmentDetailLoading extends AppointmentDetailState {
  const AppointmentDetailLoading();
}

class AppointmentDetailLoaded extends AppointmentDetailState {
  final Appointment appointment;
  final List<AppointmentNote> notes;
  const AppointmentDetailLoaded({
    required this.appointment,
    required this.notes,
  });
  @override
  List<Object?> get props => [appointment, notes];
}

class AppointmentDetailActionInProgress extends AppointmentDetailState {
  const AppointmentDetailActionInProgress();
}

class AppointmentDetailActionSuccess extends AppointmentDetailState {
  final Appointment appointment;
  const AppointmentDetailActionSuccess(this.appointment);
  @override
  List<Object?> get props => [appointment];
}

class AppointmentDetailError extends AppointmentDetailState {
  final String message;
  const AppointmentDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
