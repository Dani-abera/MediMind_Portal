import 'user.dart';

class SuperAdminUser extends User {
  const SuperAdminUser({
    required super.id,
    required super.fullName,
    required super.email,
    super.avatarUrl,
  }) : super(role: UserRole.superAdmin);
}
