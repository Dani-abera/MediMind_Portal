import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_tokens.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SuperAdminLoginUseCase {
  final AuthRepository _repo;
  const SuperAdminLoginUseCase(this._repo);

  Future<Either<Failure, ({User user, AuthTokens tokens, bool requires2fa})>>
      call({required String email, required String password}) =>
          _repo.superAdminLogin(email: email, password: password);
}
