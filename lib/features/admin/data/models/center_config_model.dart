import '../../domain/entities/center_config.dart';

class CenterConfigModel extends CenterConfig {
  const CenterConfigModel({
    super.id,
    super.centerId,
    super.name,
    super.phone,
    super.email,
    super.city,
    super.region,
    super.fullAddress,
    super.licenseNumber,
    super.latitude,
    super.longitude,
    super.specializations,
    super.services,
  });

  factory CenterConfigModel.fromJson(Map<String, dynamic> j) => CenterConfigModel(
        id: (j['id'] ?? j['centerId']) as String? ?? '',
        centerId: (j['centerId'] ?? j['id']) as String? ?? '',
        name: (j['name'] ?? j['centerName']) as String? ?? '',
        phone: (j['phone'] ?? j['phoneNumber']) as String? ?? '',
        email: j['email'] as String? ?? '',
        city: j['city'] as String? ?? '',
        region: j['region'] as String? ?? '',
        fullAddress: (j['fullAddress'] ?? j['address']) as String? ?? '',
        licenseNumber: j['licenseNumber'] as String? ?? '',
        latitude: (j['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (j['longitude'] as num?)?.toDouble() ?? 0,
        specializations: (j['specializations'] as List? ?? []).cast<String>(),
        services: ((j['services'] ?? j['servicesOffered']) as List? ?? []).cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'centerId': centerId,
        'name': name,
        'phone': phone,
        'email': email,
        'city': city,
        'region': region,
        'fullAddress': fullAddress,
        'licenseNumber': licenseNumber,
        'latitude': latitude,
        'longitude': longitude,
        'specializations': specializations,
        'services': services,
      };
}
