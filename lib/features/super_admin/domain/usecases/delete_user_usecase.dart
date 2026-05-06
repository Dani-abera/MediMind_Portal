import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/platform_users_repository.dart';

class DeleteUserUseCase {
  final PlatformUsersRepository _repo;
  DeleteUserUseCase(this._repo);

  Future<Either<Failure, void>> call(String userId) =>
      _repo.deleteUser(userId);
}
