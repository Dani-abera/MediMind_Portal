import 'package:equatable/equatable.dart';

class SuperAdminProfile extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String gender;
  final String dateOfBirth;
  final String? profileImageUrl;
  final String? lastLogin;
  final bool isVerified;
  final String createdAt;

  const SuperAdminProfile({
    this.id = '',
    this.fullName = '',
    this.email = '',
    this.phoneNumber = '',
    this.gender = 'Male',
    this.dateOfBirth = '',
    this.profileImageUrl,
    this.lastLogin,
    this.isVerified = false,
    this.createdAt = '',
  });

  SuperAdminProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? gender,
    String? dateOfBirth,
    String? profileImageUrl,
    String? lastLogin,
    bool? isVerified,
    String? createdAt,
  }) =>
      SuperAdminProfile(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        gender: gender ?? this.gender,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        lastLogin: lastLogin ?? this.lastLogin,
        isVerified: isVerified ?? this.isVerified,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [
        id, fullName, email, phoneNumber, gender,
        dateOfBirth, profileImageUrl, lastLogin, isVerified, createdAt,
      ];
}
