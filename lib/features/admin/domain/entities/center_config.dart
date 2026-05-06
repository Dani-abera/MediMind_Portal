import 'package:equatable/equatable.dart';

class CenterConfig extends Equatable {
  final String id;
  final String centerId;
  final String name;
  final String phone;
  final String email;
  final String city;
  final String region;
  final String fullAddress;
  final String licenseNumber;
  final double latitude;
  final double longitude;
  final List<String> specializations;
  final List<String> services;

  const CenterConfig({
    this.id = '',
    this.centerId = '',
    this.name = '',
    this.phone = '',
    this.email = '',
    this.city = '',
    this.region = '',
    this.fullAddress = '',
    this.licenseNumber = '',
    this.latitude = 0,
    this.longitude = 0,
    this.specializations = const [],
    this.services = const [],
  });

  CenterConfig copyWith({
    String? id,
    String? centerId,
    String? name,
    String? phone,
    String? email,
    String? city,
    String? region,
    String? fullAddress,
    String? licenseNumber,
    double? latitude,
    double? longitude,
    List<String>? specializations,
    List<String>? services,
  }) =>
      CenterConfig(
        id: id ?? this.id,
        centerId: centerId ?? this.centerId,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        city: city ?? this.city,
        region: region ?? this.region,
        fullAddress: fullAddress ?? this.fullAddress,
        licenseNumber: licenseNumber ?? this.licenseNumber,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        specializations: specializations ?? this.specializations,
        services: services ?? this.services,
      );

  @override
  List<Object?> get props => [
        id,
        centerId,
        name,
        phone,
        email,
        city,
        region,
        fullAddress,
        licenseNumber,
        latitude,
        longitude,
        specializations,
        services,
      ];
}
