import 'user.dart';

class AdminUser extends User {
  final String centerId;
  final String centerName;

  const AdminUser({
    required super.id,
    required super.fullName,
    required super.email,
    required this.centerId,
    required this.centerName,
    super.avatarUrl,
  }) : super(role: UserRole.admin);

  @override
  List<Object?> get props => [...super.props, centerId, centerName];
}
