import 'package:equatable/equatable.dart';

abstract class DoctorLoginEvent extends Equatable {
  const DoctorLoginEvent();
  @override
  List<Object?> get props => [];
}

class DoctorRequestOtp extends DoctorLoginEvent {
  final String badgeNumber;
  const DoctorRequestOtp(this.badgeNumber);
  @override
  List<Object?> get props => [badgeNumber];
}

class DoctorVerifyOtp extends DoctorLoginEvent {
  final String badgeNumber;
  final String otpCode;
  const DoctorVerifyOtp({required this.badgeNumber, required this.otpCode});
  @override
  List<Object?> get props => [badgeNumber, otpCode];
}

class DoctorOtpResendRequested extends DoctorLoginEvent {
  final String badgeNumber;
  const DoctorOtpResendRequested(this.badgeNumber);
  @override
  List<Object?> get props => [badgeNumber];
}

class DoctorLoginReset extends DoctorLoginEvent {
  const DoctorLoginReset();
}
