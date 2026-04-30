import 'package:equatable/equatable.dart';

abstract class SuperAdminLoginEvent extends Equatable {
  const SuperAdminLoginEvent();
  @override
  List<Object?> get props => [];
}

class SuperAdminLoginSubmitted extends SuperAdminLoginEvent {
  final String email;
  final String password;
  const SuperAdminLoginSubmitted({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class SuperAdmin2faSubmitted extends SuperAdminLoginEvent {
  final String email;
  final String totpCode;
  const SuperAdmin2faSubmitted({required this.email, required this.totpCode});
  @override
  List<Object?> get props => [email, totpCode];
}

class SuperAdminLoginReset extends SuperAdminLoginEvent {
  const SuperAdminLoginReset();
}
