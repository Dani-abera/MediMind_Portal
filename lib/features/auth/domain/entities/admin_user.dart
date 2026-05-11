import 'user.dart';

class AdminUser extends User {
  final String? centerId;
  final String? centerName;
  final String? centerStatus;

  const AdminUser({
    required super.id,
    required super.fullName,
    required super.email,
    this.centerId,
    this.centerName,
    this.centerStatus,
    super.avatarUrl,
  }) : super(role: UserRole.admin);

  @override
  List<Object?> get props => [...super.props, centerId, centerName, centerStatus];
}
