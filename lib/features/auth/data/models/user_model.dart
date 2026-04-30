import '../../domain/entities/admin_user.dart';
import '../../domain/entities/doctor_user.dart';
import '../../domain/entities/super_admin_user.dart';
import '../../domain/entities/user.dart';

abstract class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.role,
    super.avatarUrl,
  });

  static User fromJson(Map<String, dynamic> json) {
    final roleRaw = json['userType'] as String? ?? json['role'] as String? ?? '';
    final role = _parseRole(roleRaw);

    switch (role) {
      case UserRole.doctor:
        return DoctorUserModel.fromJson(json);
      case UserRole.admin:
        return AdminUserModel.fromJson(json);
      case UserRole.superAdmin:
        return SuperAdminUserModel.fromJson(json);
    }
  }

  static UserRole _parseRole(String raw) {
    switch (raw.toLowerCase()) {
      case 'doctor':
        return UserRole.doctor;
      case 'admin':
      case 'healthcenteradmin':
        return UserRole.admin;
      case 'superadmin':
        return UserRole.superAdmin;
      default:
        return UserRole.doctor;
    }
  }
}

class DoctorUserModel extends DoctorUser {
  const DoctorUserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.badgeNumber,
    super.specialization,
    super.avatarUrl,
  });

  factory DoctorUserModel.fromJson(Map<String, dynamic> json) =>
      DoctorUserModel(
        id: json['sub'] as String? ?? json['id'] as String? ?? '',
        fullName: json['full_name'] as String? ??
            json['fullName'] as String? ??
            'Doctor',
        email: json['email'] as String? ?? '',
        badgeNumber:
            json['badgeNumber'] as String? ?? json['badge_number'] as String? ?? '',
        specialization: json['specialization'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
      );
}

class AdminUserModel extends AdminUser {
  const AdminUserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.centerId,
    required super.centerName,
    super.avatarUrl,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) => AdminUserModel(
        id: json['sub'] as String? ?? json['id'] as String? ?? '',
        fullName: json['full_name'] as String? ??
            json['fullName'] as String? ??
            'Admin',
        email: json['email'] as String? ?? '',
        centerId: json['center_id'] as String? ??
            json['centerId'] as String? ??
            '',
        centerName: json['centerName'] as String? ??
            json['center_name'] as String? ??
            '',
        avatarUrl: json['avatarUrl'] as String?,
      );
}

class SuperAdminUserModel extends SuperAdminUser {
  const SuperAdminUserModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.avatarUrl,
  });

  factory SuperAdminUserModel.fromJson(Map<String, dynamic> json) =>
      SuperAdminUserModel(
        id: json['sub'] as String? ?? json['id'] as String? ?? '',
        fullName: json['full_name'] as String? ??
            json['fullName'] as String? ??
            'SuperAdmin',
        email: json['email'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String?,
      );
}
