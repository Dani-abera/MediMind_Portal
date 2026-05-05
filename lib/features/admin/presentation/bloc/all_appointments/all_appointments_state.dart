part of 'all_appointments_bloc.dart';

class AllApptsFilter extends Equatable {
  final String? status, doctorId, paymentStatus, search;
  final DateTime? from, to;
  final bool todayOnly;
  const AllApptsFilter({this.status, this.doctorId, this.from, this.to,
      this.paymentStatus, this.search, this.todayOnly = false});
  @override List<Object?> get props => [status, doctorId, from, to, paymentStatus, search, todayOnly];
}

abstract class AllAppointmentsState extends Equatable {
  const AllAppointmentsState();
  @override List<Object?> get props => [];
}
class AllApptsInitial extends AllAppointmentsState { const AllApptsInitial(); }
class AllApptsLoading extends AllAppointmentsState { const AllApptsLoading(); }
class AllApptsLoaded extends AllAppointmentsState {
  final List<AdminAppointment> appointments;
  final int page, pageSize, total;
  final AllApptsFilter filters;
  const AllApptsLoaded({required this.appointments, required this.page,
      required this.pageSize, required this.total, required this.filters});
  @override List<Object?> get props => [appointments, page, pageSize, total, filters];
}
class AllApptsActionInProgress extends AllAppointmentsState { const AllApptsActionInProgress(); }
class AllApptsError extends AllAppointmentsState {
  final String message;
  const AllApptsError(this.message);
  @override List<Object?> get props => [message];
}
