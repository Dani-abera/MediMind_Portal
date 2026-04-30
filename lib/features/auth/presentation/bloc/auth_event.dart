import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthAppStarted extends AuthEvent {
  const AuthAppStarted();
}

class AuthUserLoggedIn extends AuthEvent {
  final User user;
  final AuthTokens tokens;
  const AuthUserLoggedIn({required this.user, required this.tokens});
  @override
  List<Object?> get props => [user, tokens];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthTokenExpired extends AuthEvent {
  const AuthTokenExpired();
}
