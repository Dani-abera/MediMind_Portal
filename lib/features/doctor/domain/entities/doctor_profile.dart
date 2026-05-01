import 'package:equatable/equatable.dart';
import 'center_affiliation.dart';

class DoctorProfile extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String badgeNumber;
  final String? specialization;
  final String? bio;
  final List<String> qualifications;
  final List<String> languages;
  final String? avatarUrl;
  final bool licenseVerified;
  final List<CenterAffiliation> centers;

  const DoctorProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.badgeNumber,
    this.specialization,
    this.bio,
    this.qualifications = const [],
    this.languages = const [],
    this.avatarUrl,
    this.licenseVerified = false,
    this.centers = const [],
  });

  @override
  List<Object?> get props => [
        id, fullName, email, badgeNumber, specialization, bio,
        qualifications, languages, avatarUrl, licenseVerified, centers,
      ];
}
