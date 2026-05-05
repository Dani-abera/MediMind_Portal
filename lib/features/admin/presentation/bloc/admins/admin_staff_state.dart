part of 'admin_staff_bloc.dart';
abstract class AdminStaffState extends Equatable { const AdminStaffState(); @override List<Object?> get props => []; }
class AdminStaffInitial extends AdminStaffState { const AdminStaffInitial(); }
class AdminStaffLoading extends AdminStaffState { const AdminStaffLoading(); }
class AdminStaffLoaded extends AdminStaffState {
  final List<AdminStaff> staff;
  final String currentUserId;
  const AdminStaffLoaded({required this.staff, required this.currentUserId});
  @override List<Object?> get props => [staff, currentUserId];
}
class AdminStaffActionInProgress extends AdminStaffState { const AdminStaffActionInProgress(); }
class AdminStaffActionSuccess extends AdminStaffState { final String message; const AdminStaffActionSuccess(this.message); @override List<Object?> get props => [message]; }
class AdminStaffError extends AdminStaffState { final String message; const AdminStaffError(this.message); @override List<Object?> get props => [message]; }
