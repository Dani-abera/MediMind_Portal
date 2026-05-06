import 'package:equatable/equatable.dart';

class PlatformDoctor extends Equatable {
  final String id;
  final String fullName;
  final String? photoUrl;
  final String licenseNumber;
  final String specialization;
  final bool licenseVerified;
  final DateTime? licenseVerifiedAt;
  final int affiliatedCentersCount;
  final String status;
  final DateTime createdAt;

  const PlatformDoctor({
    this.id = '',
    this.fullName = '',
    this.photoUrl,
    this.licenseNumber = '',
    this.specialization = '',
    this.licenseVerified = false,
    this.licenseVerifiedAt,
    this.affiliatedCentersCount = 0,
    this.status = 'active',
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, fullName, photoUrl, licenseNumber, specialization, licenseVerified,
        licenseVerifiedAt, affiliatedCentersCount, status, createdAt,
      ];
}
