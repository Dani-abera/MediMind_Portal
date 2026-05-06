import '../../domain/entities/platform_doctor.dart';

class PlatformDoctorModel extends PlatformDoctor {
  const PlatformDoctorModel({
    super.id,
    super.fullName,
    super.photoUrl,
    super.licenseNumber,
    super.specialization,
    super.licenseVerified,
    super.licenseVerifiedAt,
    super.affiliatedCentersCount,
    super.status,
    required super.createdAt,
  });

  factory PlatformDoctorModel.fromJson(Map<String, dynamic> j) => PlatformDoctorModel(
        id: j['id'] as String? ?? '',
        fullName: j['fullName'] as String? ?? '',
        photoUrl: j['photoUrl'] as String?,
        licenseNumber: j['licenseNumber'] as String? ?? '',
        specialization: j['specialization'] as String? ?? '',
        licenseVerified: j['licenseVerified'] as bool? ?? false,
        licenseVerifiedAt: j['licenseVerifiedAt'] != null
            ? DateTime.tryParse(j['licenseVerifiedAt'] as String)
            : null,
        affiliatedCentersCount: j['affiliatedCentersCount'] as int? ?? 0,
        status: j['status'] as String? ?? 'active',
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'photoUrl': photoUrl,
        'licenseNumber': licenseNumber,
        'specialization': specialization,
        'licenseVerified': licenseVerified,
        'licenseVerifiedAt': licenseVerifiedAt?.toIso8601String(),
        'affiliatedCentersCount': affiliatedCentersCount,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };
}
