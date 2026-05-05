import 'package:equatable/equatable.dart';

enum AdminRole {
  admin,
  receptionist;

  static AdminRole fromString(String? s) => switch (s?.toLowerCase()) {
        'receptionist' => receptionist,
        _ => admin,
      };

  String get label => switch (this) {
        admin => 'Admin',
        receptionist => 'Receptionist',
      };
}

enum AdminStatus {
  active,
  suspended;

  static AdminStatus fromString(String? s) => switch (s?.toLowerCase()) {
        'suspended' => suspended,
        _ => active,
      };
}

class AdminStaff extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final AdminRole role;
  final DateTime? lastLogin;
  final AdminStatus status;
  final String centerId;

  const AdminStaff({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.lastLogin,
    this.status = AdminStatus.active,
    required this.centerId,
  });

  @override
  List<Object?> get props => [id, fullName, email, phone, role, lastLogin, status, centerId];
}
