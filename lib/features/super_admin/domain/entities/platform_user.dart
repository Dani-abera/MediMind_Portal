import 'package:equatable/equatable.dart';

class PlatformUser extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String userType;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String status;

  const PlatformUser({
    this.id = '',
    this.fullName = '',
    this.email = '',
    this.phone,
    this.avatarUrl,
    this.userType = 'patient',
    required this.createdAt,
    this.lastLoginAt,
    this.status = 'active',
  });

  @override
  List<Object?> get props => [
        id, fullName, email, phone, avatarUrl, userType, createdAt, lastLoginAt, status,
      ];
}
