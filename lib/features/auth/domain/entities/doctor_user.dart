import 'user.dart';

class DoctorUser extends User {
  final String badgeNumber;
  final String? specialization;

  const DoctorUser({
    required super.id,
    required super.fullName,
    required super.email,
    required this.badgeNumber,
    this.specialization,
    super.avatarUrl,
  }) : super(role: UserRole.doctor);

  @override
  List<Object?> get props =>
      [...super.props, badgeNumber, specialization];
}
