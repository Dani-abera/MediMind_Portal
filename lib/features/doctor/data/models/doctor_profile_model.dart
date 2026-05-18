import '../../domain/entities/doctor_profile.dart';
import 'center_affiliation_model.dart';

class DoctorProfileModel extends DoctorProfile {
  const DoctorProfileModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.badgeNumber,
    super.specialization,
    super.bio,
    super.qualifications,
    super.languages,
    super.avatarUrl,
    super.licenseVerified,
    super.centers,
  });

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) => DoctorProfileModel(
        id: (json['doctorId'] ?? json['id']).toString(),
        fullName: json['fullName'] as String,
        email: json['email'] as String? ?? '',
        badgeNumber: json['badgeNumber'] as String? ?? '',
        specialization: json['specialization'] as String?,
        bio: json['biography'] as String?,
        qualifications: (json['qualifications'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        languages: (json['languagesSpoken'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        avatarUrl: json['profileImageUrl'] as String?,
        licenseVerified: json['licenseVerified'] as bool? ?? false,
        centers: (json['affiliatedCenters'] as List<dynamic>? ?? [])
            .map((e) => CenterAffiliationModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'badgeNumber': badgeNumber,
        if (specialization != null) 'specialization': specialization,
        if (bio != null) 'bio': bio,
        'qualifications': qualifications,
        'languages': languages,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        'licenseVerified': licenseVerified,
        'centers': centers
            .map((c) => CenterAffiliationModel(
                  centerId: c.centerId,
                  centerName: c.centerName,
                  centerAddress: c.centerAddress,
                  consultationFee: c.consultationFee,
                  joinedAt: c.joinedAt,
                  isActive: c.isActive,
                ).toJson())
            .toList(),
      };
}
