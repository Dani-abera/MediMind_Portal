import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/platform_users_repository.dart';

class ReactivateUserUseCase {
  final PlatformUsersRepository _repo;
  ReactivateUserUseCase(this._repo);

  Future<Either<Failure, void>> call(String userId) =>
      _repo.reactivateUser(userId);
}
