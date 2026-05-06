import '../../domain/entities/center_branding.dart';

class CenterBrandingModel extends CenterBranding {
  const CenterBrandingModel({
    super.centerId,
    super.logoUrl,
    super.coverUrl,
    super.description,
  });

  factory CenterBrandingModel.fromJson(Map<String, dynamic> j) => CenterBrandingModel(
        centerId: j['centerId'] as String? ?? '',
        logoUrl: j['logoUrl'] as String?,
        coverUrl: j['coverUrl'] as String?,
        description: j['description'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'centerId': centerId,
        'logoUrl': logoUrl,
        'coverUrl': coverUrl,
        'description': description,
      };
}
