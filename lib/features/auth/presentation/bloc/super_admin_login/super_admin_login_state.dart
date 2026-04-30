import 'package:equatable/equatable.dart';
import '../../../domain/entities/auth_tokens.dart';
import '../../../domain/entities/user.dart';

abstract class SuperAdminLoginState extends Equatable {
  const SuperAdminLoginState();
  @override
  List<Object?> get props => [];
}

class SuperAdminLoginInitial extends SuperAdminLoginState {
  const SuperAdminLoginInitial();
}

class SuperAdminLoginLoading extends SuperAdminLoginState {
  const SuperAdminLoginLoading();
}

class SuperAdminLoginRequires2fa extends SuperAdminLoginState {
  final String email;
  const SuperAdminLoginRequires2fa(this.email);
  @override
  List<Object?> get props => [email];
}

class SuperAdminLoginSuccess extends SuperAdminLoginState {
  final User user;
  final AuthTokens tokens;
  const SuperAdminLoginSuccess({required this.user, required this.tokens});
  @override
  List<Object?> get props => [user, tokens];
}

class SuperAdminLoginError extends SuperAdminLoginState {
  final String message;
  const SuperAdminLoginError(this.message);
  @override
  List<Object?> get props => [message];
}
