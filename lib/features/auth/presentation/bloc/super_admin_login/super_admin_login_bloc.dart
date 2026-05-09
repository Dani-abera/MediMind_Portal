import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/super_admin_login_usecase.dart';
import '../../../domain/usecases/super_admin_verify_2fa_usecase.dart';
import 'super_admin_login_event.dart';
import 'super_admin_login_state.dart';

class SuperAdminLoginBloc
    extends Bloc<SuperAdminLoginEvent, SuperAdminLoginState> {
  final SuperAdminLoginUseCase _login;
  final SuperAdminVerify2faUseCase _verify2fa;

  SuperAdminLoginBloc({
    required SuperAdminLoginUseCase login,
    required SuperAdminVerify2faUseCase verify2fa,
  })  : _login = login,
        _verify2fa = verify2fa,
        super(const SuperAdminLoginInitial()) {
    on<SuperAdminLoginSubmitted>(_onLogin);
    on<SuperAdmin2faSubmitted>(_on2fa);
    on<SuperAdminLoginReset>((_, emit) => emit(const SuperAdminLoginInitial()));
  }

  Future<void> _onLogin(
    SuperAdminLoginSubmitted event,
    Emitter<SuperAdminLoginState> emit,
  ) async {
    emit(const SuperAdminLoginLoading());
    final result =
        await _login(email: event.email, password: event.password);
    result.fold(
      (failure) => emit(SuperAdminLoginError(failure.message)),
      (data) {
        if (data.requires2fa) {
          emit(SuperAdminLoginRequires2fa(event.email));
        } else {
          emit(SuperAdminLoginSuccess(user: data.user, tokens: data.tokens));
        }
      },
    );
  }

  Future<void> _on2fa(
    SuperAdmin2faSubmitted event,
    Emitter<SuperAdminLoginState> emit,
  ) async {
    emit(const SuperAdminLoginLoading());
    final result =
        await _verify2fa(email: event.email, totpCode: event.totpCode);
    result.fold(
      (failure) => emit(SuperAdminLoginError(failure.message)),
      (data) => emit(SuperAdminLoginSuccess(user: data.user, tokens: data.tokens)),
    );
  }
}
