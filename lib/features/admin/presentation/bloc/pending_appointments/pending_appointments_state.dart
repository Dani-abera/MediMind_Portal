part of 'pending_appointments_bloc.dart';

abstract class PendingAppointmentsState extends Equatable {
  const PendingAppointmentsState();
  @override List<Object?> get props => [];
}
class PendingApptsInitial extends PendingAppointmentsState { const PendingApptsInitial(); }
class PendingApptsLoading extends PendingAppointmentsState { const PendingApptsLoading(); }
class PendingApptsLoaded extends PendingAppointmentsState {
  final List<AdminAppointment> appointments;
  final Set<String> selectedIds;
  final String? doctorFilter;
  final DateTime? from;
  final DateTime? to;
  const PendingApptsLoaded({
    required this.appointments,
    this.selectedIds = const {},
    this.doctorFilter,
    this.from,
    this.to,
  });
  PendingApptsLoaded copyWith({Set<String>? selectedIds}) => PendingApptsLoaded(
        appointments: appointments,
        selectedIds: selectedIds ?? this.selectedIds,
        doctorFilter: doctorFilter,
        from: from,
        to: to,
      );
  @override List<Object?> get props => [appointments, selectedIds, doctorFilter, from, to];
}
class PendingApptsActionInProgress extends PendingAppointmentsState { const PendingApptsActionInProgress(); }
class PendingApptsActionSuccess extends PendingAppointmentsState {
  final String message;
  const PendingApptsActionSuccess(this.message);
  @override List<Object?> get props => [message];
}
class PendingApptsError extends PendingAppointmentsState {
  final String message;
  const PendingApptsError(this.message);
  @override List<Object?> get props => [message];
}
