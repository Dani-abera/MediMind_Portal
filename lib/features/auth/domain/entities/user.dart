import 'package:equatable/equatable.dart';

enum UserRole { doctor, admin, superAdmin }

class User extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, fullName, email, role, avatarUrl];
}
