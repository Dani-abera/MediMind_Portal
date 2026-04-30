import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository _repo;
  const ChangePasswordUseCase(this._repo);

  Future<Either<Failure, void>> call({
    required String currentPassword,
    required String newPassword,
  }) =>
      _repo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
}
