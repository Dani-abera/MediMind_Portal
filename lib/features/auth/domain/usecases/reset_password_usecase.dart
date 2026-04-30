import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _repo;
  const ResetPasswordUseCase(this._repo);

  Future<Either<Failure, void>> call({
    required String token,
    required String newPassword,
  }) =>
      _repo.resetPassword(token: token, newPassword: newPassword);
}
