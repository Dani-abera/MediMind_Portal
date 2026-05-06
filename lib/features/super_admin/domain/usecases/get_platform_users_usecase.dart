import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_user.dart';
import '../repositories/platform_users_repository.dart';

class GetPlatformUsersUseCase {
  final PlatformUsersRepository _repo;
  GetPlatformUsersUseCase(this._repo);

  Future<Either<Failure, ({List<PlatformUser> users, int total})>> call({
    String? userType,
    String? status,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  }) =>
      _repo.getUsers(userType: userType, status: status, from: from, to: to, page: page, pageSize: pageSize);
}
