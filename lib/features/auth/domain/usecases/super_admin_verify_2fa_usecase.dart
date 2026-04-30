import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_tokens.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SuperAdminVerify2faUseCase {
  final AuthRepository _repo;
  const SuperAdminVerify2faUseCase(this._repo);

  Future<Either<Failure, ({User user, AuthTokens tokens})>> call({
    required String email,
    required String totpCode,
  }) =>
      _repo.superAdminVerify2fa(email: email, totpCode: totpCode);
}
