import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/platform_users_repository.dart';

class ForceLogoutUserUseCase {
  final PlatformUsersRepository _repo;
  ForceLogoutUserUseCase(this._repo);

  Future<Either<Failure, void>> call(String userId) =>
      _repo.forceLogoutUser(userId);
}
