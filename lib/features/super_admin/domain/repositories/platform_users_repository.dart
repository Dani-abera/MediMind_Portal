import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_user.dart';

abstract class PlatformUsersRepository {
  Future<Either<Failure, ({List<PlatformUser> users, int total})>> getUsers({
    String? userType,
    String? status,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  });
  Future<Either<Failure, void>> suspendUser(String userId, {required String reason, DateTime? suspendUntil});
  Future<Either<Failure, void>> reactivateUser(String userId);
  Future<Either<Failure, void>> forceLogoutUser(String userId);
  Future<Either<Failure, void>> deleteUser(String userId);
}
