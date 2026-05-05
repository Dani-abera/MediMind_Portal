part of 'admin_staff_bloc.dart';
abstract class AdminStaffEvent extends Equatable { const AdminStaffEvent(); @override List<Object?> get props => []; }
class AdminStaffStarted extends AdminStaffEvent { final String centerId; const AdminStaffStarted(this.centerId); @override List<Object?> get props => [centerId]; }
class AdminStaffRefreshed extends AdminStaffEvent { const AdminStaffRefreshed(); }
class AdminAddedToStaff extends AdminStaffEvent {
  final String name, email, phone;
  final AdminRole role;
  const AdminAddedToStaff({required this.name, required this.email, required this.phone, required this.role});
  @override List<Object?> get props => [name, email, phone, role];
}
class AdminDeactivatedFromStaff extends AdminStaffEvent {
  final String adminId;
  const AdminDeactivatedFromStaff(this.adminId);
  @override List<Object?> get props => [adminId];
}
