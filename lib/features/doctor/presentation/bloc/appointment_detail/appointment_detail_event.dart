part of 'appointment_detail_bloc.dart';

abstract class AppointmentDetailEvent extends Equatable {
  const AppointmentDetailEvent();
  @override
  List<Object?> get props => [];
}

class AppointmentDetailStarted extends AppointmentDetailEvent {
  final String id;
  const AppointmentDetailStarted(this.id);
  @override
  List<Object?> get props => [id];
}

class AppointmentNoteAdded extends AppointmentDetailEvent {
  final String content;
  const AppointmentNoteAdded(this.content);
  @override
  List<Object?> get props => [content];
}

class AppointmentCancelled extends AppointmentDetailEvent {
  const AppointmentCancelled();
}

class AppointmentCompleted extends AppointmentDetailEvent {
  const AppointmentCompleted();
}

class AppointmentDeclined extends AppointmentDetailEvent {
  final String reason;
  const AppointmentDeclined(this.reason);
  @override
  List<Object?> get props => [reason];
}
