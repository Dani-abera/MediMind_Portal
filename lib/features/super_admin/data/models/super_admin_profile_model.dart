import '../../domain/entities/super_admin_profile.dart';

class SuperAdminProfileModel extends SuperAdminProfile {
  const SuperAdminProfileModel({
    super.id,
    super.fullName,
    super.email,
    super.phoneNumber,
    super.gender,
    super.dateOfBirth,
    super.profileImageUrl,
    super.lastLogin,
    super.isVerified,
    super.createdAt,
  });

  factory SuperAdminProfileModel.fromJson(Map<String, dynamic> j) =>
      SuperAdminProfileModel(
        id: j['id'] as String? ?? '',
        fullName: j['fullName'] as String? ?? '',
        email: j['email'] as String? ?? '',
        phoneNumber: j['phoneNumber'] as String? ?? '',
        gender: j['gender'] as String? ?? 'Male',
        dateOfBirth: j['dateOfBirth'] as String? ?? '',
        profileImageUrl: j['profileImageUrl'] as String?,
        lastLogin: j['lastLogin'] as String?,
        isVerified: j['isVerified'] as bool? ?? false,
        createdAt: j['createdAt'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
      };
}
