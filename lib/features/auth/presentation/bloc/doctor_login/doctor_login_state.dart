import 'package:equatable/equatable.dart';
import '../../../domain/entities/auth_tokens.dart';
import '../../../domain/entities/user.dart';

abstract class DoctorLoginState extends Equatable {
  const DoctorLoginState();
  @override
  List<Object?> get props => [];
}

class DoctorLoginInitial extends DoctorLoginState {
  const DoctorLoginInitial();
}

class DoctorLoginRequestingOtp extends DoctorLoginState {
  const DoctorLoginRequestingOtp();
}

class DoctorLoginOtpSent extends DoctorLoginState {
  final String badgeNumber;
  const DoctorLoginOtpSent(this.badgeNumber);
  @override
  List<Object?> get props => [badgeNumber];
}

class DoctorLoginVerifyingOtp extends DoctorLoginState {
  const DoctorLoginVerifyingOtp();
}

class DoctorLoginSuccess extends DoctorLoginState {
  final User user;
  final AuthTokens tokens;
  const DoctorLoginSuccess({required this.user, required this.tokens});
  @override
  List<Object?> get props => [user, tokens];
}

class DoctorLoginError extends DoctorLoginState {
  final String message;
  const DoctorLoginError(this.message);
  @override
  List<Object?> get props => [message];
}
