import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/doctor_request_otp_usecase.dart';
import '../../../domain/usecases/doctor_verify_otp_usecase.dart';
import 'doctor_login_event.dart';
import 'doctor_login_state.dart';

class DoctorLoginBloc extends Bloc<DoctorLoginEvent, DoctorLoginState> {
  final DoctorRequestOtpUseCase _requestOtp;
  final DoctorVerifyOtpUseCase _verifyOtp;

  DoctorLoginBloc({
    required DoctorRequestOtpUseCase requestOtp,
    required DoctorVerifyOtpUseCase verifyOtp,
  })  : _requestOtp = requestOtp,
        _verifyOtp = verifyOtp,
        super(const DoctorLoginInitial()) {
    on<DoctorRequestOtp>(_onRequestOtp);
    on<DoctorVerifyOtp>(_onVerifyOtp);
    on<DoctorOtpResendRequested>(_onResend);
    on<DoctorLoginReset>((_, emit) => emit(const DoctorLoginInitial()));
  }

  Future<void> _onRequestOtp(
    DoctorRequestOtp event,
    Emitter<DoctorLoginState> emit,
  ) async {
    emit(const DoctorLoginRequestingOtp());
    final result = await _requestOtp(event.badgeNumber);
    result.fold(
      (failure) => emit(DoctorLoginError(failure.message)),
      (_) => emit(DoctorLoginOtpSent(event.badgeNumber)),
    );
  }

  Future<void> _onVerifyOtp(
    DoctorVerifyOtp event,
    Emitter<DoctorLoginState> emit,
  ) async {
    emit(const DoctorLoginVerifyingOtp());
    final result = await _verifyOtp(
      badgeNumber: event.badgeNumber,
      otpCode: event.otpCode,
    );
    result.fold(
      (failure) => emit(DoctorLoginError(failure.message)),
      (data) => emit(DoctorLoginSuccess(user: data.user, tokens: data.tokens)),
    );
  }

  Future<void> _onResend(
    DoctorOtpResendRequested event,
    Emitter<DoctorLoginState> emit,
  ) async {
    emit(const DoctorLoginRequestingOtp());
    final result = await _requestOtp(event.badgeNumber);
    result.fold(
      (failure) => emit(DoctorLoginError(failure.message)),
      (_) => emit(DoctorLoginOtpSent(event.badgeNumber)),
    );
  }
}
