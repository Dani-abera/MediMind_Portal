part of 'admin_appointment_detail_bloc.dart';

abstract class AdminApptDetailEvent extends Equatable {
  const AdminApptDetailEvent();
  @override List<Object?> get props => [];
}
class AdminApptDetailStarted extends AdminApptDetailEvent {
  final String id;
  const AdminApptDetailStarted(this.id);
  @override List<Object?> get props => [id];
}
class AdminApptApproved extends AdminApptDetailEvent { const AdminApptApproved(); }
class AdminApptRejected extends AdminApptDetailEvent {
  final String? reason;
  const AdminApptRejected({this.reason});
  @override List<Object?> get props => [reason];
}
class AdminApptCancelled extends AdminApptDetailEvent {
  final String? reason;
  const AdminApptCancelled({this.reason});
  @override List<Object?> get props => [reason];
}
