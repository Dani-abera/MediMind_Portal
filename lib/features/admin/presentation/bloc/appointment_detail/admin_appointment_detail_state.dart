part of 'admin_appointment_detail_bloc.dart';

abstract class AdminApptDetailState extends Equatable {
  const AdminApptDetailState();
  @override List<Object?> get props => [];
}
class AdminApptDetailInitial extends AdminApptDetailState { const AdminApptDetailInitial(); }
class AdminApptDetailLoading extends AdminApptDetailState { const AdminApptDetailLoading(); }
class AdminApptDetailLoaded extends AdminApptDetailState {
  final AdminAppointment appointment;
  const AdminApptDetailLoaded(this.appointment);
  @override List<Object?> get props => [appointment];
}
class AdminApptDetailActionInProgress extends AdminApptDetailState { const AdminApptDetailActionInProgress(); }
class AdminApptDetailActionSuccess extends AdminApptDetailState { const AdminApptDetailActionSuccess(); }
class AdminApptDetailError extends AdminApptDetailState {
  final String message;
  const AdminApptDetailError(this.message);
  @override List<Object?> get props => [message];
}
