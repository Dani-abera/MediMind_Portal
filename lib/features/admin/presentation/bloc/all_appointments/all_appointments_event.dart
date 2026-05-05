part of 'all_appointments_bloc.dart';

abstract class AllAppointmentsEvent extends Equatable {
  const AllAppointmentsEvent();
  @override List<Object?> get props => [];
}
class AllApptsStarted extends AllAppointmentsEvent { const AllApptsStarted(); }
class AllApptsFiltered extends AllAppointmentsEvent {
  final String? status, doctorId, paymentStatus, search;
  final DateTime? from, to;
  final bool todayOnly;
  const AllApptsFiltered({this.status, this.doctorId, this.from, this.to,
      this.paymentStatus, this.search, this.todayOnly = false});
  @override List<Object?> get props => [status, doctorId, from, to, paymentStatus, search, todayOnly];
}
class AllApptsPageChanged extends AllAppointmentsEvent {
  final int page;
  const AllApptsPageChanged(this.page);
  @override List<Object?> get props => [page];
}
class AllApptCancelled extends AllAppointmentsEvent {
  final String id;
  final String? reason;
  const AllApptCancelled(this.id, {this.reason});
  @override List<Object?> get props => [id, reason];
}
