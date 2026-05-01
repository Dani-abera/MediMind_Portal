part of 'appointment_list_bloc.dart';

abstract class AppointmentListState extends Equatable {
  const AppointmentListState();
  @override
  List<Object?> get props => [];
}

class AppointmentListInitial extends AppointmentListState {
  const AppointmentListInitial();
}

class AppointmentListLoading extends AppointmentListState {
  const AppointmentListLoading();
}

class AppointmentListLoaded extends AppointmentListState {
  final List<Appointment> appointments;
  final bool hasMore;
  final int page;
  const AppointmentListLoaded({
    required this.appointments,
    required this.hasMore,
    required this.page,
  });
  @override
  List<Object?> get props => [appointments, hasMore, page];
}

class AppointmentListError extends AppointmentListState {
  final String message;
  const AppointmentListError(this.message);
  @override
  List<Object?> get props => [message];
}
