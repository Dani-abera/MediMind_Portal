import '../../domain/entities/platform_user.dart';

class PlatformUserModel extends PlatformUser {
  const PlatformUserModel({
    super.id,
    super.fullName,
    super.email,
    super.phone,
    super.avatarUrl,
    super.userType,
    required super.createdAt,
    super.lastLoginAt,
    super.status,
  });

  factory PlatformUserModel.fromJson(Map<String, dynamic> j) => PlatformUserModel(
        id: j['id'] as String? ?? '',
        fullName: j['fullName'] as String? ?? '',
        email: j['email'] as String? ?? '',
        phone: j['phone'] as String?,
        avatarUrl: j['avatarUrl'] as String?,
        userType: j['userType'] as String? ?? 'patient',
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
        lastLoginAt: j['lastLoginAt'] != null
            ? DateTime.tryParse(j['lastLoginAt'] as String)
            : null,
        status: j['status'] as String? ?? 'active',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'userType': userType,
        'createdAt': createdAt.toIso8601String(),
        'lastLoginAt': lastLoginAt?.toIso8601String(),
        'status': status,
      };
}
