part of 'appointment_list_bloc.dart';

abstract class AppointmentListEvent extends Equatable {
  const AppointmentListEvent();
  @override
  List<Object?> get props => [];
}

class AppointmentListStarted extends AppointmentListEvent {
  const AppointmentListStarted();
}

class AppointmentListFiltered extends AppointmentListEvent {
  final String? status;
  final DateTime? from;
  final DateTime? to;
  const AppointmentListFiltered({this.status, this.from, this.to});
  @override
  List<Object?> get props => [status, from, to];
}

class AppointmentListNextPage extends AppointmentListEvent {
  const AppointmentListNextPage();
}
