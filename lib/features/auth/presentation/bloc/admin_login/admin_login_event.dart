import 'package:equatable/equatable.dart';

abstract class AdminLoginEvent extends Equatable {
  const AdminLoginEvent();
  @override
  List<Object?> get props => [];
}

class AdminLoginSubmitted extends AdminLoginEvent {
  final String email;
  final String password;
  const AdminLoginSubmitted({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AdminOtpSubmitted extends AdminLoginEvent {
  final String email;
  final String otpCode;
  const AdminOtpSubmitted({required this.email, required this.otpCode});
  @override
  List<Object?> get props => [email, otpCode];
}

class AdminLoginReset extends AdminLoginEvent {
  const AdminLoginReset();
}
