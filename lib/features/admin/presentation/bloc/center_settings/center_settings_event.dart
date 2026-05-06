part of 'center_settings_bloc.dart';

abstract class CenterSettingsEvent extends Equatable {
  const CenterSettingsEvent();
  @override
  List<Object?> get props => [];
}

class CenterSettingsStarted extends CenterSettingsEvent {
  final String centerId;
  const CenterSettingsStarted(this.centerId);
  @override
  List<Object?> get props => [centerId];
}

class CenterSettingsFieldChanged extends CenterSettingsEvent {
  final String? name;
  final String? phone;
  final String? email;
  final String? city;
  final String? region;
  final String? fullAddress;
  final double? latitude;
  final double? longitude;
  final List<String>? specializations;
  final List<String>? services;

  const CenterSettingsFieldChanged({
    this.name,
    this.phone,
    this.email,
    this.city,
    this.region,
    this.fullAddress,
    this.latitude,
    this.longitude,
    this.specializations,
    this.services,
  });

  @override
  List<Object?> get props => [name, phone, email, city, region, fullAddress, latitude, longitude, specializations, services];
}

class CenterSettingsSubmitted extends CenterSettingsEvent {
  const CenterSettingsSubmitted();
}
