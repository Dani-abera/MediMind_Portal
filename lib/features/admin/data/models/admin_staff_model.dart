import '../../domain/entities/admin_staff.dart';

class AdminStaffModel extends AdminStaff {
  const AdminStaffModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.phone,
    required super.role,
    super.lastLogin,
    super.status,
    required super.centerId,
  });

  factory AdminStaffModel.fromJson(Map<String, dynamic> j) => AdminStaffModel(
        id: j['id'] as String? ?? '',
        fullName: j['fullName'] as String? ?? j['full_name'] as String? ?? j['name'] as String? ?? '',
        email: j['email'] as String? ?? '',
        phone: j['phone'] as String?,
        role: AdminRole.fromString(j['role'] as String?),
        lastLogin: DateTime.tryParse(j['lastLogin'] as String? ?? j['last_login'] as String? ?? ''),
        status: AdminStatus.fromString(j['status'] as String?),
        centerId: j['centerId'] as String? ?? j['center_id'] as String? ?? '',
      );
}
