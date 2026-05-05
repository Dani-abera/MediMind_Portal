part of 'pending_appointments_bloc.dart';

abstract class PendingAppointmentsEvent extends Equatable {
  const PendingAppointmentsEvent();
  @override List<Object?> get props => [];
}
class PendingApptsStarted extends PendingAppointmentsEvent { const PendingApptsStarted(); }
class PendingApptsRefreshed extends PendingAppointmentsEvent { const PendingApptsRefreshed(); }
class PendingApptsFiltered extends PendingAppointmentsEvent {
  final String? doctorId;
  final DateTime? from;
  final DateTime? to;
  const PendingApptsFiltered({this.doctorId, this.from, this.to});
  @override List<Object?> get props => [doctorId, from, to];
}
class PendingSelectionChanged extends PendingAppointmentsEvent {
  final List<String> selectedIds;
  const PendingSelectionChanged(this.selectedIds);
  @override List<Object?> get props => [selectedIds];
}
class PendingApptApproved extends PendingAppointmentsEvent {
  final String id;
  const PendingApptApproved(this.id);
  @override List<Object?> get props => [id];
}
class PendingApptRejected extends PendingAppointmentsEvent {
  final String id;
  final String? reason;
  const PendingApptRejected(this.id, {this.reason});
  @override List<Object?> get props => [id, reason];
}
class PendingBulkApproved extends PendingAppointmentsEvent { const PendingBulkApproved(); }
class PendingBulkRejected extends PendingAppointmentsEvent {
  final String? reason;
  const PendingBulkRejected({this.reason});
  @override List<Object?> get props => [reason];
}
