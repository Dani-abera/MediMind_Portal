import 'package:equatable/equatable.dart';
import '../../../domain/entities/auth_tokens.dart';
import '../../../domain/entities/user.dart';

abstract class AdminLoginState extends Equatable {
  const AdminLoginState();
  @override
  List<Object?> get props => [];
}

class AdminLoginInitial extends AdminLoginState {
  const AdminLoginInitial();
}

class AdminLoginLoading extends AdminLoginState {
  const AdminLoginLoading();
}

class AdminLoginRequires2fa extends AdminLoginState {
  final String email;
  const AdminLoginRequires2fa(this.email);
  @override
  List<Object?> get props => [email];
}

class AdminLoginSuccess extends AdminLoginState {
  final User user;
  final AuthTokens tokens;
  const AdminLoginSuccess({required this.user, required this.tokens});
  @override
  List<Object?> get props => [user, tokens];
}

class AdminLoginError extends AdminLoginState {
  final String message;
  const AdminLoginError(this.message);
  @override
  List<Object?> get props => [message];
}
