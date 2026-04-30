import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/admin_login_usecase.dart';
import '../../../domain/usecases/admin_verify_otp_usecase.dart';
import 'admin_login_event.dart';
import 'admin_login_state.dart';

class AdminLoginBloc extends Bloc<AdminLoginEvent, AdminLoginState> {
  final AdminLoginUseCase _login;
  final AdminVerifyOtpUseCase _verifyOtp;

  AdminLoginBloc({
    required AdminLoginUseCase login,
    required AdminVerifyOtpUseCase verifyOtp,
  })  : _login = login,
        _verifyOtp = verifyOtp,
        super(const AdminLoginInitial()) {
    on<AdminLoginSubmitted>(_onLogin);
    on<AdminOtpSubmitted>(_onVerifyOtp);
    on<AdminLoginReset>((_, emit) => emit(const AdminLoginInitial()));
  }

  Future<void> _onLogin(
    AdminLoginSubmitted event,
    Emitter<AdminLoginState> emit,
  ) async {
    emit(const AdminLoginLoading());
    final result =
        await _login(email: event.email, password: event.password);
    result.fold(
      (failure) => emit(AdminLoginError(failure.message)),
      (data) {
        if (data.requires2fa) {
          emit(AdminLoginRequires2fa(event.email));
        } else {
          emit(AdminLoginSuccess(user: data.user, tokens: data.tokens));
        }
      },
    );
  }

  Future<void> _onVerifyOtp(
    AdminOtpSubmitted event,
    Emitter<AdminLoginState> emit,
  ) async {
    emit(const AdminLoginLoading());
    final result =
        await _verifyOtp(email: event.email, otpCode: event.otpCode);
    result.fold(
      (failure) => emit(AdminLoginError(failure.message)),
      (data) => emit(AdminLoginSuccess(user: data.user, tokens: data.tokens)),
    );
  }
}
