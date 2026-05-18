import '../../domain/entities/center_affiliation.dart';

class CenterAffiliationModel extends CenterAffiliation {
  const CenterAffiliationModel({
    required super.centerId,
    required super.centerName,
    super.centerAddress,
    required super.consultationFee,
    required super.joinedAt,
    super.isActive,
  });

  factory CenterAffiliationModel.fromJson(Map<String, dynamic> json) =>
      CenterAffiliationModel(
        centerId: json['centerId'] as String,
        centerName: json['centerName'] as String,
        centerAddress: json['centerAddress'] as String?,
        consultationFee: (json['consultationFee'] as num).toDouble(),
        joinedAt: DateTime.parse((json['joinedDate'] ?? json['joinedAt']) as String),
        isActive: json['isActive'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'centerId': centerId,
        'centerName': centerName,
        if (centerAddress != null) 'centerAddress': centerAddress,
        'consultationFee': consultationFee,
        'joinedAt': joinedAt.toIso8601String(),
        'isActive': isActive,
      };
}
