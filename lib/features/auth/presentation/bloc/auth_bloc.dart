import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckAuthStatusUseCase _checkAuth;
  final LogoutUseCase _logout;

  AuthBloc({
    required CheckAuthStatusUseCase checkAuth,
    required LogoutUseCase logout,
  })  : _checkAuth = checkAuth,
        _logout = logout,
        super(const AuthInitial()) {
    on<AuthAppStarted>(_onAppStarted);
    on<AuthUserLoggedIn>(_onUserLoggedIn);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthTokenExpired>(_onTokenExpired);
  }

  Future<void> _onAppStarted(
    AuthAppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _checkAuth();
    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  void _onUserLoggedIn(AuthUserLoggedIn event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(event.user));
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logout();
    emit(const AuthUnauthenticated());
  }

  void _onTokenExpired(AuthTokenExpired event, Emitter<AuthState> emit) {
    emit(const AuthUnauthenticated());
  }
}
