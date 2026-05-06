import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/platform_users_repository.dart';

class SuspendUserUseCase {
  final PlatformUsersRepository _repo;
  SuspendUserUseCase(this._repo);

  Future<Either<Failure, void>> call(String userId, {required String reason, DateTime? suspendUntil}) =>
      _repo.suspendUser(userId, reason: reason, suspendUntil: suspendUntil);
}
